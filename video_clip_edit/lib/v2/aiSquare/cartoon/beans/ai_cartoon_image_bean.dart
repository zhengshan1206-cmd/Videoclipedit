import 'dart:convert';

class AiCartoonImageBean {
  int id;
  int pid;
  dynamic type;
  dynamic imagesId;
  String url;

  /// 图片状态 0 未上传  1 ai生成中 2 生成完成 3ai生成超时
  int status;
  String text;
  String imageOrderParam;
  int isAi;
  int changedCount;
  int canChange;

  AiCartoonImageBean({
    required this.id,
    required this.pid,
    required this.type,
    required this.imagesId,
    required this.url,
    required this.status,
    required this.text,
    required this.imageOrderParam,
    required this.isAi,
    required this.changedCount,
    required this.canChange,
  });

  AiCartoonImageBean copyWith({
    int? id,
    int? pid,
    dynamic type,
    dynamic imagesId,
    String? url,
    int? status,
    String? text,
    String? imageOrderParam,
    int? isAi,
    int? changedCount,
    int? canChange,
  }) =>
      AiCartoonImageBean(
        id: id ?? this.id,
        pid: pid ?? this.pid,
        type: type ?? this.type,
        imagesId: imagesId ?? this.imagesId,
        url: url ?? this.url,
        status: status ?? this.status,
        text: text ?? this.text,
        imageOrderParam: imageOrderParam ?? this.imageOrderParam,
        isAi: isAi ?? this.isAi,
        changedCount: changedCount ?? this.changedCount,
        canChange: canChange ?? this.canChange,
      );

  factory AiCartoonImageBean.fromRawJson(String str) =>
      AiCartoonImageBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiCartoonImageBean.fromJson(Map<String, dynamic> json) =>
      AiCartoonImageBean(
        id: json["id"],
        pid: json["pid"],
        type: json["type"],
        imagesId: json["images_id"],
        url: json["url"] ?? "",
        status: json["status"],
        text: json["text"],
        imageOrderParam: json["image_order_param"],
        isAi: json["is_ai"],
        changedCount: json["changed_count"],
        canChange: json["can_change"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "pid": pid,
        "type": type,
        "images_id": imagesId,
        "url": url,
        "status": status,
        "text": text,
        "image_order_param": imageOrderParam,
        "is_ai": isAi,
        "changed_count": changedCount,
        "can_change": canChange,
      };
}
