import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/core/base/controllers/base_controller.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/data/model/folk/story_video_bean.dart';
import 'package:video_clip_edit/widgets/common/multi_status_view.dart';

import '../../folkStory/beans/folk_story_bean.dart';

class CreateFolkStoryStepsController extends BaseController {
  /// 总共步骤数
  final int totalSteps = 2;

  /// 当前步骤
  var currentStep = 0.obs;

  /// 故事ID
  num? storyId;

  ///民间故事主题
  FolkStoryThemeBean? themeBean;

  //民间故事详情
  FolkStoryVideoBean? storyBean;

  final multiStatus = MultiStatusType.statusLoading.obs;

  late final pageController = PageController();

  @override
  void handArguments(arguments) {
    if (arguments is Map){
      storyId = arguments['id'];
      themeBean = arguments['theme'];
    }
    else {
      storyId = arguments;
    } 
  }

  @override
  fetchData() {
    loadStoryInfo();
  }

  loadStoryInfo() {
    HttpUtils.get(
      APIs.storyInfo,
      {"folk_story_id": storyId},
      success: (data) {
        print("获取民间故事详情成功~~~~~$data");
        final roleData = data["data"];
        final storyBean = FolkStoryVideoBean.fromJson(roleData);
        multiStatus.value = MultiStatusType.statusContent;
        checkStep(storyBean);
      },
      fail: (code, msg) {
        multiStatus.value = MultiStatusType.statusError;
        BotToast.showText(text: msg);
      },
    );
  }

  bool checkStep(FolkStoryVideoBean bean) {
    // if ([
    //   FolkStoryVideoStatus.roleExtracting.rawValue,
    //   FolkStoryVideoStatus.roleExtracted.rawValue,
    //   FolkStoryVideoStatus.roleDrawing.rawValue,
    //   FolkStoryVideoStatus.roleDrawn.rawValue,
    // ].contains(bean.status)) {
    //   gotoStep(0);
    //   return true;
    // } else if ([
    if ([
      FolkStoryVideoStatus.scenesCreating.rawValue,
      FolkStoryVideoStatus.scenesCreated.rawValue,
      FolkStoryVideoStatus.scenesDrawing.rawValue,
      FolkStoryVideoStatus.scenesDrawn.rawValue,
    ].contains(bean.status)) {
      gotoStep(0);
      return true;
    } else if ([
      FolkStoryVideoStatus.videoCreating.rawValue,
      FolkStoryVideoStatus.finished.rawValue,
    ].contains(bean.status)) {
      gotoStep(1);
      return true;
    }
    return false;
  }

  void gotoStep(int step) {
    currentStep.value = step;
    pageController.jumpToPage(step);
  }

  /// 重新初始化
  reset() {
    currentStep.value = 0;
    gotoStep(0);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
