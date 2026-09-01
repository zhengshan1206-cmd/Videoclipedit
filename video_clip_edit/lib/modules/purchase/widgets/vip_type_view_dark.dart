import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_string_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/purchase/beans/vip_type_bean.dart';

class VipTypeViewDark extends StatelessWidget {
  final void Function(VipTypeBean) onSelected;
  final VipTypeBean vipTypeBean;
  final int index;
  const VipTypeViewDark({
    super.key,
    required this.vipTypeBean,
    required this.onSelected,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final components = ByStringUtils.componentsWithDouble(vipTypeBean.money);
    final provider = context.read<PurchaseProvider>();
    final selected = provider.vipTypeBeans[provider.selectedVIPTypeIndex].id ==
        vipTypeBean.id;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            onSelected(vipTypeBean);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.w),
            child: ByWidgetsUtil.gradientBgContainer(
              padding: EdgeInsets.all(selected ? 2 : 2),
              gradient: ByColorUtil.lineareGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colorStart: selected
                    ? const Color(0xFFA04BFF)
                    : const Color(0xFF191C22).withOpacity(0),
                colorEnd: selected
                    ? const Color(0xFFFA23A7)
                    : const Color(0xFF191C22).withOpacity(0),
              ),
              child: Container(
                decoration: BoxDecoration(
                    color: const Color(0xFF191C22),
                    borderRadius: BorderRadius.circular(16.w)),
                child: Column(
                  children: [
                    SizedBox(height: 15.h),
                    ByWidgetsUtil.commonText(
                      fontSize: 14.sp,
                      text: vipTypeBean.title,
                      fontWeight: FontWeight.bold,
                      textColor: ByColorUtil.WhiteColor,
                    ),
                    SizedBox(height: 10.h),
                    // ShaderMask(
                    //   shaderCallback: (bounds) => const LinearGradient(
                    //     colors: [
                    //       Colors.red,
                    //       Colors.red,
                    //       // Color(0xFF5C4BFF),
                    //     ],
                    //     begin: Alignment.topCenter,
                    //     end: Alignment.bottomCenter,
                    //   ).createShader(
                    //       Rect.fromLTWH(0.0, 0.0, bounds.width, bounds.height)),
                    //   child: ByWidgetsUtil.richText(
                    //     fontSizeUnit: 12.sp,
                    //     textColorUnit: const Color(0xFF5C4BFF),
                    //     fontSizeIntegral: 28.sp,
                    //     partIntegral: components.$1,
                    //     textColorIntegral: const Color(0xFF5C4BFF),
                    //     fontSizeFractional: 14.sp,
                    //     partFractional: components.$2,
                    //     textColorFractional: const Color(0xFF5C4BFF),
                    //   ),
                    // ),
                    ByWidgetsUtil.richText(
                      fontSizeUnit: 12.sp,
                      textColorUnit: selected
                          ? const Color(0xFFFA23A7)
                          : ByColorUtil.WhiteColor,
                      fontSizeIntegral: 28.sp,
                      partIntegral: components.$1,
                      textColorIntegral: selected
                          ? const Color(0xFFFA23A7)
                          : ByColorUtil.WhiteColor,
                      fontSizeFractional: 14.sp,
                      partFractional: components.$2,
                      textColorFractional: selected
                          ? const Color(0xFFFA23A7)
                          : ByColorUtil.WhiteColor,
                    ),
                    SizedBox(height: 10.h),
                    ByWidgetsUtil.commonText(
                      text: "¥${vipTypeBean.crossedMoney}",
                      fontSize: 12.sp,
                      decoration: TextDecoration.lineThrough,
                      textColor: ByColorUtil.WhiteColor.withOpacity(0.5),
                    ),
                    const Spacer(),
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16.w),
                        bottomRight: Radius.circular(16.w),
                      ),
                      child: ByWidgetsUtil.commonContainer(
                        borerRadius: 0,
                        bgColor: ByColorUtil.WhiteColor.withOpacity(0.05),
                        padding: EdgeInsets.zero,
                        child: Container(
                          width: double.infinity,
                          height: 30.h,
                          alignment: Alignment.center,
                          child: ByWidgetsUtil.commonText(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              text: "¥${vipTypeBean.dayMoney}/天",
                              textColor:
                                  ByColorUtil.WhiteColor.withOpacity(0.5)),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: -12.h,
          child: Offstage(
            offstage: vipTypeBean.isDefault != 1,
            child: Container(
              alignment: Alignment.center,
              child: SizedBox(
                height: 24.h,
                width: 85.w,
                child: ByWidgetsUtil.gradientBtn(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  borderRadius: 12.h,
                  fontSize: 12.sp,
                  gradient: ByColorUtil.lineareGradient(
                    colorStart: const Color(0xFFFF2750),
                    colorEnd: const Color(0xFFDF3AF8),
                  ),
                  title:
                      vipTypeBean.mark.isNotEmpty ? vipTypeBean.mark : "最多人选择",
                  onClick: () {},
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
