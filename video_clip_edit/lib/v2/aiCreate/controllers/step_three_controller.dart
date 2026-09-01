import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/data/model/folk/story_video_bean.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/data/model/folk/story_scene_bean.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/create_folk_story_steps_controller.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/generating_controller.dart';

class StepThreeController extends GeneratingController {
  CreateFolkStoryStepsController get createFolkStoryStepscontroller => Get.find<CreateFolkStoryStepsController>();


  /// 当前选中的场景
  final scene = Rx<StorySceneBean?>(null);

  /// 角色列表
  RxList<StorySceneBean> sceneBeans = <StorySceneBean>[].obs;

  ///第一个生成失败的分镜索引
  RxInt firstFailedIndex = 0.obs;

  //是否有正在绘制中的分镜
  bool hasRedraw = false;

  final CancelToken sceneCancelToken = CancelToken();

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
            isGenerating.value = (storyBean.status == FolkStoryVideoStatus.scenesDrawn.rawValue ? false : true);
            onSuccessHandler?.call(storyBean);
            // onComplete?.call(storyBean);
          },
          fail: (code, msg) {
            onFaildHandler?.call(code);
          },
        );
      },
      onValidateBefore: onValidateBefore,
      onValid: (storyBean) {
        return (storyBean as FolkStoryVideoBean).status ==
            FolkStoryVideoStatus.scenesDrawn.rawValue;
      },
      onComplete: onComplete,
    );
  }

  void startPollingSceneList() {
    // 轮循分镜列表
    isGenerating.value = true;
    pollingSceneList(
      cancelToken: sceneCancelToken,
    );
  }

  /// 轮循分镜详情
  pollingSceneList({
    CancelToken? cancelToken,
    void Function(dynamic)? onComplete,
    void Function(dynamic)? onValidateBefore,
  }) {
    startPolling(
      pollingAction: ({onFaildHandler, onSuccessHandler}) {
        loadSceneList(
          onSuccess: (beans) => onSuccessHandler?.call(beans),
          onFaild: (msg) => onFaildHandler?.call(msg),
        );
      },
      onValidateBefore: onValidateBefore,
      onValid: (storyBean) {
        return !hasRedraw;
      },
      onComplete: onComplete,
    );
  }


  /// 获取分镜列表
  loadSceneList({
    Function(List<StorySceneBean> list)? onSuccess,
    Function(String msg)? onFaild,
  }) {
    HttpUtils.get(
      APIs.sceneList,
      {
        "folk_story_id": createFolkStoryStepscontroller.storyId,
      },
      success: (json) {

        final data = json["data"];
        final List<StorySceneBean> beans = data
            .map((e) => StorySceneBean.fromJson(e))
            .toList()
            .cast<StorySceneBean>();
        firstFailedIndex.value = 0;
        hasRedraw = false;
        for (StorySceneBean bean in beans) {
          if (bean.hasReDraw){
            hasRedraw = true;
          }
          if ([StorySceneStatus.drawn.rawValue,
              StorySceneStatus.redrawn.rawValue].contains(bean.status)) {
            continue;
          }
          else {
            if(firstFailedIndex.value == 0){
              firstFailedIndex.value = beans.indexOf(bean);
            }
          }
        }
        sceneBeans.value = beans;
        if (beans.isNotEmpty) {
          if (scene.value == null) {
            scene.value = beans.first;
          }
          else {
            scene.value = beans.firstWhere((element) => element.id == scene.value?.id);
          }
        }
        onSuccess?.call(beans);
      },
      fail: (code, msg) {
        onFaild?.call(msg);
        BotToast.showText(text: msg);
      },
    );
  }

  /// 下一步 开始生成视频
  nextStep({
    void Function(dynamic)? onSucess,
  }) {
    HttpUtils.post(
      APIs.createVideoTask,
      {
        "folk_story_id": createFolkStoryStepscontroller.storyId,
      },
      success: (data) {
        onSucess?.call(data);
        createFolkStoryStepscontroller.gotoStep(1);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  // 小图跳转到指定位置
  void scrollToPosition(ScrollController scroll, int index){
    final double targetPosition = index * 106.w - ByScreenUtils.screenWidth/2 + 65.w;
    final double position = targetPosition < 0 ? 0 : targetPosition > scroll.position.maxScrollExtent ? scroll.position.maxScrollExtent : targetPosition;
    scroll.animateTo(
      position,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
  );
    // scroll.jumpTo(position);
  }
}
