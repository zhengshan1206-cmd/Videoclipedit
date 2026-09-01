class StoryArgumentBean {
  String typeId = "";

  StoryArgumentBean({
    required this.typeId,
  });

  factory StoryArgumentBean.fromJson(Map<String, dynamic> json) =>
      StoryArgumentBean(
        typeId: json["typeId"],
      );

  Map<String, dynamic> toJson() => {
        "typeId": typeId,
      };
}
