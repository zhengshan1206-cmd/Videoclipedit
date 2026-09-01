import 'package:bot_toast/bot_toast.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/base/controllers/base_controller.dart';
import 'package:video_clip_edit/core/network/api.dart';
import 'package:video_clip_edit/data/model/aiCreate/ai_create_captions_config_bean.dart';
import 'package:video_clip_edit/data/model/aiCreate/ai_create_request.dart';
import 'package:video_clip_edit/data/model/aiCreate/ai_create_video_ratio_bean.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';

enum CaptionsSettingKey {
  captionsConfigBean,
  videoRatioList,
  selectCaptionsSetting;
}

class AiCreateCaptionsSettingController extends BaseController {
  ///视频比例配置项
  var videoRatioList = <AiCreateVideoRatioBean>[];

  ///字幕配置项
  var captionsConfigBean = AiCreateCaptionsConfigBean();

  ///选中的字幕位置
  final selectPosition = Rx<Position?>(null);

  ///选中的字幕样式
  final selectStyle = Rx<Style?>(null);

  ///选中的字体类型
  final selectFontType = Rx<FontType?>(null);

  ///选择的视频比例
  final selectRatioBean = Rx<AiCreateVideoRatioBean?>(null);

  ///字体大小
  final sliderValue = Rx<double>(40.0);

  String? captionSettingImg;

  @override
  void handArguments(arguments) {
    if (arguments is Map) {
      final captionsConfigBean =
          arguments[CaptionsSettingKey.captionsConfigBean];
      if (captionsConfigBean is AiCreateCaptionsConfigBean) {
        this.captionsConfigBean = captionsConfigBean;
      }
      final videoRatioList = arguments[CaptionsSettingKey.videoRatioList];
      if (videoRatioList is List<AiCreateVideoRatioBean>) {
        this.videoRatioList = videoRatioList;
      }
      final captionSettingBean =
          arguments[CaptionsSettingKey.selectCaptionsSetting];
      if (captionSettingBean is CaptionsSettingBean) {
        selectPosition.value = captionSettingBean.position;
        selectStyle.value = captionSettingBean.style;
        selectFontType.value = captionSettingBean.fontType;
        selectRatioBean.value = captionSettingBean.ratioBean;
        sliderValue.value = captionSettingBean.fontSize?.toDouble() ?? sliderValue.value;

        getCaptionSettingImg();
      }
    }
  }

  void getCaptionSettingImg() async {
    HttpUtils.post(
      API.getCaptionsSettingImg.path,
      {
        'position_id': selectPosition.value?.id,
        'style_id': selectStyle.value?.id,
        'font_type_id': selectFontType.value?.id,
        'font_size': sliderValue.value.toInt(),
        'scale_id': selectRatioBean.value?.id,
      },
      showLoading: true,
      success: (data) {
        captionSettingImg = data["data"]['img'];
        update();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }
}
