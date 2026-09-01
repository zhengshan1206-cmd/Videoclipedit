import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/util/common_ui.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/data/model/aiCreate/ai_create_request.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/ai_create_captions_setting_controller.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/base_ai_create_controller.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/bottom_sheet/ai_create_bgm_setting_view.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/bottom_sheet/ai_create_video_ratio_setting_view.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/bottom_sheet/ai_create_voice_setting_view.dart';
import 'package:video_clip_edit/widgets/form/custom_text_form_field.dart';

///ai创作类型
enum AICreateType {
  ///民间故事
  folkStory;

  static List<AICreateConfigItemType> get folkStoryConfigs => [
        AICreateConfigItemType.voice,
        AICreateConfigItemType.bgm,
        AICreateConfigItemType.captions,
        AICreateConfigItemType.ratio,
        AICreateConfigItemType.intelligentMode,
      ];

  List<AICreateConfigItemType> get configs {
    switch (this) {
      case folkStory:
        return folkStoryConfigs;
    }
  }
}

///ai创作配置项
enum AICreateConfigItemType {
  ///音色配音
  voice,

  ///背景音乐
  bgm,

  ///字幕设置
  captions,

  ///视频比列
  ratio,

  ///只能模式
  intelligentMode;

  String get title {
    switch (this) {
      case voice:
        return '音色配音';
      case ratio:
        return '视频比例';
      case bgm:
        return '背景音乐';
      case captions:
        return '字幕设置';
      case intelligentMode:
        return '手动生成模式';
    }
  }

  String? get hintText {
    switch (this) {
      case voice:
        return '请选择配音';
      case ratio:
        return '请选择视频比例';
      case bgm:
        return '请选择背景音乐';
      case captions:
        return '（可选）';
      case intelligentMode:
        return null;
    }
  }

  bool get isChoose {
    return this != intelligentMode;
  }
}

///AI创作基类
abstract class BaseAiCreatePage<T extends BaseAiCreateController>
    extends GetView<T> {
  const BaseAiCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<T>(builder: (controller) {
      return contentView(context);
    });
  }

  Widget contentView(BuildContext context);

  ///ai创作配置项
  Widget buildConfigItem(AICreateConfigItemType configItemType,
      {bool? showDivider}) {
    return Obx(() {
      return buildTextFormView(
        configItemType.title,
        configItemType.isChoose
            ? CustomTextFieldType.choose
            : CustomTextFieldType.edit,
        hintText: configItemType.hintText,
        subTitle: controller.aiCreateRequest.subTitle(configItemType),
        enable: configItemType.isChoose ? true : false,
        padding: EdgeInsets.symmetric(vertical: 17.h),
        showDivider: showDivider ?? false,
        titleStyle:
            BYTextStyle.instance(16.sp, fontWeight: BYFontWeight.semiBold),
        subTitleStyle: BYTextStyle.instance(14.sp),
        arrowWidget:
            Image.asset(Assets.aiIconAiCreateArrow, width: 12.w, height: 12.w),
        suffixWidget: !configItemType.isChoose
            ? CupertinoSwitch(
                activeColor: ByColorUtil.LoginBtnBgColor,
                value: !controller.aiCreateRequest.isAuto.value,
                onChanged: (value) {
                  controller.aiCreateRequest.isAuto.value = !value;
                },
              )
            : null,
        onTap: () {
          if (!configItemType.isChoose) return;
          _handleTap(configItemType);
        },
      );
    });
  }

  void _handleTap(AICreateConfigItemType configItemType) {
    switch (configItemType) {
      case AICreateConfigItemType.voice:
        AiCreateVoiceSettingView.show(
            voiceList: controller.voiceList,
            selectVoiceBean: controller.aiCreateRequest.selectVoiceBean.value,
            voiceSpeed: controller.aiCreateRequest.voiceSpeed,
            voiceVolume: controller.aiCreateRequest.voiceVolume,
            selectAction: (voiceBean, voiceSpeed, voiceVolume) {
              controller.aiCreateRequest.selectVoiceBean.value = voiceBean;
              controller.aiCreateRequest.voiceSpeed = voiceSpeed;
              controller.aiCreateRequest.voiceVolume = voiceVolume;
            });
        break;
      case AICreateConfigItemType.ratio:
        AiCreateVideoRatioSettingView.show(
            ratioList: controller.videoRatioList,
            selectRatioBean: controller.aiCreateRequest.selectRatioBean.value,
            selectAction: (ratioBean) {
              controller.aiCreateRequest.selectRatioBean.value = ratioBean;
              controller.aiCreateRequest.selectCaptionsBean.value?.ratioBean =
                  ratioBean;
            });
        break;
      case AICreateConfigItemType.bgm:
        AiCreateBgmSettingView.show(
            selectBgmBean: controller.aiCreateRequest.selectBgmBean.value,
            selectAction: (bgmBean) {
              controller.aiCreateRequest.selectBgmBean.value = bgmBean;
            });
        break;
      case AICreateConfigItemType.captions:
        _captionsSetting();
        break;
      case AICreateConfigItemType.intelligentMode:
        break;
      default:
        break;
    }
  }

  ///字幕设置
  _captionsSetting() async {
    var data = await Get.toNamed(Routes.aiCreateCaptionsSetting, arguments: {
      CaptionsSettingKey.captionsConfigBean: controller.captionsConfigBean,
      CaptionsSettingKey.videoRatioList: controller.videoRatioList,
      CaptionsSettingKey.selectCaptionsSetting:
          controller.aiCreateRequest.selectCaptionsBean.value,
    });

    if (data is CaptionsSettingBean) {
      controller.aiCreateRequest.selectCaptionsBean.value = data;
      controller.aiCreateRequest.selectRatioBean.value = data.ratioBean;
    }
  }
}
