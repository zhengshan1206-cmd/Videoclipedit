import 'package:get/get.dart';
import 'package:video_clip_edit/core/network/provider/ai_create_provider.dart';
import 'package:video_clip_edit/v2/slicing/controller/contents_generating_controller.dart';

class ContentGeneratingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AiCreateProvider>(
      () => AiCreateProvider(),
    );
    Get.lazyPut<ContentsGeneratingController>(
      () => ContentsGeneratingController(),
    );
  }
}
