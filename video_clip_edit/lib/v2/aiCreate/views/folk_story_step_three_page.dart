import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiCreate/views/scene_preview.dart';
import 'package:video_clip_edit/widgets/image/by_image_view.dart';
import 'package:video_clip_edit/modules/home/widgets/svga_player.dart';
import 'package:video_clip_edit/data/model/folk/story_scene_bean.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/drawing_view.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/scene_details_view.dart';
import 'package:video_clip_edit/v2/aiCreate/views/scene_regrenerate_page.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/step_three_controller.dart';
import 'package:video_clip_edit/v2/aiCreate/views/folk_stoy_video_management_page.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/create_folk_story_steps_controller.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';

import '../../../data/model/folk/story_video_bean.dart';

class FolkStoryStepThreePage extends StatefulWidget {
  const FolkStoryStepThreePage({super.key});

  @override
  State<FolkStoryStepThreePage> createState() => _FolkStoryStepThreePageState();
}

class _FolkStoryStepThreePageState extends State<FolkStoryStepThreePage> {
  final controller = Get.find<CreateFolkStoryStepsController>();
  bool isDrawing = true;
  final stepThreeController = Get.put(StepThreeController());
  final CancelToken _cancelToken = CancelToken();
  

  //小图预览滚动控制
  final ScrollController imgScroll = ScrollController();
  //大图页面滚动控制
  final PageController pageScroll = PageController();

