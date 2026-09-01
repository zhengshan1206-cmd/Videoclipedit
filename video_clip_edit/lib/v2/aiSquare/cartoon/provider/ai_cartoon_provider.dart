import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/ai_vip_guid_page.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/beans/text_risk_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_settings_mixin.dart';
import 'package:video_clip_edit/modules/home/clipped/beans/dubbing_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/providers/ai_vip_guid_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_item_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_image_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_dubbing_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_video_mode_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_video_ratio_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_screen_style_bean.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';

import '../../../../modules/home/widgets/sub_funcs_view.dart';
import '../../../../modules/purchase/widgets/module_pay_dailog.dart';

class AiCartoonProvider extends AiSettingsMixin {
  /// 是否正在加载一键成片的
  bool slicingLoading = false;
  bool slicingGenerating = false;

  ///分类列表
  List<SubFunction> modulesPayList = [];

  @override
  updateSectionConfigBeansFrom(AiCartoonItemBean itemBean, String value) {
    List<List<AiCartoonItemBean>> beans = sectionConfigBeans
        .map((ele) => ele.map((bean) {
              bool isCurrent = bean.type == itemBean.type;
              return bean.copyWith(value: isCurrent ? value : bean.value);
            }).toList())
        .toList();
    sectionConfigBeans = beans;
    // if (itemBean.type == AiCartoonItemBeanType.bgm) {
    //   selectedBgmUrl = value;
    // }
    notifyListeners();
  }

  /// 画面风格
  List<AiCartoonScreenStyleBean> screenStyleBeans = [];
  updateScreenStyleBeans(List<AiCartoonScreenStyleBean> beans) {
    screenStyleBeans = beans;
    notifyListeners();
  }

  /// 选中的画面风格id
  int selectedStyleId = -1;
  updateSelectedStyleId(int id) {
    selectedStyleId = id;
    notifyListeners();
  }

