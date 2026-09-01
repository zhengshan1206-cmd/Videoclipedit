import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/aiClip/beans/ai_oepning_video_item_bean.dart';

import '../../../widgets/toast_util.dart';

enum AiMaterialOpeningType { cloud, mine }

extension AiMaterialOpeningTypeExt on AiMaterialOpeningType {
  int get rawValue {
    switch (this) {
      case AiMaterialOpeningType.cloud:
        return 0;
      case AiMaterialOpeningType.mine:
        return 1;
      default:
        return 0;
    }
  }

  static AiMaterialOpeningType typeFromRawValue(int value) {
    switch (value) {
      case 0:
        return AiMaterialOpeningType.cloud;
      default:
        return AiMaterialOpeningType.mine;
    }
  }
}

class AiClipOpeningProvider extends BaseProvider {
  /// 选择素材类型
  AiMaterialOpeningType currentType = AiMaterialOpeningType.cloud;
  updateMaterialType(AiMaterialOpeningType type) {
    currentType = type;
    notifyListeners();
  }

  List<AiOpeningVideoItemBean> openingBeans = [];
  updateOpeningVideoItemBeans(List<AiOpeningVideoItemBean> beans) {
    openingBeans = beans;
    notifyListeners();
  }

  Detail? selectedOpeningBean;
  updateSelectedOpeningBean(Detail? bean) {
    selectedOpeningBean = bean;
    notifyListeners();
  }

  /// 获取片头列表数据
  loadAiMaterialOpeningList({
    required int videoRatio,
  }) {
    HttpUtils.get(
      APIs.aiMaterialsOpeningList,
      {
        "scale": videoRatio,
      },
      success: (data) {
        byDebugPrint(data);
        final items = data["data"]["items"] ?? [];
        List<AiOpeningVideoItemBean> beans =
            List<AiOpeningVideoItemBean>.generate(items.length,
                (idx) => AiOpeningVideoItemBean.fromJson(items[idx]));
        updateOpeningVideoItemBeans(beans);
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }
}
