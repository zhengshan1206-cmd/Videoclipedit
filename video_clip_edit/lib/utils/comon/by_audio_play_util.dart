import 'package:audioplayers/audioplayers.dart';

class ByAudioPlayUtil {
  // 私有的构造函数，确保无法在外部实例化这个类
  ByAudioPlayUtil._internal();

  // 静态私有实例
  static final ByAudioPlayUtil _instance = ByAudioPlayUtil._internal();

  // 对外暴露的工厂构造函数，返回单例实例
  factory ByAudioPlayUtil() {
    return _instance;
  }

  String? currentUrl;

  // audioplayers 实例
  final AudioPlayer _audioPlayer = AudioPlayer();

  // 当前播放状态
  bool _isPlaying = false;

  // 播放音频
  Future<bool> play(String url) async {
    /// 如果正在播放，则先停止当前音频
    if (_isPlaying) {
      await _audioPlayer.stop();
    }

    currentUrl = url;

    await _audioPlayer.play(UrlSource(url));
    _isPlaying = true;

    return _isPlaying;
  }


  // 暂停音频
  Future<bool> pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    return _isPlaying;
  }

  // 恢复音频
  Future<bool> resume() async {
    await _audioPlayer.resume();
    _isPlaying = false;
    return _isPlaying;
  }

  // 停止音频
  Future<bool> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    return _isPlaying;
  }

  // 获取当前播放状态
  bool get isPlaying => _isPlaying;

  // 获取 AudioPlayer 实例
  AudioPlayer get audioPlayer => _audioPlayer;
}
