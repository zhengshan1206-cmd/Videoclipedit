import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/purchase/beans/vip_type_bean.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_string_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class VipTypeView extends StatelessWidget {
  final void Function(VipTypeBean) onSelected;
  final VipTypeBean vipTypeBean;
  const VipTypeView({
    super.key,
    required this.vipTypeBean,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final components = ByStringUtils.componentsWithDouble(vipTypeBean.money);
    final provider = context.read<PurchaseProvider>();
    final selected = provider.selectedVIPTypeIndex == 3
        ? false
        : provider.vipTypeBeans[provider.selectedVIPTypeIndex].id ==
            vipTypeBean.id;
    return GestureDetector(
      onTap: () {
        onSelected(vipTypeBean);
      },
      child: ByWidgetsUtil.gradientBgContainer(
        padding: EdgeInsets.zero,
        gradient: ByColorUtil.lineareGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colorStart:
              selected ? const Color(0xFFFFFBEC) : ByColorUtil.WhiteColor,
          colorEnd: selected ? const Color(0xFFFDE9B0) : ByColorUtil.WhiteColor,
        ),
        borderRadius: 16.w,
        border: Border.all(
          width: selected ? 2 : 0.5,
          color: selected ? const Color(0xFFFBBD3C) : const Color(0xFFFFE8B6),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 15.h),
            ByWidgetsUtil.commonText(
              fontSize: 14.sp,
              text: vipTypeBean.title,
              fontWeight: FontWeight.bold,
              textColor: const Color(0xFF703C01),
            ),
            ByWidgetsUtil.richText(
              fontSizeUnit: 12.sp,
              textColorUnit: ByColorUtil.PurchasePriceDescColor,
              fontSizeIntegral: 28.sp,
              partIntegral: components.$1,
              textColorIntegral: ByColorUtil.PurchasePriceDescColor,
              fontSizeFractional: 14.sp,
              partFractional: components.$2,
              textColorFractional: ByColorUtil.PurchasePriceDescColor,
            ),
            ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(14.w),
                bottomRight: Radius.circular(14.w),
              ),
              child: ByWidgetsUtil.gradientBgContainer(
                padding: EdgeInsets.zero,
                borderRadius: 0,
                gradient: ByColorUtil.lineareGradient(
                  end: Alignment.topCenter,
                  begin: Alignment.bottomCenter,
                  colorEnd: selected
                      ? const Color(0xFFFACB62)
                      : const Color(0xFFFFF3DF),
                  colorStart: selected
                      ? const Color(0xFFFCDD93)
                      : const Color(0xFFFFF3DF),
                ),
                child: Container(
                  width: double.infinity,
                  height: 30.h,
                  alignment: Alignment.center,
                  child: ByWidgetsUtil.commonText(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      text: "¥${vipTypeBean.dayMoney}/天",
                      textColor: const Color(0xFF764004)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
