enum MinorPageType {
  /// 开启未成年人模式
  enable,

  /// 找回密码
  resetPassword,

  /// 输入家长密码
  enterPassword,

  /// 时间管理
  timeManage,
}

/// 家长密码验证通过后的目标动作
enum MinorVerifyIntent {
  /// 关闭未成年人模式（status=2）
  closeMinorMode,

  /// 开启未成年人模式（status=1）
  openMinorMode,

  /// 进入时间管理
  openTimeManage,
}

class MinorCreateRouteArgs {
  const MinorCreateRouteArgs({
    required this.pageType,
    this.verifyIntent,
  });

  final MinorPageType pageType;
  final MinorVerifyIntent? verifyIntent;
}

enum MinorTimeSettingMode {
  /// 统一时间设置
  unified,

  /// 每日分别设置
  daily,
}
