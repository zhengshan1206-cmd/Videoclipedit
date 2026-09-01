// To parse this JSON data, do
//
//     final cloudVideoBean = cloudVideoBeanFromJson(jsonString);
import 'dart:convert';

CloudVideoListBean cloudVideoBeanFromJson(String str) =>
    CloudVideoListBean.fromJson(json.decode(str));

String cloudVideoBeanToJson(CloudVideoListBean data) =>
    json.encode(data.toJson());

class CloudVideoListBean {
  int id;
  int materialCateId;
  String materialName;
  String desc;
  String coverUrl;
  OtherConfig? otherConfig;
  num duration;
  int sort;
  num status;
  int vipLimit;
  int isDelete;
  int adminId;
  DateTime createAt;
  DateTime updateAt;
  List<Detail> details;
  String fansNum;
  CloudVideoListBean({
    required this.id,
    required this.materialCateId,
    required this.materialName,
    required this.desc,
    required this.coverUrl,
    required this.duration,
    required this.sort,
    required this.status,
    required this.vipLimit,
    required this.isDelete,
    required this.adminId,
    required this.createAt,
    required this.updateAt,
    required this.details,
    required this.otherConfig,
    required this.fansNum,
  });

  @override
  String toString() {
    return 'CloudVideoListBean{id: $id, materialCateId: $materialCateId, materialName: $materialName, desc: $desc, coverUrl: $coverUrl, duration: $duration, sort: $sort, status: $status, vipLimit: $vipLimit, isDelete: $isDelete, adminId: $adminId, createAt: $createAt, updateAt: $updateAt, details: $details}';
  }

  factory CloudVideoListBean.fromJson(Map<String, dynamic> json) =>
      CloudVideoListBean(
        id: _toInt(json["id"]),
        materialCateId: _toInt(json["material_cate_id"]),
        materialName: json["material_name"] ?? "",
        desc: json["desc"] ?? "",
        coverUrl: json["cover_url"] ?? "",
        duration: _toNum(json["duration"]),
        sort: _toInt(json["sort"]),
        status: _toNum(json["status"]),
        vipLimit: _toInt(json["vip_limit"]),
        isDelete: _toInt(json["is_delete"]),
        adminId: _toInt(json["admin_id"]),
        createAt: DateTime.parse(json["create_at"]),
        updateAt: DateTime.parse(json["update_at"]),
        fansNum: _toString(json["fans_num"]),
        details:
            List<Detail>.from(json["details"].map((x) => Detail.fromJson(x))),
        otherConfig: json["other_config"] == null
            ? null
            : OtherConfig.fromJson(jsonDecode(json["other_config"])),
      );

  // 辅助函数：安全地将值转换为 int
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is num) return value.toInt();
    return 0;
  }

  // 辅助函数：安全地将值转换为 num
  static num _toNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) {
      return num.tryParse(value) ?? 0;
    }
    return 0;
  }

  // 辅助函数：安全地将值转换为 String
  static String _toString(dynamic value) {
    if (value == null) return "";
    if (value is String) return value;
    return value.toString();
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "material_cate_id": materialCateId,
        "material_name": materialName,
        "desc": desc,
        "cover_url": coverUrl,
        "duration": duration,
        "sort": sort,
        "status": status,
        "vip_limit": vipLimit,
        "is_delete": isDelete,
        "admin_id": adminId,
        "create_at": createAt.toIso8601String(),
        "update_at": updateAt.toIso8601String(),
        "details": List<dynamic>.from(details.map((x) => x.toJson())),
        "other_config": otherConfig?.toJson().toString(),
        // "other_config": otherConfig?.toJson(),
      };
}

class OtherConfig {
  int maxIncome;
  int joinPeopleNum;
  int fansNum;
  String bookName;
  String bookId;

  OtherConfig({
    required this.maxIncome,
    required this.joinPeopleNum,
    required this.fansNum,
    required this.bookName,
    required this.bookId,
  });

  OtherConfig copyWith({
    int? maxIncome,
    int? joinPeopleNum,
    int? fansNum,
    String? bookName,
    String? bookId,
  }) =>
      OtherConfig(
        maxIncome: maxIncome ?? this.maxIncome,
        joinPeopleNum: joinPeopleNum ?? this.joinPeopleNum,
        fansNum: fansNum ?? this.fansNum,
        bookName: bookName ?? this.bookName,
        bookId: bookId ?? this.bookId,
      );

