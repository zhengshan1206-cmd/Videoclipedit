//首页ai动态视频数据
class AiVideoBannerModel {
  int? userId;
  String? userName;
  int? type;
  int? useTime;
  String? coverUrl;
  String? prompt;
  String? multiImage;
  String? videoUrl;
  String? shareVideoUrl;
  String? shareCoverUrl;
  AiVideoBannerModel({
    required this.userId,
    required this.userName,
    required this.type,
    required this.useTime,
    required this.coverUrl,
    required this.prompt,
    required this.multiImage,
    required this.videoUrl,
    required this.shareVideoUrl,
    required this.shareCoverUrl,
  });

  factory AiVideoBannerModel.fromJson({required Map<String,dynamic> json,}) {
    return AiVideoBannerModel(
      userId: json["user_id"],
      userName: json["user_name"],
      type: json["type"],
      useTime:  json["use_time"],
      coverUrl: json["cover_url"],
      prompt: json["prompt"],
      multiImage: json["multi_image"],
      videoUrl: json["video_url"],
      shareVideoUrl: json["share_video_url"],
      shareCoverUrl: json["share_cover_url"],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      "user_id":userId,
      "user_name":userName,
      "type":type,
      "use_time":useTime,
      "cover_url":coverUrl,
      "prompt":prompt,
      "multi_image":multiImage,
      "video_url":videoUrl,
      "share_video_url":shareVideoUrl,
      "share_cover_url":shareCoverUrl,
    };
  }
}
