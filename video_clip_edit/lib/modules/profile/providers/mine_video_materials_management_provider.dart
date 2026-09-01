import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_videos_management_provider.dart';

class MineVideoMaterialsManagementProvider extends BaseProvider {
  List<MineVideosCategoryBean> mineVideos = [
    MineVideosCategoryBean.fromJson({"title": "我的素材", "id": 1}),
    MineVideosCategoryBean.fromJson({"title": "口播视频素材", "id": 2}),
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