  /// 画面风格数据
  void loadScreenStyles() {
    HttpUtils.get(
      APIs.screenStyleList,
      {
        "page": 1,
        "pageSize": 100,
      },
      showLoading: true,
      success: (data) {
        final List items = (data["data"]["items"] ?? []);
        byDebugPrint(items);
        final List<AiCartoonScreenStyleBean> beans =
            List<AiCartoonScreenStyleBean>.from(items.map(
          (ele) => AiCartoonScreenStyleBean.fromJson(ele),
        ));
        if (selectedStyleId == -1 && beans.isNotEmpty) {
          selectedStyleId = beans.first.id;
        }
        updateScreenStyleBeans(beans);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 视频比例
  // List<AiCartoonVideoRatioBean> videoRatioBeans = [];
  // @override
  // updateVideoRatioBeans(List<AiCartoonVideoRatioBean> beans) {
  //   videoRatioBeans = beans;
  //   notifyListeners();
  // }

  /// 选中的画面风格id
  // int selectedRatioId = -1;
  // @override
  // updateSelectedRatioId(int id) {
  //   selectedRatioId = id;
  //   notifyListeners();
  // }

  /// 画面风格数据
  void loadVideoRatios() {
    HttpUtils.get(
      APIs.videoRatioList,
      {
        "page": 1,
        "pageSize": 100,
      },
      success: (data) {
        final List items = data["data"] ?? [];
        byDebugPrint(items);
        final List<AiCartoonVideoRatioBean> beans = List.from(items.map(
          (ele) => AiCartoonVideoRatioBean.fromJson(ele),
        ));
        if (selectedRatioId == -1 && beans.isNotEmpty) {
          selectedRatioId = beans.first.id;
          final scale = beans.first.scale;
          updateSectionConfigBeansFrom(sectionConfigBeans[0][1], scale);
        }
        updateVideoRatioBeans(beans);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 角色配音
  // @override
  // List<AiCartoonDubbingBean> dubbingBeans = [];
  // @override
  // updateDubbingBeans(List<AiCartoonDubbingBean> beans) {
  //   dubbingBeans = beans;
  //   notifyListeners();
  // }

  /// 选中的配音角色id
  // int selectedDubbingId = -1;
  // @override
  // updateSelectedDubbingId(int id) {
  //   selectedDubbingId = id;
  //   notifyListeners();
  // }

  /// 正在试听的角色id
  // int listeningDubbingId = -1;
  // @override
  // updateListeningDubbingId(int id) {
  //   listeningDubbingId = id;
  //   notifyListeners();
  // }

  /// 获取角色配音
  loadDubbingList({
    void Function(List<DubbingBean>)? onSuccess,
  }) {
    HttpUtils.post(
      APIs.aiSpeakerList,
      // {"platform": "volcengine", "size": 999},
      {"page": 1, "size": 999},
      success: (data) {
        final List speakerList = data["data"]["items"] ?? [];
        List<AiCartoonDubbingBean> beans =
            speakerList.map((e) => AiCartoonDubbingBean.fromJson(e)).toList();
        if (selectedDubbingId == -1 && beans.isNotEmpty) {
          selectedDubbingId = beans.first.id;
          final name = beans.first.name;
          updateSectionConfigBeansFrom(sectionConfigBeans[0][0], name);
        }
        updateDubbingBeans(beans);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  String pid = "";

  saveParamsForVideoStep1({
    void Function()? onSuccess,
    void Function()? onFaild,
  }) {
    HttpUtils.post(
      APIs.saveVideoStep1,
      {
        "title": "",
        "text": desc,
        "tts_id": selectedDubbingId,
        "bgm_url": selectedBgmUrl,
        "template_id": selectedRatioId,
        "entrance_source": entranceSource.rawValue,
        "font_id": selectedFontId == -1 ? 0 : selectedFontId,
        "image_style": selectedStyleId,
        "dub_speed": voiceSpeed,
        "dub_volume": voiceVolume,
        "dub_custom": dubbingBeans.firstWhere((bean) {
          return bean.id == selectedDubbingId;
        }).speaker,
      },
      showLoading: true,
      success: (data) {
        byDebugPrint(data);
        final pidStr = data["data"]["pid"] ?? "";
        pid = pidStr.toString();
        onSuccess?.call();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        final integralVipController = IntegralVipController.getOrPut();
        integralVipController.handleStatusCode(code, msg, "ai_tweets");
      },
    );
  }

  /// *************************************** 模式 ***************************************
  /// 推推文视频的创建模式
  List<AiCartoonVideoModeBean> modeBeans = List<AiCartoonVideoModeBean>.from(
    [
      {
        "title": "自动生成模式",
        "tag": "更快速",
        "desc": "预估10-15分钟AI生成视频完成，若分段出现违规图片，则会自动切换为手动模式。",
        "selected": false,
        "selectedColor": "5B4BF7",
        "selectedIcon": "assets/ai/ai_cartoon_mode_auto_selected.png"
      },
      {
        "title": "手动生成模式",
        "tag": "更精细",
        "desc": "下一步后可以修改每个分段的AI配图，如果不满意，可以单图修改。",
        "selected": false,
        "selectedColor": "1CCB71",
        "selectedIcon": "assets/ai/ai_cartoon_mode_manual_selected.png"
      }
    ]
        .map(
          (ele) => AiCartoonVideoModeBean.fromJson(ele),
        )
        .toList(),
  );

  int selectedVideoModeIndex = 0;
  updateSelectedVideoModeIndex(int index) {
    selectedVideoModeIndex = index;
    notifyListeners();
  }

  /// *************************************** 模式 ***************************************
  /// *************************************** 基本设置 ***************************************

  /// *************************************** 分段处理 ***************************************

  // List<String> bandedWords = [];
  // updateBandedWords(List<String> words) {
  //   bandedWords = words;
  //   notifyListeners();
  // }

  // String selectedBandedWord = "";
  // updateSelectedBandedWord(String word) {
  //   selectedBandedWord = word;
  //   notifyListeners();
  // }

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
  //     showLoading: true,
  //     loadingText: "违禁词检测中",
  //     forceData: true,
  //     success: (data) {
  //       onSuccess?.call(data);
  //     },
  //     fail: (code, msg) {
  //       EasyLoading.dismiss();
  //       BotToast.showText(text: msg);
  //     },
  //   );
  // }

  bool checkParams() {
    if (desc.isEmpty) {
      BotToast.showText(text: "请输入小说文案");
      return false;
    }
    if (selectedStyleId == -1) {
      BotToast.showText(text: "请选择画面风格");
      return false;
    }
    if (selectedDubbingId == -1) {
      BotToast.showText(text: "请选择音色配音");
      return false;
    }
    if (selectedRatioId == -1) {
      BotToast.showText(text: "请选择视频比例");
      return false;
    }
    return true;
  }

  @override
  void detect(
    BuildContext context,
    String content, {
    void Function()? onSuccess,
  }) {
    textRisk(
      content: content,
      onSuccess: (data) {
        byDebugPrint(data, tag: "违禁词信息:");
        final status = data["status"] ?? 0;
        if (status == 1002) {
          ByNavRouterUtils.push(
            context,
            ChangeNotifierProvider(
              create: (BuildContext context) => AiVipGuidProvider(),
              child: const AiVipGuidPage(),
            ),
          );
          return;
        }
        if (status == -1 || status == 200) {
          final TextRiskBean riskBean = TextRiskBean.fromJson(data["data"]);
          final riskWords = riskBean.labelName;
          updateBandedWords(riskWords);
          byDebugPrint(bandedWords, tag: "违禁词列表:");
          // updateForbiddenState(status == 200);
          onSuccess?.call();
          // updateSubtitle(contentDetected);
        }
      },
    );
  }

  // replaceWithInitialLetterOfPinyin() {
  //   String content = desc;
  //   for (var e in bandedWords) {
  //     content = content.replaceAll(e, e.getFirstLetters());
  //   }
  //   return content;
  // }

  // /// 将选中的违禁词替换为[word]
  // replaceWord(String word, Function call) {
  //   final contents = desc.replaceAll(selectedBandedWord, word);
  //   byDebugPrint(contents);
  //   bandedWords.removeWhere((item) => item == selectedBandedWord);
  //   updateBandedWords(List<String>.from(bandedWords));
  //   desc = contents;
  //   call();
  // }

  /// 文章分段列表
  List<String> paragraphs = [];
  updateParagraphs(List<String> data) {
    paragraphs = data;
    notifyListeners();
  }

  /// 加载文章分段列表
  articleSplit() {
    HttpUtils.post(
      APIs.articleSplit,
      {"pid": pid},
      showLoading: true,
      success: (data) {
        final List dataList = (data["data"]["data"] ?? []);
        updateParagraphs(dataList.cast());
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 保存分段
  saveArticleSplits({
    void Function()? onSuccess,
  }) {
    HttpUtils.post(
      APIs.videoStep2,
      {
        "trackTexts": paragraphs.map((ele) => {"text": ele}).toList(),
        "pid": pid,
        "is_auto_video": selectedVideoModeIndex == 0 ? 1 : 0,
      },
      success: (data) {
        byDebugPrint(data);
        final status = data["status"] ?? -1;
        if (status == 200) {
          onSuccess?.call();
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  bool imagesGenerating = true;
  updateImageGenerating(bool status) {
    imagesGenerating = status;
    notifyListeners();
  }

  List<AiCartoonImageBean> imageBeans = [];
  updateImageBeans(List<AiCartoonImageBean> beans) {
    imageBeans = beans;
    notifyListeners();
  }

  bool loading = false;

  /// [checkStatus] 是否轮询状态到全部成功，默认为true
  loadImageList({
    CancelToken? cancelToken,
    void Function(List<AiCartoonImageBean> beans)? onSuccess,
    void Function(CancelToken cancelToken)? onFaild,
    bool checkStatus = true,
  }) {
    if (loading) {
      return;
    }
    loading = true;
    HttpUtils.get(
      APIs.imgsList,
      {"pid": pid},
      cancelToken: cancelToken,
      success: (data) {
        loading = false;
        final status = data["status"] ?? -1;
        if (status != 200) {
          final token = CancelToken();
          onFaild?.call(token);
        } else {
          final List imgListData = data["data"]["details"]["list"] ?? [];
          if (imgListData.isEmpty && checkStatus) {
            final token = CancelToken();
            onFaild?.call(token);
          } else {
            bool finished = true;
            List<AiCartoonImageBean> beans =
                List<AiCartoonImageBean>.from(imgListData.map((e) {
              final bean = AiCartoonImageBean.fromJson(e);
              if (bean.status != 2) {
                finished = false;
              }
              return bean;
            }));
            if (finished == false && checkStatus) {
              final token = CancelToken();
              onFaild?.call(token);
            }
            imageBeans = beans;
            updateImageGenerating(false);
            if (finished) {
              onSuccess?.call(beans);
            }
          }
        }
      },
      fail: (code, msg) {
        loading = false;
        BotToast.showText(text: msg);
        final token = CancelToken();
        onFaild?.call(token);
      },
    );
  }

  deleteImage({
    required imgId,
    void Function()? onSuccess,
  }) {
    HttpUtils.post(
      APIs.cleanItemImg,
      {"pid": pid, "id": imgId},
      success: (data) {
        byDebugPrint(data);
        onSuccess?.call();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// [isAi] 是否ai生成: 0 上传 1 换一张 2 重绘
  ///        0上传    1系统换图（假生成）  2系统换图（真生成）
  regernateImage({
    required imgId,
    required int isAi,
    required String imgUrl,
    required String prompt,
    void Function()? onSuccess,
  }) {
    HttpUtils.post(
      APIs.regenerateImg,
      {
        "pid": pid,
        "id": imgId,
        "is_ai": isAi,
        "url": imgUrl,
        "prompt": prompt,
      },
      success: (data) {
        byDebugPrint(data);
        onSuccess?.call();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 提交视频
  videoSubmit({
    void Function()? onSuccess,
  }) {
    HttpUtils.post(
      APIs.videoSubmit,
      {"pid": pid},
      showLoading: true,
      success: (data) {
        byDebugPrint(data);
        onSuccess?.call();
      },
      fail: (code, msg) => BotToast.showText(text: msg),
    );
  }

  /// 鉴黄
  ///[type] 鉴黄类型: 2图片 3音频 4视频
  ///[url]  url地址
  contentsRisk({
    required String type,
    required String url,
    void Function()? onSuccess,
  }) {
    HttpUtils.post(
      APIs.contentsRisk,
      showLoading: true,
      showMsgWhenFailed: false,
      {"type": type, "url": url},
      success: (data) {
        onSuccess?.call();
      },
      fail: (code, msg) {
        if (code == -1) {
          BotToast.showText(text: "图片违规，请重新选择");
        } else {
          BotToast.showText(text: msg);
        }
      },
    );
  }

  /// *************************************** 分段处理 ***************************************

  //匹配支付弹窗
  showModelPayDialog(context, String mark) {
    SubFunction? findItemOrReturnNull(
        List<SubFunction> items, String searchString) {
      try {
        return items.firstWhere((item) => item.jumpUrl == searchString);
      } catch (e) {
        return null; // 表示未找到
      }
    }

    // SubFunction? result = findItemOrReturnNull(modulesPayList, mark);
    if (Get.context != null) {
      Get.context!.read<LaunchProvider>().showPayHalfDialog(context, mark);
    }
    // showDialog(
    //   context: context,
    //   builder: (context) {
    //     return ModulePayDailog(
    //       mark: mark,
    //       markUrl: result != null
    //           ? result.imgUrl
    //           : "assets/purchase/dailog_bonus_bg_new_1.png",
    //     );
    //   },
    // );
  }

  ///获取所有分类模块弹窗列表
  loadHomeBanner() {
    HttpUtils.get(
      APIs.homeBanner,
      {"postion": 19},
      success: (data) {
        final List bannerData = data["data"]["item"] ?? [];
        byDebugPrint(bannerData, tag: "获取所有分类模块弹窗列表:");
        List<SubFunction> beans =
        bannerData.map((e) => SubFunction.fromJson(e)).toList();
        modulesPayList = beans;
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }
}
