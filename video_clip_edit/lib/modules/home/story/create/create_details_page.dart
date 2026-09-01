import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_clip_edit/utils/comon/by_permission_utils.dart';
import 'package:video_clip_edit/utils/http/intercept.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/widgets/ai_files_downoad_dialog.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/common/widget/common_dialog.dart';
import 'package:video_clip_edit/modules/home/providers/stroy_create_provider.dart';
import 'package:video_clip_edit/modules/home/story/create/widgets/edit_dailog.dart';
import 'package:video_clip_edit/modules/purchase/widgets/dailog_bonus_lowest_price.dart';

enum CreativeType { normal, continuation, rewrite, abbreviation, extension }

class CreateDetailsPage extends StatefulWidget {
  final bool? showBottomFunctions;
  final bool? isCreator;
  final bool isMany;
  final bool fromAi;
  final StroyCreateProvider? provider;
  // final String question;

  const CreateDetailsPage({
    super.key,
    this.showBottomFunctions = true,
    this.isCreator,
    this.isMany = false,
    required this.fromAi,
    this.provider,
    // required this.question,
  });

  @override
  State<CreateDetailsPage> createState() => _CreateDetailsPageState();
}

class _CreateDetailsPageState extends State<CreateDetailsPage> {
  WebSocketChannel? channel;
  final ScrollController controller = ScrollController();

  bool inCreation = false;

  bool popConfirmed = false;

  bool canShowFunctionBtns = false;

  CreativeType creativeType = CreativeType.normal;

  @override
  void initState() {
    super.initState();

    /// 连接Socket
    StroyCreateProvider createProvider = _connectWbSocket();
    createProvider.aiCreatContents = "";
    createProvider.retryTimes = 0;

    /// 监听Socket消息
    listenSocketMsgs(createProvider);
  }

  /// 监听Socket消息
  void listenSocketMsgs(StroyCreateProvider createProvider) {
    channel?.stream.listen(
      (message) {
        /// 将接收到的消息添加到列表
        byDebugPrint(message, tag: "收到Socket消息:");
        setInCreation(true);
        if (message == SocketMsgEnd) {
          createProvider.updateaAiCreateFinshed(true);
          controller.jumpTo(controller.position.maxScrollExtent);
          return;
        }
        createProvider.updateAiCreatContents(message);
        if (createProvider.isScrollByUser) return;
        controller.jumpTo(controller.position.maxScrollExtent);
      },
      onDone: () {
        byDebugPrint("Socket连接关闭:");
        byDebugPrint("aiCreateFinshed:${createProvider.aiCreateFinshed}");
        if (!createProvider.aiCreateFinshed) {
          setInCreation(false);
          _reconnectToWebSocket(createProvider);
        } else {
          /// 成功
          setInCreation(false);
          // setCreateType(CreativeType.normal);
        }
      },
      onError: (err) {
        _reconnectToWebSocket(createProvider);
        BotToast.showText(text: "服务器连接失败");
      },
    );
  }

  void _reconnectToWebSocket(StroyCreateProvider createProvider) {
    if (createProvider.retryTimes < MaxRetryTimes) {
      Future.delayed(
        const Duration(seconds: 3),
        () {
          if (mounted) {
            createProvider.retryTimes = createProvider.retryTimes + 1;
            byDebugPrint("_reconnectToWebSocket${createProvider.retryTimes}");
            _connectWbSocket();
          }
        },
      );
    }
  }

  /// 连接Socket
  StroyCreateProvider _connectWbSocket() {
    _closeChannel();

    final launchProvider = context.read<LaunchProvider>();
    final wsuri =
        launchProvider.launchInfo?.wsuri ?? 'wss://echo.websocket.org';

    final createProvider = context.read<StroyCreateProvider>();
    createProvider.updateHandleDisabledWithoutNotify(false);
    final questionID =
        Uri.encodeQueryComponent(createProvider.questionInfoBean?.token ?? "");
    final url =
        "$wsuri/answer?type=${(widget.isCreator == null) ? "general" : "creator"}&id=$questionID&token=${Uri.encodeQueryComponent(getToken())}";
    debugPrint("socketUrl:$url");

    /// 连接 WebSocket 服务
    channel = WebSocketChannel.connect(Uri.parse(url));
    return createProvider;
  }

