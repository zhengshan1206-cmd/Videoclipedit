// ignore_for_file: use_function_type_syntax_for_parameters

import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_package_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_audio_status_provider.dart';

/// 播放器当前的状态
enum ByAudioPlayerStatus {
  /// 正在加载
  loading,

  /// 播放中
  playing,

  /// 已暂停
  pause,

  /// 已停止播放
  stop,

  /// 已恢复
  resume,

  /// 播放完毕
  complete
}

class ByAudioPlayer {
  /// 内部的播放器对象
  late final AudioPlayer _audioPlayer;
  // int _duration = 0;
  final StreamController<ByAudioPlayerStatus> _playerStatusController =
      StreamController.broadcast();
  late AiCartoonAudioStatusProvider _audioStatusProvider;
  AiCartoonAudioStatusProvider get statusProvider => _audioStatusProvider;
  Stream<ByAudioPlayerStatus> statusFutuer() {
    return _playerStatusController.stream;
  }

  /// 私有构造函数
  ByAudioPlayer._privateConstructor() {
    _audioPlayer = AudioPlayer();
    _audioStatusProvider = AiCartoonAudioStatusProvider();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _init();
  }

  // 单例实例
  static final ByAudioPlayer _instance = ByAudioPlayer._privateConstructor();
  StreamSubscription? _positionSubscription;

  // 提供单例实例
  static ByAudioPlayer get sharedInstance {
    return _instance;
  }

  /// 播放完成
  bool complete = false;

  /// 是否正在播放
  bool isPlaying = false;

  /// 是否已初始化
  bool initialized = false;

  /// 播放音频
  /// [releaseMode] 为 [ReleaseMode.release] 时视为短音/瞬态音，采用 duck 焦点策略，避免打断系统/其他应用正在播放的音乐且无法恢复
  Future<bool> play(
    String url, {
    ReleaseMode releaseMode = ReleaseMode.loop,
    Duration? position,
    double playbackRate = 1.0,
    double volume = 1.0,
  }) async {
    /// 短音/瞬态音：使用 gainTransientMayDuck（duck），符合鸿蒙/Android 短音体验规范；长音使用 gain
    final bool isShortOrTransient = releaseMode == ReleaseMode.release;
    if (Platform.isAndroid || ByPackageUtils.isOhos) {
      try {
        await _audioPlayer.setAudioContext(AudioContext(
          android: AudioContextAndroid(
            audioFocus: isShortOrTransient
                ? AndroidAudioFocus.gainTransientMayDuck
                : AndroidAudioFocus.gain,
          ),
        ));
      } catch (_) {
        // 鸿蒙 fork 若未实现 setAudioContext 则忽略
      }
    }

    _playerStatusController.sink.add(ByAudioPlayerStatus.playing);
    _audioStatusProvider.changeAudioStatus(AiCartoonAudioStatus.playing);
    await _audioPlayer.stop();

    /// 播放的新的内容 做ios/鸿蒙兼容
    if (Platform.isAndroid) {
      await _audioPlayer.play(
        UrlSource(url),
        position: position,
      );
    } else if (ByPackageUtils.isOhos) {
      if (url.startsWith('/data')) {
        await _audioPlayer.play(
          DeviceFileSource(url),
          position: position,
        );
      } else {
        await _audioPlayer.play(
          UrlSource(url),
          position: position,
        );
      }
    } else {
      Get.log("换一种音频文件播放形式==>${url}");
      await _audioPlayer.play(
        DeviceFileSource(url),
        // bytesSource,
        position: position,
      );
    }

    /// 播放的新的内容
    // await _audioPlayer.play(
    //   UrlSource(url),
    //   position: position,
    // );

    /// 设置播放语速
    _audioPlayer.setPlaybackRate(playbackRate);

    /// 设置播放音量
    _audioPlayer.setVolume(volume);

    if (releaseMode != _audioPlayer.releaseMode) {
      await _audioPlayer.setReleaseMode(releaseMode);
    }
    isPlaying = true;
    return isPlaying;
  }

  Future<void> seekTo(int seconds) async {
    return _audioPlayer.seek(Duration(seconds: seconds));
  }

  Future<void> setSource(String url) async {
    if (Platform.isIOS || ByPackageUtils.isOhos) {
      return _audioPlayer.setSourceDeviceFile(url);
    } else {
      return _audioPlayer.setSource(UrlSource(url));
    }
  }

  Future<Duration?> getDuration() async {
    return _audioPlayer.getDuration();
  }

  AudioPlayer get audioPlayer => _audioPlayer;

  /// 监听播放状态
  Future<StreamSubscription> listener(void onData(event)?) async {
    return _audioPlayer.onPlayerStateChanged.listen(onData);
  }

  /// 监听播放进度
  onPositionChanged(
    void Function(Duration event)? onData,
  ) async {
    _positionSubscription = _audioPlayer.onPositionChanged.listen(onData);
    return _positionSubscription;
  }

  /// 监听播放总进度
  Future<StreamSubscription> onDurationChanged(
    void Function(Duration event)? onData,
  ) async {
    return _audioPlayer.onDurationChanged.listen(onData);
  }

  /// 停止播放
  Future<bool> stop() async {
    _playerStatusController.sink.add(ByAudioPlayerStatus.stop);
    _audioStatusProvider.changeAudioStatus(AiCartoonAudioStatus.stop);
    await _audioPlayer.stop();
    isPlaying = false;
    return isPlaying;
  }

  /// 暂停播放
  Future<bool> pause() async {
    _playerStatusController.sink.add(ByAudioPlayerStatus.pause);
    _audioStatusProvider.changeAudioStatus(AiCartoonAudioStatus.pause);
    await _audioPlayer.pause();
    isPlaying = false;
    return isPlaying;
  }

  setPlaybackRate(double playbackRate) {
    _audioPlayer.setPlaybackRate(playbackRate);
  }

  setVolume(double volume) {
    _audioPlayer.setVolume(volume);
  }

  /// 恢复播放
  Future<bool> resume({
    double playbackRate = 1.0,
    double volume = 1.0,
  }) async {
    _playerStatusController.sink.add(ByAudioPlayerStatus.resume);
    _audioStatusProvider.changeAudioStatus(AiCartoonAudioStatus.resume);
    _audioPlayer.setPlaybackRate(playbackRate);

    /// 设置播放音量
    _audioPlayer.setVolume(volume);
    await _audioPlayer.resume();
    isPlaying = true;
    return isPlaying;
  }

  /// 释放播放器资源
  Future<void> playerDispose() async {
    byDebugPrint("palyerDispose", tag: "ByAudioPlayer:");
    await stop();
    await _audioPlayer.release();
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// 初始化
  void _init() {
    if (initialized) return;

    /// 监听播放进度
    // _audioPlayer.onPositionChanged.listen(
    //   (Duration position) {
    //     final progress = position.inSeconds;
    //     if (progress == _duration) {
    //       _playerStatusController.sink.add(ByAudioPlayerStatus.complete);
    //     }
    //   },
    // );

    // // 监听音频总时长
    // _audioPlayer.onDurationChanged.listen(
    //   (Duration duration) {
    //     _duration = duration.inSeconds;
    //   },
    // );

    /// 监听播放完成事件
    _audioPlayer.onPlayerComplete.listen(
      (event) {
        _playerStatusController.sink.add(ByAudioPlayerStatus.complete);
        _audioStatusProvider.changeAudioStatus(AiCartoonAudioStatus.complete);
        complete = true;
        stop();
      },
    );

    initialized = true;
  }
}
