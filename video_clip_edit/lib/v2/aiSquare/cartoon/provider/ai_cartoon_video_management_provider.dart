import 'dart:io';
import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_video_record_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_settings_mixin.dart';

import '../../../../utils/comon/by_storage_utils.dart';
import '../../../../utils/consts/const_keys.dart';
import '../beans/kuaishou_douyin_model.dart';

class AiCartoonVideoManagementProvider extends BaseProvider {
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
      if (bean.status == 5) {
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

  ///抖音快手的数据
  KShouDYinModel? kShouDYinModel;

  Timer? _debounceTimer;

  ///刷新
  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

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
  /// [videoQueryType] 数据类型：1仅查询混剪任务 2查询非混剪任务
  loadVideoList({
    int? videoQueryType,
    EntranceSource source = EntranceSource.normal,
  }) {
    dynamic params = {
      "need_delete": 0,
      "page": page,
      "size": size,
      "video_query_type": videoQueryType,
      "entrance_source": 1,
    };

    if (source == EntranceSource.shortPlay) {
      params = {
        "need_delete": 0,
        "page": page,
        "size": size,
        "entrance_source": source.rawValue,
      };
    } else if (source == EntranceSource.explosive) {
      params = {
        "need_delete": 0,
        "page": page,
        "size": size,
        "entrance_source": source.rawValue,
      };
    }
    HttpUtils.get(
      APIs.videoList,
      params,
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

  ///新增 在短剧视频里获取 抖音快手 信息
  loadDouYinOrKShou({
    int type = 5,
    void Function()? onSuccess,
    int? platform,
  }) {
    HttpUtils.get(
      APIs.strategyGuideList,
      {
        "type": 5,
        // "version": ByStorageUtils.getString(ConstKeys.kAppVersion) ?? "5.0.0",
        // "system": Platform.isIOS ? "ios" : "android",
        "platform": platform,
      },
      success: (data) {
        Get.log("抖音快手data~~~ $data");
        if (data["status"] == 200) {
          if (data["data"] != null) {
            kShouDYinModel = KShouDYinModel.fromJson(json: data["data"]);
            Get.log("抖音快手model~~~~~~~ ${kShouDYinModel?.compr}");
            notifyListeners();
            if (onSuccess != null) {
              onSuccess();
            }
          }
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 刷新进度
  refresh() {
    _isRefreshing = true;
    notifyListeners();
  }
}
