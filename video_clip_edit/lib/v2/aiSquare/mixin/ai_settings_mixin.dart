import 'dart:math';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_item_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_dubbing_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_video_font_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_video_ratio_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_random_template_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_banner_mixin.dart';

///创作方式来源
enum EntranceSource {
  normal(1),

  ///短剧视频
  shortPlay(2),

  ///爆文视频
  explosive(3);

  final int rawValue;

  const EntranceSource(this.rawValue);

  static EntranceSource fromRawValue(int rawValue) {
    return EntranceSource.values
        .firstWhere((element) => element.rawValue == rawValue);
  }
}

abstract class AiSettingsMixin extends AiBannerMixin {
  EntranceSource entranceSource = EntranceSource.normal;
  String desc = "";
  String get currentDesc {
    return desc;
  }

  set currentDesc(String newValue) {
    if (newValue.length > 2000) {
      desc = newValue.substring(0, 2000); // 截取前 2000 个字符
    } else {
      desc = newValue;
    }
  }

  updateDesc(String txt) {
    if (txt.length > 2000) {
      txt = txt.substring(0, 2000);
    }
    desc = txt;
    notifyListeners();
  }

  String getDesc() {
    return desc;
  }

  void detect(
    BuildContext context,
    String content, {
    void Function()? onSuccess,
  });

  /// 随机模板
  List<AiCartoonRandomTemplateBean> templateBeans = [];
  updateTemplateBeans(List<AiCartoonRandomTemplateBean> beans) {
    templateBeans = beans;
    notifyListeners();
  }

  /// 随机模板的分类
  String category = "";
  updateCategory(String cate) {
    category = cate;
    notifyListeners();
  }

  int selectedTmpId = -1;
  updateSelectedTmpId(int id) {
    selectedTmpId = id;
    notifyListeners();
  }

  AiCartoonItemBean? configBeanFromType(AiCartoonItemBeanType type) {
    AiCartoonItemBean? result;
    for (var list in sectionConfigBeans) {
      for (var bean in list) {
        if (bean.type == type) {
          result = bean;
          break;
        }
      }
    }
    return result;
  }

  pickRandomCase({bool? updateDesc}) {
    final len = templateBeans.length;
    final randomIdx = Random().nextInt(len);
    AiCartoonRandomTemplateBean tmp = templateBeans[randomIdx];
    while (desc == tmp.text) {
      final idx = Random().nextInt(len);
      tmp = templateBeans[idx];
    }
    category = tmp.category;
    if (updateDesc == true || updateDesc == null) {
      desc = tmp.text;
    }

    updateSectionConfigBeans(
      List<List<AiCartoonItemBean>>.from(
        sectionConfigBeans.map(
          (section) => List<AiCartoonItemBean>.from(
              section.map((bean) => bean.copyWith())),
        ),
      ),
    );
    notifyListeners();
  }

  _pickRandomCaseWithoutDesc() {
    final len = templateBeans.length;
    final randomIdx = Random().nextInt(len);
    AiCartoonRandomTemplateBean tmp = templateBeans[randomIdx];
    category = tmp.category;
    notifyListeners();
  }

  loadRandomCase({bool pickRandom = true}) {
    HttpUtils.get(
      APIs.getRandText,
      {"platform": "beiyin"},
      showLoading: true,
      success: (data) {
        byDebugPrint(data);
        final List items = data["data"] ?? [];
        List<AiCartoonRandomTemplateBean> beans =
            List<AiCartoonRandomTemplateBean>.from(items.map(
          (e) => AiCartoonRandomTemplateBean.fromJson(e),
        ));

        updateTemplateBeans(beans);

        if (beans.isNotEmpty) {
          _pickRandomCaseWithoutDesc();
        }
      },
      fail: (code, msg) => BotToast.showText(text: msg),
    );
  }

