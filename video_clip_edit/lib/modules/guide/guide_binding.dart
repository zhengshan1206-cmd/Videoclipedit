
import 'package:get/get.dart';
import 'package:video_clip_edit/modules/guide/guide_controller.dart';

class GuideBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<GuideControllerEx>(()=>GuideControllerEx());
  }

}