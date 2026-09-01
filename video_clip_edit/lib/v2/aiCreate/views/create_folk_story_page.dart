import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/core/util/common_ui.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/flavors/app_values.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/core/base/base_view.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/create_folk_story_controller.dart';
import 'package:video_clip_edit/v2/aiCreate/views/base_ai_create_page.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/picture/picture_style_view.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/text_field/ai_create_text_field_view.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/widgets/ai_cartoon_input_view_ex.dart';
import 'package:video_clip_edit/v2/slicing/contents_generating_page.dart';
import 'package:video_clip_edit/widgets/common/common_notice_view.dart';
import 'package:video_clip_edit/widgets/common/integral_vip_view.dart';
import 'package:video_clip_edit/widgets/common/multi_status_view.dart';
import 'package:video_clip_edit/widgets/common_button.dart';
import '../../../core/widget/toolbar/top_tool_bar.dart';
import '../../../modules/guid/providers/guide_pop_providers.dart';
import '../../../utils/comon/by_color_utils.dart';
import '../../../widgets/common/right_navigation_bar.dart';
import '../controllers/ai_create_text_field_controller.dart';

///民间故事创作-文字成片
class CreateFolkStoryPage extends BaseAiCreatePage<CreateFolkStoryController> {
  const CreateFolkStoryPage({super.key});

