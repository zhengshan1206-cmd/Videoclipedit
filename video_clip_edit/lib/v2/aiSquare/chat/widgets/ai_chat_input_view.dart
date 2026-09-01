import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_color_utils.dart';
import 'package:video_clip_edit/providers/ai_chat_providers.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/widgets/ai_cartoon_prohibited_words_dailog.dart';
import 'package:video_clip_edit/widgets/common/integral_vip_view.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';

GlobalKey<_AiChatInputViewState> _aiChatInputViewKey = GlobalKey();

class AiChatInputView extends StatefulWidget {
  const AiChatInputView({
    super.key,
    this.onSentCallback,
    this.headerWidget,
    this.outerWidget,
  });

  final void Function()? onSentCallback;
  final Widget? headerWidget;
  final Widget? outerWidget;
  @override
  State<AiChatInputView> createState() => _AiChatInputViewState();
}

class _AiChatInputViewState extends State<AiChatInputView> {
  /// 输入框初始化高度
  double? initHeight;

  /// 是否显示全屏按钮
  bool showExpand = false;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        final RenderBox renderBox =
            _aiChatInputViewKey.currentContext!.findRenderObject() as RenderBox;
        final size = renderBox.size;
        setState(() {
          initHeight = size.height;
        });
      },
    );
    final provider = context.read<AiChatProviders>();
    provider.editInputController.addListener(onInputChanged);
  }

  void onInputChanged() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        if (mounted) {
          final RenderBox renderBox = _aiChatInputViewKey.currentContext!
              .findRenderObject() as RenderBox;
          final height = renderBox.size.height;

          setState(() {
            showExpand = height > 120;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    final provider = context.read<AiChatProviders>();
    provider.editInputController.removeListener(onInputChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AiChatProviders provider = context.read<AiChatProviders>();
    final hasNoHeader = widget.headerWidget == null;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        widget.outerWidget ?? const SizedBox(),
        SizedBox(height: hasNoHeader ? 0 : 10.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.w),
              topRight: Radius.circular(12.w),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    ByColorUtil.BlackColor.withOpacity(hasNoHeader ? 0 : 0.2),
                blurRadius: 4.w,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.headerWidget ?? const SizedBox(),
              Container(
                padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 4.w),
                child: _buildIntegralVipView(),
              ),
              Stack(
                children: [
                  Container(
                    color: Colors.transparent,
                    child: AnimatedContainer(
                      key: _aiChatInputViewKey,
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.only(
                          top: 4.h, left: 12.w, right: 12.w, bottom: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.w),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 6.w,
                            color: ByColorUtil.BlackColor.withOpacity(0.1),
                          )
                        ],
                      ),
                      padding: EdgeInsets.only(left: 10.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              focusNode: provider.focusNode,
                              controller: provider.editInputController,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: ByColorUtils.hexColor("#0B1843"),
                              ),
                              onChanged: (value) {},
                              maxLines: 8,
                              minLines: 1,
                              expands: false,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "有什么问题尽管问我吧",
                                hintStyle: TextStyle(
                                  fontSize: 16.sp,
                                  color: ByColorUtils.hexColor("#96989A"),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 30.w),
                        ],
                      ),
                    ),
                  ),
                  if (initHeight != null)
                    Positioned(
                      right: 18.w,
                      bottom: (initHeight! - 18.w) * 0.5,
                      child: GestureDetector(
                        onTap: () {
                          final purchaseProvider =
                              context.read<PurchaseProvider>();
                          if (purchaseProvider.preLoginCheck(context) ==
                              false) {
                            return;
                          }
                          FocusScope.of(context).unfocus();
                          if (provider.inCreation) {
                            BotToast.showText(text: "正在回答中");
                            return;
                          }
                          if (provider.editInputController.text.isEmpty) {
                            BotToast.showText(text: "请输入问题");
                            return;
                          }

                          ///针对华为用户是否需要绑定手机号码
                          ByNavigatorUtil.checkLogin(
                              context: context,
                              nextStepEvent: () {
                                // 添加违禁词检测
                                final cartoonProvider = AiCartoonProvider();
                                cartoonProvider.desc =
                                    provider.editInputController.text;
                                cartoonProvider.detect(
                                  context,
                                  provider.editInputController.text,
                                  onSuccess: () {
                                    if (cartoonProvider
                                        .bandedWords.isNotEmpty) {
                                      BotToast.showText(text: "当前存在违禁词");
                                      showDialog(
                                        context: context,
                                        useSafeArea: false,
                                        barrierDismissible: true,
                                        builder: (ctx) =>
                                            ChangeNotifierProvider.value(
                                          value: cartoonProvider,
                                          child:
                                              const AiCartoonProhibitedWordsDailog<
                                                  AiCartoonProvider>(),
                                        ),
                                      ).then((value) {
                                        // if (value != null && value is String) {
                                        //   provider.editInputController.text =
                                        //       value;
                                        //   setState(() {
                                        //     showExpand = false;
                                        //   });
                                        // }
                                        if (value != null && value is Map) {
                                          final String newValue =
                                              value['desc'] as String;
                                          provider.editInputController.text =
                                              newValue;
                                          setState(() {
                                            showExpand = false;
                                          });
                                        }
                                      });
                                    } else {
                                      setState(() {
                                        showExpand = false;
                                      });
                                      provider.sendMessageContentDatas(
                                        provider.editInputController.text,
                                        callback: () {
                                          widget.onSentCallback?.call();
                                        },
                                      );
                                    }
                                  },
                                );
                              });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Image.asset(
                            context.select<AiChatProviders, bool>(
                                    (value) => value.canSend)
                                ? "assets/ai/aiduihua_fasong.png"
                                : "assets/ai/aiduihua_fasong_normal.png",
                            width: 18.w,
                            height: 18.w,
                          ),
                        ),
                      ),
                    ),
                  if (showExpand)
                    Positioned(
                      right: 18.w,
                      top: (initHeight! - 18.w) * 0.5,
                      child: GestureDetector(
                        onTap: () {
                          showInputDialog(context);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: ByWidgetsUtil.svgAsset(
                            width: 18,
                            height: 18,
                            filePath: "assets/ai/ai_chat_input_expand.svg",
                          ),
                        ),
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  // 积分-vip-次数-消耗模块-ai对话
  Widget _buildIntegralVipView() {
    return const IntegralVipView(
      requiredPoints: 0,
      type: "txt_knows", // 通过这个type请求权益接口获取实际积分
      padding: EdgeInsets.only(bottom: 0),
    );
  }

  void showInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return ChangeNotifierProvider.value(
          value: context.read<AiChatProviders>(),
          child: AiChatInputViewDialog(
            onSentCallback: () {
              setState(() {
                showExpand = false;
              });
              widget.onSentCallback?.call();
            },
            initialValue:
                context.read<AiChatProviders>().editInputController.text,
          ),
        );
      },
    );
  }
}

