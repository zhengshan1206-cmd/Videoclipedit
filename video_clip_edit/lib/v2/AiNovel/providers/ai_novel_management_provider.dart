import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/AiNovel/models/ai_novel_model.dart';

import '../../../widgets/toast_util.dart';
import '../models/ai_novel_generation_model.dart';

class AiNovelManagementProvider extends BaseProvider {
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

  List<int> selectedNovelIdxs = [];
  updateSelectedNovelIdxsWithIndex(int id) {
    final selectedIdx = List<int>.from(selectedNovelIdxs);
    if (selectedIdx.contains(id)) {
      selectedIdx.remove(id);
    } else {
      selectedIdx.add(id);
    }
    selectedNovelIdxs = selectedIdx;
    notifyListeners();
  }

  selectAllBeans() {
    final selectedIdx = List<int>.from(selectedNovelIdxs);
    selectedIdx.clear();
    for (var bean in recordBeans) {
      if (bean.status == AiNovelStatus.done) {
        selectedIdx.add(recordBeans.indexOf(bean));
      }
    }
    selectedNovelIdxs = selectedIdx;
    notifyListeners();
  }

  deselectAllBeans() {
    selectedNovelIdxs = [];
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
    recordBeans.clear();
  }

  List<AiNovelGenerationTaskModel> recordBeans = [];
  updateNovelRecordBeans(List<AiNovelGenerationTaskModel> beans) {
    recordBeans = beans;
    notifyListeners();
  }

  /// 视频列表
  /// [videoQueryType] 数据类型：1仅查询混剪任务 2查询非混剪任务
  loadNovelList() {
    HttpUtils.get(
      "AiNovel/getTaskList",
      {
        "page": page,
        "pageSize": size,
      },
      success: (data) {
        final List items = data["data"]["data"] ?? [];
        List<AiNovelGenerationTaskModel> beans =
            List<AiNovelGenerationTaskModel>.from(
          items.map((e) {
            return AiNovelGenerationTaskModel.fromJson(e);
          }),
        );

        final List<AiNovelGenerationTaskModel> results =
            List<AiNovelGenerationTaskModel>.from(recordBeans);

        page = results.addElementsByRemovingLast(
          beans,
          currentPage: page,
          pageSize: size,
        );
        times++;
        updateNovelRecordBeans(results);
      },
      fail: (code, msg) {
        times++;
        // return BotToast.showText(text: msg);
       return ToastUtil().showToast(msg);
      },
    );
  }

  deleteNovels(
    List<int> ids, {
    void Function()? onSuccess,
  }) {
    HttpUtils.post(
      "AiNovel/deleteTask",
      {"id": ids.join(",")},
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

  Future<void> renameNovel(
    AiNovelGenerationTaskModel novel,
    String title, {
    VoidCallback? onSuccess,
  }) async {
    HttpUtils.post(
      "AiNovel/renameTask",
      {"id": novel.id.toString(), "title": title},
      showLoading: true,
      success: (data) {
        novel.title = title;
        notifyListeners();
        onSuccess?.call();
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);

      },
    );
  }

  export({
    List<int>? ids,
    required String type,
    void Function(List<String> urls)? onSuccess,
  }) {
    ids ??= selectedNovelIdxs
        .map((index) => recordBeans[index])
        .where((n) => n.status == AiNovelStatus.done)
        .map((n) => n.id)
        .toList();

    HttpUtils.post(
      APIs.exportAiNovelBatch,
      {
        "ids": ids.join(','),
        "type": type,
      },
      success: (data) {
        final url = data["data"]["urls"] ?? [];
        onSuccess?.call(url.cast<String>());
      },
      fail: (code, msg) {
        BotToast.showText(text: "导出失败，请稍后再试");
      },
    );
  }

  Future<AiNovelModel> getNovel(
    int id, {
    bool showLoading = true,
    void Function(AiNovelModel)? onSuccess,
  }) {
    final completer = Completer<AiNovelModel>();
    HttpUtils.get(
      "AiNovel/getTaskInfo",
      {
        "id": id,
      },
      showLoading: showLoading,
      success: (data) {
        final novel = AiNovelModel.fromJson(data["data"]);
        completer.complete(novel);
        onSuccess?.call(novel);
      },
      fail: (code, msg) {
        completer.completeError(msg);
        if (showLoading) {
          // BotToast.showText(text: msg);
          ToastUtil().showToast(msg);

        }
      },
    );
    return completer.future;
  }
}
