import 'package:flutter/services.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';

import 'channel_api.dart';

class BaseChannel {
  late var channel;

  factory BaseChannel() => _singleton;

  BaseChannel._() {
    channel = const MethodChannel(ChannelApi.channelIdentifier);
  }

  static final BaseChannel _singleton = BaseChannel._();

  static BaseChannel get instance => BaseChannel();

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
