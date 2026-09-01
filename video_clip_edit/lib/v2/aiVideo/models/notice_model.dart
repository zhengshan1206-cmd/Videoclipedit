class NoticeModel {
  final int? id;
  final String? icon;
  final int? type;
  final String? content;

  const NoticeModel({
    this.id,
    this.icon,
    this.type,
    this.content,
  });

  factory NoticeModel.fromJson({
    required Map json,
  }) {
    return NoticeModel(
      id: json["id"],
      icon: json["icon"],
      type: json["type"],
      content: json["content"],
    );
  }
}
