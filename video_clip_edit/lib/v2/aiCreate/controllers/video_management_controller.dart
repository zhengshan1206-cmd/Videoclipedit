import 'package:get/get.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/widgets/common/multi_status_view.dart';
import 'package:video_clip_edit/data/model/folk/story_video_bean.dart';
import 'package:video_clip_edit/core/base/controllers/base_controller.dart';
import 'dart:async';

class VideoManagementController extends BaseController {
  var multiStatus = MultiStatusType.statusContent.obs;

  /// 是否全选
  RxBool selectAll = false.obs;

  /// 是否处于编辑状态
  RxBool videosEditing = false.obs;

  /// 选中的视频索引
  RxList<int> selectedVideoIdxs = [].cast<int>().obs;

  /// 视频列表
  var videoRecordBeans = <FolkStoryVideoBean>[].obs;

  /// 是否正在刷新
  RxBool isRefreshing = false.obs;

  /// 防抖定时器
  Timer? _debounceTimer;

  /// 全选视频
  selectOrDeselectAllVideos() {
    if (selectAll.value) {
      selectedVideoIdxs.clear();
    } else {
      selectedVideoIdxs.addAll(videoRecordBeans
          .where((e) =>
              e.status == FolkStoryVideoStatus.finished.rawValue ||
              e.status == FolkStoryVideoStatus.failed.rawValue)
          .map((e) => e.id));
    }
  }

  /// 改变选中的视频索引
  changeSelectedVideoIdxs(FolkStoryVideoBean bean) {
    if (selectedVideoIdxs.contains(bean.id)) {
      selectedVideoIdxs.remove(bean.id);
    } else {
      selectedVideoIdxs.add(bean.id);
    }
  }

  var page = 1.obs;
  final int pageSize = 10;

  /// 获取民间故事列表
  loadFolkStoryList({
    bool isRefresh = false,
  }) {
    if (isRefresh) {
      multiStatus.value = MultiStatusType.statusLoading;
      pageHelper.resetPage();
    }

    HttpUtils.get(
      APIs.folkStoryList,
      {
        "page": pageHelper.page,
        "pageSize": pageHelper.row,
      },
      success: (data) {
        final jsonList = data["data"]["data"] as List;

        final List<FolkStoryVideoBean> beans =
            jsonList.map((e) => FolkStoryVideoBean.fromJson(e)).toList();
        multiStatus.value = MultiStatusType.statusContent;
        if (isRefresh) {
          videoRecordBeans.value = beans;
        } else {
          videoRecordBeans.addElementsByRemovingLast(beans,
              reset: isRefresh,
              pageSize: pageHelper.row,
              currentPage: pageHelper.page);
        }
        final hasMore = beans.length < pageHelper.row ? false : true;

        if (hasMore) {
          pageHelper.addPage();
        }
        isRefreshing.value = false;
        refreshSuccess(isRefresh, hasMore);

        /**
          List listData = data["data"]["items"] ?? [];
        List<AiCartoonBgmBean> dataList = listData.map((e) => AiCartoonBgmBean.fromJson(e)).toList();

        multiStatus.value = MultiStatusType.statusContent;
        if (isRefresh) {
          bgmList.clear();
        }
        bgmList.addAll(dataList);
        if (bgmList.isEmpty) {
          multiStatus.value = MultiStatusType.statusEmpty;
        }
        pageHelper.addPage();

        final hasMore = dataList.length < pageHelper.row ? false : true;
        refreshSuccess(isRefresh, hasMore);

        update();
         */
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        isRefreshing.value = false;
        refreshFailed(isRefresh);
      },
    );
  }

  /// 刷新进度
  refreshProgress() {
    isRefreshing.value = true;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      pageHelper.resetPage();
      loadFolkStoryList(isRefresh: true);
    });
  }

  deleteVideos(
    List<int> ids, {
    void Function()? onSuccess,
  }) {
    //DigitalHuman/deleteDigitalHuman
    HttpUtils.post(
      APIs.deleteFolkStory,
      {"folk_story_ids": ids},
      showLoading: true,
      success: (data) {
        onSuccess?.call();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}
