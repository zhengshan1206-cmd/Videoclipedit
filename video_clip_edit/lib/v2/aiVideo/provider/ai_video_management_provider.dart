import 'package:bot_toast/bot_toast.dart';
import '../../../widgets/toast_util.dart';
import '../models/ai_video_generation_model.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'dart:async';

class AiVideoManagementProvider extends BaseProvider {
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
      if (bean.status == AiVideoStatus.done) {
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

  List<AiVideoGenerationTaskModel> videoRecordBeans = [];
  updateVideoRecordBeans(List<AiVideoGenerationTaskModel> beans) {
    videoRecordBeans = beans;
    notifyListeners();
  }

  Timer? _debounceTimer;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  /// 视频列表
  /// [videoQueryType] 数据类型：1仅查询混剪任务 2查询非混剪任务
  loadVideoList() {
    HttpUtils.get(
      "VideoAi/getAiVideoTaskList",
      {
        "page": page,
        "pageSize": size,
      },
      success: (data) {
        final List items = data["data"]["data"] ?? [];
        print("items===> $items");
        List<AiVideoGenerationTaskModel> beans =
            List<AiVideoGenerationTaskModel>.from(
          items.map((e) {
            return AiVideoGenerationTaskModel.fromJson(e);
          }),
        );

        final List<AiVideoGenerationTaskModel> results =
            List<AiVideoGenerationTaskModel>.from(videoRecordBeans);

        page = results.addElementsByRemovingLast(
          beans,
          currentPage: page,
          pageSize: size,
        );
        times++;
        updateVideoRecordBeans(results);
        _isRefreshing = false;
        notifyListeners();
      },
      fail: (code, msg) {
        times++;
        _isRefreshing = false;
        notifyListeners();
        return ToastUtil().showToast(msg);
        // return BotToast.showText(text: msg);
      },
    );
  }

  deleteVideos(
    List<int> ids, {
    void Function()? onSuccess,
  }) {
    HttpUtils.post(
      "VideoAi/deleteAiVideoTask",
      {"ids": ids.join(",")},
      showLoading: true,
      success: (data) {
        onSuccess?.call();
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  /// 刷新进度
  refreshProgress() {
    if (_isRefreshing) return;

    _isRefreshing = true;
    notifyListeners();

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      resetPages();
      loadVideoList();
    });
  }
}
