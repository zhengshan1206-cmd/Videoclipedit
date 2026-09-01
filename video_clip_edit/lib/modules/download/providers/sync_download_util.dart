import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_download_util.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class DownloadManager {
  final Dio _dio = Dio();
  final CancelToken _cancelToken = CancelToken();

  /// 下载单个视频
  Future<void> downloadVideo(
    String url,
    String savePath,
    void Function(double) onProgress, {
        void Function()? onSuccess,
        void Function(Object error)? onError,
    }
  ) async {
    try {
      await _dio.download(
        url,
        savePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );
      onSuccess?.call();
    } on DioException catch (e) {
      onError?.call(e);
      if (CancelToken.isCancel(e)) {
        BotToast.showText(text: '下载已取消');
      } else {
        byDebugPrint('下载失败: $e');
      }
    }
  }

  /// 按顺序下载多个视频
  Future<void> downloadMultipleVideos(
    List<String> urls,
    void Function(int, double, String) onProgress, {
    bool save = true,
  }) async {
    for (int i = 0; i < urls.length; i++) {
      if (_cancelToken.isCancelled) break; // 如果取消了任务，停止下载
      final directory = await getApplicationCacheDirectory();
      final url = urls[i];
      final fileName = url.split(Platform.pathSeparator).last;
      final filePath = "${directory.path}/videos/${fileName}";
      await downloadVideo(
        urls[i],
        filePath,
        (progress) {
          onProgress(i + 1, progress, filePath);
          if (progress >= 1) {
            byDebugPrint(filePath, tag: "下载路径:");
            if (save) {
              ByDownloadUtil.saveVideo2Album(
                filePath,
                isToast: false,
              );
            }
          }
        },
      );
    }
  }

  /// 按顺序下载多个视频
  Future<void> downloadMultipleImages(
    List<String> urls,
    void Function(int, double) onProgress,
  ) async {
    for (int i = 0; i < urls.length; i++) {
      if (_cancelToken.isCancelled) break; // 如果取消了任务，停止下载
      final directory = await getApplicationCacheDirectory();
      final url = urls[i];
      final fileName = url.split(Platform.pathSeparator).last;
      final filePath = "${directory.path}/imgs/${fileName}";
      await downloadVideo(
        urls[i],
        filePath,
        (progress) {
          onProgress(i + 1, progress);
          if (progress >= 1) {
            byDebugPrint(filePath, tag: "下载路径:");
            final file = File(filePath);
            PhotoManager.editor.saveImageWithPath(file.path);
          }
        },
      );
    }
  }

  /// 按顺序下载多个文件
  Future<void> downloadMultipleFiles(
    List<String> urls,
    void Function(int, double) onProgress, {
    void Function(int, String)? onSuccess,
  }) async {
    for (int i = 0; i < urls.length; i++) {
      if (_cancelToken.isCancelled) break; // 如果取消了任务，停止下载
      final directory = await getApplicationCacheDirectory();
      final url = urls[i];
      final fileName = url.split(Platform.pathSeparator).last;
      final filePath = "${directory.path}/files/${fileName}";
      await downloadVideo(
        urls[i],
        filePath,
        (progress) {
          onProgress(i + 1, progress);
          byDebugPrint(progress, tag: "下载progress:");
        },
        onSuccess: () {
          byDebugPrint(filePath, tag: "下载路径:");
          onSuccess?.call(i, filePath);
        }
      );
    }
  }

  /// 取消所有下载任务
  void cancelDownloads() {
    _cancelToken.cancel();
  }
}
