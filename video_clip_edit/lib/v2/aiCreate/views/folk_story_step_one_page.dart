import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:video_clip_edit/data/model/folk/story_video_bean.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/drawing_view.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/step_one_controller.dart';
import 'package:video_clip_edit/v2/aiCreate/views/folk_stoy_video_management_page.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/create_folk_story_steps_controller.dart';

class FolkStoryStepOnePage extends StatefulWidget {
  const FolkStoryStepOnePage({super.key});

  @override
  State<FolkStoryStepOnePage> createState() => _FolkStoryStepOnePageState();
}

class _FolkStoryStepOnePageState extends State<FolkStoryStepOnePage> {
  final controller = Get.put(StepOneController());
  final stepsController = Get.find<CreateFolkStoryStepsController>();
  final CancelToken _cancelToken = CancelToken();

  @override
  void dispose() {
    _cancelToken.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller.startProgressTimer(onComplete: () {
      controller.nextStep();
    });

    controller.pollingStoryInfo(
      cancelToken: _cancelToken,
      onComplete: (storyBean) {},
      onValidateBefore: (storyBean) {
        final bean = storyBean as FolkStoryVideoBean;
        final res = stepsController.checkStep(bean);
        if (res) {
          controller.stop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final isGenerating = controller.isGenerating.value;
        final progress = controller.progress.value;
        return isGenerating ? _buildDrawingView(progress) : Container();
      }),
    );
  }

  /// 绘制中
  DrawingView _buildDrawingView(int progress) {
    return DrawingView(
      onRecords: () {
        // Get.to(const FolkStoyVideoManagementPage());
        Get.toNamed(Routes.storyManagementPage);
      },
      onViewLater: () {
        Get.back();
      },
      progressTitle: '分镜绘制中 $progress%',
    );
  }
}
