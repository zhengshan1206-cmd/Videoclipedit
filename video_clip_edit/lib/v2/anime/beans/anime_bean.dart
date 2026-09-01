class AnimeStyleBean {
  String? id;
  String? title;
  String? url;
  AnimeStyleBean({
    required this.id,
    required this.title,
    required this.url,
  });

  factory AnimeStyleBean.fromJson({
    required Map<String, dynamic> json,
  }) {
    return AnimeStyleBean(
      id: json["id"],
      title: json["title"],
      url: json["icon"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "icon": url,
    };
  }
}

class AnimeBean {
  int? id;
  String? title;
  int? categoryID;
  String? audioUrl;
  String? coverUrl;
  String? videoUrl;
  String? duration;
  String? subtitleUrl;
  int? videoBgmID;
  int? videoEndBgmID;
  String? style;
  int? sort;
  String? desc;
  int? status;
  String? story;
  String? content;
  String? createAt;
  String? updateAt;
  List<AnimeStyleBean>? styleBean;
  AnimeBean({
    required this.id,
    required this.title,
    required this.categoryID,
    required this.coverUrl,
    required this.audioUrl,
    required this.videoUrl,
    required this.duration,
    required this.subtitleUrl,
    required this.videoBgmID,
    required this.videoEndBgmID,
    required this.style,
    required this.sort,
    required this.desc,
    required this.status,
    this.story,
    this.content,
    this.createAt,
    this.updateAt,
    required this.styleBean,
  });

  factory AnimeBean.fromJson({
    required Map<String, dynamic> json,
  }) {
    final List items = json['styles'] ?? [];
    return AnimeBean(
      id: json['id'],
      title: json['title'],
      categoryID: json['category_id'],
      coverUrl: json['cover_url'] ?? '',
      audioUrl: json['audio_url'],
      videoUrl: json['video_url'],
      duration: json['duration'],
      subtitleUrl: json['subtitle_url'],
      videoBgmID: json['video_bgm_id'],
      videoEndBgmID: json['video_end_bgm_id'],
      style: json['style'],
      sort: json['sort'],
      desc: json['desc'],
      status: json['status'],
      story: json['story'],
      content: json['content'],
      createAt: json['create_at'],
      updateAt: json['update_at'],
      styleBean: items.map((e) => AnimeStyleBean.fromJson(json: e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category_id': categoryID,
      'cover_url': coverUrl,
      'audio_url': audioUrl,
      'video_url': videoUrl,
      'duration': duration,
      'subtitle_url': subtitleUrl,
      'video_bgm_id': videoBgmID,
      'video_end_bgm_id': videoEndBgmID,
      'style': style,
      'sort': sort,
      'desc': desc,
      'status': status,
      'story': story,
      'content': content,
      'create_at': createAt,
      'update_at': updateAt,
      'styles': styleBean?.map((e) => e.toJson()).toList() ?? [],
    };
  }
}
