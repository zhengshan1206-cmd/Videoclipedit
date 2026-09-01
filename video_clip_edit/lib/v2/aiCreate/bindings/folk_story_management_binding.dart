import 'package:get/get.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/video_management_controller.dart';

class FolkStoryManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoManagementController>(
      () => VideoManagementController(),
    );
  }
}
