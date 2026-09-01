


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/modules/login/controller/login_controller.dart';
import 'package:video_clip_edit/modules/login/pages/login_content_page.dart';
import '../login_page.dart';
import '../widgets/login_content_view.dart';


// ignore: must_be_immutable
class UserLoginPage extends StatefulWidget {
  //是否自动支付
  bool isPlay;

  final LoginPageType type;
  final bool showClose;
  final bool onlyPhone;
  UserLoginPage({
    super.key,
    required this.type,
    this.showClose = true,
    this.isPlay = true,
    this.onlyPhone = false,
  });

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final GlobalKey<LoginContentViewState> _contentViewKey =
      GlobalKey<LoginContentViewState>();
  final LoginController controller = Get.put(LoginController());


  @override
  void initState() {
    super.initState();
    controller.onlyPhone = widget.onlyPhone;
    //默认登录方式
    if (widget.onlyPhone){
      controller.loginType.value = LoginType.phone;
    } else {
      controller.loginType.value = LoginType.oneKey;
    }
    controller.pages = [];
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: controller.loginType.value == LoginType.oneKey ? 0.0 : 1.0,
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              Column(
                  children: [
                    Stack(
                      children: [
                        Image.asset(
                          "assets/login/dengludialog_bj.png",
                          fit: BoxFit.fitWidth,
                        ),
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: 120.h),
                          child: Image.asset(
                            "assets/login/denglulogo.png",
                            width: 100.w,
                            height: 100.h,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Image.asset(
                      "assets/login/login_ai_model.png",
                      height: 16.h,
                      fit: BoxFit.fitHeight,
                    ),
                    const Spacer(),
                    LoginContentPage(
                        key: _contentViewKey,
                        type: widget.type,
                        isPlay: widget.isPlay,
                      ),
                    SizedBox(height: 34.h),
                  ],
                ),
              closeWidget(),
              if (!widget.onlyPhone)
                _backBtn(context),
            ],
          )),
    );
  }

  Widget closeWidget() {
    if (!widget.showClose) return Container();
    final isHalf = widget.type == LoginPageType.half;
    var right = isHalf ? 0.0.w : 12.0.w;
    var height = isHalf ? 37.5.w : MediaQuery.of(context).padding.top + 35.0.h;
    var img = isHalf
        ? Image.asset(
            "assets/login/login_dialog_close.png",
            // width: 12.9,
            // height: 12.7,
        width: 13.w,
        height: 13.h
          )
        : Image.asset(
            "assets/login/login_close.png",
            width: 36,
            height: 36,
          );

    return Positioned(
      top: height,
      right: right,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        behavior: HitTestBehavior.opaque,
        child: Container(
          // width: 36,
          // height: 44,
          width: 45.w,
          height: 45.w,
          alignment: Alignment.center,
          margin: EdgeInsets.only(left: 16.w),
          child: img,
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.loginType.value = LoginType.oneKey;
    super.dispose();
  }

  _backBtn(BuildContext context) {
    final isHalf = widget.type == LoginPageType.half;
    var height = isHalf ? 37.5.w : MediaQuery.of(context).padding.top + 35.0.h;
    return Positioned(
      left: 0,
      top: height,
      child: Obx(() => Offstage(
        offstage: controller.loginType.value == LoginType.wx || controller.loginType.value == LoginType.oneKey,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (controller.loginType.value == LoginType.phone) {
              controller.updateLoginType(LoginType.wx);
            }
          },
          child: Container(
            width: 45,
            height: 45,
            alignment: Alignment.center,
            child: Image.asset(
              "assets/home/icon_back.png",
              width: 16,
              height: 16,
            ),
          ),
        ),
      ),
    ));
  }
}