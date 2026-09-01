class PurchaseVipBenefitsBean {
  String icon;
  String name;
  String redIcon;

  PurchaseVipBenefitsBean({
    required this.icon,
    required this.name,
    required this.redIcon,
  });

  factory PurchaseVipBenefitsBean.fromJson(Map<String, dynamic> json) =>
      PurchaseVipBenefitsBean(
        icon: json["icon"],
        name: json["name"],
        redIcon: json["redIcon"],
      );

  Map<String, dynamic> toJson() => {
        "icon": icon,
        "name": name,
        "redIcon": redIcon,
      };
}
