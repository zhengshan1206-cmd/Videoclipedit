import 'package:get/get.dart';
import 'package:video_clip_edit/core/util/extension.dart';
import 'package:video_clip_edit/data/model/aiCreate/ai_create_captions_config_bean.dart';
import 'package:video_clip_edit/data/model/aiCreate/ai_create_video_ratio_bean.dart';
import 'package:video_clip_edit/data/model/response/base_response_entity.dart';
import 'package:video_clip_edit/v2/aiCreate/views/base_ai_create_page.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/slider/ai_create_slider_view.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_bgm_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_dubbing_bean.dart';

class AiCreateRequest{
  AiCreateRequest({
    this.content,
    Rx<AiCartoonDubbingBean?>? selectVoiceBean,
    Rx<AiCartoonBgmBean?>? selectBgmBean,
    Rx<AiCreateVideoRatioBean?>? selectRatioBean,
    Rx<CaptionsSettingBean?>? selectCaptionsBean,
    double? voiceSpeed,
    double? voiceVolume,
    Rx<bool>? isAuto,
  }) :
        selectVoiceBean = selectVoiceBean ?? Rx<AiCartoonDubbingBean?>(null),
        selectBgmBean = selectBgmBean ?? Rx<AiCartoonBgmBean?>(null),
        selectRatioBean = selectRatioBean ?? Rx<AiCreateVideoRatioBean?>(null),
        selectCaptionsBean = selectCaptionsBean ?? Rx<CaptionsSettingBean?>(null),
        voiceSpeed = voiceSpeed ?? AiCreateVoiceSliderType.voiceSpeed.defaultValue,
        voiceVolume = voiceVolume ?? AiCreateVoiceSliderType.voiceVolume.defaultValue,
        isAuto = isAuto ?? Rx<bool>(true);

  String? content;

  ///音色配音
  final Rx<AiCartoonDubbingBean?> selectVoiceBean;

  ///背景音乐
  final Rx<AiCartoonBgmBean?> selectBgmBean;

  ///视频比例
  final Rx<AiCreateVideoRatioBean?> selectRatioBean;

  ///字幕设置
  final Rx<CaptionsSettingBean?> selectCaptionsBean;

  double? voiceSpeed;

  double? voiceVolume;

  ///是否自能模式
  final Rx<bool> isAuto;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    ///配音
    final Map<String, dynamic> dubParams = <String, dynamic>{};
    dubParams.setIfNotNull(value: selectVoiceBean.value?.id, key: 'dub_custom');
    dubParams.setIfNotNull(value: voiceSpeed?.toStringAsFixed(1), key: 'dub_speed');
    dubParams.setIfNotNull(value: voiceVolume?.toStringAsFixed(1), key: 'dub_volume');

    ///字幕
    final Map<String, dynamic> captionParams = <String, dynamic>{};
    captionParams.setIfNotNull(value: selectCaptionsBean.value?.position?.id, key: 'position_id');
    captionParams.setIfNotNull(value: selectCaptionsBean.value?.style?.id, key: 'style_id');
    captionParams.setIfNotNull(value: selectCaptionsBean.value?.fontType?.id, key: 'font_type_id');
    captionParams.setIfNotNull(value: selectCaptionsBean.value?.fontSize, key: 'font_size');

    data.setIfNotNull(value: content, key: 'content');
    data.setIfNotNull(value: selectVoiceBean.value == null ? null : dubParams, key: 'dub');
    data.setIfNotNull(value: selectBgmBean.value?.url ?? '', key: 'bgm_url');
    data.setIfNotNull(value: selectRatioBean.value?.id, key: 'scale_id');
    data.setIfNotNull(value: selectCaptionsBean.value == null ? null : captionParams, key: 'subtitle');
    data.setIfNotNull(value: isAuto.value ? 1 : 2, key: 'is_auto');
    return data;
  }

  String? subTitle(AICreateConfigItemType configItemType) {
    switch (configItemType) {
      case AICreateConfigItemType.voice:
        return selectVoiceBean.value?.name;
      case AICreateConfigItemType.ratio:
        return selectRatioBean.value?.scale;
      case AICreateConfigItemType.bgm:
        return selectBgmBean.value?.title;
      case AICreateConfigItemType.captions:
        return _getCaptionsSubTitle();
      case AICreateConfigItemType.intelligentMode:
        return null;
    }
  }

  _getCaptionsSubTitle(){
    if (selectCaptionsBean.value == null) return null;
    final position = selectCaptionsBean.value?.position;
    final style = selectCaptionsBean.value?.style;
    final fontType = selectCaptionsBean.value?.fontType;
    final fontSize = selectCaptionsBean.value?.fontSize;
    return '${position?.desc}/${style?.title}/${fontType?.title}/${fontSize}';
  }
}

class CaptionsSettingBean extends BaseData {

  Position? position;
  Style? style;
  FontType? fontType;
  AiCreateVideoRatioBean? ratioBean;
  num? fontSize;

  CaptionsSettingBean({
    this.position,
    this.style,
    this.fontType,
    this.ratioBean,
    this.fontSize,
  });

  @override
  CaptionsSettingBean.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      position = json['position'] == null
          ? null
          : Position.fromJson(json['position']);
      style = json['style'] == null
          ? null
          : Style.fromJson(json['style']);
      fontType = json['fontType'] == null
          ? null
          : FontType.fromJson(json['fontType']);
      ratioBean = json['ratioBean'] == null
          ? null
          : AiCreateVideoRatioBean.fromJson(json['ratioBean']);
      fontSize = json['fontSize'];
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['position'] = position?.toJson();
    data['style'] = style?.toJson();
    data['fontType'] = fontType?.toJson();
    data['ratioBean'] = ratioBean?.toJson();
    data['fontSize'] = fontSize;
    return data;
  }

}
