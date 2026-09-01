import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/util/common_ui.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/core/base/base_view.dart';
import 'package:video_clip_edit/v2/profile/controllers/user_profile_controller.dart';
import 'package:video_clip_edit/widgets/common_button.dart';
import 'package:video_clip_edit/widgets/form/custom_text_form_field.dart';
import 'package:video_clip_edit/widgets/image/by_image_view.dart';

class UserProfilePage extends GetView<UserProfileController> {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(builder: (controller) {
      return BaseView(
        title: '用户信息',
        backgroundColor: ByColorUtil.colorF8FAFB,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfoView(),
              const Spacer(),
              controller.userInfo?.isFormal == 1
                  ? Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 12.w),
                      child: CommonButton(
                        padding: EdgeInsets.zero,
                        minSize: 44,
                        borderRadius: BorderRadius.circular(12),
                        color: ByColorUtil.WhiteColor,
                        onPressed: controller.logout,
                        child: BYText.instance('退出登录', 14),
                      ),
                    )
                  : Container(),
              controller.userInfo?.isFormal == 1
                  ? Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(top: 20.h, bottom: 25),
                      margin: EdgeInsets.symmetric(horizontal: 12.w),
                      child: CommonButton(
                        padding: EdgeInsets.zero,
                        minSize: 0,
                        borderRadius: BorderRadius.zero,
                        color: Colors.transparent,
                        onPressed: controller.deleteAccount,
                        child: BYText.instance('注销账号', 14, color: ByColorUtil.CommonTextColor.withOpacity(0.5)),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      );
    });
  }

  _buildUserInfoView() {
    return radiusView(
      backgroundColor: ByColorUtil.WhiteColor,
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Column(
        children: [
          buildTextFormView(
            '头像',
            CustomTextFieldType.edit,
            enable: false,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            titleStyle: BYTextStyle.instance(14.sp, color: ByColorUtil.CommonTextColor),
            showDivider: true,
            suffixWidget: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BYImageView.avatar(
                imageUrl: controller.userInfo?.avatar,
                width: 58.w,
                height: 58.h,
              ),
            ),
          ),
          buildTextFormView(
            '用户ID',
            CustomTextFieldType.edit,
            subTitle: '${controller.userInfo?.userId ?? ""}',
            enable: false,
            padding: EdgeInsets.symmetric(vertical: 20.h),
            titleStyle: BYTextStyle.instance(14.sp, color: ByColorUtil.CommonTextColor),
            showDivider: true,
            suffixWidget: Container(
              margin: EdgeInsets.only(left: 4.w),
              child: Image.asset(
                Assets.commonIconCopy,
                width: 15.w,
                height: 15.h,
              ),
            ),
            onTap: controller.copyShortId,
          ),
          buildTextFormView(
            '用户名',
            CustomTextFieldType.edit,
            subTitle: controller.userController.nickName.value,
            enable: false,
            padding: EdgeInsets.symmetric(vertical: 20.h),
            titleStyle: BYTextStyle.instance(14.sp, color: ByColorUtil.CommonTextColor),
            showDivider: true,
          ),
          controller.userInfo?.isFormal == 1 && controller.userInfo?.isBindWx == 1
              ? buildTextFormView(
                  '微信',
                  CustomTextFieldType.edit,
                  subTitle: '已绑定',
                  enable: false,
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  titleStyle: BYTextStyle.instance(14.sp, color: ByColorUtil.CommonTextColor),
                  showDivider: true,
                )
              : Container(),
          buildTextFormView(
            '手机号',
            CustomTextFieldType.edit,
            enable: false,
            padding: EdgeInsets.symmetric(vertical: 20.h),
            titleStyle: BYTextStyle.instance(14.sp, color: ByColorUtil.CommonTextColor),
            suffixWidget: CommonButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              borderRadius: BorderRadius.zero,
              color: Colors.transparent,
              disabledColor: Colors.transparent,
              onPressed: controller.userInfo?.isBindPhone == 1 ? null : controller.phoneAction,
              child: BYText.instance(_getPhoneText(), 14, color: _getPhoneTextColor()),
            ),
          ),
        ],
      ),
    );
  }

  ///手机号不同状态下显示的文案
  _getPhoneText(){
    ///绑定了手机号
    if (controller.userInfo?.isBindPhone == 1) {
      return controller.userInfo?.phone ?? "";
    } else if ((controller.userInfo?.isFormal ?? 0 ) == 0 && (controller.userInfo?.isVip ?? 0) == 0) {
      ///未登录且不是会员时
      return '点击登录';
    } else {
      return '去绑定';
    }
  }
  
  _getPhoneTextColor(){
    if ((controller.userInfo?.isFormal ?? 0 )== 0) {
      return ByColorUtil.LoginBtnBgColor;
    } else if(controller.userInfo?.isBindPhone == 1) {
      ///已登录 绑定了手机号
      return ByColorUtil.CommonTextColor.withOpacity(0.5);
    } else {
      return ByColorUtil.LoginBtnBgColor;
    }
  }
}
