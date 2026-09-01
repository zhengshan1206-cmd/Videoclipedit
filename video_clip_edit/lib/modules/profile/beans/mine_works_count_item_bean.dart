import 'dart:convert';

class MyWorksCountItemBean {
  String icon;
  String title;
  int worksCount;

  MyWorksCountItemBean({
    required this.icon,
    required this.title,
    required this.worksCount,
  });

  MyWorksCountItemBean copyWith({
    String? icon,
    String? title,
    int? worksCount,
  }) =>
      MyWorksCountItemBean(
        icon: icon ?? this.icon,
        title: title ?? this.title,
        worksCount: worksCount ?? this.worksCount,
      );

  factory MyWorksCountItemBean.fromRawJson(String str) =>
      MyWorksCountItemBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MyWorksCountItemBean.fromJson(Map<String, dynamic> json) =>
      MyWorksCountItemBean(
        icon: json["icon"],
        title: json["title"],
        worksCount: json["worksCount"],
      );

  Map<String, dynamic> toJson() => {
        "icon": icon,
        "title": title,
        "worksCount": worksCount,
      };
}
