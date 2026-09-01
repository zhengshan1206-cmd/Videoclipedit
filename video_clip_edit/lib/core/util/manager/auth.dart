/*
 * @Author: cold-x
 * @Date: 2025-07-24 15:01:04
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-07-24 15:42:30
 * @FilePath: /video_clip_edit/lib/core/util/manager/auth.dart
 * @Description: 
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../modules/common/widget/common_dialog.dart';
import '../../../utils/comon/by_storage_utils.dart';

///认证权限管理
class AuthManager {
  static void materialAuth({
    void Function()? onSuccess}) {
    final checked = ByStorageUtils.getBool(kMaterialAuthTips) ?? false;
    if (checked) {
      onSuccess?.call();
    } else {
      showDialog(
          context: Get.context!,
          builder: (ctx) {
            return CommonDialog(
                reverse: false,
                maxLine: 10,
                contents: kMaterialAuthTips,
                cancelBtnTitle: "拒绝",
                confirmBtnTitle: "同意并继续",
                confirmCallback: () {
                  ByStorageUtils.saveBool(kMaterialAuthTips, true);
                  onSuccess?.call();
                });
          });
    }
  }
}
