import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';

import '../models/ai_photo_fix_task_model.dart';

class AiPhotoFixManagementProvider extends BaseProvider {
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
      if (bean.status == AiPhotoFixStatus.done) {
        selectedIdx.add(videoRecordBeans.indexOf(bean));
      }
    }
    selectedVideoIdxs = selectedIdx;
    notifyListeners();
  }

  deselectAllBeans() {
    selectedVideoIdxs = [];
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

  List<AiPhotoFixTaskModel> videoRecordBeans = [];
  updateVideoRecordBeans(List<AiPhotoFixTaskModel> beans) {
    videoRecordBeans = beans;
    notifyListeners();
  }

  /// 视频列表
  /// type=1  高清修复
  /// type=2  老照片修复
  loadVideoList({
    required int type,
  }) {
    HttpUtils.get(
      "image/getRefixImageList",
      {
        "page": page,
        "pageSize": size,
        "type": type,
      },
      success: (data) {
        final List items = data["data"]["data"] ?? [];
        List<AiPhotoFixTaskModel> beans = List<AiPhotoFixTaskModel>.from(
          items.map((e) {
            return AiPhotoFixTaskModel.fromJson(e);
          }),
        );

        final List<AiPhotoFixTaskModel> results =
            List<AiPhotoFixTaskModel>.from(videoRecordBeans);

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

  void refreshTaskStatus(int id) async {
    HttpUtils.get(
      "image/getRefixImageTask",
      {"id": id},
      showLoading: true,
      success: (data) {
        final AiPhotoFixTaskModel bean =
            AiPhotoFixTaskModel.fromJson(data["data"]);
        final List<AiPhotoFixTaskModel> results =
            List<AiPhotoFixTaskModel>.from(videoRecordBeans);
        final index = results.indexWhere((element) => element.id == id);
        if (index != -1) {
          results[index] = bean;
        }
        updateVideoRecordBeans(results);
      },
      fail: (code, msg) {
        return BotToast.showText(text: msg);
      },
    );
  }

  deleteVideos(
    List<int> ids, {
    void Function()? onSuccess,
  }) {
    HttpUtils.post(
      "image/deleteRefixImageTask",
      {"ids": ids.join(",")},
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
