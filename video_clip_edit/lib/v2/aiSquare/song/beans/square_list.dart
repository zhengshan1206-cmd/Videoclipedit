// To parse this JSON data, do
//
//     final squareList = squareListFromJson(jsonString);

import 'dart:convert';

List<SquareList> squareListFromJson(String str) => List<SquareList>.from(json.decode(str).map((x) => SquareList.fromJson(x)));

String squareListToJson(List<SquareList> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SquareList {
  int id;
  String prompt;
  String aprompt;
  String lyrics;
  String withdrawMoney;
  String useTime;
  String style;
  String coverUrl;
  String audioUrl;
  DateTime createAt;
  int status;
  String duration;
  String title;
  int isInstrumental;
  int customMode;
  int singerSex;
  WithdrawMoneyTip withdrawMoneyTip;

  SquareList({
    required this.id,
    required this.prompt,
    required this.aprompt,
    required this.lyrics,
    required this.withdrawMoney,
    required this.useTime,
    required this.style,
    required this.coverUrl,
    required this.audioUrl,
    required this.createAt,
    required this.status,
    required this.duration,
    required this.title,
    required this.isInstrumental,
    required this.customMode,
    required this.singerSex,
    required this.withdrawMoneyTip,
  });

  factory SquareList.fromJson(Map<String, dynamic> json) => SquareList(
    id: json["id"],
    prompt: json["prompt"],
    aprompt: json["aprompt"],
    lyrics: json["lyrics"],
    withdrawMoney: json["withdraw_money"],
    useTime: json["use_time"],
    style: json["style"],
    coverUrl: json["cover_url"],
    audioUrl: json["audio_url"],
    createAt: DateTime.parse(json["create_at"]),
    status: json["status"],
    duration: json["duration"],
    title: json["title"],
    isInstrumental: json["is_instrumental"],
    customMode: json["custom_mode"],
    singerSex: json["singer_sex"],
    withdrawMoneyTip: withdrawMoneyTipValues.map[json["withdraw_money_tip"]]!,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "prompt": prompt,
    "aprompt": aprompt,
    "lyrics": lyrics,
    "withdraw_money": withdrawMoney,
    "use_time": useTime,
    "style": style,
    "cover_url": coverUrl,
    "audio_url": audioUrl,
    "create_at": createAt.toIso8601String(),
    "status": status,
    "duration": duration,
    "title": title,
    "is_instrumental": isInstrumental,
    "custom_mode": customMode,
    "singer_sex": singerSex,
    "withdraw_money_tip": withdrawMoneyTipValues.reverse[withdrawMoneyTip],
  };
}

enum WithdrawMoneyTip {
  EMPTY
}

final withdrawMoneyTipValues = EnumValues({
  "已变现": WithdrawMoneyTip.EMPTY
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
