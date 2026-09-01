import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/base/base_view.dart';
import 'package:video_clip_edit/core/network/provider/user_provider.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/v2/minorMode/beans/minor_page_type.dart';
import 'package:video_clip_edit/v2/minorMode/controllers/minor_create_controller.dart';
import 'package:video_clip_edit/v2/minorMode/widgets/minor_form_section.dart';
import 'package:video_clip_edit/widgets/common_button.dart';

class MinorCreatePage extends GetView<MinorCreateController> {
  const MinorCreatePage({super.key});

  static const Color _resetPageBg = Color(0xFFF8FAFC);
  static const Color _resetLabelColor = Color(0xFF1A1E33);
  static const Color _resetAccentPink = Color(0xFFF9B2BE);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.pageType.value) {
        case MinorPageType.enable:
          return _buildEnablePage();
        case MinorPageType.resetPassword:
          return _buildResetPasswordPage();
        case MinorPageType.enterPassword:
          return _buildEnterPasswordPage();
        case MinorPageType.timeManage:
          return _buildTimeManagePage();
      }
    });
  }

  // ==================== 开启未成年人模式 ====================
  Widget _buildEnablePage() {
    return BaseView(
      isTransparentAppBar: true,
      backgroundColor: Colors.white,
      child: Stack(
        children: [
          _buildHeaderBackground(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextHeader(
                          title: '开启未成年人模式',
                          subtitle: '为孩子提供更合适的内容',
                        ),
                        SizedBox(height: 28.h),
                        MinorFormSection(
                          title: '选择孩子出生年月',
                          description: '用于为孩子推荐适合的内容',
                          child: _buildBirthField(),
                        ),
                        SizedBox(height: 24.h),
                        MinorFormSection(
                          title: '预留家长手机号',
                          description: '忘记密码时，可通过该手机号验证家长身份并找回密码',
                          child: _buildPhoneField(),
                        ),
                        SizedBox(height: 24.h),
                        MinorFormSection(
                          title: '创建家长密码',
                          description: '用于管理、设置、进入和退出未成年人模式',
                          child: _buildPasswordField(),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildBottomButton(
                  canSubmit: controller.canSubmitEnable,
                  text: '开启未成年人模式',
                  onPressed: controller.submitEnableMinorMode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 找回密码 ====================
  Widget _buildResetPasswordPage() {
    return BaseView(
      title: '找回密码',
      backgroundColor: _resetPageBg,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildResetPasswordField(
                    label: '预留手机号',
                    hint: '请输入预留家长手机号',
                    textController: controller.resetPhoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    digitsOnly: true,
                  ),
                  SizedBox(height: 24.h),
                  _buildResetPasswordVCodeField(),
                  SizedBox(height: 24.h),
                  _buildResetPasswordField(
                    label: '设置新密码：',
                    hint: '请输入新密码',
                    textController: controller.newPasswordController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    digitsOnly: true,
                  ),
                ],
              ),
            ),
          ),
          _buildResetPasswordBottomButton(
            canSubmit: controller.canSubmitReset,
            text: '确认修改',
            onPressed: controller.submitResetPassword,
          ),
        ],
      ),
    );
  }

  Widget _buildResetPasswordField({
    required String label,
    required String hint,
    required TextEditingController textController,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    bool digitsOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BYText.instance(
          label,
          15.sp,
          fontWeight: BYFontWeight.semiBold,
          color: _resetLabelColor,
        ),
        SizedBox(height: 12.h),
        Container(
          height: 50.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: textController,
            keyboardType: keyboardType,
            maxLength: maxLength,
            style: BYTextStyle.instance(14.sp, color: _resetLabelColor),
            decoration: _inputDecoration(hint),
            inputFormatters: digitsOnly
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildResetPasswordVCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BYText.instance(
          '验证码',
          15.sp,
          fontWeight: BYFontWeight.semiBold,
          color: _resetLabelColor,
        ),
        SizedBox(height: 12.h),
        Container(
          height: 50.h,
          padding: EdgeInsets.only(left: 16.w, right: 12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.vCodeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: BYTextStyle.instance(14.sp, color: _resetLabelColor),
                  decoration: _inputDecoration('请输入验证码'),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              Obx(
                () => _ResetPasswordCountDown(
                  phoneNum: controller.resetPhoneController.text,
                  enable: controller.canSendVCode.value,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResetPasswordBottomButton({
    required RxBool canSubmit,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
      child: Obx(
        () => SizedBox(
          width: double.infinity,
          child: CommonButton(
            padding: EdgeInsets.zero,
            minSize: 50.h,
            borderRadius: BorderRadius.circular(12.r),
            color: canSubmit.value
                ? const Color(0xFFFE2B54)
                : _resetAccentPink.withOpacity(0.45),
            disabledColor: _resetAccentPink.withOpacity(0.45),
            onPressed: canSubmit.value ? onPressed : null,
            child: BYText.instance(
              text,
              17.sp,
              color: Colors.white,
              fontWeight: BYFontWeight.semiBold,
            ),
          ),
        ),
      ),
    );
  }

  // ==================== 输入家长密码 ====================
  Widget _buildEnterPasswordPage() {
    return BaseView(
      isTransparentAppBar: true,
      backgroundColor: Colors.white,
      child: Stack(
        children: [
          _buildHeaderBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextHeader(
                          title: controller.enterPasswordTitle,
                          subtitle: controller.enterPasswordSubtitle,
                        ),
                        SizedBox(height: 40.h),
                        _buildPinInput(),
                        SizedBox(height: 24.h),
                        _buildForgotPasswordLink(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 时间管理 ====================
  Widget _buildTimeManagePage() {
    return BaseView(
      title: '未成年人模式时间管理',
      backgroundColor: ByColorUtil.CommonPageBgColor,
      rear: Obx(
        () => CommonButton(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          minSize: 0,
          onPressed: controller.canSaveTimeManage.value
              ? controller.saveTimeManage
              : null,
          child: BYText.instance(
            '保存',
            14.sp,
            color: controller.canSaveTimeManage.value
                ? const Color(0xFFFE2B54)
                : const Color(0xFF697088),
            fontWeight: BYFontWeight.medium,
          ),
        ),
      ),
      child: GetBuilder<MinorCreateController>(
        id: 'time_manage',
        builder: (_) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BYText.instance(
                  '可设置未成年人模式下的使用时长和禁用时间段，到时间后将限制使用，需输入密码才可继续使用',
                  13.sp,
                  color: const Color(0xFF697088),
                  height: 1.5,
                ),
                SizedBox(height: 20.h),
                BYText.instance(
                  '选择设置方式',
                  16.sp,
                  fontWeight: BYFontWeight.semiBold,
                  color: const Color(0xFF0B1843),
                ),
                SizedBox(height: 12.h),
                _buildSettingModeCard(),
                SizedBox(height: 20.h),
                Obx(
                  () =>
                      controller.timeSettingMode.value ==
                          MinorTimeSettingMode.unified
                      ? _buildUnifiedTimeCard()
                      : _buildDailyTimeList(),
                ),
                SizedBox(height: 20.h),
                _buildTimeManageNotes(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderBackground() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Image.asset(
        MinorCreateController.headerBackgroundAsset,
        fit: BoxFit.fitWidth,
        alignment: Alignment.topCenter,
      ),
    );
  }

  Widget _buildTextHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BYText.instance(
          title,
          24.sp,
          fontWeight: BYFontWeight.bold,
          color: const Color(0xFF0B1843),
        ),
        SizedBox(height: 8.h),
        BYText.instance(subtitle, 14.sp, color: const Color(0xFF697088)),
      ],
    );
  }

  Widget _buildBirthField() {
    return GestureDetector(
      onTap: controller.selectBirthDate,
      child: _buildInputContainer(
        child: Row(
          children: [
            Expanded(
              child: Obx(
                () => Text(
                  controller.birthDateText.value.isEmpty
                      ? '选择孩子出生年月'
                      : controller.birthDateText.value,
                  style: BYTextStyle.instance(
                    14.sp,
                    color: controller.birthDateText.value.isEmpty
                        ? const Color(0xFF697088).withOpacity(0.6)
                        : const Color(0xFF0B1843),
                  ),
                ),
              ),
            ),
            Image.asset(
              MinorCreateController.arrowDownAsset,
              width: 16.w,
              height: 16.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return _buildInputContainer(
      child: Row(
        children: [
          BYText.instance(
            '+86',
            14.sp,
            color: const Color(0xFF0B1843),
            fontWeight: BYFontWeight.medium,
          ),
          Container(
            width: 1,
            height: 16.h,
            margin: EdgeInsets.symmetric(horizontal: 12.w),
            color: const Color(0xFFE3E6ED),
          ),
          Expanded(
            child: TextField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 11,
              style: BYTextStyle.instance(
                14.sp,
                color: const Color(0xFF0B1843),
              ),
              decoration: _inputDecoration('请填写手机号码'),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return _buildInputContainer(
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => TextField(
                controller: controller.passwordController,
                obscureText: !controller.passwordVisible.value,
                keyboardType: TextInputType.number,
                maxLength: 4,
                style: BYTextStyle.instance(
                  14.sp,
                  color: const Color(0xFF0B1843),
                ),
                decoration: _inputDecoration('请输入4位数字密码'),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ),
          Obx(
            () => GestureDetector(
              onTap: controller.togglePasswordVisible,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Image.asset(
                  controller.passwordVisible.value
                      ? MinorCreateController.passwordVisibleAsset
                      : MinorCreateController.passwordHiddenAsset,
                  width: 20.w,
                  height: 20.w,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinInput() {
    return GestureDetector(
      onTap: controller.focusPinInput,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0,
            child: TextField(
              controller: controller.pinController,
              focusNode: controller.pinFocusNode,
              keyboardType: TextInputType.number,
              maxLength: 4,
              autofocus: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) {
                final filled = index < controller.pinText.value.length;
                return Container(
                  width: 72.w,
                  height: 72.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ByColorUtil.CommonInputBgColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: filled
                      ? Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0B1843),
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Text.rich(
      TextSpan(
        text: '忘记密码？',
        style: BYTextStyle.instance(13.sp, color: const Color(0xFF697088)),
        children: [
          TextSpan(
            text: '验证家长身份',
            style: BYTextStyle.instance(13.sp, color: const Color(0xFFFE2B54)),
            recognizer: TapGestureRecognizer()
              ..onTap = controller.goResetPassword,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingModeCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Obx(
            () => _buildSelectableRow(
              title: '统一时间设置',
              selected:
                  controller.timeSettingMode.value ==
                  MinorTimeSettingMode.unified,
              onTap: () => controller.selectTimeSettingMode(
                MinorTimeSettingMode.unified,
              ),
              showDivider: true,
            ),
          ),
          Obx(
            () => _buildSelectableRow(
              title: '每日分别设置',
              selected:
                  controller.timeSettingMode.value ==
                  MinorTimeSettingMode.daily,
              onTap: () =>
                  controller.selectTimeSettingMode(MinorTimeSettingMode.daily),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableRow({
    required String title,
    required bool selected,
    required VoidCallback onTap,
    bool showDivider = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                Expanded(
                  child: BYText.instance(
                    title,
                    15.sp,
                    color: const Color(0xFF0B1843),
                  ),
                ),
                if (selected)
                  Icon(Icons.check, size: 18.w, color: const Color(0xFFFE2B54)),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1.h, color: const Color(0xFFF0F2F5), indent: 16.w),
      ],
    );
  }

  Widget _buildUnifiedTimeCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BYText.instance(
          '时间管理',
          16.sp,
          fontWeight: BYFontWeight.semiBold,
          color: const Color(0xFF0B1843),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              Obx(
                () => _buildTimeManageRow(
                  title: '使用时长',
                  value: controller.durationText(
                    controller.unifiedDurationMinutes.value,
                  ),
                  onTap: () => controller.pickUsageDuration(),
                  showDivider: true,
                ),
              ),
              Obx(
                () => _buildTimeManageRow(
                  title: '禁用时间段',
                  value: controller.unifiedDisabledPeriod.value,
                  onTap: () => controller.pickDisabledPeriod(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyTimeList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: BYText.instance(
                  '星期',
                  13.sp,
                  color: const Color(0xFF697088),
                ),
              ),
              Expanded(
                flex: 2,
                child: BYText.instance(
                  '使用时长',
                  13.sp,
                  color: const Color(0xFF697088),
                ),
              ),
              Expanded(
                flex: 3,
                child: BYText.instance(
                  '禁用时间段',
                  13.sp,
                  color: const Color(0xFF697088),
                ),
              ),
            ],
          ),
        ),
        ...List.generate(controller.dailySettings.length, (index) {
          final item = controller.dailySettings[index];
          return Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      BYText.instance(
                        item.weekLabel,
                        15.sp,
                        color: const Color(0xFF0B1843),
                      ),
                      if (item.isToday) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFE2B54).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: BYText.instance(
                            '今天',
                            10.sp,
                            color: const Color(0xFFFE2B54),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () =>
                        controller.pickUsageDuration(dailyIndex: index),
                    child: BYText.instance(
                      controller.durationText(item.durationMinutes),
                      14.sp,
                      color: const Color(0xFF0B1843),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onTap: () =>
                        controller.pickDisabledPeriod(dailyIndex: index),
                    child: Row(
                      children: [
                        Expanded(
                          child: BYText.instance(
                            item.disabledPeriod,
                            14.sp,
                            color: const Color(0xFF697088),
                          ),
                        ),
                        Image.asset(
                          Assets.commonArrowRight,
                          width: 12.w,
                          height: 12.w,
                          color: const Color(0xFF697088),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTimeManageRow({
    required String title,
    required String value,
    required VoidCallback onTap,
    bool showDivider = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                Expanded(
                  child: BYText.instance(
                    title,
                    15.sp,
                    color: const Color(0xFF0B1843),
                  ),
                ),
                BYText.instance(value, 14.sp, color: const Color(0xFF697088)),
                SizedBox(width: 4.w),
                Image.asset(
                  Assets.commonArrowRight,
                  width: 12.w,
                  height: 12.w,
                  color: const Color(0xFF697088),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1.h, color: const Color(0xFFF0F2F5), indent: 16.w),
      ],
    );
  }

  Widget _buildTimeManageNotes() {
    const notes = [
      '为保障合理使用妙笔工坊，未成年人在「禁用时段」不可使用妙笔工坊',
      '若家长在「0点-23点」之间有特殊诉求，可自定义设置禁用时间段',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: notes
          .map(
            (note) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: BYText.instance(
                '· $note',
                12.sp,
                color: const Color(0xFF697088),
                height: 1.5,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: ByColorUtil.CommonInputBgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      isDense: true,
      counterText: '',
      border: InputBorder.none,
      hintText: hint,
      hintStyle: BYTextStyle.instance(
        14.sp,
        color: const Color(0xFF697088).withOpacity(0.6),
      ),
    );
  }

  Widget _buildBottomButton({
    required RxBool canSubmit,
    required String text,
    required VoidCallback onPressed,
  }) {
    const accentColor = Color(0xFFFE2B54);
    final disabledColor = accentColor.withOpacity(0.5);

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
      child: Obx(
        () => SizedBox(
          width: double.infinity,
          child: CommonButton(
            padding: EdgeInsets.zero,
            minSize: 50.h,
            borderRadius: BorderRadius.circular(12.h),
            color: canSubmit.value ? accentColor : disabledColor,
            disabledColor: disabledColor,
            onPressed: canSubmit.value ? onPressed : null,
            child: BYText.instance(
              text,
              17.sp,
              color: ByColorUtil.WhiteColor,
              fontWeight: BYFontWeight.semiBold,
            ),
          ),
        ),
      ),
    );
  }
}

class _ResetPasswordCountDown extends StatefulWidget {
  const _ResetPasswordCountDown({required this.phoneNum, required this.enable});

  final String phoneNum;
  final bool enable;

  @override
  State<_ResetPasswordCountDown> createState() =>
      _ResetPasswordCountDownState();
}

class _ResetPasswordCountDownState extends State<_ResetPasswordCountDown> {
  static const int _countdownSeconds = 60;

  UserProvider get _userProvider => Get.find<UserProvider>();

  String _text = '获取验证码';
  Timer? _timer;
  int _remaining = _countdownSeconds;
  bool _ticking = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canTap = widget.enable && !_ticking;
    return GestureDetector(
      onTap: canTap ? _getVCode : null,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: BYText.instance(
          _text,
          14.sp,
          color: canTap
              ? MinorCreatePage._resetAccentPink
              : MinorCreatePage._resetAccentPink.withOpacity(0.45),
          fontWeight: BYFontWeight.medium,
        ),
      ),
    );
  }

  void _getVCode() {
    _userProvider.getVCode(
      phoneNum: widget.phoneNum,
      onSuccess: (_) => _startCountdown(),
      onFailed: (_, __) {},
    );
  }

  void _startCountdown() {
    if (_ticking) return;

    setState(() {
      _ticking = true;
      _remaining = _countdownSeconds;
      _text = '${_remaining}s';
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 1) {
        timer.cancel();
        setState(() {
          _ticking = false;
          _remaining = _countdownSeconds;
          _text = '重新获取';
        });
        return;
      }

      setState(() {
        _remaining--;
        _text = '${_remaining}s';
      });
    });
  }
}
