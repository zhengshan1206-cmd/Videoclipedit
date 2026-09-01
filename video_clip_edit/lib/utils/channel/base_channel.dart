import 'package:flutter/services.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';

import 'channel_api.dart';

class BaseChannel {
  late var channel;
  Function(dynamic)? _huaweiLoginCallback;

  factory BaseChannel() => _singleton;

  BaseChannel._() {
    channel = const MethodChannel(ChannelApi.channelIdentifier);
    _setupMethodCallHandler();
  }

  static final BaseChannel _singleton = BaseChannel._();

  static BaseChannel get instance => BaseChannel();

  void setHuaweiLoginCallback(Function(dynamic) callback) {
    _huaweiLoginCallback = callback;
  }

  void removeHuaweiLoginCallback() {
    _huaweiLoginCallback = null;
  }

  void _setupMethodCallHandler() {
    channel.setMethodCallHandler((call) async {
      byDebugPrint(
        "Received method call: ${call.method} with arguments: ${call.arguments}",
        tag: "<><><><><><><>BaseChannel<><><><><><><>",
      );
      if (call.method == ChannelApi.onHuaweiLoginCode &&
          _huaweiLoginCallback != null) {
        _huaweiLoginCallback!(call.arguments);
      }
    });
  }

  Future<dynamic> callNativeMethod(String method, {dynamic params}) async {
    try {
      final result = await channel.invokeMethod(
        method,
        params,
      );
      byDebugPrint(
        "${result ?? "null"}<>${method}<>${params ?? "null"}",
        tag: "<><><><><><><>BaseChannel<><><><><><><>",
      );

      return result != null
          ? result["code"] == ChannelApi.channelSuccess
              ? result["data"]
              : Future.error(result["msg"] ??= "")
          : result;
    } on Exception catch (e) {
      return Future.error(e);
    }
  }
}
