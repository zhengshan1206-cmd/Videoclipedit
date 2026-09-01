import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/aiOralVideos/ai_oral_video_management_page.dart';
import 'package:video_clip_edit/v2/aiOralVideos/beans/ai_oral_video_item_bean.dart';
// import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_video_record_bean.dart';

class AiOralVideoManagementProvider extends BaseProvider {
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
  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  resetPages() {
    page = 1;
    videoRecordBeans.clear();
  }

  List<AiOralVideotemBean> videoRecordBeans = [];
  updateVideoRecordBeans(List<AiOralVideotemBean> beans) {
    videoRecordBeans = beans;
    notifyListeners();
  }

  /// 视频列表
  loadVideoList({ManagementRecord type = ManagementRecord.aiOral}) {
    Map<String, dynamic> params = {
      "page": page,
      "pageSize": size,
    };
    if (type == ManagementRecord.aiAnime) {
      params['type'] = 1;
    }
    HttpUtils.get(
      type == ManagementRecord.aiOral
          ? APIs.getDigitalHumanList
          : APIs.animeRecord,
      params,
      success: (data) {
        byDebugPrint(data, tag: "getDigitalHumanList===>");
        final List items = data["data"]["data"] ?? [];
        List<AiOralVideotemBean> beans = List<AiOralVideotemBean>.from(
          items.map((e) {
            if (type == ManagementRecord.aiAnime) {
              return AiOralVideotemBean.animeFromJson(e);
            }
            return AiOralVideotemBean.fromJson(e);
          }),
        );

        final List<AiOralVideotemBean> results =
            List<AiOralVideotemBean>.from(videoRecordBeans);

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
        return BotToast.showText(text: msg);
      },
    );
  }

  deleteVideos(
    List<int> ids, {
    ManagementRecord? type,
    void Function()? onSuccess,
  }) {
    //DigitalHuman/deleteDigitalHuman
    HttpUtils.post(
      type == ManagementRecord.aiOral
          ? APIs.deleteDigitalHuman
          : APIs.animeDelete,
      {type == ManagementRecord.aiOral ? "id" : "ids": ids.join(",")},
      showLoading: true,
      success: (data) {
        onSuccess?.call();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  Timer? _debounceTimer;

  /// 刷新进度
  refreshProgress({ManagementRecord type = ManagementRecord.aiOral}) {
    _isRefreshing = true;
    notifyListeners();
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      resetPages();
      loadVideoList(type: type);
    });
  }
}
