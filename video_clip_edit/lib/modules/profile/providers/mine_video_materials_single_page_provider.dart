import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/beans/ai_oral_my_video_bean.dart';
import 'package:video_clip_edit/modules/profile/widgets/mine_video_materials_managment_page_view.dart';

class MineVideoMaterialsSinglePageProvider extends BaseProvider {
  bool selectAll = false;
  updateSelectAllStatus(bool select) {
    selectAll = select;
    if (select) {
      selectAllBeans();
    } else {
      deselectAllBeans();
    }
    notifyListeners();
  }

  List<int> selectedVideoIdxs = [];
  updateSelectedVideoIdxsWithIndex(int id) {
    final selectedIdx = List<int>.from(selectedVideoIdxs);
    if (selectedIdx.contains(id)) {
      selectedIdx.remove(id);
    } else {
      selectedIdx.add(id);
    }
    selectedVideoIdxs = selectedIdx;
    notifyListeners();
  }

  selectAllBeans() {
    final selectedIdx = List<int>.from(selectedVideoIdxs);
    selectedIdx.clear();

    for (var bean in videoRecordBeans) {
      if (bean.status != 1) {
        selectedIdx.add(videoRecordBeans.indexOf(bean));
      }
    }
    selectedVideoIdxs = selectedIdx;
    notifyListeners();
  }

  deselectAllBeans() {
    final selectedIdx = List<int>.from(selectedVideoIdxs);
    selectedIdx.clear();
    selectedVideoIdxs = selectedIdx;
    notifyListeners();
  }

  bool videosEditing = false;
  updateWorksEditingState(bool state) {
    videosEditing = state;
    notifyListeners();
  }

  int page = 1;
  int size = 10;
  int times = 0;

  /// 我的视频列表
  List<AiOralMyVideoBean> videoRecordBeans = [];
  updateVideoRecordBeans(List<AiOralMyVideoBean> beans) {
    videoRecordBeans = beans;
    notifyListeners();
  }

  _resetPages() {
    page = 1;
    videoRecordBeans.clear();
  }

  loadVideoList({
    required MineVideoMaterialsPageType type,
    bool isRefresh = false,
    void Function()? onFailed,
    void Function(bool hasMore)? onSuccess,
  }) {
    if (isRefresh) {
      _resetPages();
    }

    final params = type == MineVideoMaterialsPageType.mineMaterials
        ? {"page": page, "size": size, "type": "video", 'is_ai': 2, "is_only_digital": 2}
        : {"page": page, "size": size, "type": "video", 'is_ai': 2, "is_only_digital": 1};
    HttpUtils.get(
      APIs.customBgmList,
      params,
      success: (data) {
        final List videoData = data["data"]["items"] ?? [];
        final List<AiOralMyVideoBean> beans =
            videoData.map((e) => AiOralMyVideoBean.fromJson(e)).toList();
        times++;
        final results = List<AiOralMyVideoBean>.from(videoRecordBeans);
        page = results.addElementsByRemovingLast(beans);
        updateVideoRecordBeans(results);
        onSuccess?.call(beans.isNotEmpty && beans.length % size == 0);
      },
      fail: (code, msg) {
        times++;
        BotToast.showText(text: msg);
        onFailed?.call();
      },
    );
  }

  deleteVideos(
    List<int> ids, {
    void Function()? onSuccess,
  }) {
    HttpUtils.post(
      APIs.deleteUserVideo,
      {"id": ids.join(",")},
      showLoading: true,
      success: (data) {
        onSuccess?.call();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }
}
