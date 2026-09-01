import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:video_clip_edit/v2/minorMode/beans/minor_daily_time_setting.dart';
import 'package:video_clip_edit/v2/minorMode/beans/minor_mode_info_bean.dart';
import 'package:video_clip_edit/v2/minorMode/beans/minor_mode_time_limit.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/v2/minorMode/beans/minor_page_type.dart';
import 'package:video_clip_edit/v2/minorMode/controllers/minor_mode_controller.dart';

class MinorCreateController extends GetxController {
  static const String headerBackgroundAsset = 'assets/minor/minor-6.png';
  static const String arrowDownAsset = 'assets/minor/minor-7.png';
  static const String passwordVisibleAsset = 'assets/minor/minor-8.png';
  static const String passwordHiddenAsset = 'assets/minor/minor-9.png';
  static const String toggleOffAsset = 'assets/minor/minor-10.png';
  static const String toggleOnAsset = 'assets/minor/minor-11.png';

  static const List<String> weekLabels = [
    '周一',
    '周二',
    '周三',
    '周四',
    '周五',
    '周六',
    '周日',
  ];

  final pageType = MinorPageType.enable.obs;

  // enable
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final birthDateText = ''.obs;
  final passwordVisible = false.obs;
  final canSubmitEnable = false.obs;
  DateTime? selectedBirthDate;

  // reset password
  final TextEditingController resetPhoneController = TextEditingController();
  final TextEditingController vCodeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final canSubmitReset = false.obs;
  final canSendVCode = false.obs;

  // enter password
  final TextEditingController pinController = TextEditingController();
  final pinText = ''.obs;
  final FocusNode pinFocusNode = FocusNode();

  // time manage
  final timeSettingMode = MinorTimeSettingMode.unified.obs;
  final unifiedDurationMinutes = 40.obs;
  final unifiedDisabledPeriod = MinorModeTimeLimit.defaultPeriodText.obs;
  final unifiedDisabledEnabled = true.obs;
  final canSaveTimeManage = false.obs;
  late final List<MinorDailyTimeSetting> dailySettings;
  int? editingDailyIndex;

  /// 首次设置时间管理（开启流程进入）无需密码；二次编辑必传密码
  final isFirstTimeTimeSetup = true.obs;
  final verifyIntent = Rxn<MinorVerifyIntent>();
  bool _isSavingTimeManage = false;

  String get enterPasswordTitle {
    switch (verifyIntent.value) {
      case MinorVerifyIntent.openMinorMode:
        return '输入家长密码，管理时间';
      case MinorVerifyIntent.openTimeManage:
        return '输入家长密码，管理时间';
      case MinorVerifyIntent.closeMinorMode:
      default:
        return '输入家长密码，关闭未成年人模式';
    }
  }

  String get enterPasswordSubtitle {
    switch (verifyIntent.value) {
      case MinorVerifyIntent.openMinorMode:
        return '验证通过后可开启未成年人模式';
      case MinorVerifyIntent.openTimeManage:
        return '调节孩子的使用时长限制';
      case MinorVerifyIntent.closeMinorMode:
      default:
        return '验证通过后可关闭未成年人模式';
    }
  }