class AiChatInputViewDialog extends StatefulWidget {
  const AiChatInputViewDialog({
    super.key,
    this.onSentCallback,
    required this.initialValue,
  });
  final void Function()? onSentCallback;
  final String initialValue;

  @override
  State<AiChatInputViewDialog> createState() => _AiChatInputViewDialogState();
}

class _AiChatInputViewDialogState extends State<AiChatInputViewDialog> {
  late TextEditingController controller;
  FocusNode focusNode = FocusNode()..requestFocus();
  double offsetY = 0;
  @override
  void initState() {
    super.initState();

    controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AiChatProviders provider = context.read<AiChatProviders>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          SizedBox(height: 40.h + offsetY),
          Expanded(
            child: GestureDetector(
              onVerticalDragStart: (details) {},
              onVerticalDragUpdate: (details) {
                setState(() {
                  offsetY += details.delta.dy;
                  if (offsetY < 0) offsetY = 0;
                });
              },
              onVerticalDragEnd: (details) {
                // 滑动结束时重置偏移量
                if (offsetY > 20) {
                  ByNavRouterUtils.goBack(context);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.w),
                    topRight: Radius.circular(12.w),
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        SizedBox(width: 12.w),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            ByNavRouterUtils.goBack(context);
                          },
                          child: ByWidgetsUtil.svgAsset(
                            width: 18,
                            height: 18,
                            filePath: "assets/ai/ai_chat_input_fold.svg",
                          ),
                        ),
                        SizedBox(width: 12.w),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: TextField(
                          focusNode: focusNode,
                          controller: controller,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: ByColorUtils.hexColor("#0B1843"),
                          ),
                          onChanged: (value) {
                            provider.editInputController.text = value;
                          },
                          maxLines: 1000,
                          minLines: 1,
                          expands: false,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "有什么问题尽管问我吧",
                            hintStyle: TextStyle(
                              fontSize: 16.sp,
                              color: ByColorUtils.hexColor("#96989A"),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(width: 12.w),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            if (provider.inCreation) {
                              BotToast.showText(text: "正在回答中");
                              return;
                            }
                            if (provider.editInputController.text.isEmpty) {
                              BotToast.showText(text: "请输入问题");
                              return;
                            }

                            ///针对华为用户是否需要绑定手机号码
                            ByNavigatorUtil.checkLogin(
                                context: context,
                                nextStepEvent: () {
                                  // 添加违禁词检测
                                  final cartoonProvider = AiCartoonProvider();
                                  cartoonProvider.desc =
                                      provider.editInputController.text;
                                  cartoonProvider.detect(
                                    context,
                                    provider.editInputController.text,
                                    onSuccess: () {
                                      if (cartoonProvider
                                          .bandedWords.isNotEmpty) {
                                        BotToast.showText(text: "当前存在违禁词");
                                        showDialog(
                                          context: context,
                                          useSafeArea: false,
                                          barrierDismissible: true,
                                          builder: (ctx) =>
                                              ChangeNotifierProvider.value(
                                            value: cartoonProvider,
                                            child:
                                                const AiCartoonProhibitedWordsDailog<
                                                    AiCartoonProvider>(),
                                          ),
                                        ).then((value) {
                                          if (value != null &&
                                              value is String) {
                                            provider.editInputController.text =
                                                value;
                                            provider.sendMessageContentDatas(
                                              value,
                                              callback: () {
                                                ByNavRouterUtils.goBack(
                                                    context);
                                                widget.onSentCallback?.call();
                                              },
                                            );
                                          }
                                        });
                                      } else {
                                        provider.sendMessageContentDatas(
                                          provider.editInputController.text,
                                          callback: () {
                                            ByNavRouterUtils.goBack(context);
                                            widget.onSentCallback?.call();
                                          },
                                        );
                                      }
                                    },
                                  );
                                });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: Image.asset(
                              context.select<AiChatProviders, bool>(
                                      (value) => value.canSend)
                                  ? "assets/ai/aiduihua_fasong.png"
                                  : "assets/ai/aiduihua_fasong_normal.png",
                              width: 18.w,
                              height: 18.w,
                            ),
                          ),
                        ),
                        // SizedBox(width: 12.w),
                      ],
                    ),
                    SizedBox(height: ByScreenUtils.bottomSafeHeight + 15.h)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
