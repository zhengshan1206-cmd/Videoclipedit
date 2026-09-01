import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiCreate/views/folk_stoy_video_management_page.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/step_view.dart';
import 'package:video_clip_edit/v2/aiCreate/views/role_list_view.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/drawing_view.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/step_two_controller.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/create_folk_story_steps_controller.dart';

class FolkStoryStepTwoPage extends StatefulWidget {
  const FolkStoryStepTwoPage({
    super.key,
  });

  @override
  State<FolkStoryStepTwoPage> createState() => _FolkStoryStepTwoPageState();
}

class _FolkStoryStepTwoPageState extends State<FolkStoryStepTwoPage> {
  final stepTwoController = Get.put(StepTwoController());
  final controller = Get.find<CreateFolkStoryStepsController>();
  final CancelToken _cancelToken = CancelToken();

  @override
  void dispose() {
    _cancelToken.cancel();
    Get.delete<StepTwoController>();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    stepTwoController.startProgressTimer(onComplete: () {
      stepTwoController.loadRoleList();
    });

    stepTwoController.pollingStoryInfo(
      cancelToken: _cancelToken,
      onComplete: (storyBean) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final isGenerating = stepTwoController.isGenerating.value;
        final progress = stepTwoController.progress.value;

        return isGenerating
            ? _buildDrawingView(progress)
            : _buildRoleListView(context);
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
      progressTitle: '角色绘制中 $progress%',
    );
  }

  /// 角色列表
  Widget _buildRoleList(BuildContext context) {
    return const RoleListView();
  }

  _buildRoleListView(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildRoleList(context)),
        ByWidgetsUtil.physicalModel(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(
              top: 8.h,
              left: 12.w,
              right: 12.w,
              bottom: 8.h + ByScreenUtils.bottomSafeHeight,
            ),
            child: SizedBox(
              height: 50.h,
              child: ByWidgetsUtil.commonBtn(
                title: "下一步",
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                bgColor: ByColorUtil.LoginBtnBgColor,
                padding: EdgeInsets.zero,
                borderRadius: 12.w,
                onClick: () {
                  /// 下一步 => 开始分镜
                  stepTwoController.nextStep(
                    onSucess: (data) {
                      controller.currentStep.value =
                          StepType.sceneDrawing.rawValue;
                      controller.gotoStep(StepType.sceneDrawing.rawValue);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
