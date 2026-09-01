import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/create_folk_story_steps_controller.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/step_four_controller.dart';
import 'package:video_clip_edit/v2/aiCreate/views/folk_stoy_video_management_page.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/drawing_view.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/step_view.dart';

class FolkStoryStepFourPage extends StatefulWidget {
  const FolkStoryStepFourPage({super.key});

  @override
  State<FolkStoryStepFourPage> createState() => _FolkStoryStepFourPageState();
}

class _FolkStoryStepFourPageState extends State<FolkStoryStepFourPage> {
  final controller = Get.find<CreateFolkStoryStepsController>();
  final stepFourController = Get.put(StepFourController());
  final CancelToken _cancelToken = CancelToken();

  @override
  void dispose() {
    stepFourController.dispose();
    Get.delete<StepFourController>();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    stepFourController.startProgressTimer(onComplete: () {
      Get.offNamed(Routes.storyManagementPage);
      // Get.to(const FolkStoyVideoManagementPage());
    });

    stepFourController.pollingStoryInfo(
      cancelToken: _cancelToken,
      onComplete: (storyBean) {
        byDebugPrint("-----pollingStoryInfo");
        // Get.offNamed(Routes.storyManagementPage);
      },
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DrawingView(
          onRecords: () {
            Get.toNamed(Routes.storyManagementPage);
          },
          onViewLater: () {
            Get.back();
          },
          progressTitle: '视频生成中',
        ),
    );
  }
}
