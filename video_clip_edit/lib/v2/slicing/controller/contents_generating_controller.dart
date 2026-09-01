import 'package:get/get.dart';
import 'package:video_clip_edit/core/util/app_util.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/ai_create_text_field_controller.dart';

class ContentsGeneratingController extends AiCreateTextFieldController {
  back() {
    if (isGenerating.value) {
      Get.normalDialog(
        width: Get.width * 0.85,
        title: '温馨提示',
        content: '文案生成中，退出后无法保存，\n确定要退出吗？',
        confirmText: '退出',
        confirmAction: () {
          Get.back();
        },
      );
      return;
    }
    Get.back();
  }
}
