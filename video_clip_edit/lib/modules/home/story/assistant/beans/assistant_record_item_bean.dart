class AssistantRecordItemBean {
  String token;
  String sketch;
  String answer;
  DateTime createTime;
  DateTime answerStartTime;
  DateTime answerEndTime;

  AssistantRecordItemBean({
    required this.token,
    required this.sketch,
    required this.answer,
    required this.createTime,
    required this.answerStartTime,
    required this.answerEndTime,
  });

  factory AssistantRecordItemBean.fromJson(Map<String, dynamic> json) =>
      AssistantRecordItemBean(
        token: json["token"],
        sketch: json["sketch"],
        answer: json["answer"],
        createTime: DateTime.parse(json["create_time"]),
        answerStartTime: DateTime.parse(json["answer_start_time"]),
        answerEndTime: DateTime.parse(json["answer_end_time"]),
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "sketch": sketch,
        "answer": answer,
        "createTime": createTime.toIso8601String(),
        "answerStartTime": answerStartTime.toIso8601String(),
        "answerEndTime": answerEndTime.toIso8601String(),
      };
}
