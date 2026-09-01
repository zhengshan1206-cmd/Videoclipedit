import 'package:get/get.dart';
import 'package:video_clip_edit/v2/profile/controllers/user_profile_controller.dart';

class UserProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserProfileController>(
      () => UserProfileController(),
    );
  }
}
