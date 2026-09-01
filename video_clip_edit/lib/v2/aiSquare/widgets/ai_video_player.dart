import 'dart:async';
import 'package:event_bus/event_bus.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class StopVideoPlayEvent {
  const StopVideoPlayEvent();
}

class TriggerShimmerEvent {
  const TriggerShimmerEvent();
}

final EventBus eventBus = EventBus();

///视频播放组件
class AiVideoPlayer extends StatefulWidget {
  const AiVideoPlayer({
    super.key,
    required this.videoUrl,
    this.autoPlay = true,
  });

  final String videoUrl;
  final bool autoPlay;
  @override
  State<AiVideoPlayer> createState() => _AiVideoPlayerState();
}

class _AiVideoPlayerState extends State<AiVideoPlayer>
    with WidgetsBindingObserver {
  late VideoPlayerController _videoPlayerController;
  late StreamSubscription? _streamSubscription;
  late FlickManager _flickManager;
  bool _wasPlayingBeforeInactive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    /// 初始化视频控制器
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
          ..initialize().then((_) {
            _flickManager = FlickManager(
              videoPlayerController: _videoPlayerController,
              getPlayerControlsTimeout: getPlayerControlsTimeoutDefault,
            );
            _flickManager.flickControlManager?.replay();
            setState(() {});
          })
          ..setLooping(true);
    _streamSubscription = eventBus.on<StopVideoPlayEvent>().listen((e) {
      if (_flickManager.flickVideoManager!.isPlaying) {
        _flickManager.flickControlManager?.pause();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoPlayerController.dispose();
    _streamSubscription?.cancel();
    _flickManager.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      // 应用进入后台或被弹窗遮挡时，暂停视频
      if (_flickManager.flickVideoManager?.isPlaying == true) {
        _wasPlayingBeforeInactive = true;
        _flickManager.flickControlManager?.pause();
      } else {
        _wasPlayingBeforeInactive = false;
      }
    } else if (state == AppLifecycleState.resumed) {
      // 应用回到前台时，不自动播放，除非你有特殊需求
      // 如果需要自动恢复播放，可以在这里判断 _wasPlayingBeforeInactive
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 检查当前页面是否在最前面，如果不是则暂停
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) {
      if (_flickManager.flickVideoManager?.isPlaying == true) {
        _flickManager.flickControlManager?.pause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          width: double.infinity,
          child: AspectRatio(
            aspectRatio: _videoPlayerController.value.aspectRatio,
            child: const SizedBox(),
          ),
        ),
        Positioned.fill(
          child: Container(
            alignment: Alignment.center,
            color: ByColorUtil.BlackColor.withOpacity(0.5),
          ),
        ),
        // 视频播放器
        if (_videoPlayerController.value.isInitialized)
          SizedBox(
            width: double.infinity,
            child: AspectRatio(
              aspectRatio: _videoPlayerController.value.aspectRatio,
              child: FlickVideoPlayer(
                flickManager: _flickManager,
                flickVideoWithControls: const FlickVideoWithControls(
                  controls: FlickPortraitControls(iconSize: 25, fontSize: 14),
                ),
                // flickVideoWithControlsFullscreen: const FlickVideoWithControls(
                //   controls: LandscapePlayerControls(),
                // ),
              ),
            ),
          ),
        if (_videoPlayerController.value.isInitialized == false)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF000000),
              child: ByWidgetsUtil.activityIndicator(isNormal: false),
            ),
          ),
      ],
    );
  }
}

GetPlayerControlsTimeout getPlayerControlsTimeoutDefault =
    ({
      bool? errorInVideo,
      bool? isVideoInitialized,
      bool? isPlaying,
      bool? isVideoEnded,
    }) {
      Duration duration;

      if (errorInVideo! ||
          !isVideoInitialized! ||
          !isPlaying! ||
          isVideoEnded!) {
        duration = const Duration(days: 365);
      } else {
        duration = const Duration(seconds: 1);
      }

      return duration;
    };

