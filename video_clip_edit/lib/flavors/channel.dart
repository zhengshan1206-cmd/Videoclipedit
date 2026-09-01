enum ChannelType {
  ///华为应用市场
  huawei('e30dbe3dff145d54', 414),

  ///快手-磁力聚星
  kwaiMgs('d512a115aa4d351a', 719),

  ///百度广告-投放
  baiduLaunch('7479004d24ecd691', 405),

  ///百度应用市场
  baidu('5b133582952a3a58', 391),

  ///应用宝
  tencent('5d557d6d93822579', 395),

  ///vivo
  vivo('68477f840b9ec619', 394),

  ///小米
  xiaomi('8dcf58849b40ee27', 397),

  ///oppo
  oppo('b06d0830c734ae39', 398),

  ///快手
  kwai('53f2ea0180b089b7', 399),

  ///头条
  headlines('2ce49c9cee03d75a', 400),

  ///荣耀
  huaweiHonor('dcf06ef8cd72bb82', 401),

  ///ios
  iosAppStore("54eb7becb7283889", 396),

  /// 腾讯投放
  tencentLaunch('644e58b2cd60a708', 436),

  ///头条
  headlinesTest('67d6883cab7d84b1', 1516),

  ///录屏包
  screenRecord('109bcee76d1c7589', 2438),

  ///低价策略
  lowPrice('882cd7bb079ffbc8', 1862);

  final String channel;
  final num code;

  const ChannelType(this.channel, this.code);
}
