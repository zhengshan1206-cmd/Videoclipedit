import 'dart:convert';

enum FolkStoryVideoStatus {
  ///1已保存
  saved(1),

  ///2角色提取中
  roleExtracting(2),

  ///3角色提取完成
  roleExtracted(3),

  ///4角色绘制中
  roleDrawing(4),

  ///5角色绘制完成
  roleDrawn(5),

  ///6分镜中
  scenesCreating(6),

  ///7分镜完成
  scenesCreated(7),

  ///8分镜绘制中
  scenesDrawing(8),

  ///9分镜绘制完成
  scenesDrawn(9),

  ///10视频生成中
  videoCreating(10),

  ///11已完成
  finished(11),

  ///12失败
  failed(12);

  final int rawValue;
  const FolkStoryVideoStatus(this.rawValue);

  static FolkStoryVideoStatus fromRawValue(int value) {
    for (var item in FolkStoryVideoStatus.values) {
      if (item.rawValue == value) {
        return item;
      }
    }
    return FolkStoryVideoStatus.failed;
  }
}

class FolkStoryVideoBean {
  ///民间故事id
  int id;

  ///是否是自动模式:1是 2否
  int isAuto;

  ///状态
  ///1已保存
  ///2角色提取中
  ///3角色提取完成
  ///4角色绘制中
  ///5角色绘制完成
  ///6分镜中
  ///7分镜完成
  ///8分镜绘制中
  ///9分镜绘制完成
  ///10视频生成中
  ///11已完成
  ///12失败
  int status;

  ///生成的视频url
  String videoUrl;
  int userId;

  ///生成的视频封面
  String cover;

  ///创建时间
  String createdAt;

  FolkStoryVideoBean({
    required this.id,
    required this.isAuto,
    required this.status,
    required this.videoUrl,
    required this.userId,
    required this.cover,
    required this.createdAt,
  });

  FolkStoryVideoBean copyWith({
    int? id,
    int? isAuto,
    int? status,
    String? videoUrl,
    int? userId,
    String? cover,
    String? createdAt,
  }) =>
      FolkStoryVideoBean(
        id: id ?? this.id,
        isAuto: isAuto ?? this.isAuto,
        status: status ?? this.status,
        videoUrl: videoUrl ?? this.videoUrl,
        userId: userId ?? this.userId,
        cover: cover ?? this.cover,
        createdAt: createdAt ?? this.createdAt,
      );

  factory FolkStoryVideoBean.fromRawJson(String str) =>
      FolkStoryVideoBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FolkStoryVideoBean.fromJson(Map<String, dynamic> json) =>
      FolkStoryVideoBean(
        id: json["id"],
        isAuto: json["is_auto"],
        status: json["status"],
        videoUrl: json["video_url"],
        userId: json["user_id"],
        cover: json["cover"],
        createdAt: json["created_at"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "is_auto": isAuto,
        "status": status,
        "video_url": videoUrl,
        "user_id": userId,
        "cover": cover,
        "created_at": createdAt,
      };
}
