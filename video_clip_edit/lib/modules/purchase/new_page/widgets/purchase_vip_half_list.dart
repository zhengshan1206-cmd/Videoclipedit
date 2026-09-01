import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/profile/beans/user_info_bean.dart';
import 'package:video_clip_edit/modules/purchase/beans/vip_type_bean.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class PurchaseVipHalfList extends StatelessWidget {
  const PurchaseVipHalfList({super.key, this.isBlue = false});

// true 蓝色ui,false 红色ui
  final bool isBlue;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PurchaseProvider>();
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final itemH = math.max(112.h, shortest * 0.28);
    final minCellH = 142.h;
    final cellH = math.max(itemH * 1.1, minCellH);
    final marginHor = 12.w;
    const itemCount = 3;
    final contentW = context.byScreenWidth - marginHor * 2;
    final itemW = (contentW - marginHor * (itemCount - 1)) / itemCount;
    return Column(
      children: [
        Selector<PurchaseProvider, List<VipTypeBean>>(
            builder: (context, vipTypeBeans, c) {
              return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: vipTypeBeans.isEmpty
                      ? Container(
                          key: const ValueKey('empty'),
                          height: 120.h,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        )
                      : Column(
                          key: const ValueKey('content'),
                          children: [
                            GridView.builder(
                              padding: EdgeInsets.zero,
                              // scrollDirection: Axis.horizontal,
                              clipBehavior: Clip.none,
                              shrinkWrap: true,
                              itemCount: vipTypeBeans.length,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: marginHor,
                                crossAxisSpacing: marginHor,
                                childAspectRatio: itemW / cellH,
                              ),
                              itemBuilder: (context, index) {
                                return _VipTypeViewNew(
                                  vipTypeBean: vipTypeBeans[index],
                                  index: index,
                                  isBlue: isBlue,
                                  onSelected: (VipTypeBean bean) {
                                    provider.changeSelectedVipTypeIndex(index);
                                  },
                                );
                              },
                            ),
                            Selector<PurchaseProvider, int>(
                                builder: (context, selectedVIPTypeIndex, c) {
                                  // '到期按${provider.vipTypeBeans[selectedVIPTypeIndex].money}/${provider.vipTypeBeans[selectedVIPTypeIndex].title}自动续费，可随时取消，每月赠送600积分',
                                  return provider.premiumTips.isNotEmpty
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Text(
                                            provider.premiumTips,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: const Color(0xFF101E48)
                                                  .withOpacity(0.5),
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink();
                                },
                                selector: (context, p) =>
                                    p.selectedVIPTypeIndex)
                          ],
                        ));
            },
            selector: (context, p) => p.vipTypeBeans),
      ],
    );
  }
}

class _VipTypeViewNew extends StatelessWidget {
  final void Function(VipTypeBean) onSelected;
  final VipTypeBean vipTypeBean;
  final int index;

// true 蓝色ui,false 红色ui
  final bool isBlue;

  const _VipTypeViewNew(
      {super.key,
      required this.vipTypeBean,
      required this.onSelected,
      required this.index,
      this.isBlue = true});

