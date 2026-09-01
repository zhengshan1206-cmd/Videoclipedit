// To parse this JSON data, do
//
//     final platformbean = platformbeanFromJson(jsonString);

import 'dart:convert';

List<Platformbean> platformbeanFromJson(String str) => List<Platformbean>.from(
    json.decode(str).map((x) => Platformbean.fromJson(x)));

String platformbeanToJson(List<Platformbean> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Platformbean {
  int id;
  String name;

  Platformbean({
    required this.id,
    required this.name,
  });

  factory Platformbean.fromJson(Map<String, dynamic> json) => Platformbean(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