  void _parseRouteArgs(dynamic args) {
    if (args is MinorCreateRouteArgs) {
      pageType.value = args.pageType;
      verifyIntent.value = args.verifyIntent;
      return;
    }
    if (args is MinorPageType) {
      pageType.value = args;
      if (args == MinorPageType.enterPassword) {
        verifyIntent.value = MinorVerifyIntent.closeMinorMode;
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    _parseRouteArgs(args);
    _initDailySettings();
    phoneController.addListener(_refreshEnableSubmitState);
    passwordController.addListener(_refreshEnableSubmitState);
    resetPhoneController.addListener(_refreshResetSubmitState);
    vCodeController.addListener(_refreshResetSubmitState);
    newPasswordController.addListener(_refreshResetSubmitState);
    pinController.addListener(_onPinChanged);
    if (pageType.value == MinorPageType.timeManage) {
      isFirstTimeTimeSetup.value = false;
    }
    if (pageType.value == MinorPageType.enterPassword) {
      MinorModeController.to.fetchMinorModeInfo(showLoading: false);
    }
    _refreshTimeManageSaveState();
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    resetPhoneController.dispose();
    vCodeController.dispose();
    newPasswordController.dispose();
    pinController.dispose();
    pinFocusNode.dispose();
    super.onClose();
  }

  void switchPageType(MinorPageType type) {
    pageType.value = type;
  }

  void _initDailySettings() {
    final today = DateTime.now().weekday;
    dailySettings = List.generate(
      weekLabels.length,
      (index) => MinorDailyTimeSetting(
        weekLabel: weekLabels[index],
        isToday: index + 1 == today,
      ),
    );
  }

  void _refreshEnableSubmitState() {
    canSubmitEnable.value =
        birthDateText.isNotEmpty &&
        RegExp(r'^1[3-9]\d{9}$').hasMatch(phoneController.text.trim()) &&
        passwordController.text.trim().length == 4;
  }

  Future<void> selectBirthDate() async {
    final context = Get.context;
    if (context == null) return;

    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate:
          selectedBirthDate ?? DateTime(now.year - 10, now.month, now.day),
      firstDate: DateTime(2000, 1, 1),
      lastDate: now,
      helpText: '选择孩子出生年月日',
    );
    if (date == null) return;

    selectedBirthDate = DateTime(date.year, date.month, date.day);
    birthDateText.value = DateFormat('yyyy-MM-dd').format(selectedBirthDate!);
    _refreshEnableSubmitState();
  }

  void togglePasswordVisible() {
    passwordVisible.value = !passwordVisible.value;
  }

  Future<void> submitEnableMinorMode() async {
    if (!canSubmitEnable.value) return;

    final success = await MinorModeController.to.enableMinorMode(
      birthday: birthDateText.value,
      phone: phoneController.text.trim(),
      password: passwordController.text.trim(),
    );
    if (!success) return;

    MinorModeController.to.setParentPassword(passwordController.text.trim());
    await MinorModeController.to.fetchMinorModeInfo(showLoading: false);
    applyMinorModeInfo(MinorModeController.to.info.value);
    isFirstTimeTimeSetup.value = true;
    switchPageType(MinorPageType.timeManage);
  }

  void applyMinorModeInfo(MinorModeInfoBean? config) {
    if (config == null) return;

    timeSettingMode.value = config.timeSettingMode;

    if (config.isDailyMode) {
      final limits = config.dailyTimeLimits;
      if (limits == null) return;

      for (var i = 0; i < dailySettings.length; i++) {
        final limit = _findDailyLimit(limits, i);
        if (limit == null) continue;

        if (limit.totalUseTime != null) {
          dailySettings[i].durationMinutes = limit.totalUseTime!;
        }
        dailySettings[i].disabledEnabled = limit.isDisabledPeriodEnabled;
        dailySettings[i].disabledPeriod = limit.configuredPeriodText;
      }
    } else {
      final limit = config.unifiedTimeLimit;
      if (limit == null) return;

      if (limit.totalUseTime != null) {
        unifiedDurationMinutes.value = limit.totalUseTime!;
      }
      unifiedDisabledEnabled.value = limit.isDisabledPeriodEnabled;
      unifiedDisabledPeriod.value = limit.configuredPeriodText;
    }

    _refreshTimeManageSaveState();
    update(['time_manage']);
  }

  MinorModeTimeLimit? _findDailyLimit(
    List<MinorModeTimeLimit> limits,
    int index,
  ) {
    final weekday = index + 1;
    for (final limit in limits) {
      if (limit.weekday == weekday) return limit;
    }
    return index < limits.length ? limits[index] : null;
  }

  void _refreshResetSubmitState() {
    canSendVCode.value = RegExp(
      r'^1[3-9]\d{9}$',
    ).hasMatch(resetPhoneController.text.trim());
    canSubmitReset.value =
        canSendVCode.value &&
        vCodeController.text.trim().length >= 4 &&
        newPasswordController.text.trim().length == 4;
  }

  Future<void> submitResetPassword() async {
    if (!canSubmitReset.value) return;

    final success = await MinorModeController.to.forgotMinorModePassword(
      phone: resetPhoneController.text.trim(),
      code: vCodeController.text.trim(),
      password: newPasswordController.text.trim(),
    );
    if (!success) return;

    await MinorModeController.to.fetchMinorModeInfo(showLoading: false);
    Get.until((route) => route.settings.name == Routes.main);
  }

  void goResetPassword() {
    final phone = MinorModeController.to.info.value?.phone?.trim();
    if (phone != null && phone.isNotEmpty) {
      resetPhoneController.text = phone;
      _refreshResetSubmitState();
    }
    switchPageType(MinorPageType.resetPassword);
  }

  void _onPinChanged() {
    pinText.value = pinController.text;
    if (pinText.value.length == 4) {
      _verifyPin();
    }
  }

  void focusPinInput() {
    pinFocusNode.requestFocus();
  }

  void _verifyPin() {
    final input = pinController.text.trim();
    if (input.length != 4) return;

    if (MinorModeController.to.canVerifyPassword == false) {
      EasyLoading.showToast('未获取到密码配置，请稍后重试');
      return;
    }

    if (!MinorModeController.to.verifyParentPassword(input)) {
      EasyLoading.showToast('密码错误');
      pinController.clear();
      pinText.value = '';
      return;
    }

    MinorModeController.to.setParentPassword(input);
    switch (verifyIntent.value ?? MinorVerifyIntent.closeMinorMode) {
      case MinorVerifyIntent.openMinorMode:
        _changeMinorModeAfterVerify(password: input, enabled: true);
        break;
      case MinorVerifyIntent.closeMinorMode:
        _changeMinorModeAfterVerify(password: input, enabled: false);
        break;
      case MinorVerifyIntent.openTimeManage:
        _openTimeManageAfterVerify();
        break;
    }
  }

  Future<void> _changeMinorModeAfterVerify({
    required String password,
    required bool enabled,
  }) async {
    final success = await MinorModeController.to.changeMinorModeEnabled(
      enabled: enabled,
      password: password,
    );
    if (!success) return;

    Get.until((route) => route.settings.name == Routes.main);
  }

  Future<void> _openTimeManageAfterVerify() async {
    await MinorModeController.to.fetchMinorModeInfo(showLoading: false);
    applyMinorModeInfo(MinorModeController.to.info.value);
    isFirstTimeTimeSetup.value = false;
    pinController.clear();
    pinText.value = '';
    switchPageType(MinorPageType.timeManage);
  }

  void selectTimeSettingMode(MinorTimeSettingMode mode) {
    timeSettingMode.value = mode;
    _refreshTimeManageSaveState();
  }

  void _refreshTimeManageSaveState() {
    canSaveTimeManage.value = true;
  }

  Future<void> pickUsageDuration({int? dailyIndex}) async {
    editingDailyIndex = dailyIndex;
    const options = [20, 30, 40, 60, 90, 120];
    final current = dailyIndex == null
        ? unifiedDurationMinutes.value
        : dailySettings[dailyIndex].durationMinutes;
    final selected = await _showMinutePicker(
      title: '设置使用时长',
      current: current,
      options: options,
    );
    if (selected == null) return;

    if (dailyIndex == null) {
      unifiedDurationMinutes.value = selected;
    } else {
      dailySettings[dailyIndex].durationMinutes = selected;
    }
    _refreshTimeManageSaveState();
    update(['time_manage']);
  }

  Future<void> pickDisabledPeriod({int? dailyIndex}) async {
    editingDailyIndex = dailyIndex;
    final bool initialEnabled;
    final int initialStartHour;
    final int initialEndHour;

    if (dailyIndex == null) {
      initialEnabled = unifiedDisabledEnabled.value;
      final parsed = _parseDisabledPeriod(unifiedDisabledPeriod.value);
      initialStartHour = parsed?.startHour ?? MinorModeTimeLimit.defaultStartHour;
      initialEndHour = parsed?.endHour ?? MinorModeTimeLimit.defaultEndHour;
    } else {
      final setting = dailySettings[dailyIndex];
      initialEnabled = setting.disabledEnabled;
      final parsed = _parseDisabledPeriod(setting.disabledPeriod);
      initialStartHour = parsed?.startHour ?? MinorModeTimeLimit.defaultStartHour;
      initialEndHour = parsed?.endHour ?? MinorModeTimeLimit.defaultEndHour;
    }

    final result = await _showDisabledPeriodSheet(
      initialEnabled: initialEnabled,
      initialStartHour: initialStartHour,
      initialEndHour: initialEndHour,
    );
    if (result == null) return;

    final periodText =
        '${_formatHour(result.startHour)}-${_formatHour(result.endHour)}';

    if (dailyIndex == null) {
      unifiedDisabledEnabled.value = result.enabled;
      unifiedDisabledPeriod.value = periodText;
    } else {
      dailySettings[dailyIndex].disabledEnabled = result.enabled;
      dailySettings[dailyIndex].disabledPeriod = periodText;
    }
    _refreshTimeManageSaveState();
    update(['time_manage']);
  }

  /// 仅点击「保存」时组装参数并提交接口，切换模式/修改时长不会触发请求。
  Future<void> saveTimeManage() async {
    if (!canSaveTimeManage.value || _isSavingTimeManage) return;

    String? password;
    if (!isFirstTimeTimeSetup.value) {
      password = MinorModeController.to.resolvedParentPassword;
      if (password == null) {
        EasyLoading.showToast('未获取到家长密码，请先验证身份');
        return;
      }
    }

    _isSavingTimeManage = true;
    final mode = timeSettingMode.value == MinorTimeSettingMode.unified
        ? MinorModeInfoBean.modeUnified
        : MinorModeInfoBean.modeDaily;
    final timeLimit = _buildTimeLimitPayload();

    final success = await MinorModeController.to.updateMinorModeTimeLimit(
      mode: mode,
      timeLimit: timeLimit,
      password: password,
    );
    _isSavingTimeManage = false;
    if (!success) return;

    isFirstTimeTimeSetup.value = false;
    await MinorModeController.to.fetchMinorModeInfo(showLoading: false);
    Get.until((route) => route.settings.name == Routes.main);
  }

  String _buildTimeLimitPayload() {
    if (timeSettingMode.value == MinorTimeSettingMode.unified) {
      return jsonEncode(_buildUnifiedTimeLimit());
    }
    return jsonEncode(_buildDailyTimeLimits());
  }

  Map<String, dynamic> _buildUnifiedTimeLimit() {
    final times = _resolveDisabledTimes(unifiedDisabledPeriod.value);
    return {
      'start_time': times['start_time'],
      'end_time': times['end_time'],
      'is_enable': unifiedDisabledEnabled.value ? 1 : 0,
      'total_use_time': unifiedDurationMinutes.value.toString(),
    };
  }

  List<Map<String, dynamic>> _buildDailyTimeLimits() {
    return List.generate(dailySettings.length, (index) {
      final setting = dailySettings[index];
      final times = _resolveDisabledTimes(setting.disabledPeriod);
      return {
        'weekday': index + 1,
        'start_time': times['start_time'],
        'end_time': times['end_time'],
        'is_enable': setting.disabledEnabled ? 1 : 0,
        'total_use_time': setting.durationMinutes.toString(),
      };
    });
  }

  Map<String, String> _resolveDisabledTimes(String period) {
    final parsed = _parseDisabledPeriod(period);
    return {
      'start_time': _formatHour(
        parsed?.startHour ?? MinorModeTimeLimit.defaultStartHour,
      ),
      'end_time': _formatHour(
        parsed?.endHour ?? MinorModeTimeLimit.defaultEndHour,
      ),
    };
  }

  _ParsedDisabledPeriod? _parseDisabledPeriod(String period) {
    if (period.isEmpty || period == '未设置' || !period.contains('-')) {
      return null;
    }
    final parts = period.split('-');
    if (parts.length != 2) return null;
    return _ParsedDisabledPeriod(
      startHour: _parseHour(parts[0]),
      endHour: _parseHour(parts[1]),
    );
  }

  int _parseHour(String time) {
    final segments = time.trim().split(':');
    return int.tryParse(segments.first) ?? 0;
  }

  String durationText(int minutes) => '${minutes}分钟';

  static const Color _pickerSurfaceColor = Color(0xFFF4F4F4);
  static const double _disabledPeriodItemExtent = 48;
  static double get _wheelItemExtent => 44.h;

  Widget _buildWheelHighlight({
    EdgeInsetsGeometry? margin,
    double? height,
  }) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: height ?? _wheelItemExtent,
        width: double.infinity,
        margin: margin ?? EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: _pickerSurfaceColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  Widget _buildMinorToggle({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Image.asset(
        value ? toggleOnAsset : toggleOffAsset,
        width: 44.w,
        height: 26.h,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildWheelText(String text, {required bool selected}) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          fontSize: selected ? 18.sp : 16.sp,
          color: selected
              ? const Color(0xFF0B1843)
              : const Color(0xFF697088).withOpacity(0.45),
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Future<int?> _showMinutePicker({
    required String title,
    required int current,
    required List<int> options,
  }) async {
    var selected = current;
    var selectedIndex = options.indexOf(current).clamp(0, options.length - 1);

    return Get.bottomSheet<int>(
      StatefulBuilder(
        builder: (context, setState) {
          return _MinorPickerSheet(
            title: title,
            child: SizedBox(
              height: 180.h,
              child: Stack(
                children: [
                  _buildWheelHighlight(),
                  ListWheelScrollView.useDelegate(
                    itemExtent: _wheelItemExtent,
                    diameterRatio: 1.5,
                    physics: const FixedExtentScrollPhysics(),
                    controller: FixedExtentScrollController(
                      initialItem: selectedIndex,
                    ),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedIndex = index;
                        selected = options[index];
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: options.length,
                      builder: (context, index) => _buildWheelText(
                        '${options[index]}分钟',
                        selected: index == selectedIndex,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onConfirm: () => Get.back(result: selected),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<_DisabledPeriodResult?> _showDisabledPeriodSheet({
    bool? initialEnabled,
    int? initialStartHour,
    int? initialEndHour,
  }) async {
    var enabled = initialEnabled ?? unifiedDisabledEnabled.value;
    var startHour = initialStartHour ?? 6;
    var endHour = initialEndHour ?? 22;

    return Get.bottomSheet<_DisabledPeriodResult>(
      StatefulBuilder(
        builder: (context, setState) {
          return _MinorPickerSheet(
            title: '设置禁用时间段',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          '开始时间',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: const Color(0xFF697088),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          '结束时间',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: const Color(0xFF697088),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: SizedBox(
                    height: 180.h,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildWheelHighlight(
                          height: _disabledPeriodItemExtent.h,
                          margin: EdgeInsets.zero,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildHourWheel(
                                value: startHour,
                                itemExtent: _disabledPeriodItemExtent.h,
                                onChanged: (v) =>
                                    setState(() => startHour = v),
                              ),
                            ),
                            Expanded(
                              child: _buildHourWheel(
                                value: endHour,
                                itemExtent: _disabledPeriodItemExtent.h,
                                onChanged: (v) => setState(() => endHour = v),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: _pickerSurfaceColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '设置禁用时间段',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF0B1843),
                          ),
                        ),
                        _buildMinorToggle(
                          value: enabled,
                          onChanged: (value) =>
                              setState(() => enabled = value),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            onConfirm: () => Get.back(
              result: _DisabledPeriodResult(
                enabled: enabled,
                startHour: startHour,
                endHour: endHour,
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildHourWheel({
    required int value,
    required ValueChanged<int> onChanged,
    double? itemExtent,
  }) {
    final extent = itemExtent ?? _wheelItemExtent;
    return ListWheelScrollView.useDelegate(
      itemExtent: extent,
      diameterRatio: 1.5,
      physics: const FixedExtentScrollPhysics(),
      controller: FixedExtentScrollController(initialItem: value),
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: 24,
        builder: (context, index) =>
            _buildWheelText(_formatHour(index), selected: index == value),
      ),
    );
  }

  String _formatHour(int hour) => '${hour.toString().padLeft(2, '0')}:00';
}

class _DisabledPeriodResult {
  _DisabledPeriodResult({
    required this.enabled,
    required this.startHour,
    required this.endHour,
  });

  final bool enabled;
  final int startHour;
  final int endHour;
}

class _ParsedDisabledPeriod {
  _ParsedDisabledPeriod({required this.startHour, required this.endHour});

  final int startHour;
  final int endHour;
}

class _MinorPickerSheet extends StatelessWidget {
  const _MinorPickerSheet({
    required this.title,
    required this.child,
    required this.onConfirm,
  });

  final String title;
  final Widget child;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 12.w, 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0B1843),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.close, color: Color(0xFF697088)),
                  ),
                ],
              ),
            ),
            child,
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: Get.back,
                      style: TextButton.styleFrom(
                        minimumSize: Size(double.infinity, 48.h),
                        backgroundColor: const Color(0xFFF4F4F4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        '取消',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: const Color(0xFF0B1843),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48.h),
                        backgroundColor: const Color(0xFFFE2B54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '确认设置',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
