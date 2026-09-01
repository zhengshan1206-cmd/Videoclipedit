import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/input/normal_input_view.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_page.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/widgets/ai_cartoon_prohibited_words_dailog.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_settings_mixin.dart';
import 'package:video_clip_edit/v2/slicing/controller/one_click_slicing_controller.dart';
import 'package:video_clip_edit/v2/slicing/single_list_page.dart';
import 'package:video_clip_edit/v2/slicing/widget/custom_tab_bar.dart';
import 'package:video_clip_edit/data/model/slicing/slicing_item_bean.dart';
import 'package:video_clip_edit/v2/slicing/controller/slicing_home_controller.dart';

import '../../flavors/build_config.dart';

class SlicingHomePage extends StatefulWidget {
  const SlicingHomePage({super.key});

  @override
  State<SlicingHomePage> createState() => _SlicingHomePageState();
}

class _SlicingHomePageState extends State<SlicingHomePage>
    with WidgetsBindingObserver {
  final RxInt _currentIndex = 0.obs;
  final SlicingHomeController homeController = Get.put(SlicingHomeController());
  final OneClickSlicingController slicingController =
      Get.find<OneClickSlicingController>();
  RxInt wordsCount = 0.obs;
  final ScrollController _promptScrollController = ScrollController();

  /// 上次布局尺寸；仅横竖屏/折叠尺寸变化时重建，忽略键盘引起的 metrics 变化
  Size? _lastLayoutSize;

  /// 跨旋转/重建保持焦点，避免首次点击无法拉起键盘
  final FocusNode _promptFocusNode = FocusNode();

  /// 用户主动展开编辑时才自动拉起键盘，避免重建输入框反复 requestFocus
  bool _editAutoFocus = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 添加键盘可见性监听
    KeyboardVisibilityController().onChange.listen((bool visible) {
      homeController.keyboardVisible.value = visible;
      if (visible) {
        // 延迟一帧获取键盘高度，确保viewInsets已更新
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final inset = MediaQuery.viewInsetsOf(context).bottom;
            // 只用真实 inset，避免假高度把编辑面板挤扁
            if (inset > 0) {
              homeController.keyboardHeight.value = inset;
            }
          }
        });
      } else {
        homeController.keyboardHeight.value = 0.0;
      }
    });
  }

  /// 收起编辑态并关闭键盘
  void _collapseEditing(BuildContext context) {
    _editAutoFocus = false;
    FocusManager.instance.primaryFocus?.unfocus();
    FocusScope.of(context).unfocus();
    slicingController.showAppBar.value = homeController.manualEditing.value;
    homeController.manualEditing.value = false;
  }

  /// 仅收起键盘，不退出编辑态
  void _dismissKeyboard() {
    _editAutoFocus = false;
    _promptFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// 展开编辑态（仅用户点击时自动聚焦）
  void _expandEditing() {
    _editAutoFocus = true;
    slicingController.showAppBar.value = homeController.manualEditing.value;
    homeController.manualEditing.value = true;
    wordsCount.value = homeController.currentPrompt.value.length;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && homeController.manualEditing.value) {
        _promptFocusNode.requestFocus();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lastLayoutSize ??= MediaQuery.sizeOf(context);
  }

  @override
  void didChangeMetrics() {
    // 键盘显隐也会触发 metrics；横屏下若每次都重建输入框会反复 requestFocus 关不掉键盘
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = MediaQuery.sizeOf(context);
      if (_lastLayoutSize == size) {
        return;
      }
      _lastLayoutSize = size;
      if (_promptScrollController.hasClients) {
        _promptScrollController.jumpTo(0);
      }
      // 旋转后若仍在编辑态，延迟恢复焦点（鸿蒙横竖屏切换需等待布局稳定）
      if (homeController.manualEditing.value) {
        Future.delayed(const Duration(milliseconds: 120), () {
          if (!mounted || !homeController.manualEditing.value) return;
          if (!_promptFocusNode.hasFocus && _editAutoFocus) {
            _promptFocusNode.requestFocus();
          }
        });
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _promptScrollController.dispose();
    _promptFocusNode.dispose();
    // homeController.dispose();
    // Get.delete<SlicingHomeController>();
    super.dispose();
  }

  ///继续的点击事件
  void goOnEvent() {
    if (homeController.isGenerating.value) {
      BotToast.showText(text: "内容生成中");
      return;
    }
    if (homeController.currentPrompt.value.isEmpty) {
      BotToast.showText(text: "请选择输入故事概要");
      return;
    }

    ///校验是否登录
    ByNavigatorUtil.checkLogin(
        context: context,
        nextStepEvent: () {
          final purchaseProvider = context.read<PurchaseProvider>();
          if (purchaseProvider.preLoginCheck(context) == false) return;
          _toOldFolkStoryPage();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final categoryBeans = homeController.categoryBeans;
      if (categoryBeans.isEmpty) {
        return Container();
      }
      return Stack(
        children: [
          CustomTabBar(
            tabBarHeight: 46.h,
            indicatorHeight: 3.0,
            indicatorWidth: 15.0,
            indicatorRadius: 2.0,
            isScrollable: true,
            tabBarColor: Colors.white,
            indicatorColor: Colors.transparent,
            tabPadding: EdgeInsets.zero,
            initialIndex: _currentIndex.value,
            onTabChanged: (index) {
              _currentIndex.value = index;
              homeController.refreshCurrentTabData(index);
            },
            tabs: _buildTabs(categoryBeans),
            pages: _buildPages(categoryBeans),
          ),
          if (homeController.manualEditing.value)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  // 键盘可见时仅收起键盘，避免误退出编辑态
                  if (homeController.keyboardVisible.value ||
                      (_promptFocusNode.hasFocus)) {
                    _dismissKeyboard();
                    return;
                  }
                  _collapseEditing(context);
                },
                child: Container(
                  color: const Color(0xff000000).withOpacity(0.5),
                ),
              ),
            ),
          // if (homeController.manualEditing.value)
          //   Positioned(
          //     left: 0,
          //     right: 0,
          //     top: 0,
          //     child: Image.asset(
          //       "assets/v2/slicing/appbar_bg.png",
          //       fit: BoxFit.fitWidth,
          //     ),
          //   ),
          Obx(() {
            final mq = MediaQuery.of(context);
            final viewSize = mq.size;
            // 订阅键盘 Rx，保证可见性变化时重建
            final keyboardVisible = homeController.keyboardVisible.value;
            final keyboardFromMq = mq.viewInsets.bottom;
            final rawKeyboard = keyboardFromMq > 0
                ? keyboardFromMq
                : (keyboardVisible ? homeController.keyboardHeight.value : 0.0);
            // 顶部安全距：多源取大；横屏鸿蒙状态栏常回报 0，用更高兜底
            final isLandscape = mq.orientation == Orientation.landscape;
            final topSafe = math.max(
              math.max(mq.viewPadding.top, mq.padding.top),
              math.max(
                ByScreenUtils.topSafeHeight,
                isLandscape ? 48.0 : 32.0,
              ),
            );
            final isEditing = homeController.manualEditing.value;
            final titleH = math.max(40.h, 40.0);
            const minInputH = 120.0;
            // 限制键盘 inset，避免面板高度被挤成只剩标题
            final maxKeyboard = math.max(
              0.0,
              viewSize.height - topSafe - titleH - 16 - minInputH,
            );
            final keyboardInset = math.min(rawKeyboard, maxKeyboard);

            if (isEditing) {
              // 从屏幕顶铺到键盘上方：顶部 SizedBox 预留状态栏，下方 Expanded 给输入框
              return Positioned(
                key: ValueKey('edit_panel_${viewSize.width.round()}'),
                top: 0,
                left: 0,
                right: 0,
                bottom: keyboardInset,
                child: Material(
                  color: Colors.white,
                  child: Column(
                    children: [
                      SizedBox(height: topSafe),
                      Padding(
                        padding: EdgeInsets.fromLTRB(12.w, 12, 12.w, 8),
                        child: SizedBox(
                          height: titleH,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ByWidgetsUtil.commonText(
                                text: "剧本内容：",
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                textColor: ByColorUtil.color0B1843,
                              ),
                              const Spacer(),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _collapseEditing(context),
                                child: Container(
                                  width: 40.w,
                                  height: titleH,
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    "assets/v2/slicing/icon_fold.png",
                                    width: 12.w,
                                    height: 12.w,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10),
                          child: _buildInputView(context,
                              slicingController: slicingController),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final panelH = homeController.bottomPanelHeight(context);
            return AnimatedPositioned(
              key: ValueKey('panel_${viewSize.width.round()}'),
              duration: const Duration(milliseconds: 200),
              bottom: 0,
              left: 0,
              right: 0,
              height: panelH,
              child: ByWidgetsUtil.physicalModel(
                color: Colors.white,
                child: Column(
                  children: [
                    SizedBox(height: 12.h),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: _buildInputView(context,
                            slicingController: slicingController),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      height: 44.h,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: ByWidgetsUtil.commonBtn(
                        title: "继续",
                        fontSize: 14.sp,
                        borderRadius: 12.w,
                        padding: EdgeInsets.zero,
                        textColor: Colors.white,
                        fontWeight: FontWeight.w600,
                        bgColor: ByColorUtil.LoginBtnBgColor,
                        onClick: () {
                          goOnEvent();
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.h),
                      child: ByWidgetsUtil.commonText(
                        text: "禁止利用功能从事任何违法活动",
                        fontSize: 10.sp,
                        textColor: ByColorUtil.color0B1843.withOpacity(0.3),
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            );
          }),
        ],
      );
    });
  }

  _toOldFolkStoryPage() {
    // 添加违禁词检测
    final provider = AiCartoonProvider();
    provider.desc = homeController.currentPrompt.value; // 设置当前内容
    provider.detect(
      context,
      homeController.currentPrompt.value,
      onSuccess: () {
        if (provider.bandedWords.isNotEmpty) {
          BotToast.showText(text: "当前存在违禁词");
          showDialog(
            context: context,
            useSafeArea: false,
            barrierDismissible: true,
            builder: (ctx) => ChangeNotifierProvider.value(
              value: provider,
              child: const AiCartoonProhibitedWordsDailog<AiCartoonProvider>(),
            ),
          ).then((value) {
            // print("value: $value");
            if (value != null && value is Map) {
              final String newValue = value['desc'] as String;
              homeController.currentPrompt.value = newValue; // 同步修改后的值
              wordsCount.value = newValue.length; // 同步更新字数
            }
          });
        } else {
          if (Platform.isAndroid) {
            Get.to(
              ChangeNotifierProvider(
                create: (context) {
                  final provider = AiCartoonProvider();
                  provider.slicingLoading = true;
                  provider.entranceSource = EntranceSource.normal;
                  provider.desc = homeController.currentPrompt.value;
                  return provider;
                },
                child: const AiCartoonPage(
                  fromPrompt: true,
                  title: "文字成片",
                  source: EntranceSource.normal,
                  fromSlicingHomePage: true,
                ),
              ),
            );
          } else {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => ChangeNotifierProvider(
                  create: (context) {
                    final provider = AiCartoonProvider();
                    provider.slicingLoading = true;
                    provider.entranceSource = EntranceSource.normal;
                    provider.desc = homeController.currentPrompt.value;
                    return provider;
                  },
                  child: const AiCartoonPage(
                    fromPrompt: true,
                    title: "文字成片",
                    source: EntranceSource.normal,
                    fromSlicingHomePage: true,
                  ),
                ),
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildInputView(BuildContext context,
      {required OneClickSlicingController slicingController}) {
    return ByWidgetsUtil.commonContainer(
      margin: EdgeInsets.zero,
      borerRadius: 10.w,
      bgColor: const Color(0xFFF4F8F9),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      border: Border.all(
        color: const Color(0xFF5B4BF7),
        width: 1.w,
      ),
      child: homeController.manualEditing.value
          ? GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (!_promptFocusNode.hasFocus) {
                  _editAutoFocus = true;
                  _promptFocusNode.requestFocus();
                }
              },
              child: NormalInputView(
                maxWords: 2000,
                placeholder: "您可点击上面的推荐灵感或自行输入故事概要也可以\n在此直接输入完整的故事、剧本、小说",
                initialValue: homeController.currentPrompt.value,
                externalFocusNode: _promptFocusNode,
                focusNode: _editAutoFocus,
                onChanged: (val) {
                  wordsCount.value = val.length;
                  homeController.currentPrompt.value = val;
                },
                onFinished: (val) {
                  homeController.currentPrompt.value = val;
                },
                scrollToBottom: true,
                toolBarBuilder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(() {
                        return homeController.isGenerating.value
                            ? Padding(
                                padding: EdgeInsets.only(top: 4.h, bottom: 4.h),
                                child: Row(
                                  children: [
                                    SizedBox(width: 12.w),
                                    ByWidgetsUtil.generatingBtn(),
                                    const Spacer(),
                                  ],
                                ),
                              )
                            : Container();
                      }),
                      Row(
                        children: [
                          SizedBox(width: 12.w),
                          Obx(() {
                            return ByWidgetsUtil.commonText(
                              text: "${wordsCount.value}/2000",
                              fontSize: 12.sp,
                              fontWeight: FontWeight.normal,
                              textColor:
                                  ByColorUtil.color0B1843.withOpacity(0.5),
                            );
                          }),
                          Obx(() {
                            return Offstage(
                              offstage:
                                  homeController.currentPrompt.value.isEmpty,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  homeController.currentPrompt.value = '';

                                  wordsCount.value =
                                      homeController.currentPrompt.value.length;
                                },
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.w),
                                  child: ByWidgetsUtil.commonText(
                                    text: "清空",
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.normal,
                                    textColor: ByColorUtil.color0B1843
                                        .withOpacity(0.5),
                                  ),
                                ),
                              ),
                            );
                          }),
                          const Spacer(),
                          Image.asset(
                            "assets/v2/slicing/icon_random.png",
                            width: 12.w,
                            height: 12.w,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(width: 5.w),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              homeController.fetchRandomPromptStreamData();
                            },
                            child: ByWidgetsUtil.commonText(
                              text: "随机热门灵感",
                              fontSize: 12.sp,
                              fontWeight: FontWeight.normal,
                              textColor: const Color(0xFF5B4BF7),
                            ),
                          ),
                          SizedBox(width: 12.w),
                        ],
                      ),
                    ],
                  );
                },
              ),
            )
          : Obx(() {
              final hasPrompt = homeController.currentPrompt.value.isNotEmpty;
              final promptText = hasPrompt
                  ? homeController.currentPrompt.value
                  : homeController.isGenerating.value
                      ? ""
                      : "您可点击上面的推荐灵感或自行输入故事概要也可以在此直接输入完整的故事、剧本、小说";
              return Column(
                children: [
                  SizedBox(height: 10.h),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _expandEditing,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // 不要强制撑破父约束；用顶对齐 + 可滚动文本避免旋转后字被压扁
                          final h = constraints.maxHeight;
                          if (!h.isFinite || h <= 0) {
                            return const SizedBox.shrink();
                          }
                          return SizedBox(
                            height: h,
                            width: constraints.maxWidth,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: SingleChildScrollView(
                                controller: _promptScrollController,
                                physics: const ClampingScrollPhysics(),
                                padding: EdgeInsets.zero,
                                child: Text(
                                  promptText,
                                  softWrap: true,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    height: 1.4,
                                    fontWeight: FontWeight.normal,
                                    color: ByColorUtil.color0B1843
                                        .withOpacity(hasPrompt ? 1 : 0.5),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Obx(() {
                    return homeController.isGenerating.value
                        ? Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Row(
                              children: [
                                ByWidgetsUtil.generatingBtn(),
                                const Spacer(),
                              ],
                            ),
                          )
                        : Container();
                  }),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Obx(() {
                        return ByWidgetsUtil.commonText(
                          text:
                              "${homeController.currentPrompt.value.length}/2000",
                          fontSize: 12.sp,
                          fontWeight: FontWeight.normal,
                          textColor: ByColorUtil.color0B1843.withOpacity(0.5),
                        );
                      }),
                      Obx(() {
                        return Offstage(
                          offstage:
                              !(homeController.currentPrompt.value.isNotEmpty &&
                                  !homeController.isGenerating.value),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              homeController.currentPrompt.value = '';
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                              child: ByWidgetsUtil.commonText(
                                text: "清空",
                                fontSize: 12.sp,
                                fontWeight: FontWeight.normal,
                                textColor:
                                    ByColorUtil.color0B1843.withOpacity(0.5),
                              ),
                            ),
                          ),
                        );
                      }),
                      const Spacer(),
                      Image.asset(
                        "assets/v2/slicing/icon_random.png",
                        width: 12.w,
                        height: 12.w,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 5.w),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          num appChannel =
                              BuildConfig.instance.channelType.code;
                          if (appChannel == 414) {
                            Get.log("===当前的渠道===$appChannel");
                            ByNavigatorUtil.checkLogin(
                                context: context,
                                nextStepEvent: () {
                                  homeController.fetchRandomPromptStreamData();
                                });
                            return;
                          }
                          homeController.fetchRandomPromptStreamData();
                        },
                        child: ByWidgetsUtil.commonText(
                          text: "随机热门灵感",
                          fontSize: 12.sp,
                          fontWeight: FontWeight.normal,
                          textColor: const Color(0xFF5B4BF7),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                ],
              );
            }),
    );
  }

  List<Widget> _buildTabs(RxList<SlicingItemBean> categoryBeans) {
    return categoryBeans.map((category) {
      final index = categoryBeans.indexOf(category);
      final isLast = index == categoryBeans.length - 1;
      return Tab(
        child: Obx(() {
          final isSelected = index == _currentIndex.value;
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: isSelected
                  ? ByColorUtil.colorEAEEFF
                  : ByColorUtil.colorF3F5F9,
            ),
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
            margin: EdgeInsets.only(right: isLast ? 0 : 10.w),
            child: Text(
              category.title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? ByColorUtil.LoginBtnBgColor
                    : const Color(0xFF0B0A1C),
              ),
            ),
          );
        }),
      );
    }).toList();
  }

  List<Widget> _buildPages(RxList<SlicingItemBean> categoryBeans) {
    return categoryBeans.map((category) {
      return SingleListPage(categoryBean: category);
    }).toList();
  }
}
