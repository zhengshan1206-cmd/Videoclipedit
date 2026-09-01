import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/core/network/base_provider.dart';
import 'package:video_clip_edit/modules/profile/beans/user_info_bean.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_device_info_utils.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';

class UserProvider extends BaseProvider {
  getUserInfo({
    void Function(UserInfoBean? userInfo)? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    HttpUtils.get(
      APIs.loadUserInfo,
      {},
      success: (data) {
        byDebugPrint(data, tag: "getUserInfo:===>");
        final userInfoData = data["data"];
        UserInfoBean bean = UserInfoBean.fromJson(userInfoData);
        // eventBus.fire(const BuySuccessEvent());
        onSuccess?.call(bean);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        onFailed?.call(code, msg);
      },
    );
  }

  getVCode({
    required String phoneNum,
    void Function(dynamic)? onSuccess,
    void Function(int, String)? onFailed,
  }) async {
    final imei = await ByDeviceInfoUtils.deviceInfo();
    HttpUtils.post(
      APIs.sendVCode,
      {"phone": phoneNum, "uuid": imei.item2},
      success: (data) {
        BotToast.showText(text: data["message"]);
        onSuccess?.call(data);
      },
      fail: (code, msg) {
        onFailed?.call(code, msg);
        BotToast.showText(text: msg);
      },
    );
  }
}
