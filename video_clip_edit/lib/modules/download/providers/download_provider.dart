import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_download_util.dart';
import 'package:video_clip_edit/modules/home/beans/cloud_video_bean.dart';
import 'package:video_clip_edit/modules/home/recreate/beans/commentary_item_bean.dart';

class DownloadProvider extends BaseProvider {
  /// 当前下载进度
  double progress = 0;
  updateProgress(double p) {
    progress = p;
    notifyListeners();
  }

  /// 存放文件的下载进度
  Map<String, double> progresses = {};

  /// 存放文件取消下载的CancelToken
  Map<String, CancelToken> downloadTokens = {};

  /// 下载多个视频
  Future<List<String?>> downloadVidoes(
    List<Detail> beans, {
    bool showLoading = true,
  }) async {
    final List<Completer<String?>> completers = [];
    for (var video in beans) {
      Completer<String?> completer = Completer<String?>();
      final filePath = video.videoUrl.split(Platform.pathSeparator).last;

      CancelToken cancelToken = CancelToken();
      downloadTokens[video.videoUrl] = cancelToken;
      progresses[video.videoUrl] = 0;

      ByDownloadUtil.downloadVideo(
        video.videoUrl,
        filePath,
        cancelToken: cancelToken,
        showLoading: showLoading,
        onSuccess: (filePath) {
          completer.complete(filePath);
        },
        onProgress: (progress) {
          progresses[video.videoUrl] = progress;

          /// 计算总体进度
          _calculateProgress(progresses);
        },
        onFailed: () {
          progresses.remove(video.videoUrl);

          /// 计算总体进度
          _calculateProgress(progresses);
          completer.completeError("${video.videoUrl}下载失败");
        },
      );
      completers.add(completer);
    }
    final futures = completers.map((e) => e.future).toList();
    return await Future.wait(futures);
  }

  /// 下载多个视频
  Future<List<String?>> downloadVidoesWithUrlsWithProgressesByEach(
    List<String> urls, {
    bool showLoading = true,
  }) async {
    final List<Completer<String?>> completers = [];
    for (var videoUrl in urls) {
      Completer<String?> completer = Completer<String?>();
      final filePath = videoUrl.split(Platform.pathSeparator).last;

      CancelToken cancelToken = CancelToken();
      downloadTokens[videoUrl] = cancelToken;
      progresses[videoUrl] = 0;

      ByDownloadUtil.downloadVideo(
        videoUrl,
        filePath,
        cancelToken: cancelToken,
        showLoading: showLoading,
        onSuccess: (filePath) {
          completer.complete(filePath);
        },
        onProgress: (progress) {
          progresses[videoUrl] = progress;

          /// 计算总体进度
          _calculateProgress(progresses);
        },
        onFailed: () {
          progresses.remove(videoUrl);

          /// 计算总体进度
          _calculateProgress(progresses);
          completer.completeError("${videoUrl}下载失败");
        },
      );
      completers.add(completer);
    }
    final futures = completers.map((e) => e.future).toList();
    return await Future.wait(futures);
  }

  Future<List<String?>> downloadFiles(
    List<String> urls, {
    List<CommentaryItemBean>? commentaryItemBeans,
    bool showLoading = true,
  }) async {
    final List<Completer<String?>> completers = [];

    for (var url in urls) {
      Completer<String?> completer = Completer<String?>();
      final fileName = url.split(Platform.pathSeparator).last;

      CancelToken cancelToken = CancelToken();
      downloadTokens[url] = cancelToken;
      progresses[url] = 0;

      // ignore: unused_local_variable
      String tId = "";
      ByDownloadUtil.downloadAudio(
        url,
        fileName,
        cancelToken: cancelToken,
        showLoading: showLoading,
        onSuccess: (filePath) async {
          if (commentaryItemBeans != null) {
            commentaryItemBeans.firstWhere((e) {
              if (e.audioUrl == url) {
                tId = e.taskId;
              }
              return e.audioUrl == url;
            }).audioLocalPath = filePath;
          }
          completer.complete(filePath);
        },
        onProgress: (progress) {
          progresses[url] = progress;

          /// 计算总体进度
          _calculateProgress(progresses);
        },
        onFailed: () {
          progresses.remove(url);

          /// 计算总体进度
          _calculateProgress(progresses);
          completer.completeError("${url}下载失败");
        },
      );
      completers.add(completer);
    }
    final futures = completers.map((e) => e.future).toList();
    return await Future.wait(futures);
  }

  downloadVideo(
    String videoUrl, {
    String? fileName,
    bool showLoading = true,
    bool saveToAlbum = true,
    bool deleteWhenFinished = true,
    void Function(String)? onSuccess,
  }) {
    final components = videoUrl.split(Platform.pathSeparator);
    final videoName = fileName ?? components.last;

    CancelToken cancelToken = CancelToken();
    downloadTokens[videoUrl] = cancelToken;
    progresses[videoUrl] = 0;

    ByDownloadUtil.downloadVideo(
      videoUrl,
      "$videoName.mp4",
      cancelToken: cancelToken,
      saveToAlbum: saveToAlbum,
      deleteWhenFinished: deleteWhenFinished,
      showLoading: showLoading,
      onProgress: (progress) {
        // updateProgress(progress);

        progresses[videoUrl] = progress;

        /// 计算总体进度
        _calculateProgress(progresses);
      },
      onSuccess: (filePath) {
        onSuccess?.call(filePath);
      },
    );
  }

  /// 计算总体进度
  _calculateProgress(Map<String, double> progresses) {
    double result = 0;
    final entries = progresses.entries;

    for (var entry in entries) {
      final progress = entry.value;
      result += progress / entries.length;
    }

    /// 通知外界更新总进度
    updateProgress(result);
  }

  // 取消特定文件的下载
  void cancelDownload(String url) {
    if (downloadTokens.containsKey(url)) {
      downloadTokens[url]?.cancel('下载被取消: $url');
    } else {
      byDebugPrint('找不到该文件的下载任务: $url');
    }
  }

  // 取消所有下载任务
  void cancelAllDownloads() {
    downloadTokens.forEach((url, token) {
      token.cancel('下载被取消: $url');
    });

    /// 清空 token 列表
    downloadTokens.clear();
  }
}
