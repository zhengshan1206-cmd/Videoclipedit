import 'dart:convert';

class AiChatItemBean {
  String contet;
  bool isAnswer;
  DateTime time;
  String messageId;
  AiChatItemBean({
    required this.contet,
    required this.isAnswer,
    required this.time,
    required this.messageId,
  });

  AiChatItemBean copyWith({
    String? contet,
    bool? isAnswer,
    DateTime? time,
    String? messageId,
  }) =>
      AiChatItemBean(
        contet: contet ?? this.contet,
        isAnswer: isAnswer ?? this.isAnswer,
        time: time ?? this.time,
        messageId: messageId ?? this.messageId,
      );

  factory AiChatItemBean.fromRawJson(String str) =>
      AiChatItemBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiChatItemBean.fromJson(Map<String, dynamic> json) => AiChatItemBean(
        contet: json["contet"],
        isAnswer: json["isAnswer"],
        time: json["time"] != null
            ? DateTime.parse(json["time"])
            : DateTime.now(),
        messageId: json["messageId"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "contet": contet,
        "isAnswer": isAnswer,
        "time": time,
        "messageId": messageId,
      };
}
