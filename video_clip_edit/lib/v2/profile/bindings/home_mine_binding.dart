import 'package:get/get.dart';
import 'package:video_clip_edit/v2/profile/controllers/home_mine_controller.dart';

class HomeMineBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeMineController>(
      () => HomeMineController(),
    );
  }
}
