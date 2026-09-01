import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_download_util.dart';
import '../../../../utils/comon/by_common_events.dart';
import '../../../home/providers/by_audio_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String url;
  final String? coverUrl;
  final bool autoPlay;
  final int? offset;
  final bool userInteractive;
  final bool mute;
  final double? aspectRatio;
  const VideoPlayerWidget({
    super.key,
    required this.url,
    this.autoPlay = false,
    this.offset,
    this.userInteractive = true,
    this.coverUrl,
    this.mute = false,
    this.aspectRatio,
  });

  @override
  State<VideoPlayerWidget> createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _serverPlayer;
  VideoPlayerController? _localController;
  late bool isPlaying = widget.autoPlay;

  changeMuteStatus(bool status) {
    if (_serverPlayer != null && _serverPlayer!.value.isInitialized) {
      _serverPlayer!.setVolume(status ? 0.0 : 1.0);
    }
  }

  stopPlay() {
    _localController?.pause();
    if (_serverPlayer != null && _serverPlayer!.value.isInitialized) {
      _serverPlayer!.pause();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  resumePlay() {
    _localController?.play();
    if (_serverPlayer != null && _serverPlayer!.value.isInitialized) {
      _serverPlayer!.play();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  late StreamSubscription<PauseVideoEvent> streamSubscription;

  @override
  void initState() {
    super.initState();
    byDebugPrint("--------VideoPlayerWidgetState initState", tag: "播放的url:");

    if (widget.url.startsWith("http")) {
      _serverPlayer = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      _serverPlayer!.initialize().then(
        (_) async {
          if (!_serverPlayer!.value.isInitialized) {
            byDebugPrint("播放器初始化失败", tag: "VideoPlayerWidget");
            return;
          }

          _serverPlayer!.setVolume(widget.mute ? 0.0 : 1.0);

          await _serverPlayer!.seekTo(Duration(seconds: widget.offset ?? 0));
          byDebugPrint("${_serverPlayer!.value.isInitialized}",
              tag: "播放器初始化状态 in initState seekTo");
          _serverPlayer!.setLooping(true).then((_) {
            byDebugPrint("${_serverPlayer!.value.isInitialized}",
                tag: "播放器初始化状态 in initState setLooping");
            if (mounted) {
              setState(() {});
              widget.autoPlay
                  ? _serverPlayer!.play()
                  : _serverPlayer!.pause();
            }
          });
        },
      ).catchError((error) {
        byDebugPrint("播放器初始化错误: $error", tag: "VideoPlayerWidget");
        if (mounted) {
          setState(() {});
        }
      });
    } else {
      _localController = VideoPlayerController.file(File(widget.url))
        ..initialize().then(
          (_) {
            _localController!
                .setLooping(true)
                .then((_) async {
              if (mounted) {
                setState(() {});
                await _localController!
                    .seekTo(Duration(seconds: widget.offset ?? 0));
                widget.autoPlay
                    ? _localController?.play()
                    : _localController?.pause();
              }
            });
          },
        );
    }

    streamSubscription = eventBus.on<PauseVideoEvent>().listen((event) {
      if (_serverPlayer != null && _serverPlayer!.value.isInitialized) {
        _serverPlayer!.pause();
      }

      if (_localController != null) {
        _localController!.pause();
      }

      if (mounted) {
        setState(() {
          isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    byDebugPrint("--------VideoPlayerWidgetState dispose", tag: "播放的url:");
    if (_serverPlayer != null && _serverPlayer!.value.isInitialized) {
      _serverPlayer!.dispose();
    }
    _localController?.dispose();
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPlayerInitialized = _serverPlayer?.value.isInitialized ?? false;
    byDebugPrint("$isPlayerInitialized",
        tag: "播放器初始化状态 in build：");
    if (widget.url.startsWith("http")) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (widget.userInteractive == false) return;

          if (ByAudioPlayer.sharedInstance.isPlaying) {
            ByAudioPlayer.sharedInstance.pause();
          }

          if (_serverPlayer != null && _serverPlayer!.value.isInitialized) {
            if (isPlaying) {
              _serverPlayer!.pause();
            } else {
              _serverPlayer!.play();
            }
          }
          setState(() {
            isPlaying = !isPlaying;
          });
        },
        child: Stack(
          children: [
            Container(
              child: isPlayerInitialized
                  ? AspectRatio(
                      aspectRatio: widget.aspectRatio ??
                          _serverPlayer!.value.aspectRatio,
                      child: VideoPlayer(_serverPlayer!),
                    )
                  : widget.coverUrl != null
                      ? CachedNetworkImage(imageUrl: widget.coverUrl!)
                      : ByWidgetsUtil.activityIndicator(),
            ),
            Positioned.fill(
              child: Offstage(
                offstage: isPlaying,
                child: Center(
                  child: Image.asset(
                    "assets/ai/ai_cartoon_video_play.png",
                    width: 40.w,
                    height: 40.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (isPlaying) {
          _localController?.pause();
        } else {
          _localController?.play();
        }
        setState(() {
          isPlaying = !isPlaying;
        });
      },
      child: Stack(
        children: [
          Container(
            child: (_localController?.value.isInitialized ?? false)
                ? AspectRatio(
                    aspectRatio: _localController!.value.aspectRatio,
                    child: VideoPlayer(_localController!),
                  )
                : ByDownloadUtil.videoCover(widget.url),
          ),
          Positioned.fill(
            child: Offstage(
              offstage:
                  isPlaying || (_localController?.value.isInitialized == false),
              child: Center(
                child: Image.asset(
                  "assets/home/icon_audio_play.png",
                  width: 40.w,
                  height: 40.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
