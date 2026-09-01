import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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
  VideoPlayerController? _serverPlayer;
  VideoPlayerController? _localController;
  @override
  void initState() {
    super.initState();

    /// 初始化远程视频控制器（统一使用 video_player，鸿蒙兼容）
    if (widget.url.startsWith("http")) {
      _serverPlayer = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      _serverPlayer!.initialize().then(
        (_) {
          if (!_serverPlayer!.value.isInitialized) {
            return;
          }
          _serverPlayer!.setVolume(0).then(
            (_) {
              _serverPlayer!.setLooping(true).then((_) {
                if (mounted) {
                  setState(() {});
                  _serverPlayer!.play();
                }
              });
            },
          );
        },
      ).catchError((error) {
        if (mounted) {
          setState(() {});
        }
      });
    } else {
      _localController = VideoPlayerController.asset(widget.url)
        ..initialize()
        ..setVolume(0).then(
          (_) {
            _localController!.setLooping(true).then((_) {
              setState(() {});
              _localController?.play();
            });
          },
        );
    }
  }

  @override
  void dispose() {
    if (_serverPlayer != null && _serverPlayer!.value.isInitialized) {
      _serverPlayer!.dispose();
    }
    _localController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url.startsWith("http")) {
      final isPlayerInitialized = _serverPlayer?.value.isInitialized ?? false;

      return Container(
        child: isPlayerInitialized
            ? AspectRatio(
                aspectRatio: _serverPlayer!.value.aspectRatio,
                child: VideoPlayer(_serverPlayer!),
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
