import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/purchase/beans/vip_type_bean.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';

import '../../../providers/ios_purchase_provider.dart';
import '../../../utils/comon/by_colors.dart';
import '../../../utils/comon/by_widgets_util.dart';
import '../../profile/beans/user_info_bean.dart';

///新的vip类型
class NewIosVipListView extends StatelessWidget {
  const NewIosVipListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vipTypeBeans = context.select<IosPurchaseProvider, List<VipTypeBean>>(
      (provider) => provider.vipTypeBeans,
    );
    final itemH = 120.h;
    final marginHor = 12.w;
    const itemCount = 3;
    final contentW = context.byScreenWidth - marginHor * (itemCount - 1);
    final itemW = (contentW - marginHor * (itemCount - 1)) / itemCount;
    return vipTypeBeans.isEmpty
        ? Container()
        : GridView.builder(
            padding: EdgeInsets.zero,
            // scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            shrinkWrap: true,
            itemCount: vipTypeBeans.length,
            physics: vipTypeBeans.length > itemCount
                ? null
                : const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: marginHor,
              crossAxisSpacing: marginHor,
              childAspectRatio: itemW / (itemH * 1.05),
            ),
            itemBuilder: (context, index) {
              return IosVipTypeViewNew(
                vipTypeBean: vipTypeBeans[index],
                index: index,
                onSelected: (VipTypeBean bean) {
                  Get.log("选中的vip购买类型产品Id====>${bean.toJson()}");
                  String showHintText = "";
                  String time = "月";
                  if (vipTypeBeans[index].isSubscribe == 1) {
                    if (vipTypeBeans[index].vipLevel == 365) {
                      time = "年";
                    } else if (vipTypeBeans[index].vipLevel == 30) {
                      time = "月";
                    } else if (vipTypeBeans[index].vipLevel == 90) {
                      time = "季";
                    }
                    showHintText = vipTypeBeans[index].des;
                    // "到期后按${vipTypeBeans[index].money}¥/${time}自动续费，可随时取消自动续费";
                  } else {
                    showHintText = vipTypeBeans[index].des;
                    // "一次性付费，到期后不会自动扣费，放心购买";
                  }
                  context
                      .read<IosPurchaseProvider>()
                      .changeSelectedVipTypeIndex(
                          index, bean.appleVipId, bean.id, showHintText);
                },
              );
            },
          );
  }
}

class IosVipTypeViewNew extends StatelessWidget {
  final void Function(VipTypeBean) onSelected;
  final VipTypeBean vipTypeBean;
  final int index;
  const IosVipTypeViewNew({
    super.key,
    required this.vipTypeBean,
    required this.onSelected,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // final components = ByStringUtils.componentsWithDouble(vipTypeBean.money);
    final provider = context.read<IosPurchaseProvider>();
    final selectedVIPTypeIndex = context
        .select<IosPurchaseProvider, int>((val) => val.selectedVIPTypeIndex);
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
                  const Spacer(),
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
                        height: 30.h,
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
