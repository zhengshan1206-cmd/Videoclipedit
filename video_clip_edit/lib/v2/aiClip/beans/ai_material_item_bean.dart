import 'dart:convert';

import 'package:video_clip_edit/modules/home/beans/cloud_video_bean.dart';

class AiMaterialItemBean {
  int id;
  String cateName;
  String desc;
  int sort;
  int type;
  int status;
  int isDelete;
  int adminId;
  bool folde;
  DateTime createAt;
  DateTime updateAt;
  List<MaterialPack> materialPack;

  AiMaterialItemBean({
    required this.id,
    required this.cateName,
    required this.desc,
    required this.sort,
    required this.type,
    required this.status,
    required this.isDelete,
    required this.adminId,
    required this.createAt,
    required this.updateAt,
    required this.materialPack,
    required this.folde,
  });

  AiMaterialItemBean copyWith({
    int? id,
    String? cateName,
    String? desc,
    int? sort,
    int? type,
    int? status,
    int? isDelete,
    int? adminId,
    bool? folde,
    DateTime? createAt,
    DateTime? updateAt,
    List<MaterialPack>? materialPack,
  }) =>
      AiMaterialItemBean(
        id: id ?? this.id,
        cateName: cateName ?? this.cateName,
        desc: desc ?? this.desc,
        sort: sort ?? this.sort,
        type: type ?? this.type,
        status: status ?? this.status,
        isDelete: isDelete ?? this.isDelete,
        adminId: adminId ?? this.adminId,
        createAt: createAt ?? this.createAt,
        updateAt: updateAt ?? this.updateAt,
        folde: folde ?? this.folde,
        materialPack: materialPack ?? this.materialPack,
      );

  factory AiMaterialItemBean.fromRawJson(String str) =>
      AiMaterialItemBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiMaterialItemBean.fromJson(Map<String, dynamic> json) =>
      AiMaterialItemBean(
        id: json["id"],
        cateName: json["cate_name"],
        desc: json["desc"],
        sort: json["sort"],
        folde: json["folde"] ?? true,
        type: json["type"],
        status: json["status"],
        isDelete: json["is_delete"],
        adminId: json["admin_id"],
        createAt: DateTime.parse(json["create_at"]),
        updateAt: DateTime.parse(json["update_at"]),
        materialPack: List<MaterialPack>.from(
            json["material_pack"].map((x) => MaterialPack.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "cate_name": cateName,
        "desc": desc,
        "sort": sort,
        "type": type,
        "status": status,
        "is_delete": isDelete,
        "admin_id": adminId,
        "create_at": createAt.toIso8601String(),
        "update_at": updateAt.toIso8601String(),
        "material_pack":
            List<dynamic>.from(materialPack.map((x) => x.toJson())),
      };
}

class MaterialPack {
  int id;
  int materialCateId;
  String materialName;
  String desc;
  String coverUrl;
  // int filesize;
  dynamic otherConfig;
  // dynamic source;
  String duration;
  int sort;
  int status;
  int vipLimit;
  int isDelete;
  int adminId;
  DateTime createAt;
  DateTime updateAt;
  // String bannerCoverUrl;
  // int showBanner;

  // int id;
  // int materialCateId;
  // String materialName;
  // String desc;
  // String coverUrl;
  // OtherConfig? otherConfig;
  // num duration;
  // int sort;
  // num status;
  // int vipLimit;
  // int isDelete;
  // int adminId;
  // DateTime createAt;
  // DateTime updateAt;
  // List<Detail> details;

  MaterialPack({
    required this.id,
    required this.materialCateId,
    required this.materialName,
    required this.desc,
    required this.coverUrl,
    required this.otherConfig,
    // required this.filesize,
    // required this.source,
    required this.duration,
    required this.sort,
    required this.status,
    required this.vipLimit,
    required this.isDelete,
    required this.adminId,
    required this.createAt,
    required this.updateAt,
    // required this.bannerCoverUrl,
    // required this.showBanner,
  });

  MaterialPack copyWith({
    int? id,
    int? materialCateId,
    String? materialName,
    String? desc,
    String? coverUrl,
    int? filesize,
    dynamic otherConfig,
    dynamic source,
    String? duration,
    int? sort,
    int? status,
    int? vipLimit,
    int? isDelete,
    int? adminId,
    DateTime? createAt,
    DateTime? updateAt,
    String? bannerCoverUrl,
    int? showBanner,
  }) =>
      MaterialPack(
        id: id ?? this.id,
        materialCateId: materialCateId ?? this.materialCateId,
        materialName: materialName ?? this.materialName,
        desc: desc ?? this.desc,
        coverUrl: coverUrl ?? this.coverUrl,
        otherConfig: otherConfig ?? this.otherConfig,
        // filesize: filesize ?? this.filesize,
        // source: source ?? this.source,
        duration: duration ?? this.duration,
        sort: sort ?? this.sort,
        status: status ?? this.status,
        vipLimit: vipLimit ?? this.vipLimit,
        isDelete: isDelete ?? this.isDelete,
        adminId: adminId ?? this.adminId,
        createAt: createAt ?? this.createAt,
        updateAt: updateAt ?? this.updateAt,
        // bannerCoverUrl: bannerCoverUrl ?? this.bannerCoverUrl,
        // showBanner: showBanner ?? this.showBanner,
      );

  factory MaterialPack.fromRawJson(String str) =>
      MaterialPack.fromJson(json.decode(str));

  factory MaterialPack.fromCloudVideoListBean(
          CloudVideoListBean cloudVideoListBean) =>
      MaterialPack.fromJson(cloudVideoListBean.toJson());

  String toRawJson() => json.encode(toJson());

  factory MaterialPack.fromJson(Map<String, dynamic> json) => MaterialPack(
        id: json["id"],
        materialCateId: json["material_cate_id"],
        materialName: json["material_name"],
        desc: json["desc"],
        coverUrl: json["cover_url"],
        otherConfig: json["other_config"],
        // filesize: json["filesize"],
        // source: json["source"],
        duration: json["duration"].toString(),
        sort: json["sort"],
        status: json["status"],
        vipLimit: json["vip_limit"],
        isDelete: json["is_delete"],
        adminId: json["admin_id"],
        createAt: DateTime.parse(json["create_at"]),
        updateAt: DateTime.parse(json["update_at"]),
        // bannerCoverUrl: json["banner_cover_url"],
        // showBanner: json["show_banner"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "material_cate_id": materialCateId,
        "material_name": materialName,
        "desc": desc,
        "cover_url": coverUrl,
        "other_config": otherConfig,
        // "filesize": filesize,
        // "source": source,
        "duration": duration,
        "sort": sort,
        "status": status,
        "vip_limit": vipLimit,
        "is_delete": isDelete,
        "admin_id": adminId,
        "create_at": createAt.toIso8601String(),
        "update_at": updateAt.toIso8601String(),
        // "banner_cover_url": bannerCoverUrl,
        // "show_banner": showBanner,
      };
}
