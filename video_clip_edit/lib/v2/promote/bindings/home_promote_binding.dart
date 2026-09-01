import 'package:get/get.dart';
import 'package:video_clip_edit/v2/promote/controllers/home_promote_controller.dart';
import 'package:video_clip_edit/v2/promote/controllers/promote_folk_story_controller.dart';
import 'package:video_clip_edit/v2/promote/controllers/promote_hot_novels_controller.dart';
import 'package:video_clip_edit/v2/promote/controllers/promote_hot_short_play_controller.dart';
import 'package:video_clip_edit/v2/promote/controllers/promote_comic_drama_controller.dart';

class HomePromoteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomePromoteController>(
      () => HomePromoteController(),
    );

    Get.lazyPut<PromoteHotShortPlayController>(
      () => PromoteHotShortPlayController(),
      fenix: true, // 允许在需要时重新创建，但保持实例不被销毁
    );

    Get.lazyPut<PromoteHotNovelsController>(
      () => PromoteHotNovelsController(),
    );

    Get.lazyPut<PromoteFolkStoryController>(
      () => PromoteFolkStoryController(),
    );

    Get.lazyPut<PromoteComicDramaController>(
      () => PromoteComicDramaController(),
    );
  }
}
