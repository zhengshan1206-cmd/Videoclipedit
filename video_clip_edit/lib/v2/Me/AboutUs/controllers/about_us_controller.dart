/*
 * @Author: cold-x
 * @Date: 2025-05-14 17:05:39
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-05-15 17:55:55
 * @FilePath: /video_clip_edit/lib/v2/Me/AboutUs/controllers/about_us_controller.dart
 * @Description: 
 */

import 'dart:convert';

import 'package:get/get.dart';
import 'package:video_clip_edit/v2/Me/AboutUs/pages/version_update_page.dart';

import '../../../../utils/cache/local_file_cache.dart';
import '../../../../utils/comon/by_storage_utils.dart';
import '../../../../utils/consts/const_keys.dart';
import '../beans/version_update_bean.dart';

class AboutUsController extends GetxController {

  List<String> aboutUsList = [
    "版本更新",
    "隐私政策",
    "用户协议",
    "会员服务协议",
  ];

  Map<String, dynamic> aboutUsUrl = {
    "隐私政策": "https://www.bytedance.com/privacy",
    "用户协议": "https://www.bytedance.com/user-agreement",
    "会员服务协议": "https://www.bytedance.com/vip-agreement",
    'isShowUpdate': true, // 是否显示更新弹窗
    'version': '5.0.0',
    'updateUrl': 'https://download.huilinwang.com/278a8811ad0deaf2112ffc50ba0c8b41.apk?sign=2255aa97a89a8e749d48a5b848e69a82&sign2=b873308a03c51dd181339dc52bcec2f9&t=1747303460&response-content-disposition=attachment%3Bfilename%3D%22%E5%A6%99%E7%AC%94%E5%B7%A5%E5%9D%8A_3.10.18.apk%22',
    'updateContent': '1.修复已知bug\n2.优化用户体验',
    'updateTime': '2025-05-15',
    'updateSize': '50MB',
    'isForceUpdate': false, // force: 强制更新, optional: 可选更新
  };

  VersionUpdateBean? bean;

  @override
  void onInit() {
    super.onInit();
    fetchVersionInfo();
  }

  //跳转到对应的页面
  void jumpToPage(int index) {
    switch (index) {
      case 0:
        _showUpdateDialog();
        break;
      case 1:
        Get.toNamed('/privacy');
        break;
      case 2:
        Get.toNamed('/userAgreement');
        break;
      case 3:
        Get.toNamed('/vipAgreement');
        break;
    }
  }

  void fetchVersionInfo() {
    Future.delayed(const Duration(milliseconds: 500), () {
      LocalCacheManager.saveJsonData(CacheKeys.versionCheck, aboutUsUrl);
    });
  }

  //获取当前app版本号
  String getCurrentVersonString() {
    final version = ByStorageUtils.getString(ConstKeys.kAppVersion) ?? "5.0.0";
    return version;
  }

  Future<bool> _readVersionInfo() async {
    final value = await LocalCacheManager.readJsonData(CacheKeys.versionCheck);
    if (value.isNotEmpty) {
      // 处理数据
      final Map<String, dynamic> jsonData = json.decode(value);
      bean = VersionUpdateBean.fromJson(jsonData);

      print("~~~~~Version data: $value");
      return true;
    } else {
      print("~~~~~No version data found.");
      return false;
    }
  }

  // 显示版本更新对话框
  _showUpdateDialog() async {
    final result = await _readVersionInfo();
    if (result == true && bean != null && bean!.version != getCurrentVersonString()) {
      // 版本更新
      if (bean!.isForceUpdate == true || bean!.isShowUpdate == true) {
        Get.dialog(
          VersionUpdatePage(bean: bean!),
        );
        return;
      }
      Get.dialog(
      const CurrentVersionUpdatePage(),
    );
    }
  }
}