import 'package:get/get.dart';
import 'package:video_clip_edit/v2/minorMode/controllers/minor_create_controller.dart';

class MinorCreateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MinorCreateController>(() => MinorCreateController());
  }
}
