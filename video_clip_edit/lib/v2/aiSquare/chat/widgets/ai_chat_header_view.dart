import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/v2/aiClip/ai_clip_page.dart';
import 'package:video_clip_edit/utils/comon/by_time_utils.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_color_utils.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/providers/ai_chat_providers.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_page.dart';
import 'package:video_clip_edit/modules/common/widget/common_dialog.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_material_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/chat/beans/ai_chat_item_bean.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_opening_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/chat/beans/ai_chat_model_listbean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_provider.dart';
import 'package:video_clip_edit/modules/purchase/widgets/dailog_bonus_lowest_price.dart';

class AiChatHeaderView extends StatelessWidget {
  const AiChatHeaderView({
    super.key,
    required this.onSent,
  });

  /// 点击发送
  final void Function() onSent;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AiChatProviders>();
    final aiChatDefaultPromptsRandom =
        context.select<AiChatProviders, List<String>>(
            (value) => value.aiChatDefaultPromptsRandom);
    return Column(
      children: [
        // SizedBox(height: 40.h),
        // Image.asset("assets/ai/aichat_logo.png", width: 80.w, height: 120.h),
        // SizedBox(height: 17.h),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   children: [
        //     Text(
        //       "知识问答",
        //       style: TextStyle(
        //           color: ByColorUtils.hexColor("#A5A4A7"), fontSize: 14.sp),
        //     ),
        //     Text(
        //       "  |  ",
        //       style: TextStyle(
        //           color: ByColorUtils.hexColor("#A5A4A7"), fontSize: 14.sp),
        //     ),
        //     Text(
        //       "文案创作",
        //       style: TextStyle(
        //           color: ByColorUtils.hexColor("#A5A4A7"), fontSize: 14.sp),
        //     ),
        //     Text(
        //       "  |  ",
        //       style: TextStyle(
        //           color: ByColorUtils.hexColor("#A5A4A7"), fontSize: 14.sp),
        //     ),
        //     Text(
        //       "故事编写",
        //       style: TextStyle(
        //           color: ByColorUtils.hexColor("#A5A4A7"), fontSize: 14.sp),
        //     ),
        //   ],
        // ),
        // SizedBox(height: 7.h),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   children: [
        //     Text(
        //       "种草文案",
        //       style: TextStyle(
        //           color: ByColorUtils.hexColor("#A5A4A7"), fontSize: 14.sp),
        //     ),
        //     Text(
        //       "  |  ",
        //       style: TextStyle(
        //           color: ByColorUtils.hexColor("#A5A4A7"), fontSize: 14.sp),
        //     ),
        //     Text(
        //       "生活助理",
        //       style: TextStyle(
        //           color: ByColorUtils.hexColor("#A5A4A7"), fontSize: 14.sp),
        //     ),
        //     Text(
        //       "  |  ",
        //       style: TextStyle(
        //           color: ByColorUtils.hexColor("#A5A4A7"), fontSize: 14.sp),
        //     ),
        //     Text(
        //       "短剧解说",
        //       style: TextStyle(
        //           color: ByColorUtils.hexColor("#A5A4A7"), fontSize: 14.sp),
        //     ),
        //   ],
        // ),
        SizedBox(height: 31.h),
        Container(
          margin: const EdgeInsets.only(left: 32, right: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "你可以试着问我:",
                style: TextStyle(
                    color: ByColorUtils.hexColor("#0B1843"), fontSize: 14.sp),
              ),
              GestureDetector(
                onTap: () {
                  provider.updateAiChatDefaultPromptRandom(
                    provider.getRandomPrompt(),
                  );
                },
                child: Row(
                  children: [
                    Image.asset("assets/ai/aiduihua_hyp.png",
                        width: 12.w, height: 12.h),
                    SizedBox(width: 5.w),
                    Text(
                      "换一批",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: ByColorUtils.hexColor("#5E4AFF"),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (c, i) {
            String item = aiChatDefaultPromptsRandom[i];
            return GestureDetector(
              onTap: () {
                final purchaseProvider = context.read<PurchaseProvider>();
                if (purchaseProvider.preLoginCheck(context) == false) return;
                provider.canSend = true;
                provider.sendMessageContentDatas(item, callback: onSent);
              },
              child: Container(
                padding: const EdgeInsets.only(
                    top: 15, bottom: 15, left: 10, right: 10),
                decoration: BoxDecoration(
                  color: ByColorUtils.hexColor("#F3F5F9"),
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.only(
                    bottom: 5, top: 5, left: 23, right: 23),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.toString(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: ByColorUtils.hexColor("#0B1843"),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Image.asset(
                      "assets/ai/fasongxiaoxi.png",
                      width: 12.w,
                      height: 12.h,
                    ),
                  ],
                ),
              ),
            );
          },
          itemCount: aiChatDefaultPromptsRandom.length,
        )
      ],
    );
  }
}

/// Ai对话框
class AiChatCell extends StatelessWidget {
  const AiChatCell({
    super.key,
    required this.chat,
    required this.index,
    required this.isLast,
  });
  final int index;
  final bool isLast;

  /// 对话内容模型
  final AiChatItemBean chat;

  @override
  Widget build(BuildContext context) {
    final isMyMsg = !chat.isAnswer;
    final inCreation =
        context.select<AiChatProviders, bool>((vm) => vm.inCreation);
    if (isMyMsg) {
      return MineMessageCell(chat: chat);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 40, left: 10, top: 15),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
          decoration: BoxDecoration(
            color: ByColorUtils.hexColor("#F5F5F5"),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(2),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 问题和回答内容
              Container(
                alignment: Alignment.centerLeft,
                child: ByWidgetsUtil.commonText(
                  maxLines: 1000,
                  fontSize: 16.sp,
                  text: chat.contet,
                  fontWeight: FontWeight.normal,
                  textColor: ByColorUtil.CommonTextColor,
                ),
              ),

              /// 正在回答
              Offstage(
                offstage: !isLast || !inCreation,
                child: _buildAnsweringWidget(),
              ),
              Row(
                children: [
                  const Spacer(),
                  Offstage(
                    offstage: isMyMsg || inCreation,
                    child: Container(
                      padding: EdgeInsets.only(top: 5.h, bottom: 5.h),
                      child: ByWidgetsUtil.commonText(
                        text: "内容由AI生成，仅供参考",
                        fontSize: 10.sp,
                        textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),

              /// 操作按钮组
              Offstage(
                offstage: isLast && inCreation,
                child: _buildActions(context),
              ),
            ],
          ),
        ),
        // SizedBox(height: 15.h),
      ],
    );
  }

  /// 正在回答
  Widget _buildAnsweringWidget() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 2),
          child: _buildBtnStyleWidget(
            "正在回答中",
            rightWidget: ByWidgetsUtil.activityIndicator(
              radius: 6,
              color: ByColorUtils.hexColor("#6978FD"),
            ),
          ),
        ),
      ],
    );
  }

  /// 操作按钮
  _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildBtnStyleWidget(
          "删除",
          rightW: 12.w,
          rightH: 12.h,
          grc: () {
            showDialog(
              context: context,
              builder: (ctx) {
                return CommonDialog(
                  reverse: false,
                  maxLine: 10,
                  contents: "请确认是否删除，删除后将不可回恢复，请谨慎操作",
                  confirmBtnTitle: "删除",
                  confirmCallback: () {
                    final provider = context.read<AiChatProviders>();
                    provider.deleteMessage(
                      msgID: chat.messageId,
                      onSuccess: () {
                        final messagesCopy =
                            provider.messages.map((e) => e.copyWith()).toList();
                        messagesCopy
                            .removeWhere((e) => e.messageId == chat.messageId);
                        provider.updateMessages(messagesCopy);
                      },
                    );
                  },
                );
              },
            );
          },
        ),
        SizedBox(
          width: 5.w,
        ),
        _buildBtnStyleWidget(
          "复制",
          rightW: 12.w,
          rightH: 12.h,
          grc: () async {
            await Clipboard.setData(
              ClipboardData(text: chat.contet),
            );
            BotToast.showText(text: "复制成功");
          },
        ),
        SizedBox(width: 5.w),
        _buildBtnStyleWidget(
          "一键成片",
          grc: () {
            // _selectVideoStyleDialog(context);
            ByNavigatorUtil.checkLogin(
                context: context,
                nextStepEvent: () {
                  _selectVideoStyleDialog(context);
                });
          },
          rightIcon: "assets/ai/aiduihua_yjcp.png",
          rightW: 12.w,
          rightH: 12.h,
        ),
      ],
    );
  }

  _selectVideoStyleDialog(BuildContext context) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(18),
        ),
      ),
      builder: (BuildContext ctx) {
        //构建弹框中的内容
        return StatefulBuilder(builder: (c, setBottomSheetState) {
          return Container(
            padding:
                const EdgeInsets.only(top: 20, bottom: 20, left: 12, right: 12),
            alignment: Alignment.center,
            height: 265.h,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(),
                    Text(
                      "选择视频类型",
                      style: TextStyle(
                          color: ByColorUtils.hexColor("#0B1843"),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Image.asset(
                        "assets/ai/aichat_hsgb.png",
                        width: 14.w,
                        height: 14.h,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 20.w,
                  height: 20.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: GestureDetector(
                      onTap: () {
                        ByNavRouterUtils.goBack(context);
                        final provider = AiCartoonProvider();
                        provider.desc = chat.contet;
                        ByNavRouterUtils.push(
                          context,
                          ChangeNotifierProvider(
                            create: (context) => provider,
                            child: const AiCartoonPage(fromChat: true),
                          ),
                        );
                      },
                      child: Image.asset(
                        "assets/ai/text_to_video.png",
                        height: 180.h,
                      ),
                    )),
                    SizedBox(
                      width: 10.w,
                    ),
                    Expanded(
                        child: GestureDetector(
                      onTap: () {
                        ByNavRouterUtils.goBack(context);
                        final clipProvider = AiClipProvider();
                        clipProvider.desc = chat.contet;
                        ByNavRouterUtils.push(
                            context,
                            MultiProvider(providers: [
                              ChangeNotifierProvider(
                                create: (context) => clipProvider,
                              ),
                              ChangeNotifierProvider(
                                create: (BuildContext context) =>
                                    AiMaterialProvider(),
                              ),
                              ChangeNotifierProvider(
                                create: (BuildContext context) =>
                                    AiClipOpeningProvider(),
                              ),
                            ], child: const AiClipPage(fromChat: true)));
                      },
                      child: Image.asset(
                        "assets/ai/aichat_znhj.png",
                        height: 180.h,
                      ),
                    )),
                  ],
                )
              ],
            ),
          );
        });
      },
      context: context,
    );
  }

  ///按钮样式
  Widget _buildBtnStyleWidget(String txt,
      {GestureTapCallback? grc,
      String? leftIcon,
      String? rightIcon,
      double rightW = 7,
      double rightH = 7.0,
      Widget? rightWidget}) {
    return GestureDetector(
      onTap: grc,
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        decoration: BoxDecoration(
          color: ByColorUtils.hexColor("#EAEEFF"),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leftIcon != null)
              Image.asset(
                leftIcon,
                width: 7.w,
                height: 7.h,
              ),
            Text(
              txt,
              style: TextStyle(
                color: ByColorUtils.hexColor("#5E4AFF"),
                fontSize: 12.sp,
              ),
            ),
            if (rightIcon != null)
              SizedBox(
                width: 5.w,
              ),
            if (rightIcon != null)
              Image.asset(
                rightIcon,
                width: rightW,
                height: rightH,
              ),
            if (rightWidget != null) rightWidget
          ],
        ),
      ),
    );
  }
}

