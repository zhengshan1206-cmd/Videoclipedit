import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/base/base_view.dart';
import 'package:video_clip_edit/core/util/common_ui.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/modules/home/widgets/svga_player.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/ai_create_bgm_setting_controller.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_bgm_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_bgm_cat_bean.dart';
import 'package:video_clip_edit/widgets/common/multi_status_view.dart';
import 'package:video_clip_edit/widgets/common_button.dart';
import 'package:video_clip_edit/widgets/image/by_image_view.dart';
import 'package:video_clip_edit/widgets/refresh/by_refresh.dart';

///背景音乐-平台推荐
class BgmPlatformRecommendView extends StatefulWidget {
  const BgmPlatformRecommendView({
    super.key,
    required this.selectBgmBean,
    this.selectAction,
  });

  final Rx<AiCartoonBgmBean?> selectBgmBean;
  final ValueChanged<AiCartoonBgmBean?>? selectAction;

  @override
  State<BgmPlatformRecommendView> createState() => _BgmPlatformRecommendViewState();
}

class _BgmPlatformRecommendViewState extends State<BgmPlatformRecommendView>
    with AutomaticKeepAliveClientMixin {
  final controller = Get.find<AiCreateBgmSettingController>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<AiCreateBgmSettingController>(builder: (controller) {
      return BaseView(
        hasAppBar: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeView(),
            Expanded(
              child: _buildBgmList(),
            ),
            _buildButton(),
          ],
        ),
      );
    });
  }

  ///平台推荐类型
  _buildTypeView() {
    return Obx(
      () {
        return controller.categoryList.isNotEmpty
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Row(
                  children: List.generate(controller.categoryList.length, (index) {
                    return _buildTypeItem(controller.categoryList[index], index);
                  }),
                ),
              )
            : Container();
      },
    );
  }

  _buildTypeItem(AiCartoonBgmCatBean categoryBean, int index) {
    return Container(
      margin: EdgeInsets.only(right: index != controller.categoryList.length - 1 ? 8.w : 0),
      child: GestureDetector(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.5.w, vertical: 9.5.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.h),
            color: controller.categoryType.value == categoryBean
                ? ByColorUtil.TabTextColorSelected
                : ByColorUtil.colorF8FAFB,
          ),
          child: BYText.instance(categoryBean.title, 14.sp,
              color: controller.categoryType.value == categoryBean
                  ? ByColorUtil.colorF8FAFB
                  : ByColorUtil.CommonTextColor),
        ),
        onTap: () {
          if (controller.categoryType.value == categoryBean) return;
          controller.queryChanged(categoryBean);
        },
      ),
    );
  }

  _buildBgmList() {
    return BYRefresh.instance(
      controller: controller.refreshController,
      hasBefore: false,
      hasMore: false,
      child: Obx(() {
        return MultiStatusView(
          backgroundColor: Colors.transparent,
          currentStatus: controller.multiStatus.value,
          emptyActionType: EmptyActionType.text,
          hasAppBar: false,
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: controller.bgmList.length,
            separatorBuilder: (context, index) => getDivider(color: ByColorUtil.color81899F.withOpacity(0.05)),
            itemBuilder: (context, index) {
              var bgmBean = controller.bgmList[index];
              return _buildBgmItem(bgmBean);
            },
          ),
        );
      }),
    );
  }

  _buildBgmItem(AiCartoonBgmBean bgmBean) {
    return Obx(() {
      final selectId = widget.selectBgmBean.value?.id;
      final isSelected = selectId != null && selectId == bgmBean.id;
      return GestureDetector(
        onTap: () {
          if (controller.playingId == bgmBean.id) {
            if (controller.audioPlayer.isPlaying) {
              controller.audioPlayer.pause();
            } else {
              controller.audioPlayer.resume();
            }
            return;
          }
          controller.audioPlayer.play(bgmBean.url);
          controller.playingId = bgmBean.id;
          if (isSelected) return;
          widget.selectBgmBean.value = bgmBean;
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
          padding: EdgeInsets.only(left: 8.w, top: 8.h, right: 20.w, bottom: 8.h),
          decoration: BoxDecoration(
              color: isSelected ? ByColorUtil.colorF4F6FF : Colors.transparent,
              borderRadius: BorderRadius.circular(12.h),
              border: Border.all(
                  color: isSelected
                      ? ByColorUtil.LoginBtnBgColor
                      : Colors.transparent,
                  width: 2.w)),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BYImageView.normal(
                  imageUrl: bgmBean.icon,
                  placeholderName: Assets.aiBgmDefault,
                  width: 44.w,
                  height: 44.w,
                ),
              ),
              SizedBox(width: 13.5.w),
              Expanded(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                            child: BYText.instance(
                                bgmBean.title.split(".").first, 14.sp,
                                color: isSelected
                                    ? ByColorUtil.LoginBtnBgColor
                                    : ByColorUtil.CommonTextColor,
                                fontWeight: BYFontWeight.semiBold)),
                        SizedBox(width: 9.5.w),
                        isSelected
                            ? Obx(() {
                                return controller.isPlaying
                                    ? SizedBox(
                                        width: 19.w,
                                        height: 15.h,
                                        child: const SvgaPlayer(url: Assets.aiAiMusicPlay),
                                      )
                                    : Container();
                              })
                            : Container(),
                      ],
                    ),
                    // SizedBox(height: 10.h),
                    // BYText.instance('郭顶 | 03:42', 12.sp,
                    //     color: ByColorUtil.CommonTextColor.withOpacity(0.5)),
                  ],
                ),
              ),
              isSelected
                  ? Obx(() {
                      return controller.isLoading
                          ? ByWidgetsUtil.activityIndicator(
                              radius: 8.w,
                              color: const Color(0xFFED3F8D),
                            )
                          : controller.isPlaying
                              ? Image.asset(
                                  Assets.aiIconAudioPause,
                                  width: 18.w,
                                  height: 18.w,
                                )
                              : Image.asset(
                                  Assets.aiIconAudioPlay,
                                  width: 15.w,
                                  height: 15.h,
                                );
                    })
                  : Container(),
            ],
          ),
        ),
      );
    });
  }

  _buildButton() {
    return PhysicalModel(
      color: Colors.black,
      child: Container(
        color: ByColorUtil.WhiteColor,
        padding: EdgeInsets.only(left: 12.w, top: 8.h, right: 12.w),
        child: Row(
          children: [
            SizedBox(
              width: 91.w,
              height: 50.h,
              child: CommonButton(
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(12.h),
                color: ByColorUtil.colorEAEEFF,
                minSize: 50.h,
                spacing: 5.h,
                suffixDirectional: SuffixDirectional.top,
                suffixWidget: Image.asset(
                  Assets.aiIconNoNeedBgm,
                  width: 18.w,
                  height: 18.w,
                ),
                onPressed: (){
                  if (controller.audioPlayer.isPlaying) {
                    controller.audioPlayer.stop();
                  }
                  controller.selectBgmBean.value = null;
                  widget.selectAction?.call(widget.selectBgmBean.value);
                  Get.back();
                },
                child: BYText.instance('不需要音乐', 12.sp,
                    color: ByColorUtil.LoginBtnBgColor, height: 1.0),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: CommonButton(
                padding: EdgeInsets.zero,
                minSize: 50.h,
                borderRadius: BorderRadius.circular(12.h),
                color: ByColorUtil.LoginBtnBgColor,
                onPressed: () {
                  widget.selectAction?.call(widget.selectBgmBean.value);
                  Get.back();
                },
                child: BYText.instance('确定', 16.sp,
                    color: Colors.white, fontWeight: BYFontWeight.medium),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
