import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/step_three_controller.dart';
import 'package:video_clip_edit/widgets/image/by_image_view.dart';
import 'package:video_clip_edit/data/model/folk/story_scene_bean.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/scene_preview_controller.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/create_folk_story_steps_controller.dart';

import '../../../providers/launch_provider.dart';
import '../../aiVideo/provider/ai_square_provider.dart';
import 'scene_regrenerate_page.dart';

class ScenePreview extends StatefulWidget {
  ScenePreview({
    super.key,
    required this.scene,
    this.onComplete,
  });

  StorySceneBean scene;
  final void Function(dynamic)? onComplete;

  @override
  State<ScenePreview> createState() => _ScenePreviewState();
}

class _ScenePreviewState extends State<ScenePreview> {
  final CreateFolkStoryStepsController stepsController =
      Get.find<CreateFolkStoryStepsController>();

  final ScenePreviewController previewController =
      Get.put(ScenePreviewController());

  final StepThreeController threeController =  Get.find<StepThreeController>();

  late final Rx<StorySceneBean> _scene = widget.scene.obs;

  final CancelToken _cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _cancelToken.cancel();
    previewController.dispose();
    Get.delete<ScenePreviewController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = StorySceneStatus.fromValue(_scene.value.status);

      var failed = StorySceneStatus.drawFailed == status && !_scene.value.hasReDraw;

      var drawing = StorySceneStatus.drawFailed == status && _scene.value.hasReDraw;

      final finshed =
          [StorySceneStatus.drawn, StorySceneStatus.redrawn].contains(status);

      if (failed) {
        return ByWidgetsUtil.commonContainer(
          borerRadius: 0,
          alignment: Alignment.center,
          bgColor: const Color(0xFFF8FAFB),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Image.asset(
                "assets/v2/folk/generate_faild.png",
                width: 51.w,
                height: 45.h,
              ),
              SizedBox(height: 25.h),
              ByWidgetsUtil.commonText(
                text: "生成失败",
                fontSize: 12.sp,
                fontWeight: FontWeight.normal,
                textColor: const Color(0xFF81899F),
              ),
              SizedBox(height: 15.h),
              Container(
                width: 80.w,
                height: 32.h,
                alignment: Alignment.center,
                child: ByWidgetsUtil.commonBtn(
                  title: "重新生成",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  padding: EdgeInsets.zero,
                  borderRadius: 8.w,
                  onClick: () {
                    gotoReCreateScene(_scene.value);
                    // _retry();
                  },
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        );
      }
      if (drawing) {
        return ByWidgetsUtil.commonContainer(
          borerRadius: 0,
          alignment: Alignment.center,
          bgColor: const Color(0xFFF8FAFB),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 44.w,
                height: 44.w,
                child: ByWidgetsUtil.activityIndicator(radius: 20.w),
              ),
              SizedBox(height: 25.h),
              ByWidgetsUtil.commonText(
                text: "正在生成中...",
                fontSize: 14.sp,
                fontWeight: FontWeight.normal,
                textColor: ByColorUtil.LoginBtnBgColor,
              ),
            ],
          ),
        );
      }
      if (finshed) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // _retry();
          },
          child: BYImageView(
            imageUrl: _scene.value.url,
            width: double.infinity,
            height: double.infinity,
          ),
        );
      }
      return Container();
    });
  }

  void _retry() {
    // final reworkNum = _scene.value.reworkNum;
    // if (reworkNum <= 0) {
    //   BotToast.showText(text: "已达到最大重绘次数");
    //   return;
    // }
    previewController.sceneRepaint(
      storyId: stepsController.storyId! as int,
      sceneId: _scene.value.id,
      prompt: _scene.value.prompt,
      onSucess: (data) {
        previewController.reset();
        previewController.pollingSceneInfo(
          cancelToken: _cancelToken,
          onValidateBefore: (p0) {
            widget.scene = p0 as StorySceneBean; 
            _scene.value = widget.scene;
          },
          storyId: stepsController.storyId! as int,
          sceneId: _scene.value.id,
          onComplete: (scene) {
            StorySceneBean bean = scene as StorySceneBean;
            // ///轮循到当前分镜时才自动刷新状态
            // if (widget.scene.id == bean.id){
            //   widget.scene = bean;
            //   _scene.value = bean;
            // }
            final reworkUrl = bean.reworkUrl.firstOrNull?.img ?? "";
            if (reworkUrl.isEmpty) return;
            
            _scene.value = bean;
            previewController.updateSceneInfo(
              storyId: stepsController.storyId! as int,
              sceneId: _scene.value.id,
              url: reworkUrl,
              prompt: _scene.value.prompt,
              onSucess: (data) {
                widget.onComplete?.call(bean);
              },
            );
          },
          // onComplete: widget.onComplete,
        );
      },
    );
  }

  //重新绘制
  void gotoReCreateScene(StorySceneBean scene) async{
    final result = await Get.to(
            MultiProvider(
              providers: [
                ChangeNotifierProvider.value(
                  value: Provider.of<LaunchProvider>(context, listen: false),
                ),
                ChangeNotifierProvider.value(
                  value: Provider.of<AiSquareProvider>(context, listen: false),
                ),
              ],
              child: SceneRegreneratePage(scene: scene),
            ),
          );
          if (result == true) {
            threeController.loadSceneList();
          }
  }
}