class MineMessageCell extends StatelessWidget {
  const MineMessageCell({
    super.key,
    required this.chat,
  });

  final AiChatItemBean chat;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: ByWidgetsUtil.commonText(
            text: ByTimeUtils.formatDateTime(chat.time),
            fontSize: 10.sp,
            textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: double.infinity,
            ),
            child: Container(
              margin: const EdgeInsets.only(left: 40, right: 10, top: 12),
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
              decoration: BoxDecoration(
                color: ByColorUtils.hexColor("#674AF9"),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(2),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: ByWidgetsUtil.commonText(
                maxLines: 1000,
                fontSize: 16.sp,
                text: chat.contet,
                fontWeight: FontWeight.normal,
                textColor: ByColorUtil.WhiteColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AiChatModelCell extends StatelessWidget {
  const AiChatModelCell({
    super.key,
    required this.model,
    required this.index,
  });

  // final bool isSelect;
  final int index;
  final AiChatModelListBean model;

  @override
  Widget build(BuildContext context) {
    final select = context.select<AiChatProviders, int>(
          (value) => value.selectedModelIndex,
        ) ==
        index;
    return GestureDetector(
      onTap: () {
        final needVip = model.needVip == 1;
        if (needVip &&
            (context.read<LaunchProvider>().launchInfo?.isVip ?? 0) != 1) {
          context.read<PurchaseProvider>().loadVIPItems(
            onSuccess: () {
              showDialog(
                context: context,
                builder: (context) {
                  return const DailogBonusLowestPrice();
                },
              );
            },
          );
          return;
        }
        final provider = context.read<AiChatProviders>();
        provider.updateSelectedModelIndex(index);
        BotToast.showText(
          text: "已切换到${model.title}",
        );
        provider.setShowModel(false);
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(
                  color: select
                      ? ByColorUtils.hexColor("#5E4AFF")
                      : ByColorUtils.hexColor("#F8FAFB"),
                  width: 1),
              // border
              color: select
                  ? ByColorUtils.hexColor("#EAEEFF")
                  : ByColorUtils.hexColor("#F8FAFB"),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      model.title,
                      style: TextStyle(
                        color: select
                            ? ByColorUtils.hexColor("#5E4AFF")
                            : ByColorUtils.hexColor("#0B1843"),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Offstage(
                      offstage: model.needVip != 1,
                      child: SizedBox(
                        height: 14.h,
                        child: ByWidgetsUtil.gradientBgContainer(
                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                            gradient: ByColorUtil.lineareGradient(
                              colorStart: const Color(0xFFFF8D05),
                              colorEnd: const Color(0xFFFFC763),
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            child: ByWidgetsUtil.commonText(
                                text: "vip",
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                                textColor: const Color(0xFFFFFFFF))),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                  model.desc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: select
                        ? ByColorUtils.hexColor("#5E4AFF")
                        : ByColorUtils.hexColor("#A0A3AE"),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Offstage(
              offstage: !select,
              child: Image.asset(
                "assets/ai/aichat_mxitem_duisdn.png",
                width: 24.w,
                height: 24.h,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AiChatListView extends StatefulWidget {
  const AiChatListView({
    super.key,
    required this.onSent,
    required this.controller,
  });

  final void Function() onSent;
  final ScrollController controller;

  @override
  State<AiChatListView> createState() => _AiChatListViewState();
}

class _AiChatListViewState extends State<AiChatListView> {
  @override
  void initState() {
    super.initState();
    // widget.controller.jumpTo(widget.controller.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    final messages = context.select<AiChatProviders, List<AiChatItemBean>>(
      (value) => value.messages,
    );
    final len = messages.isEmpty ? 1 : messages.length;
    // if (widget.controller.position.pixels > 0) {
    //   widget.controller.jumpTo(widget.controller.position.maxScrollExtent);
    // }
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (mounted) {
          _handleScrollNotification(notification, context);
        }
        return true;
      },
      child: ListView.builder(
        itemCount: len,
        controller: widget.controller,
        padding: EdgeInsets.only(
          bottom: math.max(
            ByScreenUtils.bottomSafeHeight + 150.h,
            MediaQuery.viewPaddingOf(context).bottom + 170.h,
          ),
        ),
        itemBuilder: (c, index) {
          if (messages.isEmpty) {
            return AiChatHeaderView(onSent: widget.onSent);
          } else {
            return AiChatCell(
              index: index,
              chat: messages[index],
              isLast: messages.length - 1 == index,
            );
          }
        },
      ),
    );
  }

  /// 处理屏幕滚动
  bool _handleScrollNotification(
    ScrollNotification notification,
    BuildContext context,
  ) {
    AiChatProviders provider = context.read<AiChatProviders>();
    if (notification is ScrollStartNotification) {
      // 用户开始滑动
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.updateScrollByUser(true);
      });
    } else if (notification is ScrollEndNotification) {
      // 用户停止滑动
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.updateScrollByUser(false);
      });
    }
    return true;
  }
}
