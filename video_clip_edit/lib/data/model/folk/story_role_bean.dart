import 'dart:convert';

enum RoleRegenerateStatus {
  ///1 角色已提取
  roleExtracted(1),

  ///2 角色绘制中
  roleDrawing(2),

  ///3 角色绘制完成
  roleDrawCompleted(3),

  ///6 角色绘制失败
  roleDrawFailed(6),

  ///4 角色重绘中
  roleRedrawing(7),

  ///5 角色重绘完成
  roleRedrawCompleted(8),

  ///5 角色重绘完成
  roleRedrawFailed(9);

  const RoleRegenerateStatus(this.rawValue);

  final int rawValue;

  static RoleRegenerateStatus fromValue(int value) {
    for (var item in RoleRegenerateStatus.values) {
      if (item.rawValue == value) {
        return item;
      }
    }
    return RoleRegenerateStatus.roleDrawFailed;
  }
}

class StoryRoleBean {
  int id;
  String name;
  String desc;
  int status;
  String url;
  List<ReworkUrl> reworkUrl;
  int reworkNum;

  StoryRoleBean({
    required this.id,
    required this.name,
    required this.desc,
    required this.status,
    required this.url,
    required this.reworkUrl,
    required this.reworkNum,
  });

  StoryRoleBean copyWith({
    int? id,
    String? name,
    String? desc,
    int? status,
    String? url,
    List<ReworkUrl>? reworkUrl,
    int? reworkNum,
  }) =>
      StoryRoleBean(
        id: id ?? this.id,
        name: name ?? this.name,
        desc: desc ?? this.desc,
        status: status ?? this.status,
        url: url ?? this.url,
        reworkUrl: reworkUrl ?? this.reworkUrl,
        reworkNum: reworkNum ?? this.reworkNum,
      );

  factory StoryRoleBean.fromRawJson(String str) =>
      StoryRoleBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StoryRoleBean.fromJson(Map<String, dynamic> json) => StoryRoleBean(
        id: json["id"],
        name: json["name"],
        desc: json["desc"],
        status: json["status"],
        url: json["url"],
        reworkUrl: List<ReworkUrl>.from(
            (json["rework_url"] ?? []).map((x) => ReworkUrl.fromJson(x))),
        reworkNum: json["rework_num"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "desc": desc,
        "status": status,
        "url": url,
        "rework_url": List<dynamic>.from(reworkUrl.map((x) => x.toJson())),
        "rework_num": reworkNum,
      };
}

class ReworkUrl {
  int id;

  ///状态:
  ///1 - 绘制中
  ///2 - 绘制成功
  ///3 - 绘制失败
  int status;
  String img;
  int objectId;

  ReworkUrl({
    required this.id,
    required this.img,
    required this.status,
    required this.objectId,
  });

  ReworkUrl copyWith({
    int? id,
    int? status,
    String? img,
    int? objectId,
  }) =>
      ReworkUrl(
        id: id ?? this.id,
        status: status ?? this.status,
        img: img ?? this.img,
        objectId: objectId ?? this.objectId,
      );

  factory ReworkUrl.fromRawJson(String str) =>
      ReworkUrl.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ReworkUrl.fromJson(Map<String, dynamic> json) => ReworkUrl(
        id: json["id"],
        status: json["status"],
        img: json["img"],
        objectId: json["object_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "img": img,
        "object_id": objectId,
      };
}