  /// 获取推小果URL
  @override
  loadTuixiaoguoUrl({
    void Function(String)? onSuccess,
  }) {
    HttpUtils.get(
      APIs.tuixiaoguoUrl,
      {
        "need_detail": 1,
        "page": 1,
        "pageSize": 10,
      },
      showLoading: true,
      success: (json) {
        var data = json["data"];
        if (data != null && data["jump_url"] != null) {
          final tuixiaoguoUrl = data["jump_url"];
          onSuccess?.call(tuixiaoguoUrl);
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 配置选项
  List<List<AiCartoonItemBean>> sectionConfigBeans = [
    [
      AiCartoonItemBean.fromJson(
        {
          "value": "",
          "placeholder": "请选择配音",
          "type": AiCartoonItemBeanType.voice,
          "shouldBold": false,
          "required": true,
          "imgPath": "assets/ai/icon_cartoon_voice.png",
          "title": "音色配音",
          "hasHeader": true,
        },
      ),
      AiCartoonItemBean.fromJson(
        {
          "value": "",
          "placeholder": "请选择视频比例",
          "type": AiCartoonItemBeanType.ratio,
          "shouldBold": false,
          "required": true,
          "imgPath": "assets/ai/icon_cartoon_ratio.png",
          "title": "视频比例",
          "hasHeader": true,
        },
      ),
    ],
    [
      AiCartoonItemBean.fromJson(
        {
          "value": "不需要背景音乐",
          "placeholder": "请选择背景音乐",
          "type": AiCartoonItemBeanType.bgm,
          "shouldBold": false,
          "imgPath": "assets/ai/icon_cartoon_bgm.png",
          "title": "背景音乐",
          "required": false,
          "hasHeader": true,
        },
      ),
      AiCartoonItemBean.fromJson(
        {
          "value": "",
          "placeholder": "请选择字幕样式",
          "type": AiCartoonItemBeanType.font,
          "shouldBold": false,
          "imgPath": "assets/ai/icon_cartoon_fonts.png",
          "title": "字幕样式",
          "required": false,
          "hasHeader": true,
        },
      ),
    ],
    [
      AiCartoonItemBean.fromJson(
        {
          "value": "更多设置",
          "placeholder": "更多设置",
          "type": AiCartoonItemBeanType.settings,
          "shouldBold": true,
          "imgPath": "assets/ai/icon_cartoon_settings.png",
          "title": "更多设置",
          "required": false,
          "hasHeader": false,
        },
      )
    ],
  ];
  updateSectionConfigBeans(List<List<AiCartoonItemBean>> beans) {
    sectionConfigBeans = beans;
    notifyListeners();
  }

  /// 角色配音
  List<AiCartoonDubbingBean> dubbingBeans = [];

  updateDubbingBeans(List<AiCartoonDubbingBean> beans) {
    dubbingBeans = beans;
    notifyListeners();
  }

  /// 选中的配音角色id
  int selectedDubbingId = -1;
  updateSelectedDubbingId(int id) {
    selectedDubbingId = id;
    notifyListeners();
  }

  /// 正在试听的角色id
  int listeningDubbingId = -1;
  updateListeningDubbingId(int id) {
    listeningDubbingId = id;
    notifyListeners();
  }

  /// 更新设置项数据
  updateSectionConfigBeansFrom(AiCartoonItemBean itemBean, String value);

  /// 选中的画面风格id
  int selectedRatioId = -1;
  updateSelectedRatioId(int id) {
    selectedRatioId = id;
    notifyListeners();
  }

  /// 视频比例
  List<AiCartoonVideoRatioBean> videoRatioBeans = [];
  updateVideoRatioBeans(List<AiCartoonVideoRatioBean> beans) {
    videoRatioBeans = beans;
    notifyListeners();
  }

  /// 画面字幕样式
  List<AiCartoonVideoFontBean> videoFontBeans = [];
  updateVideoFontBeans(List<AiCartoonVideoFontBean> beans) {
    videoFontBeans = beans;
    notifyListeners();
  }

  /// 选中的字幕样式id
  int selectedFontId = -1;
  updateSelectedFontId(int id) {
    selectedFontId = id;
    notifyListeners();
  }

  /// 获取字幕样式列表
  loadVideoFonts() {
    HttpUtils.get(
      APIs.videoFontList,
      {},
      success: (data) {
        final List items = data["data"]["items"] ?? [];
        byDebugPrint(items);
        final List<AiCartoonVideoFontBean> beans = List.from(items.map(
          (ele) => AiCartoonVideoFontBean.fromJson(ele),
        ));
        if (beans.isNotEmpty) {
          selectedFontId = beans.first.id;
        }
        updateVideoFontBeans(beans);
        print(
            "字幕样式===> ${beans.first.toJson()}  已经存在的数据==> ${sectionConfigBeans.first.first.toJson()} ");
        if (beans.isNotEmpty) {
          if (sectionConfigBeans.length >= 2) {
            if (sectionConfigBeans[1].length >= 2) {
              updateSectionConfigBeansFrom(
                  sectionConfigBeans[1][1], beans.first.title);
              // updateSelectedFontId(beans.first.id);
            }
          }
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 选中的背景音乐url
  String selectedBgmUrl = "";
  updateSelectedBgmUrl(String url) {
    selectedBgmUrl = url;
    notifyListeners();
  }

  List<String> bandedWords = [];
  updateBandedWords(List<String> words) {
    bandedWords = words;
    notifyListeners();
  }

  String selectedBandedWord = "";
  updateSelectedBandedWord(String word) {
    selectedBandedWord = word;
    notifyListeners();
  }

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
      loadingText: "违禁词检测中",
      forceData: true,
      success: (data) {
        onSuccess?.call(data);
      },
      fail: (code, msg) {
        EasyLoading.dismiss();
        BotToast.showText(text: msg);
      },
    );
  }

  replaceWithInitialLetterOfPinyin() {
    String content = desc;
    for (var e in bandedWords) {
      content = content.replaceAll(e, e.getFirstLetters());
    }
    return content;
  }

  /// 将选中的违禁词替换为[word]
  replaceWord(String word, Function call) {
    final contents = desc.replaceAll(selectedBandedWord, word);
    byDebugPrint(contents);
    bandedWords.removeWhere((item) => item == selectedBandedWord);
    updateBandedWords(List<String>.from(bandedWords));
    desc = contents;
    call();
  }

  /// *************************************** 更多设置 ***************************************

  resetMoreSettings() {
    videoTimes = 1.0;
    voiceSpeed = 1.0;
    voiceVolume = 1.0;
    bgmSpeed = 1.0;
    bgmVolume = 1.0;
    notifyListeners();
  }

  double videoTimes = 1.0;
  changeVideoTimes(double times) {
    videoTimes = times;
    notifyListeners();
  }

  double voiceSpeed = 1.0;
  changeVoiceSpeed(double speed) {
    voiceSpeed = speed;
    notifyListeners();
  }

  double voiceVolume = 1.0;
  changeVoiceVolume(double volume) {
    voiceVolume = volume;
    notifyListeners();
  }

  double bgmSpeed = 1.0;
  changeBgmSpeed(double speed) {
    bgmSpeed = speed;
    notifyListeners();
  }

  double bgmVolume = 1.0;
  changeBgmVolume(double volume) {
    bgmVolume = volume;
    notifyListeners();
  }

  /// *************************************** 更多设置 ***************************************
}
