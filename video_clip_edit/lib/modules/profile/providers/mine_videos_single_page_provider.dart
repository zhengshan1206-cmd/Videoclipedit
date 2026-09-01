import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/v2/aiVideo/models/ai_video_generation_model.dart';
import 'package:video_clip_edit/v2/aiOralVideos/beans/ai_oral_video_item_bean.dart';
import 'package:video_clip_edit/modules/tool_box/beans/extraction_record_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_video_record_bean.dart';
import 'package:video_clip_edit/modules/profile/widgets/mine_videos_management_gride_view.dart';

class MineVideosSinglePageProvider extends BaseProvider {
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
    for (var bean in oralVideoRecordBeans) {
      if (bean.status == 4 || bean.status == 5) {
        selectedIdx.add(oralVideoRecordBeans.indexOf(bean));
      }
    }
    for (var bean in dynamicRecordBeans) {
      if (bean.status == AiVideoStatus.done ||
          bean.status == AiVideoStatus.failed) {
        selectedIdx.add(dynamicRecordBeans.indexOf(bean));
      }
    }
    for (var bean in videoExtractBeans) {
      selectedIdx.add(videoExtractBeans.indexOf(bean));
    }
    for (var bean in hotRecordBeans) {
      if (bean.status == 4 || bean.status == 5) {
        selectedIdx.add(hotRecordBeans.indexOf(bean));
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

  /// 混剪/推文视频列表
  List<AiCartoonVideoRecordBean> videoRecordBeans = [];
  updateVideoRecordBeans(List<AiCartoonVideoRecordBean> beans) {
    videoRecordBeans = beans;
    notifyListeners();
  }

  List<AiOralVideotemBean> oralVideoRecordBeans = [];
  updateOralVideoRecordBeans(List<AiOralVideotemBean> beans) {
    oralVideoRecordBeans = beans;
    notifyListeners();
  }

  List<AiVideoGenerationTaskModel> dynamicRecordBeans = [];
  updateDynamicVideoRecordBeans(List<AiVideoGenerationTaskModel> beans) {
    dynamicRecordBeans = beans;
    notifyListeners();
  }

  List<ExtractionRecordBean> videoExtractBeans = [];
  updateVideoExtractBeans(List<ExtractionRecordBean> beans) {
    videoExtractBeans = beans;
    notifyListeners();
  }

  List<AiCartoonVideoRecordBean> hotRecordBeans = [];
  updateHotRecordBeans(List<AiCartoonVideoRecordBean> beans) {
    hotRecordBeans = beans;
    notifyListeners();
  }

  _resetPages(MineVideoType type) {
    page = 1;
    switch (type) {
      case MineVideoType.aiClip:
      case MineVideoType.aiTweets:
      case MineVideoType.playPromote:
      case MineVideoType.novelPromote:
        videoRecordBeans.clear();
        break;
      case MineVideoType.oral:
        oralVideoRecordBeans.clear();
        break;
      case MineVideoType.textToVideo:
      case MineVideoType.imgToVideo:
      case MineVideoType.embraceVideo:
        dynamicRecordBeans.clear();
        break;
      case MineVideoType.hot:
        hotRecordBeans.clear();
        break;
      // case MineVideoType.playPromote:
      //   videoExtractBeans.clear();
      // break;
    }
  }

  loadVideoList({
    required MineVideoType type,
    bool isRefresh = false,
    void Function(bool hasMore)? onSuccess,
    void Function()? onFailed,
  }) {
    if (isRefresh) {
      _resetPages(type);
    }
    switch (type) {
      case MineVideoType.aiClip:
      case MineVideoType.aiTweets:
      case MineVideoType.playPromote:
      case MineVideoType.novelPromote:
        dynamic params = {
          "need_delete": 0,
          "page": page,
          "size": size,
          "video_query_type": MineVideoType.aiClip == type ? 1 : 2,
          "entrance_source": 1,
        };

        if (type == MineVideoType.novelPromote) {
          params = {
            "need_delete": 0,
            "page": page,
            "size": size,
            "entrance_source": 3,
          };
        } else if (type == MineVideoType.playPromote) {
          params = {
            "need_delete": 0,
            "page": page,
            "size": size,
            "entrance_source": 2,
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
            onSuccess?.call(beans.isNotEmpty && beans.length % 10 == 0);
          },
          fail: (code, msg) {
            times++;
            BotToast.showText(text: msg);
            onFailed?.call();
          },
        );
        break;

      case MineVideoType.oral:
        HttpUtils.get(
          APIs.getDigitalHumanList,
          {
            "page": page,
            "pageSize": size,
          },
          success: (data) {
            final List items = data["data"]["data"] ?? [];
            List<AiOralVideotemBean> beans = List<AiOralVideotemBean>.from(
              items.map((e) {
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
            updateOralVideoRecordBeans(results);
            onSuccess?.call(beans.isNotEmpty && beans.length % 10 == 0);
          },
          fail: (code, msg) {
            times++;
            BotToast.showText(text: msg);
            onFailed?.call();
          },
        );
        break;

      case MineVideoType.textToVideo:
      case MineVideoType.imgToVideo:
      case MineVideoType.embraceVideo:
        HttpUtils.get(
          "VideoAi/getAiVideoTaskList",
          {"page": page, "pageSize": size, "type": type.rawValue - 3},
          success: (data) {
            final List items = data["data"]["data"] ?? [];
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
            updateDynamicVideoRecordBeans(results);
            onSuccess?.call(beans.isNotEmpty && beans.length % 10 == 0);
          },
          fail: (code, msg) {
            times++;
            BotToast.showText(text: msg);
            onFailed?.call();
          },
        );
        break;

      case MineVideoType.hot:
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
                List<AiCartoonVideoRecordBean>.from(hotRecordBeans);

            page = results.addElementsByRemovingLast(
              beans,
              currentPage: page,
              pageSize: size,
            );
            times++;
            updateHotRecordBeans(results);
          },
          fail: (code, msg) {
            times++;
            return BotToast.showText(text: msg);
          },
        );
        break;
      case MineVideoType.playPromote:
        HttpUtils.get(
          APIs.getParseList,
          {
            "page": page,
            "pageSize": size,
          },
          success: (data) {
            final List records = data["data"]["data"] ?? [];
            List<ExtractionRecordBean> beans =
                records.map((e) => ExtractionRecordBean.fromJson(e)).toList();

            final List<ExtractionRecordBean> results =
                List<ExtractionRecordBean>.from(videoExtractBeans);
            page = results.addElementsByRemovingLast(
              beans,
              currentPage: page,
              pageSize: size,
            );
            times++;
            updateVideoExtractBeans(results);
            onSuccess?.call(beans.isNotEmpty && beans.length % 10 == 0);
          },
          fail: (code, msg) {
            times++;
            BotToast.showText(text: msg);
            onFailed?.call();
          },
        );
        break;
      default:
    }
  }

  deleteVideos(
    List<int> ids, {
    required MineVideoType type,
    void Function()? onSuccess,
  }) {
    switch (type) {
      case MineVideoType.aiClip:
      case MineVideoType.aiTweets:
      case MineVideoType.playPromote:
      case MineVideoType.novelPromote:
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
        break;
      case MineVideoType.hot:
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
        break;
      case MineVideoType.oral:
        HttpUtils.post(
          APIs.deleteDigitalHuman,
          {"id": ids.join(",")},
          showLoading: true,
          success: (data) {
            onSuccess?.call();
          },
          fail: (code, msg) {
            BotToast.showText(text: msg);
          },
        );
        break;
      case MineVideoType.textToVideo:
      case MineVideoType.imgToVideo:
      case MineVideoType.embraceVideo:
        HttpUtils.post(
          "VideoAi/deleteAiVideoTask",
          {"ids": ids.join(",")},
          showLoading: true,
          success: (data) {
            onSuccess?.call();
          },
          fail: (code, msg) {
            BotToast.showText(text: msg);
          },
        );
        break;
      case MineVideoType.playPromote:
        HttpUtils.post(
          APIs.parseDelete,
          {"ids": ids.join(",")},
          showLoading: true,
          success: (data) {
            onSuccess?.call();
          },
          fail: (code, msg) {
            BotToast.showText(text: msg);
          },
        );
        break;
      default:
    }
  }
}
