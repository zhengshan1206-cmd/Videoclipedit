import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:video_clip_edit/flavors/build_config.dart';

Logger get DefaultLogger => BuildConfig.instance.config.logger;

void BYDebugPrint(
  Object? object, {
  bool needSplit = false,
}) {
  if (kDebugMode) {
    final content = object.toString();
    if (needSplit) {
      DefaultLogger.d(content);
    } else {
      print(content);
    }
  }
}
