import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_input_mixin.dart';
import 'package:video_clip_edit/v2/aiSquare/song/beans/rights_by_type.dart';

class HotCaseReplicaProvider extends AiInputMixin {
  HotCaseReplicaProvider() {
    getVipRights();
  }

  bool moreSettingsOn = false;
  changeMoreSettingsOn(bool value) {
    moreSettingsOn = value;
    notifyListeners();
  }

  String title = "";
  updateTitle(String value) {
    title = value;
    notifyListeners();
  }

  // double offset = 0.0;
  // updateOffset(double value) {
  //   offset = value;
  //   notifyListeners();
  // }

  RightsByType? rightsByType;
  updateRightsByType(RightsByType? type) {
    rightsByType = type;
    notifyListeners();
  }

  bool hasTitleFocus = false;
  updateHasTitleFocus(bool value) {
    hasTitleFocus = value;
    notifyListeners();
  }

  bool hasLinkFocus = false;
  updateHasLinkFocus(bool value) {
    hasLinkFocus = value;
    notifyListeners();
  }

  /// 创建爆款复刻视频
  createHotCaseReplicaVideo({
    required String shareUrl,
    required String videoHeadUrls,
    required String videoUrls,
    required String materialPackId,
    required String videoSource,
    required String title,
    required int fontStyle,
    String ratio = "",
    void Function()? onSuccess,
    void Function()? onFaild,
  }) {
    HttpUtils.post(
      APIs.createHotCopy,
      {
        "share_url": shareUrl,
        "video_head_urls": videoHeadUrls,
        "video_urls": videoUrls,
        "material_pack_id": materialPackId,
        "video_source": videoSource,
        "font_style": fontStyle,
        "video_template": ratio,
        "title": title,
      },
      showLoading: true,
      success: (data) {
        byDebugPrint(data, tag: "---------爆款复刻:");
        onSuccess?.call();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        onFaild?.call();
      },
    );
  }

  /// 获取VIP权益
  getVipRights() {
    HttpUtils.post(
      APIs.getRightsByType,
      {"type": "digital_human"},
      showLoading: false,
      success: (data) {
        final rghtsByType = RightsByType.fromJson(data["data"]);
        updateRightsByType(rghtsByType);
      },
      fail: (code, msg) {
        BotToast.showText(text: "获取权益失败");
      },
    );
  }
}
