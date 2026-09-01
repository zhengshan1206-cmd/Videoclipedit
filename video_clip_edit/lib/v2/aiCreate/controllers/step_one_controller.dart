/*
 * @Author: cold-x
 * @Date: 2025-04-14 17:58:13
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-05-14 14:11:35
 * @FilePath: /video_clip_edit/lib/v2/aiCreate/controllers/step_one_controller.dart
 * @Description: 
 */
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/step_two_controller.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/step_view.dart';
import 'package:video_clip_edit/data/model/folk/story_video_bean.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/generating_controller.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/create_folk_story_steps_controller.dart';

import 'step_three_controller.dart';

class StepOneController extends GeneratingController {
  StepOneController();

  CreateFolkStoryStepsController get createFolkStoryStepscontroller => Get.find<CreateFolkStoryStepsController>();


  /// 获取角色详情
  pollingStoryInfo({
    CancelToken? cancelToken,
    void Function(dynamic)? onComplete,
    void Function(dynamic)? onValidateBefore,
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
      onValidateBefore: onValidateBefore,
      onValid: (storyBean) {
        return (storyBean as FolkStoryVideoBean).status ==
            FolkStoryVideoStatus.roleExtracted.rawValue;
      },
      onComplete: onComplete,
    );
  }

  /// 进入下一步（开始分镜）
  nextStep({
    void Function(dynamic)? onSucess,
  }) {
    final controller = Get.find<CreateFolkStoryStepsController>();
    Get.put(StepThreeController());

    /// 下一步 => 开始分镜
    controller.currentStep.value = StepType.sceneDrawing.rawValue;
    controller.gotoStep(StepType.sceneDrawing.rawValue);
  }
}
