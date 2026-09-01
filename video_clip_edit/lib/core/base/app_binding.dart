import 'package:get/get.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/core/network/provider/user_provider.dart';
import 'package:video_clip_edit/v2/minorMode/controllers/minor_mode_controller.dart';

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
    Get.put<MinorModeController>(
      MinorModeController(),
      permanent: true,
    );
  }
}
