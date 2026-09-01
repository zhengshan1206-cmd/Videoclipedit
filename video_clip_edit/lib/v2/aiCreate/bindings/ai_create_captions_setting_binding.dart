import 'package:get/get.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/ai_create_captions_setting_controller.dart';

class AiCreateCaptionsSettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AiCreateCaptionsSettingController>(
      () => AiCreateCaptionsSettingController(),
    );
  }
}
