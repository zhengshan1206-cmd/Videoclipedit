import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_video_record_bean.dart';

class ReplicaVideoManagementProvider extends BaseProvider {
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
      if (bean.status == 4 || bean.status == 5) {
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

  resetPages() {
    page = 1;
    videoRecordBeans.clear();
  }

  List<AiCartoonVideoRecordBean> videoRecordBeans = [];
  updateVideoRecordBeans(List<AiCartoonVideoRecordBean> beans) {
    videoRecordBeans = beans;
    notifyListeners();
  }

  /// 视频列表
  loadVideoList({
    bool isRefresh = false,
  }) {
    HttpUtils.get(
      APIs.videoList,
      {
        "need_delete": 0,
        "page": page,
        "size": size,
        "platform": "hotCopy",
      },
      success: (data) {
        final List items = data["data"]["items"] ?? [];
        List<AiCartoonVideoRecordBean> beans =
            List<AiCartoonVideoRecordBean>.from(
          items.map((e) {
            return AiCartoonVideoRecordBean.fromJson(e);
          }),
        );

        final List<AiCartoonVideoRecordBean> results =
            List<AiCartoonVideoRecordBean>.from(videoRecordBeans);

        page = results.addElementsByRemovingLast(
          beans,
          currentPage: page,
          pageSize: size,
        );
        times++;
        updateVideoRecordBeans(results);
      },
      fail: (code, msg) {
        times++;
        return BotToast.showText(text: msg);
      },
    );
  }

  deleteVideos(
    List<int> ids, {
    void Function()? onSuccess,
  }) {
    HttpUtils.post(
      APIs.batchDeleteMyWork,
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

  // deleteVideos(
  //   List<int> ids, {
  //   void Function()? onSuccess,
  // }) {
  //   //DigitalHuman/deleteDigitalHuman
  //   HttpUtils.post(
  //     APIs.deleteDigitalHuman,
  //     {"id": ids.join(",")},
  //     showLoading: true,
  //     success: (data) {
  //       onSuccess?.call();
  //     },
  //     fail: (code, msg) {
  //       BotToast.showText(text: msg);
  //     },
  //   );
  // }
}
