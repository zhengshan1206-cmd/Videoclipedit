import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/data/model/folk/story_video_bean.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/data/model/folk/story_scene_bean.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/create_folk_story_steps_controller.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/generating_controller.dart';

class StepFourController extends GeneratingController {
  CreateFolkStoryStepsController get createFolkStoryStepscontroller => Get.find<CreateFolkStoryStepsController>();

  /// 获取角色详情
  pollingStoryInfo({
    CancelToken? cancelToken,
    void Function(dynamic)? onComplete,
  }) {
    startPolling(
      pollingAction: ({onFaildHandler, onSuccessHandler}) {
        HttpUtils.get(
          APIs.storyInfo,
          {"folk_story_id": createFolkStoryStepscontroller.storyId},
          cancelToken: cancelToken,
          success: (data) {
            final roleData = data["data"];
            final storyBean = FolkStoryVideoBean.fromJson(roleData);
            onSuccessHandler?.call(storyBean);
          },
          fail: (code, msg) {
            onFaildHandler?.call(code);
          },
        );
      },
      onValid: (storyBean) {
        return (storyBean as FolkStoryVideoBean).status ==
            FolkStoryVideoStatus.finished.rawValue;
      },
      onComplete: onComplete,
    );
  }
}
