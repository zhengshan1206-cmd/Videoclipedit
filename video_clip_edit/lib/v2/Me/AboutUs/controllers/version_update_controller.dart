

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../utils/comon/by_common_utils.dart';


class VersionUpdateController extends GetxController {

  final ApkDownloadService _downloadService = ApkDownloadService();
  var downloadProgress = 0.0.obs;
  var isDownloading = false.obs;
  var statusText = '立即更新'.obs;
  final String url  = 'http://example.com/app.apk';

  void startDownloadApp(String url) async {

    //iOS平台直接跳转appStore
    if (Platform.isIOS){
      // 跳转到外部链接页面
      ByCommonUtils.launchWebURL(url);
      return;
    }
    isDownloading.value = true;
    statusText.value = '开始下载...';

    try {
      await _downloadService.downloadApk(
        url,
        onProgress: (progress) {
          downloadProgress.value = progress;
          statusText.value = '正在下载... ${(progress * 100).toStringAsFixed(1)}%';
        },
      );
      statusText.value = '下载完成，正在安装...';
    } catch (e) {
      isDownloading.value = false;
      statusText.value = '下载失败: $e';
    }
  }
}



class ApkDownloadService {
  final Dio _dio = Dio();
  String? _savePath;

  // 下载APK文件
  Future<void> downloadApk(String url, {Function(double progress)? onProgress}) async {
    // 请求存储权限（Android）
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('需要存储权限才能下载文件');
      }
    }

    // 创建保存路径
    await _prepareSavePath();

    try {
      await _dio.download(
        url,
        _savePath,
        onReceiveProgress: (count, total) {
          if (onProgress != null) {
            final progress = count / total;
            onProgress(progress);
          }
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
        ),
      );

      print('下载完成: $_savePath');
      // 下载完成后安装APK
      await _installApk();
    } catch (e) {
      print('下载失败: $e');
      rethrow;
    }
  }

  // 准备保存路径
  Future<void> _prepareSavePath() async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      throw Exception('无法获取存储目录');
    }
    
    // 构建保存路径（例如：/storage/emulated/0/Download/app-release.apk）
    _savePath = '${directory.path}/app-release.apk';
    print('保存路径: $_savePath');
  }

  // 安装APK（Android）
  Future<void> _installApk() async {
    if (!Platform.isAndroid) return;
    
    // 检查文件是否存在
    final file = File(_savePath!);
    if (!await file.exists()) {
      throw Exception('APK文件不存在');
    }

    // 打开文件以触发安装
    // final result = await OpenFile.open(_savePath);
    // if (result.type != ResultType.done) {
    //   throw Exception('无法打开安装文件: ${result.message}');
    // }
  }
}