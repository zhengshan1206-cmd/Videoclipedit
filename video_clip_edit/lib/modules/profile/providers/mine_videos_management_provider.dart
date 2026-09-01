import 'dart:convert';
import 'package:video_clip_edit/providers/base_provider.dart';

class MineVideosCategoryBean {
  String title;
  int id;

  MineVideosCategoryBean({
    required this.title,
    required this.id,
  });

  MineVideosCategoryBean copyWith({
    String? title,
    int? id,
  }) =>
      MineVideosCategoryBean(
        title: title ?? this.title,
        id: id ?? this.id,
      );

  factory MineVideosCategoryBean.fromRawJson(String str) =>
      MineVideosCategoryBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MineVideosCategoryBean.fromJson(Map<String, dynamic> json) =>
      MineVideosCategoryBean(
        title: json["title"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "id": id,
      };
}

class MineVideosManagementProvider extends BaseProvider {
  List<MineVideosCategoryBean> mineVideos = [
    MineVideosCategoryBean.fromJson({"title": "混剪推文", "id": 1}),
    MineVideosCategoryBean.fromJson({"title": "漫画推文", "id": 2}),
    MineVideosCategoryBean.fromJson({"title": "AI口播", "id": 3}),
    MineVideosCategoryBean.fromJson({"title": "文生视频", "id": 4}),
    MineVideosCategoryBean.fromJson({"title": "图生视频", "id": 5}),
    MineVideosCategoryBean.fromJson({"title": "时空拥抱", "id": 6}),
    MineVideosCategoryBean.fromJson({"title": "一键爆款", "id": 7}),
    MineVideosCategoryBean.fromJson({"title": "短剧推广", "id": 8}),
    MineVideosCategoryBean.fromJson({"title": "小说推广", "id": 9}),
  ];

  int selectedCategory = 0;
  updateSelectedCategory(int index) {
    selectedCategory = index;
    notifyListeners();
  }

  /// 是否全选
  bool selectAll = false;
  updateSelectAllStatus(bool select) {
    selectAll = select;
    notifyListeners();
  }

  /// 是否处于编辑状态
  bool videosEditing = false;
  updateWorksEditingState(bool state) {
    videosEditing = state;
    notifyListeners();
  }
}
