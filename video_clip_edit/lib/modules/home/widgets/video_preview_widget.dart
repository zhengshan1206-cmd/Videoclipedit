import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';

class VideoPreviewWidget extends StatefulWidget {
  final String url;
  const VideoPreviewWidget({
    super.key,
    required this.url,
  });

  @override
  State<VideoPreviewWidget> createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<VideoPreviewWidget> {
  CachedVideoPlayerPlus? _serverPlayer;
  VideoPlayerController? _localController;
  @override
  void initState() {
    super.initState();

    /// 初始化远程视频控制器
    if (widget.url.startsWith("http")) {
      _serverPlayer = CachedVideoPlayerPlus.networkUrl(
        Uri.parse(widget.url),
        invalidateCacheIfOlderThan: const Duration(minutes: 10),
      );
      _serverPlayer!.initialize().then(
        (_) {
          // 确保初始化成功后再访问 controller
          if (!_serverPlayer!.isInitialized) {
            return;
          }

          _serverPlayer!.controller.setVolume(0).then(
            (_) {
              _serverPlayer!.controller.setLooping(true).then((_) {
                if (mounted) {
                  setState(() {});
                  // 自动播放
                  _serverPlayer!.controller.play();
                }
              });
            },
          );
        },
      ).catchError((error) {
        // 初始化失败时的错误处理
        // 错误已静默处理，避免影响用户体验
        if (mounted) {
          setState(() {});
        }
      });
    } else {
      // 初始化视频控制器
      _localController = VideoPlayerController.asset(widget.url)
        ..initialize()
        ..setVolume(0).then(
          (_) {
            _localController!.setLooping(true).then((_) {
              setState(() {});
              // 自动播放
              _localController?.play();
            });
          },
        );
    }
  }

  @override
  void dispose() {
    // 确保 player 已初始化才能访问 controller
    if (_serverPlayer != null && _serverPlayer!.isInitialized) {
      _serverPlayer!.controller.dispose();
    }
    _localController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url.startsWith("http")) {
      // 安全地检查初始化状态
      final isPlayerInitialized = _serverPlayer?.isInitialized ?? false;
      bool isControllerInitialized = false;
      if (isPlayerInitialized) {
        try {
          isControllerInitialized =
              _serverPlayer!.controller.value.isInitialized;
        } catch (e) {
          // 如果访问 controller 失败，说明未完全初始化
          isControllerInitialized = false;
        }
      }

      return Container(
        child: (isPlayerInitialized && isControllerInitialized)
            ? AspectRatio(
                aspectRatio: _serverPlayer!.controller.value.aspectRatio,
                child: VideoPlayer(_serverPlayer!.controller),
              )
            : const CircularProgressIndicator.adaptive(),
      );
    }

    return Container(
      child: _localController?.value.isInitialized ?? false
          ? AspectRatio(
              aspectRatio: _localController!.value.aspectRatio,
              child: VideoPlayer(_localController!),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
