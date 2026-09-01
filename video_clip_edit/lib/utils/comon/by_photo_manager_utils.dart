import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

class ByPhotoManagerUtils {
  static Future<bool> checkFileRight() async {
    bool value = false;
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      value = true;
    } else {}
    byDebugPrint("是否拥有权限：$value");
    return value;
  }

  static Future<void> downFile(String url) async {
    try {
      // 获取临时目录
      Directory tempDir = await getTemporaryDirectory();
      String thumbFileName =
          "${DateTime.now().millisecondsSinceEpoch}_${url.split(Platform.pathSeparator).last}";
      String thumbPath = "${tempDir.path}/$thumbFileName";
      bool thumbnailExists = await File(thumbPath).exists();
      if (!thumbnailExists) {
        byDebugPrint(thumbnailExists, tag: "下载目录：");

        /// 创建Dio实例
        Dio dio = Dio();

        EasyLoading.show(status: "视频下载中...");
        // 下载视频
        await dio.download(
          url,
          thumbPath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = (received / total) * 100;
              byDebugPrint("${progress.toStringAsFixed(0)}%", tag: "下载进度:");
            }
          },
        );
        byDebugPrint("开始保存");

        ImageGallerySaver.saveFile(thumbPath)
            .then((value) {
              byDebugPrint("保存成功");
            })
            .onError((msg, code) {
              byDebugPrint("保存失败");
            });
      }
    } catch (e) {
      EasyLoading.dismiss();
      byDebugPrint("$e", tag: "文件下载失败:");
      BotToast.showText(text: "视频下载失败,请稍后重试");
    }
  }
}
