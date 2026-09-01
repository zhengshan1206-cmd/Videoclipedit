import 'dart:convert';

enum StorySceneStatus {
  ///1分镜已创建
  created(1),

  ///2分镜绘制中
  drawing(2),

  ///3分镜绘制完成
  drawn(3),

  ///4分镜重绘中
  redrawing(4),

  ///5分镜重绘完成
  redrawn(5),

  ///6分镜绘制失败
  drawFailed(6),

  ///7 分镜重绘中
  sceneRedrawing(7),

  ///8 分镜重绘完成
  sceneRedrawCompleted(8),

  ///9 分镜重绘失败
  sceneRedrawFailed(9);

  final int rawValue;

  const StorySceneStatus(this.rawValue);

  static StorySceneStatus fromValue(int value) {
    for (var item in StorySceneStatus.values) {
      if (item.rawValue == value) {
        return item;
      }
    }
    return StorySceneStatus.drawing;
  }

  bool get isDrawn => rawValue == drawn.rawValue;
}

class StorySceneBean {
  int id;
  String original;
  String prompt;
  List<String> roleList;
  int status;
  String url;
  int reworkNum;
  List<ReworkUrl> reworkUrl;
  int drawNum;//绘制张数
  bool hasReDraw; //是否有正在绘制中的分镜

  StorySceneBean({
    required this.id,
    required this.original,
    required this.prompt,
    required this.roleList,
    required this.status,
    required this.url,
    required this.reworkNum,
    required this.reworkUrl,
    required this.drawNum,
    required this.hasReDraw,
  });

  StorySceneBean copyWith({
    int? id,
    String? original,
    String? prompt,
    List<String>? roleList,
    int? status,
    String? url,
    int? reworkNum,
    List<ReworkUrl>? reworkUrl,
    int? drawNum,
    bool? hasReDraw,
  }) =>
      StorySceneBean(
        id: id ?? this.id,
        original: original ?? this.original,
        prompt: prompt ?? this.prompt,
        roleList: roleList ?? this.roleList,
        status: status ?? this.status,
        url: url ?? this.url,
        reworkNum: reworkNum ?? this.reworkNum,
        reworkUrl: reworkUrl ?? this.reworkUrl,
        drawNum: drawNum ?? this.drawNum,
        hasReDraw: hasReDraw ?? this.hasReDraw,
      );

  factory StorySceneBean.fromRawJson(String str) =>
      StorySceneBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StorySceneBean.fromJson(Map<String, dynamic> json) => StorySceneBean(
        id: json["id"],
        original: json["original"] ?? '',
        prompt: json["prompt"] ?? '',
        roleList: List<String>.from(json["role_list"].map((x) => x)),
        status: json["status"],
        url: json["url"] ?? '',
        reworkNum: json["rework_num"],
        reworkUrl: List<ReworkUrl>.from(
            (json["rework_url"] ?? []).map((x) => ReworkUrl.fromJson(x))),
        drawNum: json['draw_num'] ?? 0,
        hasReDraw: json['has_re_draw'] == 1 ? true : false,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "original": original,
        "prompt": prompt,
        "role_list": List<dynamic>.from(roleList.map((x) => x)),
        "status": status,
        "url": url,
        "rework_num": reworkNum,
        "rework_url": List<dynamic>.from(reworkUrl.map((x) => x.toJson())),
        'has_re_draw': hasReDraw ? 1 : 2,
        'draw_num': drawNum,
      };
}

class ReworkUrl {
  int id;
  int status;
  String img;
  int objectId;

  ReworkUrl({
    required this.id,
    required this.status,
    required this.img,
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
