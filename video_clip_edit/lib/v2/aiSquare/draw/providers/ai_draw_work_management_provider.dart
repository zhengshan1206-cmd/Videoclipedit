import 'dart:async';
import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/beans/ai_draw_img_details_bean.dart';

class AiDrawWorkManagementProvider extends BaseProvider {
  bool selectAll = false;
  updateSelectAllStatus(bool select) {
    selectAll = select;
    if (select) {
      selectAllBeans();
    } else {
      deselectAllBeans();
    }
    // notifyListeners();
  }

  List<int> selectedWorkIdxs = [];
  updateSelectedWorkIdxsWithIndex(int id) {
    final selectedIdx = List<int>.from(selectedWorkIdxs);
    if (selectedIdx.contains(id)) {
      selectedIdx.remove(id);
    } else {
      selectedIdx.add(id);
    }
    selectedWorkIdxs = selectedIdx;
    notifyListeners();
  }

  selectAllBeans() {
    final selectedIdx = List<int>.from(selectedWorkIdxs);
    selectedIdx.clear();
    for (var bean in workRecordBeans) {
      if (bean.status == 3) {
        selectedIdx.add(workRecordBeans.indexOf(bean));
      }
    }
    selectedWorkIdxs = selectedIdx.toSet().toList();
    notifyListeners();
  }

  deselectAllBeans() {
    final selectedIdx = List<int>.from(selectedWorkIdxs);
    selectedIdx.clear();
    selectedWorkIdxs = selectedIdx;
    notifyListeners();
  }

  bool worksEditing = false;
  updateWorksEditingState(bool state) {
    worksEditing = state;
    notifyListeners();
  }

  int page = 1;
  int size = 10;
  int times = 0;
  Timer? _debounceTimer;
  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  resetPages() {
    page = 1;
    workRecordBeans.clear();
  }

  List<AiDrawImgDetailsBean> workRecordBeans = [];
  updateWorkRecordBeans(List<AiDrawImgDetailsBean> beans) {
    workRecordBeans = beans;
    notifyListeners();
  }

  /// 视频列表
  loadPictureList() {
    log("====page===>  $page");
    HttpUtils.get(
      APIs.allAiPictures,
      {"page": page, "size": size},
      success: (data) {
        times++;
        final List items = data["data"]["items"] ?? [];
        List<AiDrawImgDetailsBean> beans = List<AiDrawImgDetailsBean>.from(
          items.map((e) {
            return AiDrawImgDetailsBean.fromJson(e);
          }),
        );

        final List<AiDrawImgDetailsBean> results =
            List<AiDrawImgDetailsBean>.from(workRecordBeans);

        page = results.addElementsByRemovingLast(
          beans,
          currentPage: page,
          pageSize: size,
        );
        updateWorkRecordBeans(results);
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

/*
  /// 加载我的作品
  loadAllPictures({
    int page = 1,
    int size = 10,
    void Function(List<AiDrawImgDetailsBean>)? onSuccess,
    void Function()? onFailed,
  }) {
    HttpUtils.get(
      APIs.allAiPictures,
      {"page": page, "size": size},
      // showLoading: true,
      success: (data) {
        final workData = data["data"]["items"];

        if (workData == null) {
          onFailed?.call();
          return;
        }

        final beans = List<AiDrawImgDetailsBean>.from(
          workData.map(
            (e) => AiDrawImgDetailsBean.fromJson(e),
          ),
        );
        onSuccess?.call(beans);
      },
      fail: (code, msg) {
        onFailed?.call();
        BotToast.showText(text: msg);
      },
    );
  }
*/
  deletePictures(
    List<int> ids, {
    void Function()? onSuccess,
  }) {
    HttpUtils.get(
      APIs.batchDeletePictures,
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

  //刷新进度-绘图
  refreshProgress() {
    _isRefreshing = true;
    notifyListeners();
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      resetPages();
      loadPictureList();
    });
  }
}
