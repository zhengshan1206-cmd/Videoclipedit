//智能绘图接口数据模型
class AiTipsModel {
  String? tip;
  int? subjectId;
  AiTipsModel({required this.tip, required this.subjectId});
  factory AiTipsModel.fromJson({
    required Map<String, dynamic> json,
  }) {
    return AiTipsModel(tip: json["tip"], subjectId: json["subject_id"]);
  }

  Map<String, dynamic> toJson(){
    return {
      "tip":tip,
      "subjectId":subjectId,
    };
  }
}
