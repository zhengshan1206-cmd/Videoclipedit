import 'dart:convert';
import 'dart:developer';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_video_square_model.g.dart';

@JsonEnum(valueField: 'code')
enum AiVideoGenerationType {
  textToVideo(1),
  imageToVideo(2),
  embraceVideo(3),
  firstAndEndFrame(52),
  multipleImages(53);

  final int code;
  const AiVideoGenerationType(this.code);

  factory AiVideoGenerationType.fromJson(int json) =>
      AiVideoGenerationType.values.firstWhere((e) => e.code == json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AiVideoSquareModel {
  int userId;
  AiVideoGenerationType type;
  String userName;
  String? prompt;
  String? negativePrompt;
  String useTime;
  String withdrawMoney;
  String categoryIds;
  List<String>? labels;
  List<String>? multiImage;
  String? bgmUrl;
  String? imageTail;
  double cfgScale;
  String mode;
  String aspectRatio;
  String videoUrl;
  String coverUrl;
  String shareVideoUrl;
  String shareCoverUrl;
  String withdrawMoneyTip;
  String activeUserName;
  String activeUserAvatar;
  int activeUserCreateDays;

  AiVideoSquareModel({
    required this.userId,
    required this.type,
    required this.userName,
    required this.prompt,
    required this.negativePrompt,
    required this.useTime,
    required this.withdrawMoney,
    required this.categoryIds,
    required this.labels,
    required this.multiImage,
    this.bgmUrl,
    this.imageTail,
    required this.cfgScale,
    required this.mode,
    required this.aspectRatio,
    required this.videoUrl,
    required this.coverUrl,
    required this.shareVideoUrl,
    required this.shareCoverUrl,
    required this.withdrawMoneyTip,
    required this.activeUserName,
    required this.activeUserAvatar,
    required this.activeUserCreateDays,
  });

  AiVideoSquareModel copyWith({
    int? userId,
    AiVideoGenerationType? type,
    String? userName,
    String? prompt,
    String? negativePrompt,
    String? useTime,
    String? withdrawMoney,
    String? categoryIds,
    List<String>? labels,
    List<String>? multiImage,
    String? bgmUrl,
    String? imageTail,
    double? cfgScale,
    String? mode,
    String? aspectRatio,
    String? videoUrl,
    String? coverUrl,
    String? shareVideoUrl,
    String? shareCoverUrl,
    String? withdrawMoneyTip,
    String? activeUserName,
    String? activeUserAvatar,
    int? activeUserCreateDays,
  }) {
    return AiVideoSquareModel(
      userId: userId ?? this.userId,
      type: type ?? this.type,
      userName: userName ?? this.userName,
      prompt: prompt ?? this.prompt,
      negativePrompt: negativePrompt ?? this.negativePrompt,
      useTime: useTime ?? this.useTime,
      withdrawMoney: withdrawMoney ?? this.withdrawMoney,
      categoryIds: categoryIds ?? this.categoryIds,
      labels: labels ?? this.labels,
      multiImage: multiImage ?? this.multiImage,
      imageTail: imageTail ?? this.imageTail,
      bgmUrl: bgmUrl??this.bgmUrl,
      cfgScale: cfgScale ?? this.cfgScale,
      mode: mode ?? this.mode,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      videoUrl: videoUrl ?? this.videoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      shareVideoUrl: shareVideoUrl ?? this.shareVideoUrl,
      shareCoverUrl: shareCoverUrl ?? this.shareCoverUrl,
      withdrawMoneyTip: withdrawMoneyTip ?? this.withdrawMoneyTip,
      activeUserName: activeUserName ?? this.activeUserName,
      activeUserAvatar: activeUserAvatar ?? this.activeUserAvatar,
      activeUserCreateDays: activeUserCreateDays ?? this.activeUserCreateDays,
    );
  }

  Map<String, dynamic> toJson() => _$AiVideoSquareModelToJson(this);
  factory AiVideoSquareModel.fromJson(Map<String, dynamic> json) =>
      _$AiVideoSquareModelFromJson(json);

  factory AiVideoSquareModel.fromRawJson(String str) =>
      AiVideoSquareModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}
