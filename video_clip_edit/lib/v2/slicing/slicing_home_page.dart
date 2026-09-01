import 'dart:io';
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

class _SlicingHomePageState extends State<SlicingHomePage> {
  final RxInt _currentIndex = 0.obs;
  final SlicingHomeController homeController = Get.put(SlicingHomeController());
  final OneClickSlicingController slicingController =
      Get.find<OneClickSlicingController>();
  RxInt wordsCount = 0.obs;

  @override
  void initState() {
    super.initState();
    // 添加键盘可见性监听
    KeyboardVisibilityController().onChange.listen((bool visible) {
      homeController.keyboardVisible.value = visible;
      if (visible) {
        // 延迟一帧获取键盘高度，确保viewInsets已更新
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            homeController.keyboardHeight.value = 500;
          }
        });
      } else {
        homeController.keyboardHeight.value = 0.0;
      }
    });
  }

  @override
  void dispose() {
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
                  FocusScope.of(context).unfocus();
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
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              bottom: 0,
              left: 0,
              right: 0,
              height: homeController.manualEditing.value
                  ? 400
                  : homeController.bottomViewHeight,
              child: ByWidgetsUtil.physicalModel(
                color: Colors.white,
                child: Column(
                  children: [
                    // if (homeController.manualEditing.value)
                    //   SizedBox(height: 15.h),
                    if (homeController.manualEditing.value)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
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
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                slicingController.showAppBar.value =
                                    homeController.manualEditing.value;
                                homeController.manualEditing.value =
                                    !homeController.manualEditing.value;
                              },
                              child: Container(
                                width: 40.w,
                                height: 40.h,
                                alignment: Alignment.bottomRight,
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
                    SizedBox(height: 12.h),
                    Expanded(
                        child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: _buildInputView(context,
                          slicingController: slicingController),
                    )),
                    if (!homeController.manualEditing.value)
                      SizedBox(height: 10.h),
                    if (!homeController.manualEditing.value)
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
                    if (!homeController.manualEditing.value)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.h),
                        child: ByWidgetsUtil.commonText(
                          text: "禁止利用功能从事任何违法活动",
                          fontSize: 10.sp,
                          textColor: ByColorUtil.color0B1843.withOpacity(0.3),
                        ),
                      ),
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
          ? NormalInputView(
              maxWords: 2000,
              placeholder: "您可点击上面的推荐灵感或自行输入故事概要也可以\n在此直接输入完整的故事、剧本、小说",
              initialValue: homeController.currentPrompt.value,
              onChanged: (val) {
                wordsCount.value = val.length;
              },
              onFinished: (val) {
                homeController.currentPrompt.value = val;
              },
              scrollToBottom: true,
              key: ValueKey(homeController.currentPrompt.value),
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
                            textColor: ByColorUtil.color0B1843.withOpacity(0.5),
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
            )
          : Obx(() {
              final hasPrompt = homeController.currentPrompt.value.isNotEmpty;
              return Column(
                children: [
                  SizedBox(height: 10.h),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        slicingController.showAppBar.value =
                            homeController.manualEditing.value;
                        homeController.manualEditing.value =
                            !homeController.manualEditing.value;
                        wordsCount.value =
                            homeController.currentPrompt.value.length;
                      },
                      child: Builder(builder: (context) {
                        final ScrollController scrollController =
                            ScrollController();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (hasPrompt && scrollController.hasClients) {
                            scrollController.animateTo(
                              scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        });

                        return ListView(
                          controller: scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          children: [
                            ByWidgetsUtil.commonText(
                              text: hasPrompt
                                  ? homeController.currentPrompt.value
                                  : homeController.isGenerating.value
                                      ? ""
                                      : "您可点击上面的推荐灵感或自行输入故事概要也可以在此直接输入完整的故事、剧本、小说",
                              fontSize: 14.sp,
                              fontWeight: FontWeight.normal,
                              maxLines: 10000000,
                              textColor: ByColorUtil.color0B1843
                                  .withOpacity(hasPrompt ? 1 : 0.5),
                            )
                          ],
                        );
                      }),
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
                          num appChannel = BuildConfig.instance.channelType.code;
                          if(appChannel==414){
                            Get.log("===当前的渠道===$appChannel");
                            ByNavigatorUtil.checkLogin(context: context, nextStepEvent: (){
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
