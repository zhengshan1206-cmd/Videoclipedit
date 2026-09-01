class VipPageBean {
  String kfUrl = "";
  VipPageUser user =
      VipPageUser(protocolUrl: "", subScribeProtocolUrl: "", integralRule: "");
  String retainWindowUrl = "";

  VipPageBean({
    required this.kfUrl,
    required this.user,
    required this.retainWindowUrl,
  });

  factory VipPageBean.fromJson(Map<String, dynamic> json) => VipPageBean(
        kfUrl: json["kf_url"] ?? "",
        user: VipPageUser.fromJson(json["user"]),
        retainWindowUrl: json["retain_window_url"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "kfUrl": kfUrl,
        "user": user,
        "retainWindowUrl": retainWindowUrl,
      };
}

class VipPageUser {
  String protocolUrl = "";
  String subScribeProtocolUrl = "";
  String integralRule = "";

  VipPageUser({
    required this.protocolUrl,
    required this.subScribeProtocolUrl,
    required this.integralRule,
  });

  factory VipPageUser.fromJson(Map<String, dynamic> json) => VipPageUser(
        protocolUrl: json["protocol_url"],
        subScribeProtocolUrl: json["subscribe_protocol_url"],
        integralRule: json["integral_rule"],
      );

  Map<String, dynamic> toJson() => {
        "protocolUrl": protocolUrl,
        "subscribe_protocol_url": subScribeProtocolUrl,
        "integral_rule": integralRule,
      };
}
