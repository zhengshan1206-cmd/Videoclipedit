import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/utils/http/intercept.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_color_utils.dart';
import 'package:video_clip_edit/providers/ai_chat_providers.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/common/widget/common_dialog.dart';
import 'package:video_clip_edit/v2/aiSquare/chat/widgets/ai_chat_appbar.dart';
import 'package:video_clip_edit/v2/toolBox/beans/new_tool_box_list_bean.dart';
import 'package:video_clip_edit/v2/toolBox/widgets/sliver_type_list_view.dart';
import 'package:video_clip_edit/v2/aiSquare/chat/beans/ai_chat_item_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/chat/widgets/ai_chat_input_view.dart';
import 'package:video_clip_edit/v2/aiSquare/chat/widgets/ai_chat_header_view.dart';
import 'package:video_clip_edit/v2/aiSquare/chat/beans/ai_chat_model_listbean.dart';

import '../widgets/ai_video_player.dart';
import '../widgets/home_page_scroll_list_view.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({
    super.key,
  });

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  late AiChatProviders provider;
  WebSocketChannel? channel;
  final ScrollController controller = ScrollController();

  final ScrollController _categoryScrollController = ScrollController();

  late StreamSubscription<ClickAiChatPageEvent>? streamSubscription;

  @override
  void initState() {
    super.initState();
    provider = context.read<AiChatProviders>();

    /// 获取大模型列表
    provider.getModelList();

    /// 获取默认的提问示例列表
    provider.getDefaultPrompt();

    provider.loadMessages();

    provider.loadList();

    streamSubscription = eventBus.on<ClickAiChatPageEvent>().listen((e) {
      getFirstQuestion();
    });
  }

  /// 监听Socket消息
  void _listenSocketMsgs() {
    channel?.stream.listen(
      (message) {
        /// 将接收到的消息添加到列表
        if (message == provider.SocketMsgEnd) {
          provider.updateInCreation(false);
          return;
        } else {
          provider.updateInCreation(true);
          provider.updateAiCreatContents(message);
          if (provider.isScrollByUser) return;
          provider.messageContentDatasScrollController.jumpTo(
            provider
                .messageContentDatasScrollController.position.maxScrollExtent,
          );
        }
        if (provider.isScrollByUser) return;
        provider.messageContentDatasScrollController.jumpTo(
          provider.messageContentDatasScrollController.position.maxScrollExtent,
        );
      },
      onDone: () {
        /// 成功
        provider.updateInCreation(false);
      },
      onError: (err) {
        _reconnectToWebSocket();
        // BotToast.showText(text: "服务器连接失败");
      },
    );
  }

  _checkIsGenerate() => true;

  /// 连接Socket
  _connectWbSocket() {
    _closeChannel();

    final launchProvider = context.read<LaunchProvider>();
    final wsuri =
        launchProvider.launchInfo?.wsuri ?? 'wss://echo.websocket.org';

    final questionID =
        Uri.encodeQueryComponent(provider.questionInfoBean!.token);

    /// 是否是故事创作模式
    bool isGenerate = _checkIsGenerate();

    /// socket 连接地址
    final url =
        "$wsuri/answer?type=${isGenerate ? "general" : "creator"}&id=$questionID&token=${Uri.encodeQueryComponent(getToken())}";
    debugPrint("socketUrl:$url");

    /// 连接 WebSocket 服务
    channel = WebSocketChannel.connect(Uri.parse(url));

    /// 开始监听消息
    _listenSocketMsgs();
  }

  /// 重连 Socket
  void _reconnectToWebSocket() {
    if (provider.retryTimes < provider.MaxRetryTimes) {
      Future.delayed(
        const Duration(seconds: 3),
        () {
          if (mounted) {
            provider.retryTimes = provider.retryTimes + 1;
            _connectWbSocket();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _closeChannel();
    streamSubscription?.cancel();
    super.dispose();
  }

  void _closeChannel() {
    channel?.sink.close();
    channel = null;
  }

  getFirstQuestion() async {
    log("==========");
    if (provider.firstDesQuestion.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          provider.canSend = true;
          provider.sendMessageContentDatas(provider.firstDesQuestion,
              callback: () {
            _closeChannel();
            _connectWbSocket();
          });
        } on Exception catch (e) {
          log("初始化ai提问问题异常");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    log("ai聊天页面");
    return Scaffold(
      backgroundColor: ByColorUtil.WhiteColor,
      body: Column(
        children: [
          // _buildAppBar(context),
          Expanded(
              child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: AiChatListView(
                      controller: provider.messageContentDatasScrollController,
                      onSent: () {
                        context.read<AiChatProviders>().focusNode.unfocus();
                        _connectWbSocket();
                      },
                    ),
                  ),
                ],
              ),
              // _buildFloatEntries(context),
              _buildBottomEditInputWidget(context),
              _buildModelListWidget(context),
            ],
          )),
        ],
      ),
    );
  }

  ///模型列表
  _buildModelListWidget(BuildContext context) {
    final show = context.select<AiChatProviders, bool>(
      (value) => value.showModelList,
    );
    return Positioned.fill(
      child: Offstage(
        offstage: !show,
        child: GestureDetector(
          onTap: () {
            provider.setShowModel(!show);
          },
          child: Stack(
            children: [
              Container(
                color: const Color(0xFF1C1C1D).withOpacity(0.7),
              ),
              Container(
                decoration: BoxDecoration(
                  color: ByColorUtils.hexColor("#FFFFFF"),
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18)),
                ),
                child: GridView.builder(
                  itemCount: provider.aiChatModelListBeans.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 11,
                    childAspectRatio: 17 / 9,
                  ),
                  itemBuilder: (c, i) {
                    AiChatModelListBean item = provider.aiChatModelListBeans[i];
                    return AiChatModelCell(model: item, index: i);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  ///底部输入框
  _buildBottomEditInputWidget(BuildContext context) {
    final categoryBeans =
        context.select<AiChatProviders, List<NewToolBoxListBean>>(
      (value) => value.listBeans,
    );
    final hasNoCategories = categoryBeans.isEmpty;
    return AiChatInputView(
      onSentCallback: () {
        context.read<AiChatProviders>().focusNode.unfocus();
        _connectWbSocket();
      },
      headerWidget: hasNoCategories
          ? null
          : AiChatTypeListView(
              categoryScrollController: _categoryScrollController,
              onSize: (Size size, int index) {},
            ),
      outerWidget: Offstage(
        offstage: context.select<AiChatProviders, bool>(
              (value) => value.hasFocus,
            ) ||
            context
                .select<AiChatProviders, List<AiChatItemBean>>(
                  (value) => value.messages,
                )
                .isEmpty ||
            context.select<AiChatProviders, bool>((vm) => vm.inCreation),
        child: Row(
          children: [
            const Spacer(),
            SizedBox(
              height: 25.h,
              child: ByWidgetsUtil.btnWithIcon(
                title: "清空",
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                bgColor: ByColorUtil.WhiteColor,
                borderRadius: 50,
                iconH: 12,
                iconW: 12,
                contentGap: 5,
                fontSize: 11.sp,
                fontWeight: FontWeight.normal,
                textColor: ByColorUtil.TabTextColorSelected,
                boxDecoration: BoxDecoration(
                  border: Border.all(color: ByColorUtil.TabTextColorSelected),
                  borderRadius: BorderRadius.circular(50.w),
                  color: Colors.white,
                ),
                iconPath: "assets/ai/aiduihua_clear.png",
                onClick: () {
                  showDialog(
                    context: context,
                    builder: (c) {
                      return CommonDialog(
                        reverse: false,
                        maxLine: 10,
                        contents: "请确认是否清空消息，清空后将不可回恢复，请谨慎操作",
                        confirmBtnTitle: "确定",
                        confirmCallback: () {
                          context.read<AiChatProviders>().cleanUpAllChats();
                        },
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(width: 5.w),
            SizedBox(
              height: 25.h,
              child: ByWidgetsUtil.btnWithIcon(
                title: "新话题",
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                bgColor: ByColorUtil.WhiteColor,
                borderRadius: 50,
                iconH: 12,
                iconW: 12,
                contentGap: 5,
                fontSize: 11.sp,
                fontWeight: FontWeight.normal,
                textColor: ByColorUtil.TabTextColorSelected,
                boxDecoration: BoxDecoration(
                  border: Border.all(color: ByColorUtil.TabTextColorSelected),
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.white,
                ),
                iconPath: "assets/ai/aiduihua_refresh.png",
                onClick: () {
                  showDialog(
                    context: context,
                    builder: (c) {
                      return CommonDialog(
                        reverse: false,
                        maxLine: 10,
                        contents: "请确认是否刷新话题，刷新后将开启新的话题",
                        confirmBtnTitle: "确定",
                        confirmCallback: () {
                          final provider = context.read<AiChatProviders>();
                          provider.canSend = true;
                          provider.sendMessageContentDatas(
                            "刷新",
                            callback: () {
                              _closeChannel();

                              context
                                  .read<AiChatProviders>()
                                  .focusNode
                                  .unfocus();
                              _connectWbSocket();
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(width: 12.w),
          ],
        ),
      ),
    );
  }

  _buildAppBar(BuildContext context) {
    return const AiChatAppBar();
  }

  _buildFloatEntries(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 70.h,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Offstage(
            offstage: context.select<AiChatProviders, bool>(
                  (value) => value.hasFocus,
                ) ||
                context
                    .select<AiChatProviders, List<AiChatItemBean>>(
                      (value) => value.messages,
                    )
                    .isEmpty ||
                context.select<AiChatProviders, bool>((vm) => vm.inCreation),
            child: Row(
              children: [
                const Spacer(),
                SizedBox(
                  height: 25.h,
                  child: ByWidgetsUtil.btnWithIcon(
                    title: "清空",
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    bgColor: ByColorUtil.WhiteColor,
                    borderRadius: 50,
                    iconH: 12,
                    iconW: 12,
                    contentGap: 5,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.normal,
                    textColor: ByColorUtil.TabTextColorSelected,
                    boxDecoration: BoxDecoration(
                      border:
                          Border.all(color: ByColorUtil.TabTextColorSelected),
                      borderRadius: BorderRadius.circular(50.w),
                      color: Colors.white,
                    ),
                    iconPath: "assets/ai/aiduihua_clear.png",
                    onClick: () {
                      showDialog(
                        context: context,
                        builder: (c) {
                          return CommonDialog(
                            reverse: false,
                            maxLine: 10,
                            contents: "请确认是否清空消息，清空后将不可回恢复，请谨慎操作",
                            confirmBtnTitle: "确定",
                            confirmCallback: () {
                              context.read<AiChatProviders>().cleanUpAllChats();
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(width: 5.w),
                SizedBox(
                  height: 25.h,
                  child: ByWidgetsUtil.btnWithIcon(
                    title: "新话题",
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    bgColor: ByColorUtil.WhiteColor,
                    borderRadius: 50,
                    iconH: 12,
                    iconW: 12,
                    contentGap: 5,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.normal,
                    textColor: ByColorUtil.TabTextColorSelected,
                    boxDecoration: BoxDecoration(
                      border:
                          Border.all(color: ByColorUtil.TabTextColorSelected),
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.white,
                    ),
                    iconPath: "assets/ai/aiduihua_refresh.png",
                    onClick: () {
                      showDialog(
                        context: context,
                        builder: (c) {
                          return CommonDialog(
                            reverse: false,
                            maxLine: 10,
                            contents: "请确认是否刷新话题，刷新后将开启新的话题",
                            confirmBtnTitle: "确定",
                            confirmCallback: () {
                              final provider = context.read<AiChatProviders>();
                              provider.canSend = true;
                              provider.sendMessageContentDatas(
                                "刷新",
                                callback: () {
                                  _closeChannel();

                                  context
                                      .read<AiChatProviders>()
                                      .focusNode
                                      .unfocus();
                                  _connectWbSocket();
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(width: 12.w),
              ],
            ),
          ),
          // Offstage(
          //   offstage: context.select<AiChatProviders, bool>(
          //         (value) => value.hasFocus,
          //       ) ||
          //       context
          //           .select<AiChatProviders, List<AiChatItemBean>>(
          //             (value) => value.messages,
          //           )
          //           .isEmpty ||
          //       context.select<AiChatProviders, bool>((vm) => vm.inCreation) ||
          //       hasNoCategories,
          //   child: AiChatTypeListView(
          //     categoryScrollController: _categoryScrollController,
          //     onSize: (Size size, int index) {},
          //   ),
          // ),
        ],
      ),
    );
  }

  // _buildFloatActions(BuildContext context) {
  //   return Positioned(
  //     left: 0,
  //     right: 0,
  //     bottom: 105.h,
  //     child: Offstage(
  //       offstage: context.select<AiChatProviders, bool>(
  //             (value) => value.hasFocus,
  //           ) ||
  //           context
  //               .select<AiChatProviders, List<AiChatItemBean>>(
  //                 (value) => value.messages,
  //               )
  //               .isEmpty ||
  //           context.select<AiChatProviders, bool>((vm) => vm.inCreation),
  //       child: Row(
  //         children: [
  //           const Spacer(),
  //           SizedBox(
  //             height: 25.h,
  //             child: ByWidgetsUtil.btnWithIcon(
  //               title: "清空",
  //               padding: EdgeInsets.symmetric(horizontal: 10.w),
  //               bgColor: ByColorUtil.WhiteColor,
  //               borderRadius: 50,
  //               iconH: 12,
  //               iconW: 12,
  //               contentGap: 5,
  //               fontSize: 11.sp,
  //               fontWeight: FontWeight.normal,
  //               textColor: ByColorUtil.TabTextColorSelected,
  //               boxDecoration: BoxDecoration(
  //                 border: Border.all(color: ByColorUtil.TabTextColorSelected),
  //                 borderRadius: BorderRadius.circular(50.w),
  //                 color: Colors.white,
  //               ),
  //               iconPath: "assets/ai/aiduihua_clear.png",
  //               onClick: () {
  //                 showDialog(
  //                   context: context,
  //                   builder: (c) {
  //                     return CommonDialog(
  //                       reverse: false,
  //                       maxLine: 10,
  //                       contents: "请确认是否清空消息，清空后将不可回恢复，请谨慎操作",
  //                       confirmBtnTitle: "确定",
  //                       confirmCallback: () {
  //                         context.read<AiChatProviders>().cleanUpAllChats();
  //                       },
  //                     );
  //                   },
  //                 );
  //               },
  //             ),
  //           ),
  //           SizedBox(width: 5.w),
  //           SizedBox(
  //             height: 25.h,
  //             child: ByWidgetsUtil.btnWithIcon(
  //               title: "新话题",
  //               padding: EdgeInsets.symmetric(horizontal: 10.w),
  //               bgColor: ByColorUtil.WhiteColor,
  //               borderRadius: 50,
  //               iconH: 12,
  //               iconW: 12,
  //               contentGap: 5,
  //               fontSize: 11.sp,
  //               fontWeight: FontWeight.normal,
  //               textColor: ByColorUtil.TabTextColorSelected,
  //               boxDecoration: BoxDecoration(
  //                 border: Border.all(color: ByColorUtil.TabTextColorSelected),
  //                 borderRadius: BorderRadius.circular(50),
  //                 color: Colors.white,
  //               ),
  //               iconPath: "assets/ai/aiduihua_refresh.png",
  //               onClick: () {
  //                 showDialog(
  //                   context: context,
  //                   builder: (c) {
  //                     return CommonDialog(
  //                       reverse: false,
  //                       maxLine: 10,
  //                       contents: "请确认是否刷新话题，刷新后将开启新的话题",
  //                       confirmBtnTitle: "确定",
  //                       confirmCallback: () {
  //                         final provider = context.read<AiChatProviders>();
  //                         provider.canSend = true;
  //                         provider.sendMessageContentDatas(
  //                           "刷新",
  //                           callback: () {
  //                             _closeChannel();

  //                             context
  //                                 .read<AiChatProviders>()
  //                                 .focusNode
  //                                 .unfocus();
  //                             _connectWbSocket();
  //                           },
  //                         );
  //                       },
  //                     );
  //                   },
  //                 );
  //               },
  //             ),
  //           ),
  //           SizedBox(width: 12.w),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
