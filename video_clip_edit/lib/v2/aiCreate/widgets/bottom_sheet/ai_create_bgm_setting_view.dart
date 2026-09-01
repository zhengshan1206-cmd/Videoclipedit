import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/flavors/app_values.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/ai_create_bgm_setting_controller.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/bottom_sheet/bgm_my_music_view.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/bottom_sheet/bgm_platform_recommend_view.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_bgm_bean.dart';
import 'package:video_clip_edit/widgets/common/common_tab_bar.dart';
import 'package:video_clip_edit/widgets/common_button.dart';

///背景音乐类型
enum AICreateBgmType implements TabBarItem {
  ///平台推荐
  platformRecommend;

  ///我的音乐库
  // myMusic;

  @override
  String get tabText {
    switch (this) {
      case platformRecommend:
        return '平台推荐';
      // case myMusic:
      //   return '我的音乐库';
    }
  }

  @override
  String? get tabIcon {
    return null;
  }

  @override
  String? get markIcon {
    return null;
  }
}

///背景音乐设置弹窗
class AiCreateBgmSettingView extends StatefulWidget {
  const AiCreateBgmSettingView({
    super.key,
    this.selectBgmBean,
    this.selectAction,
  });

  final AiCartoonBgmBean? selectBgmBean;
  final ValueChanged<AiCartoonBgmBean?>? selectAction;

  static void show({
    AiCartoonBgmBean? selectBgmBean,
    ValueChanged<AiCartoonBgmBean?>? selectAction}) {
    Get.bottomSheet(
      AiCreateBgmSettingView(
        selectBgmBean: selectBgmBean,
        selectAction: selectAction,
      ),
      barrierColor: ByColorUtil.BlackColor.withOpacity(0.3),
      ignoreSafeArea: true,
      isScrollControlled: true,
    );
  }

  @override
  State<AiCreateBgmSettingView> createState() => _AiCreateBgmSettingViewState();
}

class _AiCreateBgmSettingViewState extends State<AiCreateBgmSettingView> {

  final controller = Get.put(AiCreateBgmSettingController());

  @override
  void initState() {
    super.initState();
    controller.selectBgmBean.value = widget.selectBgmBean;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.73,
      padding: EdgeInsets.only(bottom: safeAreaBottomDistance(15.h)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(18.h), topRight: Radius.circular(18.h)),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: BYText.instance('背景音乐', 16.sp, fontWeight: BYFontWeight.semiBold),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: CommonButton(
                  padding: EdgeInsets.only(left: 10.w, top: 20.h, right: 15.w, bottom: 20.h),
                  minSize: 0,
                  borderRadius: BorderRadius.zero,
                  onPressed: Get.back,
                  child: Image.asset(Assets.commonIconBottomSheetClose,
                      width: 14.w, height: 14.w),
                ),
              ),
            ],
          ),
          // CommonIndicatorTabBar(
          //   tabController: controller.tabController,
          //   currentIndex: controller.tabIndex,
          //   tabs: AICreateBgmType.values,
          //   isScrollable: true,
          // ),
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                BgmPlatformRecommendView(
                  selectBgmBean: controller.selectBgmBean,
                  selectAction: widget.selectAction,
                ),
                // BgmMyMusicView(
                //   selectBgmBean: controller.selectBgmBean,
                //   selectAction: (value){
                //     Get.back();
                //     widget.selectAction?.call(value);
                //   },
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