  @override
  void dispose() {
    stepThreeController.sceneCancelToken.cancel();
    stepThreeController.dispose();
    Get.delete<StepThreeController>();
    _cancelToken.cancel();
    imgScroll.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    stepThreeController.startProgressTimer(onComplete: () {
      stepThreeController.loadSceneList();
    });

    stepThreeController.pollingStoryInfo(
      cancelToken: _cancelToken,
      onComplete: (storyBean) {
        final bean = storyBean as FolkStoryVideoBean;
        if (bean.status == FolkStoryVideoStatus.scenesDrawn.rawValue){
          // stepThreeController.loadSceneList();
          stepThreeController.startPollingSceneList();
        }
      },
      onValidateBefore: (storyBean) {
        final bean = storyBean as FolkStoryVideoBean;
        final res = controller.checkStep(bean);
        if (res) {
          stepThreeController.stop();
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final isGenerating = stepThreeController.isGenerating.value;
        return isGenerating && stepThreeController.sceneBeans.isEmpty
            ? _buildDrawingView()
            : stepThreeController.sceneBeans.isEmpty ? _sceneLoadingView() : Stack(
                children: [
                  Obx(() {
                    return _buildSceneListView(context);
                  }) ,
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ByWidgetsUtil.physicalModel(
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
                            bgColor: stepThreeController.firstFailedIndex.value == 0 ?ByColorUtil.LoginBtnBgColor : ByColorUtil.LoginBtnBgColor.withOpacity(0.3),
                            padding: EdgeInsets.zero,
                            borderRadius: 12.w,
                            onClick: () {
                              if (stepThreeController.firstFailedIndex.value == 0){
                                stepThreeController.nextStep();
                              }
                              else{
                                int index = stepThreeController.firstFailedIndex.value;
                                pageScroll.jumpToPage(index);
                                stepThreeController.scene.value = stepThreeController.sceneBeans[index];
                                stepThreeController.scrollToPosition(imgScroll, index);
                                BotToast.showText(text: '场景绘制失败，请重新生成后继续');
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
      }),
    );
  }

  Widget _sceneLoadingView() {
    return Container(
      color: Colors.transparent,
      child: Stack(
        children: [
          Container(
            color: Colors.transparent,
            child: const Center(
                // child: ByWidgetsUtil.activityIndicator(),
                child: CupertinoActivityIndicator(),
              ),
          ),
          // _buildTopBar(),
        ] 
      ),
    );
  }

  /// 绘制中
  DrawingView _buildDrawingView() {
    return DrawingView(
      onRecords: () {
        Get.toNamed(Routes.storyManagementPage);
      },
      onViewLater: () {
        Get.back();
      },
      progressTitle: '分镜绘制中',
    );
  }

  Widget _buildSceneListView(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(bottom: 76.h + ByScreenUtils.bottomSafeHeight),
      children: [
        /// 图片预览
        // _buildImgPreview(context),
        _buildImgPageView(context),

        /// 场景列表
        _buildSceneList(context),

        /// 场景详情
        _buildSceneTab(context),
      ],
    );
  }

  Widget _buildImgPageView(BuildContext context) {
    return  AspectRatio(
              aspectRatio: 1,
              child: PageView.builder(
                controller: pageScroll,
                itemCount: stepThreeController.sceneBeans.length,
                onPageChanged: (value) {
                  stepThreeController.scrollToPosition(imgScroll, value);
                  stepThreeController.scene.value = stepThreeController.sceneBeans[value];
                },
                itemBuilder: (context, index) {
                  return _buildImgPreview(context, index);
                },
              ),
            );
  }

  Widget _buildImgPreview(BuildContext context, int index) {
    return Padding(
            padding: EdgeInsets.only(
              left: 12.w,
              right: 12.w,
              bottom: 7.h,
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Obx(() {
                    return ScenePreview(
                      key: UniqueKey(),
                      scene: stepThreeController.sceneBeans[index],
                      onComplete: (scene) {
                        stepThreeController.loadSceneList();
                      },
                    );
                  }),
                  Positioned(
                    bottom: 5.h,
                    right: 5.w,
                    height: 20.h,
                    child: ByWidgetsUtil.commonContainer(
                      alignment: Alignment.center,
                      bgColor: Color.fromARGB(255, 77, 38, 38).withOpacity(0.6),
                      padding: EdgeInsets.symmetric(horizontal: 7.w),
                      child: Obx(() => ByWidgetsUtil.commonText(
                            text:
                                "${index + 1}/${stepThreeController.sceneBeans.length}",
                            fontSize: 10.sp,
                            textColor: const Color(0xFFFFFFFF).withOpacity(0.5),
                            fontWeight: FontWeight.normal,
                          )),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildSceneList(BuildContext context) {
    final listViewH = 76.w;
    return SizedBox(
      height: listViewH,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        scrollDirection: Axis.horizontal,
        controller: imgScroll,
        itemCount: stepThreeController.sceneBeans.length,
        itemBuilder: (context, index) {
          return Obx(() {
            final currentScene = stepThreeController.sceneBeans[index];
            final selected =
                currentScene.id == stepThreeController.scene.value?.id;
            final status = StorySceneStatus.fromValue(currentScene.status);

            var finshed = [StorySceneStatus.drawn, StorySceneStatus.redrawn]
                .contains(status);

            // var drawing = [
            //   StorySceneStatus.created,
            //   StorySceneStatus.drawing,
            //   StorySceneStatus.redrawing
            // ].contains(status);

            var drawing = StorySceneStatus.drawFailed == status && currentScene.hasReDraw;;

            return GestureDetector(
              onTap: () {
                pageScroll.jumpToPage(index);
                stepThreeController.scrollToPosition(imgScroll, index);
                stepThreeController.scene.value = currentScene;
              },
              child: ByWidgetsUtil.commonContainer(
                borerRadius: 8.w,
                border: Border.all(
                  color: selected
                      ? ByColorUtil.LoginBtnBgColor
                      : Colors.transparent,
                  width: 2.w,
                ),
                bgColor: Colors.white,
                padding: EdgeInsets.all(1.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.w),
                  child: Stack(children: [
                      finshed
                          ? BYImageView(
                              imageUrl: currentScene.url,
                              width: 100.w,
                              height: 70.w,
                            )
                          : Container(
                              width: 100.w,
                              height: 70.w,
                              color: const Color(0xFFF4F8F9),
                              alignment: Alignment.center,
                              child: !drawing
                                  ? Image.asset(
                                      "assets/v2/folk/generate_faild.png",
                                      width: 18.w,
                                      fit: BoxFit.fitWidth,
                                    )
                                  : SizedBox(
                                      width: 18.w,
                                      height: 18.w,
                                      child: const SvgaPlayer(
                                          url:
                                              "assets/v2/folk/scene_placeolder.svga"),
                                    ),
                            ),
                      //是否有角标
                      if (currentScene.drawNum > 1 || (currentScene.drawNum == 1 && !finshed))
                        Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              alignment: Alignment.center,
                              height: 20.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6.w),
                                color: Colors.white.withOpacity(0.9),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  gotoReCreateScene(currentScene);
                                },
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.w),
                                  child: ByWidgetsUtil.commonText(
                                      text: '${currentScene.drawNum}张',
                                      fontSize: 12,
                                      textColor: ByColorUtil.CommonTextColor),
                                ),
                              ),
                            )
                          )
                    ])
                ),
              ),
              // ByWidgetsUtil.svgAsset(
              //     filePath: "assets/v2/folk/scene_placeolder.svga",
              //     width: 50.w,
              //     height: 50.w,
              //   ),
            );
          });
        },
      ),
    );
  }

  Widget _buildSceneTab(BuildContext context) {
    return Obx(() {
      final scene = stepThreeController.scene.value;
      return SceneDetailsView(
        key: UniqueKey(),
        scene: scene,
        onRegenerate: (scene) async {
          gotoReCreateScene(scene);
        },
      );
    });
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
            stepThreeController.loadSceneList();
          }
  }
}
