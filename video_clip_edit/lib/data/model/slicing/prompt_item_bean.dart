import 'dart:convert';

class PromptItemBean {
  int id;
  String prompt;

  PromptItemBean({
    required this.id,
    required this.prompt,
  });

  PromptItemBean copyWith({
    int? id,
    String? prompt,
  }) =>
      PromptItemBean(
        id: id ?? this.id,
        prompt: prompt ?? this.prompt,
      );

  factory PromptItemBean.fromRawJson(String str) =>
      PromptItemBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PromptItemBean.fromJson(Map<String, dynamic> json) => PromptItemBean(
        id: json["id"],
        prompt: json["prompt"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "prompt": prompt,
      };
}
