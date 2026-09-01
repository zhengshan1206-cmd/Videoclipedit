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
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
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
  CachedVideoPlayerPlus? _serverPlayer;
  VideoPlayerController? _localController;
  late bool isPlaying = widget.autoPlay;

  changeMuteStatus(bool status) {
    // 确保 player 已初始化才能访问 controller
    if (_serverPlayer != null && _serverPlayer!.isInitialized) {
      _serverPlayer!.controller.setVolume(status ? 0.0 : 1.0);
    }
  }

  stopPlay() {
    _localController?.pause();
    // 确保 player 已初始化才能访问 controller
    if (_serverPlayer != null && _serverPlayer!.isInitialized) {
      _serverPlayer!.controller.pause();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  resumePlay() {
    _localController?.play();
    // 确保 player 已初始化才能访问 controller
    if (_serverPlayer != null && _serverPlayer!.isInitialized) {
      _serverPlayer!.controller.play();
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

    /// 初始化远程视频控制器
    if (widget.url.startsWith("http")) {
      _serverPlayer = CachedVideoPlayerPlus.networkUrl(
        Uri.parse(widget.url),
      );
      _serverPlayer!.initialize().then(
        (_) async {
          // 确保初始化成功后再访问 controller
          if (!_serverPlayer!.isInitialized) {
            byDebugPrint("播放器初始化失败", tag: "VideoPlayerWidget");
            return;
          }

          _serverPlayer!.controller.setVolume(widget.mute ? 0.0 : 1);

          await _serverPlayer!.controller
              .seekTo(Duration(seconds: widget.offset ?? 0));
          byDebugPrint("${_serverPlayer!.controller.value.isInitialized}",
              tag: "播放器初始化状态 in initState seekTo");
          _serverPlayer!.controller.setLooping(true).then((_) {
            byDebugPrint("${_serverPlayer!.controller.value.isInitialized}",
                tag: "播放器初始化状态 in initState setLooping");
            if (mounted) {
              setState(() {});
              // 自动播放
              widget.autoPlay
                  ? _serverPlayer!.controller.play()
                  : _serverPlayer!.controller.pause();
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
      // 初始化视频控制器
      _localController = VideoPlayerController.file(File(widget.url))
        ..initialize().then(
          (_) {
            _localController!
                // ..seekTo(Duration(seconds: widget.offset ?? 0))
                .setLooping(true)
                .then((_) async {
              if (mounted) {
                setState(() {});
                await _localController!
                    .seekTo(Duration(seconds: widget.offset ?? 0));
                // 自动播放
                // _localController?.pause();
                widget.autoPlay
                    ? _localController?.play()
                    : _localController?.pause();
              }
            });
          },
        );
    }

    streamSubscription = eventBus.on<PauseVideoEvent>().listen((event) {
      // 确保 player 已初始化才能访问 controller
      if (_serverPlayer != null && _serverPlayer!.isInitialized) {
        _serverPlayer!.controller.pause();
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
    // 确保 player 已初始化才能访问 controller
    if (_serverPlayer != null && _serverPlayer!.isInitialized) {
      _serverPlayer!.controller.dispose();
    }
    _localController?.dispose();
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 安全地检查初始化状态，避免访问未初始化的 controller
    final isPlayerInitialized = _serverPlayer?.isInitialized ?? false;
    bool isControllerInitialized = false;
    if (isPlayerInitialized) {
      try {
        isControllerInitialized = _serverPlayer!.controller.value.isInitialized;
      } catch (e) {
        // 如果访问 controller 失败，说明未完全初始化
        isControllerInitialized = false;
      }
    }
    byDebugPrint("$isPlayerInitialized - $isControllerInitialized",
        tag: "播放器初始化状态 in build：");
    if (widget.url.startsWith("http")) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (widget.userInteractive == false) return;

          if (ByAudioPlayer.sharedInstance.isPlaying) {
            ByAudioPlayer.sharedInstance.pause();
          }

          // 确保 player 已初始化才能访问 controller
          if (_serverPlayer != null && _serverPlayer!.isInitialized) {
            if (isPlaying) {
              _serverPlayer!.controller.pause();
            } else {
              _serverPlayer!.controller.play();
            }
          }
          setState(() {
            isPlaying = !isPlaying;
          });
        },
        child: Stack(
          children: [
            Container(
              child: (isPlayerInitialized && isControllerInitialized)
                  ? AspectRatio(
                      aspectRatio: widget.aspectRatio ??
                          _serverPlayer!.controller.value.aspectRatio,
                      // aspectRatio: 3/4,
                      child: VideoPlayer(
                        _serverPlayer!.controller,
                      ),
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
