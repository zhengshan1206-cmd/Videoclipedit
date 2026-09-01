import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/data/model/folk/story_role_bean.dart';
import 'package:video_clip_edit/data/model/folk/story_video_bean.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/create_folk_story_steps_controller.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/generating_controller.dart';

class StepTwoController extends GeneratingController {
  CreateFolkStoryStepsController get createFolkStoryStepscontroller => Get.find<CreateFolkStoryStepsController>();

  /// 角色列表
  RxList<StoryRoleBean> roleBeans = [].cast<StoryRoleBean>().obs;

  /// 获取民间故事角色列表
  loadRoleList({
    bool isRefresh = true,
  }) {
    HttpUtils.get(
      APIs.roleList,
      {"folk_story_id": createFolkStoryStepscontroller.storyId},
      success: (data) {
        final roleDataList = data["data"];
        final storyBean = List<StoryRoleBean>.from(
            roleDataList.map((e) => StoryRoleBean.fromJson(e)).toList());
        roleBeans.value = storyBean;
      },
      fail: (code, msg) {},
    );
  }

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
            FolkStoryVideoStatus.roleDrawn.rawValue;
      },
      onComplete: onComplete,
    );
  }

  /// 进入下一步（开始分镜）
  nextStep({
    void Function(dynamic)? onSucess,
  }) {
    {
      HttpUtils.post(
        APIs.manualDrawScene,
        {"folk_story_id": createFolkStoryStepscontroller.storyId},
        showLoading: true,
        success: (data) {
          onSucess?.call(data);
        },
        fail: (code, msg) {
          BotToast.showText(text: msg);
        },
      );
    }
  }
}