  @override
  void dispose() {
    _closeChannel();
    super.dispose();
  }

  void _closeChannel() {
    channel?.sink.close();
    channel = null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (value) {
        if (value) return;
        _close(context);
      },
      child: Scaffold(
        appBar: ByWidgetsUtil.appBar(
          context: context,
          title: "创作详情",
          leaing: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              EasyLoading.dismiss();
              _close(context);
            },
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              child: Image.asset(
                "assets/home/icon_back.png",
                width: 16,
                height: 16,
              ),
            ),
          ),
        ),
        backgroundColor: ByColorUtil.WhiteColor,
        body: Column(
          children: [
            // Container(
            //   height: 5.h,
            //   color: const Color(0xFFF5F8F9),
            // ),
            _buildListView(context),

            /// 底部功能按钮
            if (widget.showBottomFunctions ?? true) _buildFunctionBtns(context),

            if (widget.fromAi) SizedBox(height: 10.h),
            if (widget.fromAi) _buildActions(context),

            /// 复制按钮
            _buildCopyBtn(context),
          ],
        ),
      ),
    );
  }

  _buildActions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      child: SizedBox(
        height: 36.h,
        child: Row(
          children: [
            Expanded(
              child: ByWidgetsUtil.btnWithIcon(
                title: "复制文案",
                borderRadius: 8.w,
                padding: EdgeInsets.zero,
                bgColor: const Color(0xFFF8FAFB),
                fontSize: 14.sp,
                textColor: ByColorUtil.CommonTextColor,
                iconPath: "assets/mine/score_icon_copy.png",
                onClick: () {
                  Clipboard.setData(
                    ClipboardData(text: widget.provider?.aiCreatContents ?? ""),
                  );
                  BotToast.showText(text: "复制成功");
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ByWidgetsUtil.btnWithIcon(
                title: "导出Word",
                borderRadius: 8.w,
                padding: EdgeInsets.zero,
                bgColor: const Color(0xFFF8FAFB),
                fontSize: 14.sp,
                textColor: ByColorUtil.CommonTextColor,
                iconPath: "assets/mine/score_icon_word.png",
                onClick: () {
                  widget.provider?.exportDoc(
                    ids: widget.provider?.questionInfoBean?.token ?? "",
                    type: "word",
                    onSuccess: (url) async {
                      if (inCreation) {
                        BotToast.showText(text: "内容正在生成中，请稍后");
                        return;
                      }
                      final status = await ByPermissionUtils.storage();
                      if (!status) return;
                      showDialog(
                        context: context,
                        builder: (c) {
                          return AiFilesDownoadDialog(
                            contents: "",
                            maxLine: 10,
                            cancelBtnTitle: "取消",
                            confirmBtnTitle: "确定",
                            confirmCallback: () {},
                            fileUrls: [url],
                            onSuccess: (index, filePath) async {
                              await Share.shareXFiles([XFile(filePath)],
                                  text: 'Word Document Shared');
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
            Expanded(
              child: ByWidgetsUtil.btnWithIcon(
                title: "导出TXT",
                borderRadius: 8.w,
                padding: EdgeInsets.zero,
                bgColor: const Color(0xFFF8FAFB),
                fontSize: 14.sp,
                textColor: ByColorUtil.CommonTextColor,
                iconPath: "assets/mine/score_icon_txt.png",
                onClick: () async {
                  if (inCreation) {
                    BotToast.showText(text: "内容正在生成中，请稍后");
                    return;
                  }
                  final directory = await getApplicationCacheDirectory();
                  final filePath =
                      "${directory.path}/files/file_${DateTime.now().millisecondsSinceEpoch}.txt";
                  // 创建文件并写入内容
                  File file = File(filePath);
                  await file.writeAsString(
                    "内容: ${widget.provider?.aiCreatContents ?? ""}\n\n\n",
                  );

                  await Share.shareXFiles([XFile(filePath)],
                      text: 'Txt Document Shared');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 开始缩写
  void _startAbbreviation(BuildContext context) {
    final provider = context.read<StroyCreateProvider>();
    provider.loadMessageID(
      ask: "",
      configId: "",
      parentId: provider.pid,
      opt: EditDailogType.abbreviation.typeKey,
      onSuccess: (infoBean) {
        bool needMoney = infoBean.isMoney == 1;
        if (needMoney) {
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
        provider.pid = infoBean.token;
        ByNavRouterUtils.pushReplacement(
          context,
          ChangeNotifierProvider.value(
            value: context.read<StroyCreateProvider>(),
            child: const CreateDetailsPage(
              showBottomFunctions: false,
              fromAi: true,
            ),
          ),
        );
      },
    );
  }

  Expanded _buildListView(BuildContext context) {
    return Expanded(
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: ListView(
            controller: controller,
            padding: EdgeInsets.zero,
            children: [
              /// 创作标题
              if (widget.isCreator ?? true) _buildTitle(context),

              /// AI生成的创作内容
              _buildAIContents(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 创作标题
  _buildTitle(BuildContext context) {
    return Offstage(
      offstage: context.read<StroyCreateProvider>().creatTitle.isEmpty,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 10.h,
        ),
        child: ByWidgetsUtil.commonContainer(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 13.h,
          ),
          bgColor: const Color(0xFF2E54FF).withOpacity(0.1),
          child: ByWidgetsUtil.commonText(
            text: context
                .select<StroyCreateProvider, String>((p) => p.creatTitle),
            textColor: ByColorUtil.TabTextColorSelected,
            fontSize: 14.sp,
            maxLines: 1000,
          ),
        ),
      ),
    );
  }

  /// AI生成的创作内容
  _buildAIContents(BuildContext context) {
    final aiCreatContents =
        context.select<StroyCreateProvider, String>((p) => p.aiCreatContents);
    final aiCreateFinshed =
        context.select<StroyCreateProvider, bool>((p) => p.aiCreateFinshed);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
      ),
      child: ByWidgetsUtil.commonContainer(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 13.h,
        ),
        bgColor: const Color(0xFFF5F8F9),
        child: ByWidgetsUtil.commonRichText(
          texts: [
            TextSpan(text: aiCreatContents),
            WidgetSpan(
              child: aiCreateFinshed
                  ? Container()
                  : CupertinoActivityIndicator(
                      color: ByColorUtil.CommonTextColor,
                      radius: 7.sp,
                    ),
            ),
          ],
          textColor: ByColorUtil.CommonTextColor,
          fontSize: 14.sp,
          // maxLines: 1000,
        ),
      ),
    );
  }

  _buildFunctionBtns(BuildContext context) {
    final icons = [
      "assets/home/icon_continue.png",
      "assets/home/icon_modify.png",
      "assets/home/icon_expand.png",
      "assets/home/icon_shrink.png"
    ];
    final titles = ["续写", "改写", "扩写", "缩写"];
    EditDailogType getType(String title) {
      return {
        "续写": EditDailogType.continuation,
        "改写": EditDailogType.modify,
        "扩写": EditDailogType.extension,
        "缩写": EditDailogType.abbreviation,
      }[title] as EditDailogType;
    }

    return inCreation || !canShowFunctionBtns
        ? Container()
        : Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 15.h,
            ),
            child: IgnorePointer(
              ignoring: context.select<StroyCreateProvider, bool>((p) {
                return !(p.aiCreateFinshed);
              }),
              child: Consumer<StroyCreateProvider>(
                builder: (c, p, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: icons.map((e) {
                      final idx = icons.indexOf(e);
                      final type = getType(titles[idx]);
                      BoxDecoration? boxDecoration;
                      Color color = const Color(0xFF2E54FF).withOpacity(0.1);
                      Color textColor = ByColorUtil.TabTextColorSelected;
                      if (type == EditDailogType.abbreviation &&
                          creativeType == CreativeType.abbreviation) {
                        textColor = const Color(0xff5B4BF7);
                        boxDecoration = BoxDecoration(
                          borderRadius: BorderRadius.circular(8.w),
                          color: color,
                          border: Border.all(color: textColor, width: 1),
                        );
                      }

                      return SizedBox(
                        height: 36.h,
                        child: ByWidgetsUtil.btnWithIcon(
                          title: titles[idx],
                          iconPath: e,
                          bgColor: color,
                          fontSize: 14.sp,
                          textColor: textColor,
                          boxDecoration: boxDecoration,
                          padding: EdgeInsets.only(
                            left: 10.w,
                            right: 18.w,
                          ),
                          onClick: () {
                            final type = getType(titles[idx]);
                            if (type == EditDailogType.abbreviation) {
                              /// 直接缩写
                              setCreateType(CreativeType.abbreviation);
                              return;
                            } else if (type == EditDailogType.extension) {
                              setCreateType(CreativeType.extension);
                            } else if (type == EditDailogType.continuation) {
                              setCreateType(CreativeType.continuation);
                            } else {
                              setCreateType(CreativeType.rewrite);
                            }

                            /// 弹出编辑框
                            showDialog(
                              context: context,
                              useSafeArea: false,
                              builder: (ctx) => ChangeNotifierProvider.value(
                                value: context.read<StroyCreateProvider>(),
                                child: EditDialog(
                                  type: type,
                                  isMany: widget.isMany,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          );
  }

  /// 复制按钮
  _buildCopyBtn(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        bottom: 10.h + ByScreenUtils.bottomSafeHeight,
      ),
      child: Consumer<StroyCreateProvider>(
        builder: (c, p, child) {
          return SizedBox(
            height: 50.h,
            child: ByWidgetsUtil.commonBtn(
              title: bottomStr(),
              borderRadius: 12.w,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              onClick: () {
                if (inCreation) return;

                if (creativeType == CreativeType.abbreviation) {
                  _startAbbreviation(context);
                  return;
                }

                final aiCreateContents = p.aiCreatContents;
                if (aiCreateContents.isNotEmpty) {
                  if (!inCreation) {
                    Clipboard.setData(
                      ClipboardData(text: aiCreateContents),
                    );
                    BotToast.showText(text: "复制成功");
                  } else {
                    BotToast.showText(text: "正在创作中...");
                  }
                } else {
                  BotToast.showText(text: "暂无创作内容");
                }
              },
            ),
          );
        },
      ),
    );
  }

  /// 处理屏幕滚动
  bool _handleScrollNotification(ScrollNotification notification) {
    StroyCreateProvider provider = context.read<StroyCreateProvider>();
    if (notification is ScrollStartNotification) {
      // 用户开始滑动
      provider.updateScrollByUser(true);
    } else if (notification is ScrollEndNotification) {
      // 用户停止滑动
      provider.updateScrollByUser(false);
    }
    return true;
  }

  String bottomStr() {
    var str = "复制";
    if (inCreation) {
      if (creativeType == CreativeType.normal) {
        str = "正在创作中...";
      } else if (creativeType == CreativeType.continuation) {
        str = "正在续写中...";
      } else if (creativeType == CreativeType.rewrite) {
        str = "正在改写中...";
      } else if (creativeType == CreativeType.extension) {
        str = "正在扩写中...";
      } else {
        str = "正在缩写中...";
      }
    } else {
      if (creativeType == CreativeType.abbreviation) {
        str = "开始缩写";
      }
    }
    return str;
  }

  setCreateType(CreativeType type) {
    if (mounted) {
      setState(() {
        creativeType = creativeType == type ? CreativeType.normal : type;
      });
    }

    debugPrint("当前状态::::::$creativeType");
  }

  setInCreation(bool state) {
    if (mounted) {
      setState(() {
        inCreation = state;
        canShowFunctionBtns = true;
      });
    }
  }

  _close(BuildContext context) async {
    final navigator = Navigator.of(context);

    if (popConfirmed) return;

    /// 没在创作 直接返回
    if (!inCreation) {
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   navigator.pop();
      // });
      popConfirmed = true;
      navigator.pop();
      return;
    }

    final result = await showDialog(
      context: context,
      builder: (c) {
        return const CommonDialog(
          contents: "正在创作中，您确定要退出吗？",
          cancelBtnTitle: "取消",
          confirmBtnTitle: "退出",
        );
      },
    );

    if (result != null && result == true) {
      popConfirmed = true;
      navigator.pop();
    }
  }
}