  @override
  Widget build(BuildContext context) {
    // final components = ByStringUtils.componentsWithDouble(vipTypeBean.money);
    final provider = context.read<PurchaseProvider>();
    final selectedVIPTypeIndex = context
        .select<PurchaseProvider, int>((val) => val.selectedVIPTypeIndex);
    final selected =
        provider.vipTypeBeans[selectedVIPTypeIndex].id == vipTypeBean.id;
    Get.log("vip type==== ${vipTypeBean.vipListStyle}");
    BoxBorder? border = isBlue
        ? (selected
            ? Border.all(
                width: 1,
                color: const Color(0xFF5B4BF7),
              )
            : Border.all(width: 1, color: const Color(0xFFEFEFEF)))
        : (selected
            ? Border.all(
                width: 1,
                color: const Color(0xFFFED38B),
              )
            : Border.all(width: 1, color: const Color(0xFFEFEFEF)));
    // item 背景颜色
    Color colorStart = isBlue
        ? (selected ? const Color(0xFF5B4BF7) : Colors.transparent)
        : (selected ? const Color(0xFFFFE7B0) : Colors.transparent);
    // item 背景颜色
    Color colorEnd = isBlue
        ? (selected ? const Color(0xFF5B4BF7) : Colors.transparent)
        : (selected ? const Color(0xFFFEF6E3) : Colors.transparent);
    isBlue ? const Color(0xFF5B4BF7) : Colors.transparent;
    // 价格-标题字体颜色
    Color tvColor = isBlue
        ? (selected ? const Color(0xFFFFFFFF) : const Color(0xFF101E48))
        : (selected ? const Color(0xFF663400) : const Color(0xFF5C5C5C));
    // 价格-划线颜色
    Color crossedMoneyColor = isBlue
        ? (selected
            ? ByColorUtil.WhiteColor.withOpacity(0.5)
            : const Color(0xFF101E48).withOpacity(0.5))
        : (selected
            ? const Color(0xFF663400).withOpacity(0.5)
            : const Color(0xFF5C5C5C).withOpacity(0.5));

    ///背景遮罩
    Color bgColor = isBlue
        ? (selected
            ? ByColorUtil.WhiteColor.withOpacity(0.1)
            : const Color(0xFF1A376C).withOpacity(0.04))
        : (selected
            ? const Color(0xFFF09748).withOpacity(0.1)
            : const Color(0xFFF4F6F9));

    ///遮罩中文字颜色
    Color bgTextColor = isBlue
        ? (selected
            ? ByColorUtil.WhiteColor.withOpacity(0.5)
            : const Color(0xFF101E48).withOpacity(0.5))
        : (selected
            ? const Color(0xFF663400).withOpacity(0.5)
            : const Color(0xFF5C5C5C).withOpacity(0.5));

    ///悬浮按钮颜色
    Color btnStartColor =
        isBlue ? const Color(0xFFFF4479) : const Color(0xFFFE7542);
    Color btnEndColor =
        isBlue ? const Color(0xFFFF4479) : const Color(0xFFFD9105);
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
              border: border,
              borderRadius: 16.w,
              padding: EdgeInsets.zero,
              gradient: ByColorUtil.lineareGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colorStart: colorStart,
                colorEnd: colorEnd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 18.h),
                          ByWidgetsUtil.commonText(
                            fontSize: 14.sp,
                            text: vipTypeBean.title,
                            fontWeight: FontWeight.bold,
                            textColor: tvColor,
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ByWidgetsUtil.richText(
                                unit: vipTypeBean.vipListStyle == 1 ||
                                        (vipTypeBean.vipListStyle == 3 &&
                                            vipTypeBean.level == VIPLevel.monthy)
                                    ? '¥'
                                    : '≈',
                                fontSizeUnit: 12.sp,
                                textColorUnit: tvColor,
                                fontSizeIntegral:
                                    vipTypeBean.vipListStyle == 1 ? 28.sp : 24.sp,
                                partIntegral: _getPrefixText(),
                                textColorIntegral: tvColor,
                              ),
                              if (vipTypeBean.vipListStyle != 1)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 4.h),
                                  child: ByWidgetsUtil.richText(
                                    unit: "",
                                    fontSizeUnit: 12.sp,
                                    textColorUnit: tvColor,
                                    fontSizeIntegral: 10.sp,
                                    partIntegral: "元/",
                                    textColorIntegral: tvColor,
                                  ),
                                ),
                              if (vipTypeBean.vipListStyle != 1)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 4.h),
                                  child: ByWidgetsUtil.richText(
                                    unit: "",
                                    fontSizeUnit: 12.sp,
                                    textColorUnit: tvColor,
                                    fontSizeIntegral: 10.sp,
                                    partIntegral:
                                        vipTypeBean.vipListStyle == 2 ? "天" : "月",
                                    textColorIntegral: tvColor,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          ByWidgetsUtil.commonText(
                            text: "¥${vipTypeBean.crossedMoney}",
                            fontSize: 12.sp,
                            decoration: TextDecoration.lineThrough,
                            decorationThickness: 1,
                            textColor: crossedMoneyColor,
                            decorationColor: crossedMoneyColor,
                          ),
                          SizedBox(height: 8.h),
                        ],
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16.w),
                      bottomRight: Radius.circular(16.w),
                    ),
                    child: ByWidgetsUtil.commonContainer(
                      bgColor: bgColor,
                      borerRadius: 0,
                      child: Container(
                        width: double.infinity,
                        height: 30.h,
                        alignment: Alignment.center,
                        child: ByWidgetsUtil.commonText(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          text: _getSuffixText(),
                          textColor: bgTextColor,
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
                  csutomerBorderRadius: BorderRadius.circular(12),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  gradient: ByColorUtil.lineareGradient(
                    colorStart: btnStartColor,
                    colorEnd: btnEndColor,
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
