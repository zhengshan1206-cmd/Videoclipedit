

import 'package:get/get.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/new_short_play_list_controller.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';

class NewShortPlayListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewShortPlayListController>(
        () => NewShortPlayListController());
    // 确保 IntegralVipController 已注册（IntegralVipView 在页面 build 时会 find）
    IntegralVipController.getOrPut();
  }
}