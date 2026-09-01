import 'package:get/get.dart';
import 'package:video_clip_edit/core/network/provider/ai_create_provider.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/ai_create_text_field_controller.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/create_folk_story_controller.dart';

class CreateFolkStoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateFolkStoryController>(
      () => CreateFolkStoryController(),
    );
    Get.lazyPut<AiCreateTextFieldController>(
          () => AiCreateTextFieldController(),
    );
    Get.lazyPut<AiCreateProvider>(
          () => AiCreateProvider(),
    );
  }
}
