import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/consts/const.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/modules/home/beans/text_risk_bean.dart';
import 'package:video_clip_edit/modules/home/clipped/beans/dubbing_bean.dart';
import 'package:video_clip_edit/modules/home/clipped/beans/bgm_item_bean.dart';
import 'package:video_clip_edit/modules/home/clipped/beans/bgm_category_bean.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/modules/purchase/widgets/dailog_bonus_lowest_price.dart';

import '../../../widgets/toast_util.dart';

class ClippedProvider extends MaterialBaseProvider {
  @override
  MaterialProviderType get type => MaterialProviderType.clip;
  ClippedProvider() {
    loadBanners(postion: 9);
  }

  /// 创建作品
  /// 现在的逻辑是 只有一个文件
  @override
  Future<void> addNewWork(
    List<dynamic> assets, {
    void Function(dynamic)? onSuccess,
  }) async {
    var details = [];
    for (var ele in assets) {
      if (ele is AssetEntity) {
        File? file = await ele.file;
        if (file == null) continue;
        details.add({
          "file_url": file.path,

          /// 文件类型 3视频 4图片
          "file_type": ele.duration > 0 ? 3 : 4,
          "file_cover_url": file.path,
        });
      } else if (ele is File) {
        details.add({
          "file_url": ele.path,

          /// 文件类型 3视频 4图片
          "file_type": ele.path.contains(".mp4") ? 3 : 4,
          "file_cover_url": ele.path,
        });
      }
    }

    HttpUtils.post(
      APIs.createUserWork,
      {
        // "file_cover_url": flePath,
        // "file_url": flePath,
        "type": Consts.kUserWorkLogTypeClip,
        "details": details,
      },
      showMsgWhenFailed: false,
      success: (data) {
        onSuccess?.call(data);
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  /// 视频合成
  Future<String?> videoComposition(List files) async {
    return null;
    // if (files.isEmpty) {
    //   BotToast.showText(text: "请先选择素材");
    //   return null;
    // }

    // List<String> filePaths = [];
    // for (var asset in files) {
    //   if (asset is AssetEntity) {
    //     File? file = await asset.file;
    //     if (file != null) {
    //       filePaths.add(file.path);
    //     }
    //   } else if (asset is File) {
    //     filePaths.add(asset.path);
    //   }
    // }

    // final data = await ChannelOperate.toVideoEdit(
    //   false,
    //   isShowLoadDialog: true,
    //   isSavePhoto: false,
    //   dialogTitle: "视频编辑中",
    //   isExportVideo: true,
    //   videoLocalFilePathParameter: filePaths,
    // );
    // try {
    //   if (data == null) return null;
    //   return data["edit_result"];
    // } catch (e) {
    //   byDebugPrint(e);
    //   return null;
    // }
  }

  // /// 1自建鉴黄规则
  // /// 2ZAKER鉴黄
  // /// 3第三方 5118检测
  // textRisk({
  //   String? type,
  //   String? needMark,
  //   required String content,
  //   void Function(dynamic)? onSuccess,
  // }) {
  //   HttpUtils.post(
  //     APIs.textRisk,
  //     {
  //       "type": type ?? "3",
  //       "needMark": needMark ?? "2",
  //       "labelType": "499001",
  //       "content": content,
  //     },
  //     forceData: true,
  //     success: (data) {
  //       onSuccess?.call(data);
  //     },
  //     fail: (code, msg) {
  //       BotToast.showText(text: msg);
  //     },
  //   );
  // }

  @override
  loadDubbingList({
    void Function(List<DubbingBean>)? onSuccess,
  }) {
    HttpUtils.post(
      APIs.speakerList,
      {
        "platform": "volcengine",
        "size": 999,
      },
      success: (data) {
        // DubbingBean
        byDebugPrint(data, tag: "配音列表:");
        final List speakerList = data["data"]["items"] ?? [];
        List<DubbingBean> beans =
            speakerList.map((e) => DubbingBean.fromJson(e)).toList();
        updateDubbingBeans(beans);
        onSuccess?.call(beans);
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  @override
  loadStyles({
    void Function(List<String> styles)? onSuccess,
  }) {
    HttpUtils.get(
      APIs.voiceStyle,
      {},
      showLoading: true,
      success: (data) {
        final List<String> styleData = (data["data"] ?? []).cast<String>();
        updateStyles(styleData);
        onSuccess?.call(styleData);
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  @override
  changeVoiceStyle({
    void Function(String taskId)? onSuccess,
  }) {
    HttpUtils.post(
      APIs.optimizeText,
      {
        "text": subtitlesBean.wordsOrigin,
        "style": selectedStyle,
      },
      showLoading: false,
      success: (data) {
        final taskId = data["data"]["task_id"] ?? "";
        onSuccess?.call(taskId);
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  @override
  queryVoiceStyleOptimizeState({
    required String taskId,
    void Function(String result)? onSuccess,
  }) {
    HttpUtils.get(
      APIs.queryOptimizeTextState,
      {"task_id": taskId},
      success: (data) {
        final resData = data["data"];
        final status = resData["status"] ?? "-1";

        if (status == "200") {
          EasyLoading.dismiss();
          final wordsStr = resData["data"];
          // 将 JSON 字符串转换为 Dart 对象 (Map)
          Map<String, dynamic> result = json.decode(wordsStr);
          final words = result["text"];
          onSuccess?.call(words ?? "");
        } else if (status == "500") {
          EasyLoading.dismiss();
          BotToast.showText(text: "修改失败，请稍后再试");
        } else {
          Future.delayed(const Duration(milliseconds: 1000), () {
            queryVoiceStyleOptimizeState(taskId: taskId, onSuccess: onSuccess);
          });
        }
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  @override
  loadBgmCateoryList() {
    HttpUtils.get(
      APIs.bgmCategoryList,
      {},
      success: (data) {
        final List bgmCateData = data["data"]["items"] ?? [];
        final beans = bgmCateData
            .map((e) => BgmCategoryBean.fromJson(e))
            .toList()
            .cast<BgmCategoryBean>();
        updateBgmCategoryBeans(beans);

        if (beans.isNotEmpty) {
          /// 默认选中第一个分类
          updateSelectedBgmCategoryIdx(0);
          loadBgmList();
        }
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  int bgmPage = 1;
  int bgmPageSize = 10;

  resetBgm() {
    bgmPage = 1;
    selectedBgmIdx = -1;
    bgmBeans.clear();
  }

  @override
  loadBgmList({
    bool reset = false,
  }) {
    if (reset) {
      resetBgm();
    }
    HttpUtils.get(
      APIs.bgmList,
      {
        "page": bgmPage,
        "pageSize": bgmPageSize,
        "cate": bgmCategoryBeans?[selectedBgmCategoryIdx].id ?? 1,
        "useScenes": 4,
      },
      success: (data) {
        byDebugPrint(data["data"]["items"], tag: "配音列表:");
        final List bgmData = data["data"]["items"] ?? [];
        final beans = bgmData
            .map((e) => BgmItemBean.fromJson(e))
            .toList()
            .cast<BgmItemBean>();
        byDebugPrint(beans, tag: "beans:");
        byDebugPrint(bgmBeans, tag: "bgmBeans:");
        bgmPageSize = bgmBeans.addElementsByRemovingLast(
          beans,
          currentPage: bgmPage,
          pageSize: bgmPageSize,
        );
        updateBgmBeans(beans);
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  /// 1自建鉴黄规则
  /// 2ZAKER鉴黄
  /// 3第三方 5118检测
  @override
  textRisk({
    String? type,
    String? needMark,
    required String content,
    void Function(dynamic)? onSuccess,
  }) {
    HttpUtils.post(
      APIs.textRisk,
      {
        "type": type ?? "3",
        "needMark": needMark ?? "2",
        "labelType": "499001",
        "content": content,
      },
      showLoading: true,
      forceData: true,
      success: (data) {
        onSuccess?.call(data);
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  @override
  void detect(
    BuildContext context,
    String content, {
    void Function()? onSuccess,
  }) {
    if (content.isEmpty) {
      BotToast.showText(text: "请输入检测内容");
      return;
    }

    textRisk(
      content: content,
      onSuccess: (data) {
        byDebugPrint(data, tag: "违禁词信息:");
        final status = data["status"] ?? 0;
        if (status == 1002) {
          context.read<PurchaseProvider>().loadVIPItems(
            onSuccess: () {
              showDialog(
                context: context,
                builder: (context) {
                  return const DailogBonusLowestPrice();
                },
              );
            },
          );
          return;
        }

        if (status == -1 || status == 200) {
          final TextRiskBean riskBean = TextRiskBean.fromJson(data["data"]);
          final riskWords = riskBean.labelName;
          updateProhibiteWords(riskWords);
          byDebugPrint(prohibiteWords, tag: "违禁词列表:");
          updateForbiddenState(status == 200);
          onSuccess?.call();
          // updateSubtitle(contentDetected);
        }
      },
    );
  }
}
