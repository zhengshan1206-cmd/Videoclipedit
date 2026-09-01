import 'dart:convert';

class LaunchInfoBean {
  int userId;
  int isVip;
  int vipLevel;
  String token;
  int isFormal;
  String wsuri;
  String wsuri2;
  int appTaste;
  Config config;
  int update;
  int forceUpdate;
  String version;
  String versionDes;
  String versionUrl;
  VerConfig verConfig;
  bool canBoundCode;
  String vipcoursepublicize;
  int isAudit;
  String upgradeNotice;
  String userCreatedAt;

  LaunchInfoBean({
    required this.userId,
    required this.isVip,
    required this.vipLevel,
    required this.token,
    required this.isFormal,
    required this.wsuri,
    required this.wsuri2,
    required this.appTaste,
    required this.config,
    required this.update,
    required this.forceUpdate,
    required this.version,
    required this.versionDes,
    required this.versionUrl,
    required this.verConfig,
    required this.canBoundCode,
    required this.vipcoursepublicize,
    required this.isAudit,
    required this.upgradeNotice,
    required this.userCreatedAt,
  });

  LaunchInfoBean copyWith({
    int? userId,
    int? isVip,
    int? vipLevel,
    String? token,
    int? isFormal,
    String? wsuri,
    String? wsuri2,
    int? appTaste,
    Config? config,
    int? update,
    int? forceUpdate,
    String? version,
    String? versionDes,
    String? versionUrl,
    VerConfig? verConfig,
    bool? canBoundCode,
    String? vipcoursepublicize,
    int? isAudit,
    String? upgradeNotice,
    String? userCreatedAt,
    String? newUserUndertakeType,
  }) =>
      LaunchInfoBean(
        userId: userId ?? this.userId,
        isVip: isVip ?? this.isVip,
        vipLevel: vipLevel ?? this.vipLevel,
        token: token ?? this.token,
        isFormal: isFormal ?? this.isFormal,
        wsuri: wsuri ?? this.wsuri,
        wsuri2: wsuri2 ?? this.wsuri2,
        appTaste: appTaste ?? this.appTaste,
        config: config ?? this.config,
        update: update ?? this.update,
        forceUpdate: forceUpdate ?? this.forceUpdate,
        version: version ?? this.version,
        versionDes: versionDes ?? this.versionDes,
        versionUrl: versionUrl ?? this.versionUrl,
        verConfig: verConfig ?? this.verConfig,
        canBoundCode: canBoundCode ?? this.canBoundCode,
        vipcoursepublicize: vipcoursepublicize ?? this.vipcoursepublicize,
        isAudit: isAudit ?? this.isAudit,
        upgradeNotice: upgradeNotice ?? this.upgradeNotice,
        userCreatedAt: userCreatedAt ?? this.userCreatedAt,
      );

  factory LaunchInfoBean.fromRawJson(String str) =>
      LaunchInfoBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LaunchInfoBean.fromJson(Map<String, dynamic> json) => LaunchInfoBean(
        userId: json["user_id"],
        isVip: json["is_vip"],
        vipLevel: json["vip_level"],
        token: json["token"],
        isFormal: json["is_formal"],
        wsuri: json["wsuri"] ?? "",
        wsuri2: json["wsuri2"] ?? "",
        appTaste: json["app_taste"],
        config: Config.fromJson(json["config"]),
        update: json["update"],
        forceUpdate: json["force_update"],
        version: json["version"],
        versionDes: json["version_des"],
        versionUrl: json["version_url"],
        verConfig: VerConfig.fromJson(json["ver_config"]),
        canBoundCode: json["can_bound_code"],
        vipcoursepublicize: json["vipcoursepublicize"] ?? "",
        isAudit: json["is_audit"],
        upgradeNotice: json["upgrade_notice"] ?? "",
        userCreatedAt: json['user_created_at'] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "is_vip": isVip,
        "vip_level": vipLevel,
        "token": token,
        "is_formal": isFormal,
        "wsuri": wsuri,
        "wsuri2": wsuri2,
        "app_taste": appTaste,
        "config": config.toJson(),
        "update": update,
        "force_update": forceUpdate,
        "version": version,
        "version_des": versionDes,
        "version_url": versionUrl,
        "ver_config": verConfig.toJson(),
        "can_bound_code": canBoundCode,
        "vipcoursepublicize": vipcoursepublicize,
        "is_audit": isAudit,
        "upgrade_notice": upgradeNotice,
        "user_created_at": userCreatedAt,
      };
}

