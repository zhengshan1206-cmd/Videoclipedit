class AiMusicBannerModel {
  int? id;
  String? prompt;
  String? coverUrl;
  String? audioUrl;
  int? status;
  AiMusicBannerModel({
    required this.id,
    required this.prompt,
    required this.coverUrl,
    required this.audioUrl,
    required this.status,
  });

  factory AiMusicBannerModel.fromJson({
    required Map<String, dynamic> json,
  }) {
    return AiMusicBannerModel(
      id: json["id"],
      prompt: json["prompt"],
      coverUrl: json["cover_url"],
      audioUrl: json["audio_url"],
      status: json["status"],
    );
  }

  Map<String,dynamic> toJson(){
    return {
      "id":id,
      "prompt":prompt,
      "cover_url":coverUrl,
      "audio_url":audioUrl,
       "status":status,
    };
  }
}
