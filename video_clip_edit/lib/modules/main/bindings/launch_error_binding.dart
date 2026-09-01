import 'package:get/get.dart';
import 'package:video_clip_edit/modules/main/controllers/launch_error_controller.dart';

class LaunchErrorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LaunchErrorController>(
      () => LaunchErrorController(),
    );
  }
}
