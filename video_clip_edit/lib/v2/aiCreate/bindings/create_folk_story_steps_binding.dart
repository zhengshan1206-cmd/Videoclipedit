import 'package:get/get.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/create_folk_story_steps_controller.dart';

class CreateFolkStoryStepsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CreateFolkStoryStepsController());
  }
}
