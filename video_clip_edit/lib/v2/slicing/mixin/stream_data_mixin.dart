import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:video_clip_edit/core/network/result.dart';
import 'package:video_clip_edit/core/util/extension.dart';
import 'package:video_clip_edit/utils/http/intercept.dart';
import 'package:video_clip_edit/utils/consts/const_keys.dart';
import 'package:video_clip_edit/utils/comon/by_storage_utils.dart';
import 'package:video_clip_edit/utils/comon/by_encrypt_utils.dart';

mixin StreamDataMixin {
  Future<Stream<String>> getStream({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    final controller = StreamController<String>();
    final uri = Uri.parse(url);

    final request = http.Request('POST', uri);
    _updateHeaders(request);

    if (body != null && body.isNotEmpty) {
      request.bodyFields = body.convertMap();
    }
    request.send().then((http.StreamedResponse response) async {
      // 处理响应
      if (response.statusCode == 200) {
        await for (String chunk in response.stream.transform(utf8.decoder)) {
          controller.add(chunk);
        }
        controller.close();
      } else {
        controller.addError(
            APIError(response.reasonPhrase ?? '', response.statusCode));
      }
    });

    return controller.stream;
  }

  void _updateHeaders(http.Request request) {
    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    request.headers[ConstKeys.kToken] = getToken();
    request.headers[ConstKeys.kClientType] = "strong";
    request.headers[ConstKeys.kTimeStamp] = timestamp.toString();
    request.headers[ConstKeys.kAppFramework] = 'flutter';
    request.headers[ConstKeys.kAppVersion] =
        ByStorageUtils.getString(ConstKeys.kAppVersion) ?? "5.0.0";
    request.headers[ConstKeys.kSign] = _getSign(timestamp);
  }

  String _getSign(int timestamp) {
    final token = ByAESStorageUtils.getString(ConstKeys.kToken) ?? "";
    final sign = ByEncryptUtils.md5String("$timestamp$token");
    return sign;
  }
}
