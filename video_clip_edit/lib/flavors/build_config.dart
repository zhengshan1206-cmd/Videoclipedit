import 'package:video_clip_edit/flavors/channel.dart';

import 'environment.dart';
import 'environment_config.dart';

class BuildConfig {
  late final Environment environment;
  late final EnvironmentConfig config;
  late final ChannelType channelType;
  bool _lock = false;

  static final BuildConfig instance = BuildConfig._internal();

  BuildConfig._internal();

  factory BuildConfig.instantiate({
    required Environment envType,
    required EnvironmentConfig envConfig,
    required ChannelType channelType,
  }) {
    if (instance._lock) return instance;

    instance.environment = envType;
    instance.config = envConfig;
    instance.channelType = channelType;
    instance._lock = true;

    return instance;
  }
}
