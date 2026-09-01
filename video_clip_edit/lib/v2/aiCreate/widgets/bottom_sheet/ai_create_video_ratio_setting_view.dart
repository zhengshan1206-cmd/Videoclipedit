import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/data/model/aiCreate/ai_create_video_ratio_bean.dart';
import 'package:video_clip_edit/flavors/app_values.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/widgets/common_button.dart';

///视频比例弹窗
class AiCreateVideoRatioSettingView extends StatefulWidget {
  const AiCreateVideoRatioSettingView({
    super.key,
    required this.ratioList,
    this.selectRatioBean,
    this.selectAction,
  });

  final List<AiCreateVideoRatioBean> ratioList;
  final AiCreateVideoRatioBean? selectRatioBean;
  final ValueChanged<AiCreateVideoRatioBean?>? selectAction;

  static void show(
      {required List<AiCreateVideoRatioBean> ratioList,
        AiCreateVideoRatioBean? selectRatioBean,
      ValueChanged<AiCreateVideoRatioBean?>? selectAction}) {
    Get.bottomSheet(
      AiCreateVideoRatioSettingView(
          ratioList: ratioList,
          selectRatioBean: selectRatioBean,
          selectAction: selectAction),
      barrierColor: ByColorUtil.BlackColor.withOpacity(0.3),
      ignoreSafeArea: true,
      isScrollControlled: true,
    );
  }

  @override
  State<AiCreateVideoRatioSettingView> createState() => _AiCreateVideoRatioSettingViewState();
}

class _AiCreateVideoRatioSettingViewState extends State<AiCreateVideoRatioSettingView> {
  final selectRatioBean = Rx<AiCreateVideoRatioBean?>(null);

  @override
  void initState() {
    super.initState();
    selectRatioBean.value = widget.selectRatioBean;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: safeAreaBottomDistance(15.h)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(18.h), topRight: Radius.circular(18.h)),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: BYText.instance('视频比例', 16.sp, fontWeight: BYFontWeight.semiBold),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: CommonButton(
                  padding: EdgeInsets.only(left: 10.w, top: 20.h, right: 3.w, bottom: 20.h),
                  minSize: 0,
                  borderRadius: BorderRadius.zero,
                  onPressed: Get.back,
                  child: Image.asset(Assets.commonIconBottomSheetClose, width: 14.w, height: 14.w),
                ),
              ),
            ],
          ),
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.only(bottom: 22.h),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 每行的列
              mainAxisSpacing: 12.h, // 垂直间隔
              crossAxisSpacing: 12.w, // 水平间隔
              childAspectRatio: 109 / 60,
            ),
            itemCount: widget.ratioList.length,
            itemBuilder: (context, index) {
              var ratioBean = widget.ratioList[index];
              return _buildRatioItem(ratioBean);
            },
          ),
          _buildButton(),
        ],
      ),
    );
  }

  ///比例列表
  _buildRatioItem(AiCreateVideoRatioBean ratioBean) {
    return Obx(() {
      final selectId = selectRatioBean.value?.id;
      final isSelected = selectId != null && selectId == ratioBean.id;
      return GestureDetector(
        onTap: () {
          if (isSelected) return;
          selectRatioBean.value = ratioBean;
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ByColorUtil.CommonPageBgColor,
                  borderRadius: BorderRadius.circular(10.w),
                  border: Border.all(
                    color: isSelected ? ByColorUtil.TabTextColorSelected : Colors.transparent,
                    width: 1.w,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 15.w),
                    Image.asset(
                      "assets/ai/ai_cartoon_video_ratio_${ratioBean.scale?.replaceAll(":", "_")}.png",
                      width: 24.w,
                      height: 24.w,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: 10.w),
                    BYText.instance(ratioBean.scale ?? '', 14.sp, fontWeight: BYFontWeight.medium),
                  ],
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Image.asset(
                  Assets.aiAiCarttonSelected,
                  width: 24.w,
                  height: 24.w,
                  fit: BoxFit.contain,
                ),
              ),
          ],
        ),
      );
    });
  }

  _buildButton() {
    return SizedBox(
      width: double.infinity,
      child: CommonButton(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        minSize: 50.h,
        borderRadius: BorderRadius.circular(12.h),
        color: ByColorUtil.LoginBtnBgColor,
        onPressed: () {
          Get.back();
          widget.selectAction?.call(selectRatioBean.value);
        },
        child: BYText.instance('确定', 16.sp, color: Colors.white, fontWeight: BYFontWeight.medium),
      ),
    );
  }

}
