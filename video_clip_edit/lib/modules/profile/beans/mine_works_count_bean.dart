import 'dart:convert';

class MyWorksCountBean {
  int novelCount;
  int mixCount;
  int photoSpeakCount;
  int aiImageCount;
  int aiVideoCount;
  int aiMusicCount;
  int dubbingCount;
  int userMaterialCount;
  int parseVideoCount;
  int extractCount;

  MyWorksCountBean({
    required this.novelCount,
    required this.mixCount,
    required this.photoSpeakCount,
    required this.aiImageCount,
    required this.aiVideoCount,
    required this.aiMusicCount,
    required this.dubbingCount,
    required this.userMaterialCount,
    required this.parseVideoCount,
    required this.extractCount,
  });

  MyWorksCountBean copyWith({
    int? novelCount,
    int? mixCount,
    int? photoSpeakCount,
    int? aiImageCount,
    int? aiVideoCount,
    int? aiMusicCount,
    int? dubbingCount,
    int? userMaterialCount,
    int? parseVideoCount,
    int? extractCount,
  }) =>
      MyWorksCountBean(
        novelCount: novelCount ?? this.novelCount,
        mixCount: mixCount ?? this.mixCount,
        photoSpeakCount: photoSpeakCount ?? this.photoSpeakCount,
        aiImageCount: aiImageCount ?? this.aiImageCount,
        aiVideoCount: aiVideoCount ?? this.aiVideoCount,
        aiMusicCount: aiMusicCount ?? this.aiMusicCount,
        dubbingCount: dubbingCount ?? this.dubbingCount,
        userMaterialCount: userMaterialCount ?? this.userMaterialCount,
        parseVideoCount: parseVideoCount ?? this.parseVideoCount,
        extractCount: extractCount ?? this.extractCount,
      );

  factory MyWorksCountBean.fromRawJson(String str) =>
      MyWorksCountBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MyWorksCountBean.fromJson(Map<String, dynamic> json) =>
      MyWorksCountBean(
        novelCount: json["novel_count"],
        mixCount: json["mix_count"],
        photoSpeakCount: json["photo_speak_count"],
        aiImageCount: json["ai_image_count"],
        aiVideoCount: json["ai_video_count"],
        aiMusicCount: json["ai_music_count"],
        dubbingCount: json["dubbing_count"],
        userMaterialCount: json["user_material_count"],
        parseVideoCount: json["parse_video_count"],
        extractCount: json["extract_count"],
      );

  Map<String, dynamic> toJson() => {
        "novel_count": novelCount,
        "mix_count": mixCount,
        "photo_speak_count": photoSpeakCount,
        "ai_image_count": aiImageCount,
        "ai_video_count": aiVideoCount,
        "ai_music_count": aiMusicCount,
        "dubbing_count": dubbingCount,
        "user_material_count": userMaterialCount,
        "parse_video_count": parseVideoCount,
        "extract_count": extractCount,
      };
}
