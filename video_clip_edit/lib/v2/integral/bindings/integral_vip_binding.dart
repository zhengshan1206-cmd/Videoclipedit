import 'package:get/get.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';

class IntegralVipBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IntegralVipController>(
      () => IntegralVipController(),
    );
  }
}
