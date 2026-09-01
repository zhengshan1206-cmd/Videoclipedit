//  base_web_view.dart
//
//  Created by iotjin on 2020/03/27.
//  description:  WebView基类

// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_clip_edit/utils/channel/channel_operate.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_package_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class BaseWebView extends StatefulWidget {
  const BaseWebView({
    super.key,
    required this.title,
    required this.url,
    this.direction,
  });

  final String title;
  final String url;
  final String? direction;

  @override
  State<BaseWebView> createState() => _BaseWebViewState();
}

class _BaseWebViewState extends State<BaseWebView> {
  late final WebViewController _controller;
  int _progressValue = 0;

  @override
  void initState() {
    super.initState();

    _init();
  }

  _init() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('FlutterJs',
          onMessageReceived: (JavaScriptMessage message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.message)),
        );
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (ByPackageUtils.isOhos &&
                request.url.contains('https://work.weixin.qq.com/')) {
              ChannelOperate.bindSheetService();
              return NavigationDecision.prevent;
            }
            if (request.url.startsWith('https://') ||
                request.url.startsWith('http://')) {
              return NavigationDecision.navigate;
            }
            launchUrl(
              Uri.parse(request.url),
              webViewConfiguration: const WebViewConfiguration(
                headers: {
                  'harmony_browser_page': 'pages/LaunchInAppPage',
                },
              ),
            );
            _controller.goBack();
            return NavigationDecision.prevent;
          },
          onProgress: (int progress) {
            if (!mounted) {
              return;
            }
            setState(() {
              _progressValue = progress;
            });
          },
        ),
      );
    //安卓选择文件
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      final AndroidWebViewController androidController =
          _controller.platform as AndroidWebViewController;
      androidController.setOnShowFileSelector((FileSelectorParams params) {
        final completer = Completer<List<String>>();
        int maxCount = 1;
        if (params.mode == FileSelectorMode.openMultiple) {
          //多选
          maxCount = 9;
        }
        RequestType? type;
        if (params.acceptTypes.any((type) => type == 'image/*')) {
          //图片
          type = RequestType.image;
        } else if (params.acceptTypes.any((type) => type == 'video/*')) {
          //视频
          type = RequestType.video;
        } else {
          //所有文件
          type = RequestType.common;
        }
        ByCommonUtils.pickAssets(context, type: type, maxCount: maxCount,
            onSelectedCallback: (assets) async {
          List<String> list = [];
          if (assets.isNotEmpty) {
            for (int i = 0; i < assets.length; i++) {
              AssetEntity asset = assets[i];
              if (await asset.exists) {
                var file = await asset.file;
                var path = file?.uri.toString();
                if (path != null) list.add(path);
              }
            }
          }
          if (!completer.isCompleted) {
            completer.complete(list);
          }
        }, onCancelCallback: () {
          if (!completer.isCompleted) {
            completer.complete([]);
          }
        });
        return completer.future;
      });
    }
    _controller.loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  _body() {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (widget.direction != null) {
          await _controller.runJavaScript("document.body.innerHTML = ''");
          await _controller.loadRequest(Uri.parse(widget.direction!));
        }
        byDebugPrint("--onPopInvoked:$didPop");
        final bool canGoBack = await _controller.canGoBack();
        if (canGoBack) {
          // 网页可以返回时，优先返回上一页
          await _controller.goBack();
          // _controller.
          return;
        }
        // 不管canPop是否为true，onPopInvoked都会调用
        if (didPop) return;

        if (!context.mounted) return;

        ByNavRouterUtils.goBack(context);
      },
      child: Scaffold(
        appBar: ByWidgetsUtil.appBar(
            context: context,
            title: widget.title,
            popScop: false,
            onPop: () async {
              if (widget.direction != null) {
                await _controller.runJavaScript("document.body.innerHTML = ''");
                await _controller.loadRequest(Uri.parse(widget.direction!));
              }
              final bool canGoBack = await _controller.canGoBack();
              if (canGoBack) {
                // 网页可以返回时，优先返回上一页
                await _controller.goBack();
                // _controller.
                return;
              }

              ByNavRouterUtils.goBack(context);
            },
            actions: [
              GestureDetector(
                onTap: () {
                  _showActionSheet();
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 12.w,
                  ),
                  child: Image.asset(
                    "assets/home/icon_more.png",
                    width: 10,
                    height: 10,
                  ),
                ),
              )
            ]),
        body: Stack(
          children: [
            WebViewWidget(
              controller: _controller,
            ),
            if (_progressValue != 100)
              LinearProgressIndicator(
                value: _progressValue / 100,
                backgroundColor: Colors.transparent,
                minHeight: 2,
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  /// 弹出操作菜单
  void _showActionSheet() {
    showAdaptiveActionSheet(
      context: context,
      title: ByWidgetsUtil.commonText(
        text: "请选择操作",
        fontSize: 14.sp,
        textColor: ByColorUtil.CommonTextColor.withOpacity(0.8),
      ),
      androidBorderRadius: 15.w,
      actions: <BottomSheetAction>[
        BottomSheetAction(
          title: ByWidgetsUtil.commonText(
            text: '复制链接',
            fontSize: 15.sp,
            textColor: ByColorUtil.CommonTextColor,
          ),
          onPressed: (context) {
            Clipboard.setData(
              ClipboardData(
                text: widget.url,
              ),
            );
            BotToast.showText(text: "链接复制成功");
            Navigator.of(context).pop();
          },
        ),
        BottomSheetAction(
          title: ByWidgetsUtil.commonText(
            text: '在外部浏览器中打开',
            fontSize: 15.sp,
            textColor: ByColorUtil.CommonTextColor,
          ),
          onPressed: (context) async {
            final navigator = Navigator.of(context);
            final Uri uri = Uri.parse(widget.url);
            await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
            navigator.pop();
          },
        ),
      ],
      cancelAction: CancelAction(
        title: ByWidgetsUtil.commonText(
          text: '取消',
          fontSize: 15.sp,
          textColor: ByColorUtil.TabTextColorMarquee,
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (widget.direction != null) {
      _controller.runJavaScript("document.body.innerHTML = ''");
      _controller.loadRequest(Uri.parse(widget.direction!));
    }
    super.dispose();
  }
}
