import 'dart:ffi';

import 'package:bot_toast/bot_toast.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/data/model/folk/story_scene_bean.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/scene_info_edit_controller.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/input/normal_input_view.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/prohited/prohibited_words_dailog.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/prohited/prohited_words_detect_mixin.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';
import 'package:video_clip_edit/widgets/common/integral_vip_view.dart';

import '../../../widgets/common_button.dart';
import '../../../widgets/image/by_image_view.dart';
import '../controllers/step_three_controller.dart';

class SceneRegreneratePage extends StatefulWidget {
  const SceneRegreneratePage({
    super.key,
    required this.scene,
  });

  final StorySceneBean scene;

  @override
  State<SceneRegreneratePage> createState() => _SceneRegreneratePageState();
}

class _SceneRegreneratePageState extends State<SceneRegreneratePage>
    with ProhitedWordsDetectMixin {
  RxInt selectedIdx = (-1).obs;
  final editController = Get.put(SceneInfoEditController());
  late final Rx<StorySceneBean> _scene = widget.scene.obs;
  final CancelToken _cancelToken = CancelToken();
  final StepThreeController stepThreeController = Get.find<StepThreeController>();

  @override
  void dispose() {
    editController.dispose();
    Get.delete<SceneInfoEditController>();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _checkSelectedStatus();

    /// 轮询场景详情
    _checkSceneStatus();
  }

  void _checkSelectedStatus() {
    // final redraw = _scene.value.reworkUrl.isNotEmpty;
    // if (redraw) {
    //   final rework = _scene.value.reworkUrl.first;
    //   final status = rework.status;
    //   if (status == StorySceneStatus.sceneRedrawCompleted.rawValue) {
    //     selectedIdx.value = 1;
    //     return;
    //   }
    // }

    final status = StorySceneStatus.fromValue(_scene.value.status);
    
    
    final success = StorySceneStatus.drawn == status;
    if (success) {
      selectedIdx.value = 0;
    } else {
      selectedIdx.value = -1;
    }

    //生成失败时默认选择第一个生成成功的分镜
    if (status == StorySceneStatus.drawFailed){
      if (_scene.value.reworkUrl.isNotEmpty){
        for (ReworkUrl rework in _scene.value.reworkUrl){
          if(rework.img.isNotEmpty){
            int index = _scene.value.reworkUrl.indexOf(rework);
            selectedIdx.value = index + 1;
            break;
          }
        }
      }
    }
  }

  void _checkSceneStatus() {
    editController.reset();
    editController.pollingSceneInfo(
      sceneId: _scene.value.id,
      cancelToken: _cancelToken,
      onValidateBefore: (sceneBean) {
        setState(() {
          _scene.value = sceneBean;
          _checkSelectedStatus();
        });
      },
      onComplete: (sceneBean) {
        editController.reset();
        setState(() {
          _scene.value = sceneBean;
          stepThreeController.loadSceneList();
          _checkSelectedStatus();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(
        context: context,
        title: "场景绘制",
        showBottmLine: true,
      ),
      body: _buildView(context),
    );
  }

  Widget _buildView(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 16.sp),
        _buildImageList(context),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 13.sp),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/v2/folk/scene_words_origin.png",
                        width: 16.w,
                        height: 16.w,
                      ),
                      SizedBox(width: 4.w),
                      ByWidgetsUtil.commonText(
                        text: "对应剧情",
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  width: double.infinity,
                  child: ByWidgetsUtil.commonText(
                    maxLines: 100,
                    fontSize: 12.sp,
                    text: _scene.value.original,
                    fontWeight: FontWeight.normal,
                    textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                  ),
                ),
                SizedBox(height: 18.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/v2/folk/scene_desc.png",
                        width: 16.w,
                        height: 16.w,
                      ),
                      SizedBox(width: 4.w),
                      ByWidgetsUtil.commonText(
                        text: "场景描述",
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                _buildInputVIew(context),
              ],
            ),
          ),
        ),
        _buildBottomBar(context),
      ],
    );
  }

  // // 积分-vip-次数-消耗模块-重绘
  Widget _buildIntegralVipView() {
    return IntegralVipView(
      requiredPoints: 0,
      type: "folk_story_repaint", // 通过这个type请求权益接口获取实际积分
      padding: EdgeInsets.only(bottom: 4.h),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return ByWidgetsUtil.physicalModel(
      color: Colors.white,
      child: Container(
        padding: EdgeInsets.only(
          top: 4.h,
          left: 12.w,
          right: 12.w,
          bottom: 8.h,
        ),
        height: 105.h + context.byBottomSafeHeight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIntegralVipView(),
            SizedBox(height: 8.h),
            SizedBox(
              height: 50.h,
              child: Row(
                children: [
                  Expanded(
                    child: ByWidgetsUtil.commonBtn(
                      title: "重新绘制",
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      bgColor: const Color(0xFFEAEEFF),
                      padding: EdgeInsets.zero,
                      borderRadius: 12.w,
                      textColor: ByColorUtil.LoginBtnBgColor,
                      onClick: () {
                        _checkSelectedStatus();

                        // 有积分后统一使用权益下发
                        // final reworkNum = _scene.value.reworkNum;
                        // if (reworkNum <= 0) {
                        //   BotToast.showText(text: "已达到最大重绘次数");
                        //   return;
                        // }

                        final integralVipController =
                            IntegralVipController.getOrPut();

                        /// 检查积分是否足够-积分购买
                        if (!integralVipController.canContinueUse()) {
                          integralVipController.showIntegralPayDialog();
                          return;
                        }
                        detect(
                          context,
                          _scene.value.prompt,
                          onSuccess: () {
                            editController.sceneRepaint(
                              sceneId: _scene.value.id,
                              prompt: _scene.value.prompt,
                              onSucess: (data) {
                                byDebugPrint("-----1");
                                integralVipController.init(
                                  requiredPoints: 0,
                                  type: "folk_story_repaint",
                                );

                                stepThreeController.startPollingSceneList();
                                /// 轮询角色详情
                                _checkSceneStatus();
                              },
                            );
                          },
                          onFail: () {
                            showDialog(
                                context: context,
                                useSafeArea: false,
                                barrierDismissible: true,
                                builder: (ctx) => ProhibitedWordsDailog(
                                    originalContents: _scene.value.prompt,
                                    onTextChanged: (value) {
                                      _scene.value.prompt = value;
                                    }));
                          },
                        );
                      },
                    ),
                  ),
                  if (selectedIdx >=0)
                  SizedBox(width: 12.w),
                  if (selectedIdx >=0)
                  Expanded(
                    child: ByWidgetsUtil.commonBtn(
                      title: "使用",
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      bgColor:ByColorUtil.LoginBtnBgColor,
                      padding: EdgeInsets.zero,
                      borderRadius: 12.w,
                      onClick: () {
                        _useScene();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //使用绘制好的场景
  _useScene() {
    //选中默认分镜
    if (selectedIdx.value == 0) {
      Get.back(result: false);
      return;
    }
    final reworkUrl = _scene.value.reworkUrl[selectedIdx.value - 1].img;
    if (reworkUrl.isEmpty) {
      Get.back(result: false);
      return;
    }

    editController.updateSceneInfo(
      sceneId: _scene.value.id,
      url: reworkUrl,
      prompt: _scene.value.prompt,
      onSucess: (data) {
        Get.back(result: true);
      },
    );
  }

  Widget _buildInputVIew(BuildContext context) {
    return SizedBox(
      height: 200.h,
      width: double.infinity,
      child: ByWidgetsUtil.commonContainer(
        margin: EdgeInsets.symmetric(horizontal: 12.w),
        borerRadius: 10.w,
        bgColor: const Color(0xFFF4F8F9),
        child: NormalInputView(
          maxWords: 10000,
          placeholder: "请输入场景描述",
          initialValue: widget.scene.prompt,
          focusNode: false,
          onChanged: (p0) {
            _scene.value.prompt = p0;
          },
        ),
      ),
    );
  }

  Widget _buildImageList(BuildContext context) {
    // final contentsW = ByScreenUtils.screenWidth - 12.w * 2;
    // final margin = 5.w;
    // const showCount = 2.5;
    final width = 145.w;
    final height = width;
    //是否只有一个生成的分镜
    bool onlyOneSuccessScene = _scene.value.reworkUrl.isEmpty;
    return Obx(() {
      final total =  _scene.value.reworkUrl.length + 1;
      return SizedBox(
        height: height,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: onlyOneSuccessScene ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              SceneRegenerateCell(
                selected: true,
                isOriginal: true,
                index: 0,
                scene: _scene.value,
                onSelected: onSelected,
                total: 1,
              )
            ]
          ) : ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            itemCount: total,
            itemBuilder: (context, index) {
              return Obx(() {
                return SceneRegenerateCell(
                selected: selectedIdx.value == index,
                isOriginal: index == 0,
                index: index,
                scene: _scene.value,
                onSelected: onSelected,
                total: total,
              );
            });
            },
          ),
        ),
      );
    });
  }

  void onSelected(StorySceneStatus status, int index, bool useScene) {
    //
    if (index == 0) {
      selectedIdx.value = index;
    }
    else {
      if ([
      StorySceneStatus.drawn,
      StorySceneStatus.redrawn,
      StorySceneStatus.sceneRedrawCompleted
    ].contains(status)) {
      selectedIdx.value = index;
    }
    }
    //已经使用分镜
    if(useScene){
      _useScene();
    }
  }
}

class SceneRegenerateCell extends StatelessWidget {
  const SceneRegenerateCell({
    super.key,
    this.onSelected,
    required this.index,
    required this.scene,
    this.selected = false,
    required this.isOriginal,
    required this.total,
  });

  final int index;
  final int total;
  final bool selected;
  final bool isOriginal;
  final StorySceneBean scene;
  final void Function(StorySceneStatus, int , bool)? onSelected;

  @override
  Widget build(BuildContext context) {
    final rawValue = isOriginal ? scene.status : scene.reworkUrl[index-1].status;
    final status = StorySceneStatus.fromValue(rawValue);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onSelected?.call(status, index, false);
      },
      child: ByWidgetsUtil.commonContainer(
        alignment: Alignment.center,
        borerRadius: 15.w,
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        border: Border.all(
          color: (selected && status != StorySceneStatus.drawFailed) ? ByColorUtil.LoginBtnBgColor : Colors.transparent,
          width: 2.w,
        ),
        padding: EdgeInsets.all(2.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11.w),
          child: ByWidgetsUtil.commonContainer(
            alignment: Alignment.center,
            border: Border.all(
              color:
                  (selected && status != StorySceneStatus.drawFailed) ? ByColorUtil.WhiteColor : const Color(0xFFEAEEFF),
              width: 0.5.w,
            ),
            child: Stack(
              children: [
                _buildContentsByStatus(context, status),
                Positioned(
                  bottom: 5.h,
                  right: 5.w,
                  height: 20.h,
                  child: ByWidgetsUtil.commonContainer(
                    alignment: Alignment.center,
                    bgColor: const Color(0xFF000000).withOpacity(0.3),
                    padding: EdgeInsets.symmetric(horizontal: 7.w),
                    child: ByWidgetsUtil.commonText(
                      text: "${index + 1}/$total",
                      fontSize: 10.sp,
                      textColor: const Color(0xFFFFFFFF),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),

                if ([StorySceneStatus.drawn,StorySceneStatus.redrawn,StorySceneStatus.sceneRedrawCompleted].contains(status))
                Positioned(
                  right: 5.w,
                  top: 5.w,
                  child: GestureDetector(
                    onTap: () {
                      List <String> urls = [];
                      int hasReDraw = 0;
                      if (scene.url.isNotEmpty){
                        urls.add(scene.url);
                      }
                      else{
                        hasReDraw ++;
                      }
                      for (ReworkUrl url in scene.reworkUrl){
                        if(url.img.isNotEmpty){
                          urls.add(url.img);
                        }
                        else {
                          hasReDraw ++;
                        }
                      } 
                      Get.dialog(
                        SceneImgPicker(
                          urls: urls,
                          currentIndex: index - hasReDraw,
                          onSelected: (index){
                            onSelected?.call(status, index + hasReDraw, true);
                          },
                        ),
                        useSafeArea: false,
                      );
                    },
                    child: Image.asset(
                          "assets/v2/folk/folk_video_scene_img_scale.png",
                          width: 24.w,
                          height: 24.w,
                        ),
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentsByStatus(BuildContext context, StorySceneStatus status) {
    final renderW = 135.w;
    if (isOriginal) {
      if (status == StorySceneStatus.drawn) {
        return CachedNetworkImage(
          imageUrl: scene.url,
          width: renderW,
          height: renderW,
          fit: BoxFit.cover,
          alignment: Alignment.center,
        );
      }
      if (status == StorySceneStatus.drawFailed) {
        return SizedBox(
          width: renderW,
          child: ByWidgetsUtil.commonContainer(
            bgColor: const Color(0xFFF8FAFB),
            child: Column(
              children: [
                const Spacer(),
                Image.asset(
                  "assets/v2/folk/generate_faild.png",
                  width: 44.w,
                  height: 44.w,
                ),
                SizedBox(height: 15.h),
                ByWidgetsUtil.commonText(
                  text: "生成失败",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  textColor: const Color(0xFF81899F),
                ),
                const Spacer(),
              ],
            ),
          ),
        );
      }
    }
    switch (status) {
      case StorySceneStatus.created:
      case StorySceneStatus.drawing:
      case StorySceneStatus.sceneRedrawing:
        return SizedBox(
          width: renderW,
          child: ByWidgetsUtil.commonContainer(
            bgColor: const Color(0xFFF8FAFB),
            child: Column(
              children: [
                const Spacer(),
                SizedBox(
                  width: 33.w,
                  height: 33.w,
                  child: ByWidgetsUtil.activityIndicator(),
                ),
                SizedBox(height: 15.h),
                ByWidgetsUtil.commonText(
                  text: "图片绘制中...",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  textColor: ByColorUtil.LoginBtnBgColor,
                ),
                const Spacer(),
              ],
            ),
          ),
        );
      case StorySceneStatus.drawn:
      case StorySceneStatus.sceneRedrawCompleted:
        return CachedNetworkImage(
          imageUrl: scene.reworkUrl[index-1].img,
          width: renderW,
          height: renderW,
          fit: BoxFit.cover,
          alignment: Alignment.center,
        );
      case StorySceneStatus.sceneRedrawFailed:
        return SizedBox(
          width: renderW,
          child: ByWidgetsUtil.commonContainer(
            bgColor: const Color(0xFFF8FAFB),
            child: Column(
              children: [
                const Spacer(),
                Image.asset(
                  "assets/v2/folk/generate_faild.png",
                  width: 44.w,
                  height: 44.w,
                ),
                SizedBox(height: 15.h),
                ByWidgetsUtil.commonText(
                  text: "生成失败",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  textColor: const Color(0xFF81899F),
                ),
                const Spacer(),
              ],
            ),
          ),
        );
      default:
        return Container();
    }
  }
}

///图片查看器(预留可滑动选择)
class SceneImgPicker extends StatefulWidget {
  const SceneImgPicker({
    super.key,
    required this.urls,
    required this.currentIndex,
    this.onSelected,
  });

  final List<String> urls;
  final int currentIndex;
  final void Function(int)? onSelected;
  @override
  _SceneImgPickerState createState() => _SceneImgPickerState();
}

class _SceneImgPickerState extends State<SceneImgPicker>  {
  final _carouselController = CarouselSliderController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return _buildAppBar(context);
  }
  

  _buildAppBar(BuildContext context) {
    return Container(
      color: ByColorUtil.BlackColor.withOpacity(0.3),
      child: Padding(
        padding: EdgeInsets.only(top: 206.w),
        child: Column(
          children: [
            SizedBox(
                  height: 400.w,
                  child: CarouselSlider(
                    carouselController: _carouselController,
                    items: widget.urls.map((e) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(15.w),
                        child: CachedNetworkImage(
                          imageUrl: e,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: double.infinity,
                      viewportFraction: 0.8,
                      initialPage: _currentIndex,
                      enableInfiniteScroll: false,
                      reverse: false,
                      autoPlay: false,
                      autoPlayInterval: const Duration(seconds: 3),
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      enlargeFactor: 0.3,
                      onPageChanged: (index, reason) {
                        _currentIndex = index;
                      },
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                ),
            SizedBox(
              height: 15.w,
            ),
            SizedBox(
              height: 50.w,
              width: 300.w,
              child: ByWidgetsUtil.commonBtn(
                title: '使用', 
                fontSize: 16,
                fontWeight: BYFontWeight.medium,
                onClick: (){
                widget.onSelected?.call(_currentIndex);
                Get.back();
              }),
            ),
            SizedBox(
              height: 30.w,
            ),
            //关闭按钮
            CommonButton(
            onPressed: () => {
              Get.back(),
            },
            child: SizedBox(
              width: 32.w,
              height: 32.w,
              child: Image.asset(
                'assets/v2/folk/folk_story_img_close.png',
                fit: BoxFit.fill,
                ),
            ),
            ),
          ],
        )
      ),
    );
  }
}