class LandscapePlayerControls extends StatelessWidget {
  const LandscapePlayerControls({
    super.key,
    this.iconSize = 20,
    this.fontSize = 12,
  });
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const FlickShowControlsAction(
          child: FlickSeekVideoAction(
            child: Center(
              child: FlickVideoBuffer(
                child: FlickAutoHideChild(
                  showIfVideoNotInitialized: false,
                  child: LandscapePlayToggle(),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Column(
              children: <Widget>[
                Expanded(child: Container()),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  color: const Color.fromRGBO(0, 0, 0, 0.4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const FlickPlayToggle(size: 20),
                      const SizedBox(width: 10),
                      FlickCurrentPosition(fontSize: fontSize),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FlickVideoProgressBar(
                          flickProgressBarSettings: FlickProgressBarSettings(
                            height: 10,
                            handleRadius: 10,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 8,
                            ),
                            backgroundColor: Colors.white24,
                            bufferedColor: Colors.white38,
                            getPlayedPaint:
                                ({
                                  double? handleRadius,
                                  double? height,
                                  double? playedPart,
                                  double? width,
                                }) {
                                  return Paint()
                                    ..shader =
                                        const LinearGradient(
                                          colors: [
                                            Color.fromRGBO(108, 165, 242, 1),
                                            Color.fromRGBO(97, 104, 236, 1),
                                          ],
                                          stops: [0.0, 0.5],
                                        ).createShader(
                                          Rect.fromPoints(
                                            const Offset(0, 0),
                                            Offset(width!, 0),
                                          ),
                                        );
                                },
                            getHandlePaint:
                                ({
                                  double? handleRadius,
                                  double? height,
                                  double? playedPart,
                                  double? width,
                                }) {
                                  return Paint()
                                    ..shader =
                                        const RadialGradient(
                                          colors: [
                                            Color.fromRGBO(97, 104, 236, 1),
                                            Color.fromRGBO(97, 104, 236, 1),
                                            Colors.white,
                                          ],
                                          stops: [0.0, 0.4, 0.5],
                                          radius: 0.4,
                                        ).createShader(
                                          Rect.fromCircle(
                                            center: Offset(
                                              playedPart!,
                                              height! / 2,
                                            ),
                                            radius: handleRadius!,
                                          ),
                                        );
                                },
                          ),
                        ),
                      ),
                      FlickTotalDuration(fontSize: fontSize),
                      const SizedBox(width: 10),
                      const FlickSoundToggle(size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 20,
          top: 30,
          child: GestureDetector(
            onTap: () {
              // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
              //     overlays: SystemUiOverlay.values);
              // SystemChrome.setPreferredOrientations(
              //     [DeviceOrientation.portraitUp]);
              Navigator.pop(context);
            },
            child: const Icon(Icons.cancel, size: 30),
          ),
        ),
      ],
    );
  }
}

class LandscapePlayToggle extends StatelessWidget {
  const LandscapePlayToggle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlickControlManager controlManager = Provider.of<FlickControlManager>(
      context,
    );
    FlickVideoManager videoManager = Provider.of<FlickVideoManager>(context);

    double size = 50;
    Color color = Colors.white;

    Widget playWidget = Icon(Icons.play_arrow, size: size, color: color);
    Widget pauseWidget = Icon(Icons.pause, size: size, color: color);
    Widget replayWidget = Icon(Icons.replay, size: size, color: color);

    Widget child = videoManager.isVideoEnded
        ? replayWidget
        : videoManager.isPlaying
        ? pauseWidget
        : playWidget;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        splashColor: const Color.fromRGBO(108, 165, 242, 0.5),
        key: key,
        onTap: () {
          videoManager.isVideoEnded
              ? controlManager.replay()
              : controlManager.togglePlay();
        },
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
          padding: const EdgeInsets.all(10),
          child: child,
        ),
      ),
    );
  }
}
