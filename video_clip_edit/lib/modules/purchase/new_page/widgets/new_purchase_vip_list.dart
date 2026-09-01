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
import 'package:video_clip_edit/v2/business/get_red_envelope_dialog.dart';

class NewVipListViewNew extends StatelessWidget {
  const NewVipListViewNew({super.key, this.isBlue = true});

// true 蓝色ui,false 红色ui
  final bool isBlue;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PurchaseProvider>();
    final itemH = 120.h;
    final marginHor = 12.w;
    const itemCount = 3;
    final contentW = context.byScreenWidth - marginHor * (itemCount - 1);
    final itemW = (contentW - marginHor * (itemCount - 1)) / itemCount;
    return Column(
      children: [
        Selector<PurchaseProvider, List<VipTypeBean>>(
            builder: (context, vipTypeBeans, c) {
              return vipTypeBeans.isEmpty
                  ? Container()
                  : Column(
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
                            childAspectRatio: itemW / (itemH * 1.08),
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
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        provider.premiumTips,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0x80ffffff)),
                                      ),
                                    )
                                  : const SizedBox.shrink();
                            },
                            selector: (context, p) => p.selectedVIPTypeIndex)
                      ],
                    );
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

    // item边框
    BoxBorder? border = isBlue
        ? Border.all(
            width: 2,
            color: selected ? const Color(0xFF5B4BF7) : Colors.transparent,
          )
        : Border.all(
            width: 2,
            color: selected
                ? const Color(
                    0xFFFF387A,
                  )
                : Colors.transparent,
          );
    // item背景颜色
    Color contentColor = isBlue ? const Color(0xFF5B4BF7) : Colors.transparent;
    // 价格字体颜色（蓝色UI使用渐变，红色UI使用此颜色）
    Color tvColor = isBlue
        ? ByColorUtil.WhiteColor
        : (selected ? const Color(0xFFFF387A) : ByColorUtil.WhiteColor);
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
                colorStart: isBlue && selected
                    ? const Color(0xff191c22)
                    : (selected ? contentColor : const Color(0xff191c22)),
                colorEnd: isBlue && selected
                    ? const Color(0xff191c22)
                    : (selected ? contentColor : const Color(0xff191c22)),
              ),
              child: Column(
                children: [
                  SizedBox(height: 13.h),
                  ByWidgetsUtil.commonText(
                      fontSize: 14.sp,
                      text: vipTypeBean.title,
                      fontWeight: FontWeight.bold,
                      textColor: ByColorUtil.WhiteColor),
                  SizedBox(height: 8.h),
                  isBlue
                      ? ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) => const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFFFFFFF), // #FFFFFF
                              Color(0xFFDDAAFF), // #DDAAFF
                            ],
                            stops: [0.0, 1.0],
                          ).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (vipTypeBean.isDefault != 1)
                                ByWidgetsUtil.richText(
                                  unit: vipTypeBean.vipListStyle == 1 ||
                                          (vipTypeBean.vipListStyle == 3 &&
                                              vipTypeBean.level ==
                                                  VIPLevel.monthy)
                                      ? '¥'
                                      : '≈',
                                  fontSizeUnit: 12.sp,
                                  textColorUnit: Colors.white,
                                  fontSizeIntegral:
                                      vipTypeBean.vipListStyle == 1
                                          ? 28.sp
                                          : 24.sp,
                                  partIntegral: _getPrefixText(),
                                  textColorIntegral: Colors.white,
                                ),
                              if (vipTypeBean.isDefault == 1)
                                NumberScrollAnimation(
                                  startNum:
                                      double.tryParse(vipTypeBean.crossedMoney),
                                  endNum: double.tryParse(_getPrefixText()),
                                  showSymbol: false,
                                  prefixText: vipTypeBean.vipListStyle == 1 ||
                                          (vipTypeBean.vipListStyle == 3 &&
                                              vipTypeBean.level ==
                                                  VIPLevel.monthy)
                                      ? '¥'
                                      : '≈',
                                  prefixTextStyle: TextStyle(
                                    // fontFamily: fontFamily,
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    height: 1.2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: vipTypeBean.vipListStyle == 1
                                        ? 28.sp
                                        : 24.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              if (vipTypeBean.vipListStyle != 1)
                                ByWidgetsUtil.richText(
                                  unit: "",
                                  fontSizeUnit: 12.sp,
                                  textColorUnit: Colors.white,
                                  fontSizeIntegral: 10.sp,
                                  partIntegral: "元/",
                                  textColorIntegral: Colors.white,
                                ),
                              if (vipTypeBean.vipListStyle != 1)
                                ByWidgetsUtil.richText(
                                  unit: "",
                                  fontSizeUnit: 12.sp,
                                  textColorUnit: Colors.white,
                                  fontSizeIntegral: 10.sp,
                                  partIntegral:
                                      vipTypeBean.vipListStyle == 2 ? "天" : "月",
                                  textColorIntegral: Colors.white,
                                ),
                            ],
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (vipTypeBean.isDefault != 1)
                              ByWidgetsUtil.richText(
                                unit: vipTypeBean.vipListStyle == 1 ||
                                        (vipTypeBean.vipListStyle == 3 &&
                                            vipTypeBean.level ==
                                                VIPLevel.monthy)
                                    ? '¥'
                                    : '≈',
                                fontSizeUnit: 12.sp,
                                textColorUnit: tvColor,
                                fontSizeIntegral: vipTypeBean.vipListStyle == 1
                                    ? 28.sp
                                    : 24.sp,
                                partIntegral: _getPrefixText(),
                                textColorIntegral: tvColor,
                              ),
                            if (vipTypeBean.isDefault == 1)
                              NumberScrollAnimation(
                                startNum:
                                    double.tryParse(vipTypeBean.crossedMoney),
                                endNum: double.tryParse(_getPrefixText()),
                                showSymbol: false,
                                prefixText: vipTypeBean.vipListStyle == 1 ||
                                        (vipTypeBean.vipListStyle == 3 &&
                                            vipTypeBean.level ==
                                                VIPLevel.monthy)
                                    ? '¥'
                                    : '≈',
                                prefixTextStyle: TextStyle(
                                  // fontFamily: fontFamily,
                                  color: tvColor,
                                  fontSize: 12.sp,
                                  height: 1.2,
                                  fontWeight: FontWeight.bold,
                                ),
                                textStyle: TextStyle(
                                  color: tvColor,
                                  fontSize: vipTypeBean.vipListStyle == 1
                                      ? 28.sp
                                      : 24.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (vipTypeBean.vipListStyle != 1)
                              ByWidgetsUtil.richText(
                                unit: "",
                                fontSizeUnit: 12.sp,
                                textColorUnit: tvColor,
                                fontSizeIntegral: 10.sp,
                                partIntegral: "元/",
                                textColorIntegral: tvColor,
                              ),
                            if (vipTypeBean.vipListStyle != 1)
                              ByWidgetsUtil.richText(
                                unit: "",
                                fontSizeUnit: 12.sp,
                                textColorUnit: tvColor,
                                fontSizeIntegral: 10.sp,
                                partIntegral:
                                    vipTypeBean.vipListStyle == 2 ? "天" : "月",
                                textColorIntegral: tvColor,
                              ),
                          ],
                        ),
                  SizedBox(height: 2.h),
                  ByWidgetsUtil.commonText(
                    text: "¥${vipTypeBean.crossedMoney}",
                    fontSize: 12.sp,
                    decoration: TextDecoration.lineThrough,
                    decorationThickness: 1,
                    textColor: ByColorUtil.WhiteColor.withOpacity(0.3),
                    decorationColor: ByColorUtil.WhiteColor.withOpacity(0.3),
                  ),
                  const Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16.w),
                      bottomRight: Radius.circular(16.w),
                    ),
                    child: ByWidgetsUtil.commonContainer(
                      bgColor: selected
                          ? ByColorUtil.WhiteColor.withOpacity(0.05)
                          : ByColorUtil.WhiteColor.withOpacity(0.04),
                      borerRadius: 0,
                      child: Container(
                        width: double.infinity,
                        height: 30.h,
                        alignment: Alignment.center,
                        child: ByWidgetsUtil.commonText(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          text: _getSuffixText(),
                          textColor: ByColorUtil.WhiteColor.withOpacity(0.3),
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
                  fontWeight: FontWeight.w600,
                  gradient: ByColorUtil.lineareGradient(
                    colorStart: const Color(0xFFF74B9C),
                    colorEnd: const Color(0xFFF74B9C),
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
