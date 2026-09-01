/*
 * @Author: cold-x
 * @Date: 2025-04-14 17:58:13
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-05-22 15:51:21
 * @FilePath: /video_clip_edit/lib/v2/aiCreate/views/folk_story_steps_page.dart
 * @Description: 
 */
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/step_view.dart';
import 'package:video_clip_edit/v2/aiCreate/views/folk_story_step_two_page.dart';
import 'package:video_clip_edit/v2/aiCreate/views/folk_story_step_one_page.dart';
import 'package:video_clip_edit/v2/aiCreate/views/folk_story_step_four_page.dart';
import 'package:video_clip_edit/v2/aiCreate/views/folk_story_step_three_page.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/create_folk_story_steps_controller.dart';
import 'package:video_clip_edit/widgets/common/multi_status_view.dart';

class FolkStoryStepsPage extends StatefulWidget {
  const FolkStoryStepsPage({
    super.key,
  });

  @override
  State<FolkStoryStepsPage> createState() => _FolkStoryStepsPageState();
}

class _FolkStoryStepsPageState extends State<FolkStoryStepsPage> {
  final controller = Get.put(CreateFolkStoryStepsController());

  @override
  void dispose() {
    controller.dispose();
    Get.delete<CreateFolkStoryStepsController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(context: context, title: "民间故事"),
      body: Obx(() {
        return MultiStatusView(
          backgroundColor: Colors.transparent,
          currentStatus: controller.multiStatus.value,
          child: Column(
            children: [
              SizedBox(height: 2.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                child: Obx(() => StepView(
                    currentStep:
                        StepType.fromRawValue(controller.currentStep.value + 1))),
              ),
              Expanded(
                child: PageView(
                  controller: controller.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    // FolkStoryStepOnePage(),
                    // FolkStoryStepTwoPage(),
                    FolkStoryStepThreePage(),
                    FolkStoryStepFourPage(),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
