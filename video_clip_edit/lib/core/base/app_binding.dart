import 'package:get/get.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/core/network/provider/user_provider.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<UserController>(
      UserController(),
      permanent: true,
    );
    Get.put<UserProvider>(
      UserProvider(),
      permanent: true,
    );
  }
}
