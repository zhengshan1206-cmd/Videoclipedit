// To parse this JSON data, do
//
//     final roleWordsBean = roleWordsBeanFromJson(jsonString);

import 'dart:convert';

RoleWordsBean roleWordsBeanFromJson(String str) =>
    RoleWordsBean.fromJson(json.decode(str));

String roleWordsBeanToJson(RoleWordsBean data) => json.encode(data.toJson());

class RoleWordsBean {
  String roleName;
  String roleQuotes;

  RoleWordsBean({
    required this.roleName,
    required this.roleQuotes,
  });

  factory RoleWordsBean.fromJson(Map<String, dynamic> json) => RoleWordsBean(
        roleName: json["roleName"] ?? "",
        roleQuotes: json["roleQuotes"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "roleName": roleName,
        "roleQuotes": roleQuotes,
      };
}
