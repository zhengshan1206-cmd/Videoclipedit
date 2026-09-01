import 'package:video_clip_edit/modules/home/beans/setting_item_bean.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';

class SettingsProvider extends BaseProvider {
  List<List<SettingItemBean>> sectionBeans = [
    [
      SettingItemBean.fromJson({
        "title": "个人信息设置",
        "desc": null,
        "interactive": true,
        "isAvatar": false,
        "canCopy": false,
        "url": "",
      }),
      SettingItemBean.fromJson({
        "title": "注销账号",
        "desc": null,
        "interactive": true,
        "isAvatar": false,
        "canCopy": false,
        "url": "",
      }),
    ],
  ];
  List<List<SettingItemBean>> personalSectionBeans = [];

  /// 加载设置界面的数据列表
  loadSettingItems() {
    HttpUtils.get(
      APIs.loadSettingIems,
      {},
      success: (data) {
        final itemBeans =
            data["data"].map((e) => SettingItemBean.fromJson(e)).toList();
        sectionBeans = [
          [
            SettingItemBean.fromJson({
              "title": "个人信息设置",
              "desc": null,
              "interactive": true,
              "isAvatar": false,
              "canCopy": false,
              "url": "",
            }),
            SettingItemBean.fromJson({
              "title": "注销账号",
              "desc": null,
              "interactive": true,
              "isAvatar": false,
              "canCopy": false,
              "url": "",
            }),
            ...itemBeans
          ]
        ];
        notifyListeners();
      },
      fail: (code, msg) {},
    );
  }

  /// 组装个人信息数据
  assemblePersonalSettingBeans({
    required String avatar,
    required String userID,
    required String nickName,
    required String phoneNO,
  }) {
    personalSectionBeans = [
      [
        SettingItemBean.fromJson({
          "title": "头像",
          "desc": null,
          "imgUrl": avatar,
          "interactive": false,
          "isAvatar": true,
          "canCopy": false,
          "url": "",
        })
      ],
      [
        SettingItemBean.fromJson({
          "title": "账号ID",
          "desc": userID,
          "interactive": false,
          "isAvatar": false,
          "canCopy": true,
          "url": "",
        }),
        SettingItemBean.fromJson({
          "title": "名称",
          "desc": nickName,
          "interactive": false,
          "isAvatar": false,
          "canCopy": false,
          "url": "",
        }),
        SettingItemBean.fromJson({
          "title": "手机号",
          "desc": phoneNO,
          "interactive": false,
          "isAvatar": false,
          "canCopy": false,
          "url": "",
        }),
      ],
    ];
    notifyListeners();
  }
}
