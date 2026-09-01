import 'dart:convert';

class AiCartoonScreenStyleBean {
  int id;
  String title;
  String url;
  List<Case> cases;

  AiCartoonScreenStyleBean({
    required this.id,
    required this.title,
    required this.url,
    required this.cases,
  });

  AiCartoonScreenStyleBean copyWith({
    int? id,
    String? title,
    String? url,
    List<Case>? cases,
  }) =>
      AiCartoonScreenStyleBean(
        id: id ?? this.id,
        title: title ?? this.title,
        url: url ?? this.url,
        cases: cases ?? this.cases,
      );

  factory AiCartoonScreenStyleBean.fromRawJson(String str) =>
      AiCartoonScreenStyleBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiCartoonScreenStyleBean.fromJson(Map<String, dynamic> json) =>
      AiCartoonScreenStyleBean(
        id: json["id"],
        title: json["title"],
        url: json["url"],
        cases: List<Case>.from((json["cases"]).map((x) => Case.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "url": url,
        "cases": List<dynamic>.from(cases.map((x) => x.toJson())),
      };
}

class Case {
  String url;
  String ratio;

  Case({
    required this.url,
    required this.ratio,
  });

  Case copyWith({
    String? url,
    String? ratio,
  }) =>
      Case(
        url: url ?? this.url,
        ratio: ratio ?? this.ratio,
      );

  factory Case.fromRawJson(String str) => Case.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Case.fromJson(Map<String, dynamic> json) => Case(
        url: json["url"],
        ratio: json["ratio"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "ratio": ratio,
      };
}
