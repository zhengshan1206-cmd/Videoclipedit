import 'dart:io';
import 'dart:convert';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/beans/function_item_bean.dart';
import 'package:video_clip_edit/modules/home/beans/text_risk_bean.dart';
import 'package:video_clip_edit/modules/home/clipped/beans/bgm_category_bean.dart';
import 'package:video_clip_edit/modules/home/clipped/beans/bgm_item_bean.dart';
import 'package:video_clip_edit/modules/home/clipped/beans/dubbing_bean.dart';
import 'package:video_clip_edit/modules/home/recreate/beans/commentary_item_bean.dart';
import 'package:video_clip_edit/modules/home/words/beans/audio_result_bean.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/modules/purchase/widgets/dailog_bonus_lowest_price.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/utils/consts/const.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../../widgets/toast_util.dart';

class ShowRecreateProvider extends MaterialBaseProvider {
  ShowRecreateProvider() {
    loadBanners(postion: 10);
  }

  @override
  MaterialProviderType get type => MaterialProviderType.recreate;
  @override
  List<FunctionItemBean> get functionList => [
        FunctionItemBean.fromJson({
          "icon": "assets/home/watermark_upload.png",
          "title": "本地上传",
          "desc": "上传本地图片、视频文件"
        }),
        FunctionItemBean.fromJson({
          "icon": "assets/home/watermark_my_woks.png",
          "title": "我的作品",
          "desc": "上传我的作品文件"
        }),
        // FunctionItemBean.fromJson({
        //   "icon": "assets/home/icon_cloud_art.png",
        //   "title": "云端素材",
        //   "desc": "上传云端素材"
        // }),
        FunctionItemBean.fromJson({
          "icon": "assets/home/watermark_video.png",
          "title": "热门短剧",
          "desc": "选择授权短剧视频"
        }),
      ];

  /// 创建作品
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
        // "file_url": flePath,
        // "file_cover_url": flePath,
        "type": Consts.kUserWorkLogTypeRecreate,
        "details": details,
      },
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
  Future<String?> videoComposition(List assets) async {
    return null;
    // }
    // if (assets.isEmpty) {
    //   BotToast.showText(text: "请先选择素材");
    //   return null;
    // }

    // List<String> filePaths = [];
    // for (var asset in assets) {
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
    //   isSavePhoto: false,
    //   isShowLoadDialog: true,
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

  int videoOffset = 0;

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

  /// 更新视频进度
  updateVideoOffset(AudioResultBean bean) {
    final time = bean.startTime.ceil();
    videoOffset = time;
    notifyListeners();
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
          // BotToast.showText(text: "修改失败，请稍后再试");
          ToastUtil().showToast("修改失败，请稍后再试");

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

  /// 修改角色台词
  modifyQuotes({
    required AudioResultBean bean,
    required String replace,
    void Function()? onSuccess,
  }) {
    final index = speakerQuotesBeans.indexOf(bean);
    final newBean = bean.copyWith();
    newBean.text = replace;
    speakerQuotesBeans[index] = newBean;
    notifyListeners();

    onSuccess?.call();
  }

  /// 修改角色名
  modifyRoleName({
    required AudioResultBean bean,
    required String replace,
    void Function()? onSuccess,
  }) {
    final originName = bean.speaker;
    for (var e in speakerQuotesBeans) {
      if (e.speaker == originName) {
        e.speaker = replace;
        e.nameModified = true;
      }
    }
    onSuccess?.call();
    notifyListeners();
  }

  /// 修改当前一句角色名
  modifyCurrentRoleName({
    required AudioResultBean bean,
    required String replace,
    void Function()? onSuccess,
  }) {
    final text = bean.text;
    for (var e in speakerQuotesBeans) {
      if (e.text == text) {
        e.speaker = replace;
        e.nameModified = true;
        break;
      }
    }
    onSuccess?.call();
    notifyListeners();
  }

  /// 修改解说内容
  modifyCommentary({
    required CommentaryItemBean bean,
    required String replace,
    required int index,
    void Function(bool changed)? onSuccess,
  }) {
    final originCommentary = bean.commentary.commentary;
    final beanNew = bean.copyWith();
    final changed = originCommentary == replace;
    beanNew.commentary.commentary = replace;
    updateCommentaryItemBeanAtIndex(index, beanNew);
    notifyListeners();
    onSuccess?.call(changed);
  }

  /// 解说列表
  List<CommentaryItemBean> commentaryItemBeans = [];
  updateCommentaryItemBeans(List<CommentaryItemBean> itemBeans) {
    commentaryItemBeans = itemBeans;
    notifyListeners();
  }

  /// 更新解说列表
  updateCommentaryItemBeanAtIndex(int index, CommentaryItemBean bean) {
    commentaryItemBeans[index] = bean;
    notifyListeners();
  }

  /// 查询解说进度
  queryVoiceOptimizeState({
    required String taskId,
    void Function(List<CommentaryItemBean> commentaryItemBeans)? onSuccess,
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
          final List result = json.decode(wordsStr) ?? [];
          final List<CommentaryItemBean> beans = result
              .map(
                (e) => CommentaryItemBean.fromJson(e),
              )
              .toList();
          updateCommentaryItemBeans(beans);
          onSuccess?.call(beans);
        } else if (status == "500") {
          EasyLoading.dismiss();
          BotToast.showText(text: "修改失败，请稍后再试");
        } else {
          Future.delayed(const Duration(milliseconds: 1000), () {
            queryVoiceOptimizeState(
              taskId: taskId,
              onSuccess: onSuccess,
            );
          });
        }
      },
      fail: (code, msg) {
        EasyLoading.dismiss();
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  String selectedRoleName = "第三视角";
  resetSelectedRoleName() {
    selectedRoleName = "第三视角";
  }

  realNameFormSelectedRoleName() {
    if (selectedRoleName == "第三视角") return "0";
    return speakerQuotesBeans
        .firstWhere((e) => e.speaker == selectedRoleName)
        .realName();
  }

  updateSelectedRoleName(String name) {
    selectedRoleName = name;
    notifyListeners();
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
        final List bgmData = data["data"]["items"] ?? [];
        final beans = bgmData
            .map((e) => BgmItemBean.fromJson(e))
            .toList()
            .cast<BgmItemBean>();
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

  getCommentarySimpleText({
    required String text,
    void Function(String taskId)? onSuccess,
    void Function()? onFailed,
  }) {
    HttpUtils.post(
      APIs.getCommentarySimpleText,
      {"text": text},
      success: (data) {
        byDebugPrint(data, tag: "getCommentarySimpleText------:");
        final taskId = data["data"]["task_id"] ?? "";
        onSuccess?.call(taskId);
      },
      showMsgWhenFailed: false,
      fail: (code, msg) {
        onFailed?.call();
      },
    );
  }
}
