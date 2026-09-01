import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/profile/beans/user_info_bean.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_string_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/purchase/beans/vip_type_bean.dart';

class VipTypeViewNew extends StatelessWidget {
  final void Function(VipTypeBean) onSelected;
  final VipTypeBean vipTypeBean;
  final int index;
  const VipTypeViewNew({
    super.key,
    required this.vipTypeBean,
    required this.onSelected,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // final components = ByStringUtils.componentsWithDouble(vipTypeBean.money);
    final provider = context.read<PurchaseProvider>();
    final selectedVIPTypeIndex = context
        .select<PurchaseProvider, int>((val) => val.selectedVIPTypeIndex);
    final selected =
        provider.vipTypeBeans[selectedVIPTypeIndex].id == vipTypeBean.id;
    Get.log("vip type==== ${vipTypeBean.vipListStyle}");
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
              border: Border.all(
                color: selected
                    ? Colors.transparent
                    : const Color(
                        0xFFDED5C4,
                      ),
              ),
              borderRadius: 16.w,
              padding: EdgeInsets.zero,
              gradient: ByColorUtil.lineareGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colorStart: selected
                    ? const Color(0xFFFF387A)
                    : const Color(0xFFFFFCF6),
                colorEnd: selected
                    ? const Color(0xFFFF6B6B)
                    : const Color(0xFFFFFCF6),
              ),
              child: Column(
                children: [
                  SizedBox(height: 8.h),
                  ByWidgetsUtil.commonText(
                    fontSize: 12.sp,
                    text: vipTypeBean.title,
                    fontWeight: FontWeight.bold,
                    textColor: selected
                        ? ByColorUtil.WhiteColor
                        : const Color(0xFF67441E),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ByWidgetsUtil.richText(
                        unit: vipTypeBean.vipListStyle == 1 ||
                                (vipTypeBean.vipListStyle == 3 &&
                                    vipTypeBean.level == VIPLevel.monthy)
                            ? '¥'
                            : '≈',
                        fontSizeUnit: 12.sp,
                        textColorUnit: selected
                            ? ByColorUtil.WhiteColor
                            : const Color(0xFF67441E),
                        fontSizeIntegral:
                            vipTypeBean.vipListStyle == 1 ? 28.sp : 24.sp,
                        partIntegral: _getPrefixText(),
                        textColorIntegral: selected
                            ? ByColorUtil.WhiteColor
                            : const Color(0xFF67441E),
                      ),
                      if (vipTypeBean.vipListStyle != 1)
                        ByWidgetsUtil.richText(
                          unit: "",
                          fontSizeUnit: 12.sp,
                          textColorUnit: selected
                              ? ByColorUtil.WhiteColor
                              : const Color(0xFF67441E),
                          fontSizeIntegral: 10.sp,
                          partIntegral: "元/",
                          textColorIntegral: selected
                              ? ByColorUtil.WhiteColor
                              : const Color(0xFF67441E),
                        ),
                      if (vipTypeBean.vipListStyle != 1)
                        ByWidgetsUtil.richText(
                          unit: "",
                          fontSizeUnit: 12.sp,
                          textColorUnit: selected
                              ? ByColorUtil.WhiteColor
                              : const Color(0xFF67441E),
                          fontSizeIntegral: 10.sp,
                          partIntegral:
                              vipTypeBean.vipListStyle == 2 ? "天" : "月",
                          textColorIntegral: selected
                              ? ByColorUtil.WhiteColor
                              : const Color(0xFF67441E),
                        ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  ByWidgetsUtil.commonText(
                    text: "¥${vipTypeBean.crossedMoney}",
                    fontSize: 12.sp,
                    decoration: TextDecoration.lineThrough,
                    decorationThickness: 3,
                    decorationColor: selected
                        ? null
                        : const Color(0xFF67441E).withOpacity(0.5),
                    textColor: selected
                        ? ByColorUtil.WhiteColor.withOpacity(0.6)
                        : const Color(0xFF67441E).withOpacity(0.6),
                  ),
                  SizedBox(height: 8.h),
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16.w),
                      bottomRight: Radius.circular(16.w),
                    ),
                    child: ByWidgetsUtil.commonContainer(
                      bgColor: selected
                          ? ByColorUtil.WhiteColor.withOpacity(0.1)
                          : const Color(0xFFFFF6D7),
                      borerRadius: 0,
                      child: Container(
                        width: double.infinity,
                        height: 34.h,
                        alignment: Alignment.center,
                        child: ByWidgetsUtil.commonText(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          text: _getSuffixText(),
                          textColor: selected
                              ? ByColorUtil.WhiteColor
                              : const Color(0xFF67441E),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              // ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: -12.h,
          child: Offstage(
            offstage: vipTypeBean.isDefault != 1,
            child: Container(
              alignment: Alignment.center,
              child: SizedBox(
                height: 20.h,
                width: 85.w,
                child: ByWidgetsUtil.gradientBtn(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  csutomerBorderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4.w),
                    topRight: Radius.circular(12.w),
                    bottomLeft: Radius.circular(4.w),
                    bottomRight: Radius.circular(4.w),
                  ),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  gradient: ByColorUtil.lineareGradient(
                    colorStart: const Color(0xFFF731FE),
                    colorEnd: const Color(0xFFA531FE),
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
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

  _getPrefixText() {
    /// 3 -month 2-day
    if (vipTypeBean.vipListStyle == 1) {
      return vipTypeBean.money;
    } else if (vipTypeBean.vipListStyle == 2) {
      return '${vipTypeBean.dayMoney}';
    }
    return vipTypeBean.level == VIPLevel.monthy
        ? "${vipTypeBean.money}"
        : "${vipTypeBean.monthMoney}";
  }

  _getSuffixText() {
    if (vipTypeBean.vipListStyle == 1) {
      return "≈${vipTypeBean.dayMoney}元/天";
    }
    return "¥${vipTypeBean.money}";
  }
}
