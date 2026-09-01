import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/modules/home/beans/function_item_bean.dart';
import 'package:video_clip_edit/modules/home/beans/words_task_cell_bean.dart';

enum MediaType {
  /// 视频提取
  video,

  /// 音频提取
  audio,

  /// 图片提取
  picture,

  /// 链接提取
  link,
}

extension MediaTypeEx on MediaType {
  String get rawValue {
    switch (this) {
      case MediaType.video:
        return "视频提取";
      case MediaType.audio:
        return "音频提取";
      case MediaType.picture:
        return "图片提取";
      case MediaType.link:
        return "链接提取";
    }
  }

  String get typeValue {
    switch (this) {
      case MediaType.video:
        return "video";
      case MediaType.audio:
        return "audio";
      case MediaType.picture:
        return "image";
      case MediaType.link:
        return "link";
    }
  }

  RequestType get uploadFileType {
    switch (this) {
      case MediaType.video:
        return RequestType.video;
      case MediaType.audio:
        return RequestType.audio;
      case MediaType.picture:
        return RequestType.image;
      case MediaType.link:
        return RequestType.common;
    }
  }
}

const querySts = "ffmpeg -i input_video.mp4 -q:a 0 -map a output_audio.mp3";

class WordsExtractProvider extends BaseProvider {
  /// 识别的图片文字
  String extractedContent = "";
  updateExtractedContent(String cts) {
    extractedContent = cts;
    notifyListeners();
  }

  WordsExtractProvider() {
    loadRecords();
  }

  final functionList = [
    FunctionItemBean.fromJson({
      "icon": "assets/home/watermark_links.png",
      "title": "链接提取",
      "desc": "提取短视频链接里面的文案"
    }),
    FunctionItemBean.fromJson({
      "icon": "assets/home/watermark_video.png",
      "title": "视频提取",
      "desc": "提取视频里面的文案"
    }),
    FunctionItemBean.fromJson({
      "icon": "assets/home/watermark_upload.png",
      "title": "图片提取",
      "desc": "提取图片里面的文案"
    }),
    FunctionItemBean.fromJson({
      "icon": "assets/home/watermark_my_woks.png",
      "title": "音频提取",
      "desc": "提取音频里面的文案"
    }),
  ];

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

  int page = 1;
  int pageSize = 10;
  int refCount = 0;

  /// 加载提取纪录
  void loadRecords() {
    HttpUtils.get(
      APIs.getExtractTextList,
      {
        "page": page,
        "pageSize": pageSize,
        // "type": "Advanced",
        // "file_type": 1,
      },
      success: (data) {
        List records = data["data"]["data"] ?? [];
        final List<WordsTaskCellBean> beans =
            records.map((e) => WordsTaskCellBean.fromJson(e)).toList();
        byDebugPrint(beans.length, tag: "提取纪录：");
        page = taskBeans.addElementsByRemovingLast(
          beans,
          currentPage: page,
          pageSize: pageSize,
        );
        refCount++;
        updateTaskBeans(taskBeans);
      },
      fail: (code, msg) {
        refCount++;
        BotToast.showText(text: msg);
      },
    );
  }

  /// 删除提取纪录
  void deleteRecords(List<String> ids) {
    HttpUtils.post(
      APIs.extractTextBatchDelete,
      {
        "ids": ids.join(","),
      },
      success: (data) {
        byDebugPrint(data, tag: "删除提取纪录:");
        BotToast.showText(text: data["message"]);
        page = 1;
        loadRecords();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  List<WordsTaskCellBean> taskBeans = [];
  updateTaskBeans(List<WordsTaskCellBean> beans) {
    taskBeans = beans;
    notifyListeners();
  }

  resetPages() {
    taskBeans.clear();
    page = 1;
  }
}
