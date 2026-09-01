import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/core/util/app_util.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/commn_alert_dailog.dart';
import 'package:video_clip_edit/modules/login/widgets/login_agreement_view.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/providers/login_provider.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';

class BindPhoneController extends GetxController {
  LaunchProvider get launchProvider => Get.context!.read<LaunchProvider>();
  LoginProvider get _loginProvider => Get.context!.read<LoginProvider>();

  final FocusNode phoneNode = FocusNode();
  var isInputing = false.obs;
  var inputPhoneText = ''.obs;
  var inputVCodeText = ''.obs;

  var checkAgreement = false.obs;
  var vCodeEnable = false.obs;
  var loginEnable = false.obs;

  @override
  void onInit() {
    super.onInit();
    final isAudit = launchProvider.launchInfo?.isAudit;
    if (isAudit == 1) {
      checkAgreement.value = false;
    } else {
      checkAgreement.value = _loginProvider.agreementChecked;
    }
    phoneNode.addListener(() {
      isInputing.value = phoneNode.hasFocus;
    });
  }

  ///手机号码变化
  phoneChanged(String value) {
    inputPhoneText.value = value;
    vCodeEnable.value = checkVCodeBtnEnabled();
    checkSubmitBtnEnabled();
  }

  ///验证码变化
  vCodeChanged(String value) {
    inputVCodeText.value = value;
    checkSubmitBtnEnabled();
  }

  ///提交按钮是否可点击
  void checkSubmitBtnEnabled() => loginEnable.value =
      inputPhoneText.value.length == 11 && inputVCodeText.value.length == 4;

  ///验证码按钮是否可点击
  checkVCodeBtnEnabled() => inputPhoneText.value.length == 11;

  void bindPhone() {
    if (checkAgreement.value) {
      _startBind(confirm: 0);
    } else {
      Get.customDialog(widget: LoginAgreementView(
        callback: () {
          checkAgreement.value = true;
          _startBind(confirm: 0);
        },
      ));
    }
  }

  void _startBind({int? confirm}) {
    HttpUtils.post(
      showLoading: true,
      APIs.bindPhone,
      {
        "phone": inputPhoneText.value,
        "is_confirm": confirm ?? 0,
        "code": inputVCodeText.value,
      },
      success: (data) {
        BotToast.showText(text: data["message"]);
        Get.find<UserController>().reloadUserInfo(goBack: (){
          Get.back(result: true);
        });
      },
      fail: (code, msg) {
        if (code == 100) {
          Get.customDialog(
              widget: CommonAlertDialog(
            contents: msg,
            showCancel: true,
            cancelBtnTitle: "取消",
            manLine: 3,
            cancelCallback: (_) {},
            confirmBtnTitle: "确定",
            confirmCallback: (_) {
              _startBind(confirm: 1);
            },
          ));
        }
        BotToast.showText(text: msg);
      },
    );
  }

  void confirmBack({String content = "取消绑定有可能导致会员权益丢失， 是否继续绑定？" , VoidCallback? cancel }){
    Get.normalDialog(
      width: Get.width * 0.85,
      title: '是否取消绑定',
      content: content,
      cancelText: '取消绑定',
      confirmText: '继续绑定',
      cancelAction: (){
        Get.back();
        cancel?.call();
      },
    );
  }

  @override
  void onClose() {
    super.onClose();
    phoneNode.dispose();
  }
}
