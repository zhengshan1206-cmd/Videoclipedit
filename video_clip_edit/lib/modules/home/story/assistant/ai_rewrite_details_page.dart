import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/utils/http/intercept.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_settings_mixin.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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

enum CreativeType {
  normal,
  continuation,
  rewrite,
  abbreviation,
  extension,
}

class AiRewriteDetailsPage<T extends AiSettingsMixin> extends StatefulWidget {
  final bool? showBottomFunctions;
  final bool? isCreator;
  final bool isMany;
  final bool fromAi;
  final StroyCreateProvider? provider;
  // final String question;

  const AiRewriteDetailsPage({
    super.key,
    this.showBottomFunctions = true,
    this.isCreator,
    this.isMany = false,
    required this.fromAi,
    this.provider,
    // required this.question,
  });

  @override
  State<AiRewriteDetailsPage> createState() => _AiRewriteDetailsPageState<T>();
}

class _AiRewriteDetailsPageState<T extends AiSettingsMixin>
    extends State<AiRewriteDetailsPage<T>> {
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
          title: "AI改写",
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 12.w,
                right: 12.w,
                top: 7.h,
                bottom: 10.h,
              ),
              child: ByWidgetsUtil.commonTipsBar("内容由AI生成仅供参考，禁止利用功能从事违法活动。"),
            ),
            Padding(
              padding: EdgeInsets.only(left: 12.w),
              child: ByWidgetsUtil.commonText(
                text: "主要内容：",
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),

            _buildListView(context),

            /// 复制按钮
            _buildCopyBtn(context),
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
            child: const AiRewriteDetailsPage(
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
          child: ByWidgetsUtil.commonContainer(
            margin: EdgeInsets.symmetric(horizontal: 12.w),
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 13.h,
            ),
            bgColor: const Color(0xFFF5F8F9),
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
    return ByWidgetsUtil.commonRichText(
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

                final aiCreateContents = p.aiCreatContents;
                if (aiCreateContents.isNotEmpty) {
                  if (!inCreation) {
                    final providerT = context.read<T>();
                    providerT.updateDesc(aiCreateContents);
                    ByNavRouterUtils.goBack(context);
                    ByNavRouterUtils.goBack(context);
                  } else {
                    BotToast.showText(text: "正在改写中...");
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
    var str = "使用";
    if (inCreation) {
      if (creativeType == CreativeType.normal) {
        str = "改写中...";
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
