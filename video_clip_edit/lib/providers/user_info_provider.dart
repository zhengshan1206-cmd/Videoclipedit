import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/modules/login/beans/login_info_bean.dart';
import 'package:video_clip_edit/modules/profile/beans/user_info_bean.dart';

class UserInfoProvider extends BaseProvider {
  LoginInfoBean? loginInfoBean;

  /// 更新登陆信息
  updateLoginInfo(LoginInfoBean user) {
    loginInfoBean = user;
    notifyListeners();
  }

  UserInfoBean? userInfoBean;

  /// 更新用户个人信息
  updateUserInfo(UserInfoBean user) {
    userInfoBean = user;
    notifyListeners();
  }

  loadUserInfo({
    void Function()? onSuccess,
  }) {
    HttpUtils.get(
      APIs.loadUserInfo,
      {},
      success: (data) {
        final userInfoData = data["data"];
        UserInfoBean bean = UserInfoBean.fromJson(userInfoData);
        updateUserInfo(bean);

        onSuccess?.call();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }
}
