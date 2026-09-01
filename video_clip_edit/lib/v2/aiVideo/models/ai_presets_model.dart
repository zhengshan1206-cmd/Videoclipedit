//智能绘图接口数据模型
class AiPresetsModel {
  String? title;
  int? id;
  String? des;
  String? icon;
  AiPresetsModel({required this.title, required this.id,required this.des,required this.icon,});
  factory AiPresetsModel.fromJson({
    required Map<String, dynamic> json,
  }) {
    return AiPresetsModel(title: json["title"], id: json["subject_id"],des: json["des"],icon: json["icon"]);
  }

  Map<String, dynamic> toJson(){
    return {
      "title":title,
      "id":id,
      "des":des,
       "icon":icon,
    };
  }
}