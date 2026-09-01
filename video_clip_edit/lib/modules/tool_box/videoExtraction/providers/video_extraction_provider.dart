import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/modules/tool_box/beans/extraction_record_bean.dart';
import 'package:video_clip_edit/modules/tool_box/beans/video_tutor_bean.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/utils/comon/by_storage_utils.dart';
import 'package:video_clip_edit/utils/consts/const_keys.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';

class VideoExtractionProvider extends BaseProvider {
  int parsePage = 1;
  int parsePageSize = 10;
  int refCount = 0;
  List<ExtractionRecordBean> extractionRecordBeans = [];
  resetPage() {
    parsePage = 1;
    extractionRecordBeans.clear();
  }

  hasMore() {
    return extractionRecordBeans.length % parsePageSize == 0;
  }

  loadSurpportedPlatforms({
    void Function(String)? onSuccess,
    void Function()? onFailed,
  }) {
    HttpUtils.get(
      APIs.getParseShareUrlConfig,
      {},
      success: (data) {
        byDebugPrint(data);
        final platformTips = data["data"]["platform_tips"] ?? "";
        onSuccess?.call(platformTips);
      },
      fail: (code, msg) {
        onFailed?.call();
        BotToast.showText(text: msg);
      },
    );
  }

  removeRecord({
    required List<String> ids,
    void Function()? onSuccess,
  }) {
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
  }

  loadParseRecords({
    bool refresh = false,
    void Function()? onSuccess,
    void Function()? onFailed,
  }) {
    if (refresh) {
      resetPage();
    }
    HttpUtils.get(
      APIs.getParseList,
      {
        "page": parsePage,
        "pageSize": parsePageSize,
      },
      success: (data) {
        final List records = data["data"]["data"] ?? [];
        List<ExtractionRecordBean> beans =
            records.map((e) => ExtractionRecordBean.fromJson(e)).toList();
        parsePage = extractionRecordBeans.addElementsByRemovingLast(
          beans,
          currentPage: parsePage,
          pageSize: parsePageSize,
        );
        refCount++;
        notifyListeners();
      },
      fail: (code, msg) {
        refCount++;
        notifyListeners();
        BotToast.showText(text: msg);
      },
    );
  }

  int introPage = 1;
  int introPageSize = 10;
  List<VideoTutorBean> tutorBeans = [];
  resetIntroPage() {
    introPage = 1;
    tutorBeans.clear();
  }

  loadTutors({
    void Function()? onSuccess,
  }) {
    HttpUtils.get(
      APIs.videoIntroList,
      {
        "page": introPage,
        "size": introPageSize,
      },
      success: (data) {
        byDebugPrint(data, tag: "攻略：");
        final List items = data["data"]["items"] ?? [];
        final List<VideoTutorBean> beans =
            items.map((e) => VideoTutorBean.fromJson(e)).toList();
        introPage = tutorBeans.addElementsByRemovingLast(
          beans,
          pageSize: introPageSize,
          currentPage: introPage,
        );
        notifyListeners();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///获取攻略信息
  ///展示位置 1：文生视频，2：图生视频，3：小说推文，4：短剧混剪，5：短剧解说，6：音乐生成，7：小说生成，8：数字人，9：文生图 10：爆文创作
  loadStrategyGuideList({
    required int type,
    void Function()? onSuccess,
  }) {
    HttpUtils.get(
      APIs.strategyGuideList,
      {
        "type": type,
        "version": ByStorageUtils.getString(ConstKeys.kAppVersion) ?? "5.0.0",
        "system": Platform.isIOS ? "ios" : "android",
      },
      success: (data) {
        // print('获取攻略信息成功==>${data}');
        byDebugPrint(data, tag: "攻略信息");
        // final List items = data["data"] ?? [];
        // final List<VideoTutorBean> beans =
        //     items.map((e) => VideoTutorBean.fromJson(e)).toList();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }
}
