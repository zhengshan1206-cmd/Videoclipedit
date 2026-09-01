// To parse this JSON data, do
//
//     final roleBean = roleBeanFromJson(jsonString);

import 'dart:convert';

RoleBean roleBeanFromJson(String str) => RoleBean.fromJson(json.decode(str));

String roleBeanToJson(RoleBean data) => json.encode(data.toJson());

class RoleBean {
  String name;
  String avatar;
  String userId;
  String nameEditing;

  RoleBean({
    required this.name,
    required this.avatar,
    required this.userId,
    required this.nameEditing,
  });

  factory RoleBean.fromJson(Map<String, dynamic> json) => RoleBean(
        name: json["name"],
        avatar: json["avatar"],
        userId: json["userId"],
        nameEditing: json["nameEditing"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "avatar": avatar,
        "userId": userId,
        "nameEditing": nameEditing,
      };
}