  factory OtherConfig.fromRawJson(String str) =>
      OtherConfig.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OtherConfig.fromJson(Map<String, dynamic> json) => OtherConfig(
        maxIncome: _toInt(json["max_income"]),
        joinPeopleNum: _toInt(json["join_people_num"]),
        fansNum: _toInt(json["fans_num"]),
        bookName: json["book_name"] ?? "",
        bookId: json["book_id"] ?? "",
      );

  // 辅助函数：安全地将值转换为 int，兼容字符串和整数
  // 如果返回的是字符串，尝试解析为 int；如果是 int，直接使用
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    // 如果是 int，直接返回
    if (value is int) return value;
    // 如果是字符串，尝试解析为 int
    if (value is String) {
      if (value.isEmpty) return 0;
      // 尝试解析字符串为整数
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
      // 如果解析失败，返回 0
      return 0;
    }
    // 如果是 num 类型（double 或 int），转换为 int
    if (value is num) return value.toInt();
    // 其他类型返回 0
    return 0;
  }

  Map<String, dynamic> toJson() => {
        "max_income": maxIncome,
        "join_people_num": joinPeopleNum,
        "fans_num": fansNum,
        "book_name": bookName,
        "book_id": bookId,
      };
}

class Detail {
  int id;
  String videoUrl;
  String coverUrl;
  num duration;
  String fullVideoTitle;
  DateTime createAt;
  DateTime updateAt;
  String videoTitle;
  String content;
  // int materialPackId;
  // String? savePath;
  // int scale;
  int sort;
  // int status;
  // int isDemo;

  Detail({
    required this.id,
    required this.videoUrl,
    required this.coverUrl,
    required this.duration,
    required this.fullVideoTitle,
    required this.createAt,
    required this.updateAt,
    required this.videoTitle,
    required this.content,
    // required this.materialPackId,
    // required this.scale,
    required this.sort,
    // required this.status,
    // required this.isDemo,
    // this.savePath,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        // materialPackId: json["material_pack_id"],
        // scale: json["scale"],
        sort: _toInt(json["sort"]),
        // status: json["status"],
        // isDemo: json["is_demo"],
        // savePath: json["savePath"],
        id: _toInt(json["id"]),
        videoTitle: json["video_title"] ?? "",
        fullVideoTitle: json["full_video_title"] ?? "",
        videoUrl: json["video_url"] ?? "",
        coverUrl: json["cover_url"] ?? "",
        duration: _toNum(json["duration"]),
        content: json["content"] ?? "",
        createAt: DateTime.parse(json["create_at"]),
        updateAt: DateTime.parse(json["update_at"]),
      );

  // 辅助函数：安全地将值转换为 int
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is num) return value.toInt();
    return 0;
  }

  // 辅助函数：安全地将值转换为 num
  static num _toNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) {
      return num.tryParse(value) ?? 0;
    }
    return 0;
  }

  factory Detail.fromWork(Map<String, dynamic> json) => Detail(
        // materialPackId: json["material_pack_id"],
        // scale: json["scale"],
        sort: json["sort"],
        // status: json["status"],
        // isDemo: json["is_demo"],
        // savePath: json["savePath"],
        id: json["id"],
        videoTitle: json["title"] ?? "",
        fullVideoTitle: json["full_video_title"] ?? "",
        videoUrl: json["file_url"] ?? "",
        coverUrl: json["file_cover_url"] ?? "",
        duration: json["duration"] ?? 0,
        content: json["content"] ?? "",
        createAt: DateTime.parse(json["created_at"]),
        updateAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        // "material_pack_id": materialPackId,
        // "scale": scale,
        "sort": sort,
        // "savePath": savePath,
        // "status": status,
        // "is_demo": isDemo,
        "id": id,
        "video_title": videoTitle,
        "full_video_title": fullVideoTitle,
        "video_url": videoUrl,
        "cover_url": coverUrl,
        "duration": duration,
        "content": content,
        "create_at": createAt.toIso8601String(),
        "update_at": updateAt.toIso8601String(),
      };
}