class Config {
  String privacy;
  String protocol;
  String userintegral;
  String uservip;
  String customerService;

  Config({
    required this.privacy,
    required this.protocol,
    required this.userintegral,
    required this.uservip,
    required this.customerService,
  });

  Config copyWith({
    String? privacy,
    String? protocol,
    String? userintegral,
    String? uservip,
    String? customerService,
  }) =>
      Config(
        privacy: privacy ?? this.privacy,
        protocol: protocol ?? this.protocol,
        userintegral: userintegral ?? this.userintegral,
        uservip: uservip ?? this.uservip,
        customerService: customerService ?? this.customerService,
      );

  factory Config.fromRawJson(String str) => Config.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Config.fromJson(Map<String, dynamic> json) => Config(
        privacy: json["privacy"],
        protocol: json["protocol"],
        userintegral: json["userintegral"],
        uservip: json["uservip"],
        customerService: json["customer_service"],
      );

  Map<String, dynamic> toJson() => {
        "privacy": privacy,
        "protocol": protocol,
        "userintegral": userintegral,
        "uservip": uservip,
        "customer_service": customerService,
      };
}

class VerConfig {
  String landingPage;
  int allowTouristsVip;
  int launchPage;
  String halfScreenPage;
  List<HalfScreenRightsDesc> halfScreenRightsDesc;
  String newUserUndertakeType;

  VerConfig({
    required this.landingPage,
    required this.allowTouristsVip,
    required this.launchPage,
    required this.halfScreenPage,
    required this.halfScreenRightsDesc,
    required this.newUserUndertakeType,
  });

  VerConfig copyWith({
    String? landingPage,
    int? allowTouristsVip,
    int? launchPage,
    String? halfScreenPage,
    List<HalfScreenRightsDesc>? halfScreenRightsDesc,
  }) =>
      VerConfig(
        landingPage: landingPage ?? this.landingPage,
        allowTouristsVip: allowTouristsVip ?? this.allowTouristsVip,
        launchPage: launchPage ?? this.launchPage,
        halfScreenPage: halfScreenPage ?? this.halfScreenPage,
        halfScreenRightsDesc: halfScreenRightsDesc ?? this.halfScreenRightsDesc,
        newUserUndertakeType: newUserUndertakeType ?? this.newUserUndertakeType,
      );

  factory VerConfig.fromRawJson(String str) =>
      VerConfig.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory VerConfig.fromJson(Map<String, dynamic> json) => VerConfig(
        landingPage: json["landing_page"] ?? "",
        allowTouristsVip: json["allow_tourists_vip"] ?? 0,
        launchPage: json["launch_page"] ?? 0,
        halfScreenPage: json["half_screen_page"] ?? "",
        halfScreenRightsDesc: json["half_screen_rights_desc"] != null
            ? List<HalfScreenRightsDesc>.from(json["half_screen_rights_desc"]
                .map((x) => HalfScreenRightsDesc.fromJson(x)))
            : [],
        newUserUndertakeType: json["new_user_undertake_type"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "landing_page": landingPage,
        "allow_tourists_vip": allowTouristsVip,
        "launch_page": launchPage,
        "half_screen_page": halfScreenPage,
        "half_screen_rights_desc": halfScreenRightsDesc,
        "new_user_undertake_type": newUserUndertakeType,
      };
}

class HalfScreenRightsDesc {
  String title;
  String icon;

  HalfScreenRightsDesc({
    required this.title,
    required this.icon,
  });

  factory HalfScreenRightsDesc.fromJson(Map<String, dynamic> json) =>
      HalfScreenRightsDesc(
        title: json["title"],
        icon: json["icon"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "icon": icon,
      };
}
