import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';

class BaseProvider extends ChangeNotifier {
  bool _mounted = true;
  bool get isMounted => _mounted;

  @override
  void dispose() {
    /// 设置为未挂载
    _mounted = false;
    super.dispose();
  }

  @override
  void notifyListeners() {
    /// 仅在未销毁时通知监听者
    if (_mounted == true) {
      super.notifyListeners();
    }
  }

  String tuixiaoguoUrl = "";

  int needDetail = 1;

  /// 获取推小果URL
  loadTuixiaoguoUrl({
    void Function(String)? onSuccess,
  }) {
    HttpUtils.get(
      APIs.tuixiaoguoUrl,
      {
        "need_detail": needDetail,
        "page": 1,
        "pageSize": 10,
      },
      success: (json) {
        var data = json["data"];
        if (data != null && data["jump_url"] != null) {
          tuixiaoguoUrl = data["jump_url"];
          onSuccess?.call(tuixiaoguoUrl);
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 检查DNS
  dnsCheck({
    required String url,
    required void Function() onSuccess,
  }) {
    HttpUtils.post(
      APIs.dnsCheck,
      {
        "url": url,
      },
      success: (json) {
        var data = json["data"];
        byDebugPrint(data);
        onSuccess();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }
}