  @override
  Widget contentView(BuildContext context) {
    return GetBuilder<CreateFolkStoryController>(builder: (controller) {
      final screenHeight = ByScreenUtils.screenHeight;
      final appBarHeight = ByScreenUtils.navigationBarHeight;
      final noticeHeight = controller.noticeList.isNotEmpty ? 30.h : 0;
      final bottomBarH = safeAreaBottomDistance(15.h) + 60.h;
      final maxHeight =
          screenHeight - appBarHeight - noticeHeight - bottomBarH - 50.h;
      final textController = Get.find<AiCreateTextFieldController>();
      if (controller.normalText.isNotEmpty) {
        textController.textController.text = controller.normalText;
        textController.textChanged(controller.normalText);
      }
      textController.folkStoryThemeId = controller.themeId;
      ///返回拦截
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          controller.back();
        },
        child: BaseView(
          title: '民间故事',
          rear: _actionView(),
          leadingAction: controller.back,
          hasFlexibleSpace: true,
          hasAppBar: false,
          child: MultiStatusView(
            // backgroundColor: Colors.transparent,
            backgroundColor: const Color(0xFFF8FBFA),
            currentStatus: controller.multiStatus,
            emptyActionType: EmptyActionType.text,
            hasAppBar: false,
            child: Stack(children: [
              controller.themeBean?.themeColor != null
                  ? Positioned(
                      left: 0,
                      top: 0,
                      right: 0,
                      child: Container(
                        width: double.infinity,
                        height: 250.h,
                        // color: Colors.blue,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                          colors: [
                            ByColorUtils.hexColor(
                                controller.themeBean?.themeColor ?? ''),
                            const Color(0xFFF8FBFA),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )),
                      ))
                  : Positioned.fill(child: Container()),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: controller.themeBean?.bgImage != null
                    ? CachedNetworkImage(
                        imageUrl: controller.themeBean!.bgImage,
                        fit: BoxFit.cover,
                      )
                    : Container(),
              ),
              Positioned.fill(
                child: Column(
                  children: [
                    SizedBox(
                      height: 125.h,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                            left: 12.w, top: 0.h, right: 12.w, bottom: 12.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ///公告
                            _buildMarqueeView(),

                            ///动态文案
                            Obx(() {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                                height: controller.isExpand.value
                                    ? maxHeight
                                    : 240.h,
                                child: Stack(
                                  children: [
                                    controller.isSlicingGenerating.value
                                        ? const ContentsGeneratingPage()
                                        : const AiCreateTextFieldView(
                                            showExpand: false),
                                    (controller.isSlicingGenerating.value || textController.inputText.value.isEmpty)
                                        ? Container()
                                        : Positioned(
                                            bottom: 10.h,
                                            left: 0,
                                            right: 0,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                GestureDetector(
                                                  behavior:
                                                      HitTestBehavior.opaque,
                                                  onTap: () {
                                                    controller.isExpand.value =
                                                        !controller
                                                            .isExpand.value;
                                                  },
                                                  child: Image.asset(
                                                    controller.isExpand.value
                                                        ? "assets/v2/folk/text_field_fold.png"
                                                        : "assets/v2/folk/text_field_expand.png",
                                                    fit: BoxFit.contain,
                                                    width: 24.w,
                                                    height: 24.w,
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                  ),
                                                ),
                                              ],
                                            )),
                                  ],
                                ),
                              );
                            }),

                            ///画面风格
                            //画面风格数量大于1才显示
                            Obx(() => (controller.isSlicingGenerating.value ||
                                    controller.pictureStyleList.length <= 1)
                                ? Container()
                                : PictureStyleView(
                                    pictureStyleList:
                                        controller.pictureStyleList,
                                    selectStyleBean: controller
                                        .folkStoryCreateRequest.selectStyleBean,
                                    selectAction: (value) {
                                      controller.folkStoryCreateRequest
                                          .selectStyleBean.value = value;
                                    },
                                    themeColor: ByColorUtils.hexColor(
                                        controller.themeBean?.buttonColor ??
                                            ''),
                                  )),

                            ///ai创作配置
                            Obx(() => controller.isSlicingGenerating.value
                                ? Container()
                                : _buildConfigView()),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomButton(),
                  ],
                ),
              ),
              //上方工具栏 返回和攻略教程
              // const TopToolBar(guideType: GuideEntranceType.novelCreate),
              _buildTopBar(),
              // _loginPopup(),
            ]),
          ),
        ),
      );
    });
  }

  Positioned _buildTopBar() {
    //初始化上方工具按钮
    return Positioned(
      top: 50.w,
      left: 17.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              controller.back();
            },
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Image.asset(
                "assets/home/icon_back.png",
                color: Colors.white,
                width: 16,
                height: 16,
              ),
            ),
          ),
          // SizedBox(
          //   width: 230.w,
          // ),
          // //民间故事  爆文创作 novel_create	flutter
          // const RightNavigationBar(entranceType: GuideEntranceType.novelCreate),
          // SizedBox(
          //   width: 17.w,
          // )
        ],
      ),
    );
  }

  //弹出登录按钮
  // Widget _loginPopup() {
  //   if((controller.userInfo?.isFormal ?? 0) == 1){
  //     return Positioned.fill(
  //       child: controller.userController.login
  //     );
  //   }
  //   else{
  //     return Positioned.fill(
  //       child: Container()
  //     );
  //   }
  // }

  _actionView() {
    return const KeyboardDismissOnTap(
      dismissOnCapturedTaps: true,
      child: SizedBox(),
    );
  }

  _buildMarqueeView() {
    return Obx(
      () {
        return controller.noticeList.isNotEmpty
            ? CommonNoticeView(
                noticeList: controller.noticeList.value,
                padding: EdgeInsets.only(bottom: 12.h),
              )
            : Container();
      },
    );
  }

  ///ai创作配置项
  Widget _buildConfigView() {
    return radiusView(
      margin: EdgeInsets.only(top: 15.h),
      padding: EdgeInsets.only(left: 13.w, right: 9.5.w),
      backgroundColor: ByColorUtil.WhiteColor,
      border: Border.all(color: ByColorUtil.colorEAEEFF, width: 0.5.w),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: AICreateType.folkStory.configs.length,
        itemBuilder: (context, index) {
          final configItemType = AICreateType.folkStory.configs[index];
          return buildConfigItem(configItemType,
              showDivider: index != AICreateType.folkStory.configs.length - 1);
        },
      ),
    );
  }

  // 积分-vip-次数-消耗模块-新民间故事
  Widget _buildIntegralVipView() {
    return const IntegralVipView(
      requiredPoints: 0,
      type: "folk_story", // 通过这个type请求权益接口获取实际积分
    );
  }

  _buildBottomButton() {
    // final userController = Get.find<HomeMineController>();
    return Obx(() => controller.isSlicingGenerating.value
        ? Container()
        : KeyboardDismissOnTap(
            dismissOnCapturedTaps: true,
            // child: SafeArea(
            //   maintainBottomViewPadding: true,
            child: PhysicalModel(
              color: Colors.black,
              child: Container(
                color: ByColorUtil.WhiteColor,
                padding: EdgeInsets.only(
                    left: 12.w,
                    top: 8.h,
                    right: 12.w,
                    bottom: 8.h + ByScreenUtils.bottomSafeHeight),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIntegralVipView(),
                    // SizedBox(height: 8.h),
                    Row(
                      children: [
                        //vip用户才显示创作记录
                        if (controller.userInfo?.isVip == 1)
                          SizedBox(
                            width: 91.w,
                            height: 50.h,
                            child: CommonButton(
                              padding: EdgeInsets.zero,
                              borderRadius: BorderRadius.circular(12.h),
                              // color: ByColorUtil.colorEAEEFF,
                              color: ByColorUtils.hexColor(controller.themeBean!.buttonColor).withOpacity(0.1),
                              minSize: 50.h,
                              onPressed: controller.creationRecord,
                              child: BYText.instance('创作记录', 16.sp,
                                  color: ByColorUtils.hexColor(
                                      controller.themeBean!.buttonColor)),
                            ),
                          ),
                        if (controller.userInfo?.isVip == 1)
                          SizedBox(width: 10.w),
                        Expanded(
                          child: Obx(() {
                            final enable = controller.nextOperateEnable.value;
                            return CommonButton(
                              padding: EdgeInsets.zero,
                              minSize: 50.h,
                              borderRadius: BorderRadius.circular(12.h),
                              disabledColor: ByColorUtil.LoginBtnBgColor,
                              color: enable
                                  ? ByColorUtils.hexColor(
                                      controller.themeBean!.buttonColor)
                                  : ByColorUtil.LoginBtnBgColor,
                              //未登录用户需要先登录
                              onPressed:() {
                                ByNavigatorUtil.checkLogin(
                                  context: Get.context!, 
                                  nextStepEvent: (){
                                    controller.nextBtnOperate();
                                  });
                              },
                              child: BYText.instance('下一步', 16.sp,
                                  color: ByColorUtil.WhiteColor,
                                  fontWeight: BYFontWeight.medium),
                            );
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // ),
            ),
          ));
  }
}
