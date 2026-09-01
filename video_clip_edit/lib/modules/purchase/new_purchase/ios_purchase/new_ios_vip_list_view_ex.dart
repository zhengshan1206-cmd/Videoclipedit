import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/purchase/beans/vip_type_bean.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import '../../../../providers/ios_purchase_provider.dart';
import '../../../../utils/comon/by_colors.dart';
import '../../../../utils/comon/by_widgets_util.dart';
import '../../../profile/beans/user_info_bean.dart';
import 'ui_type_enum.dart';

///新的vip类型
class NewIosVipListViewEx extends StatelessWidget {
  const NewIosVipListViewEx({super.key, this.type = PurchaseUiType.Blue});

  final PurchaseUiType type;

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
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: marginHor,
              crossAxisSpacing: marginHor,
              childAspectRatio: itemW / (itemH * 1.08),
            ),
            itemBuilder: (context, index) {
              return IosVipTypeViewNew(
                type: type,
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

  ///Blue Red 指向的不同付费配置模式（3.10.17版本只是UI不同）
  final PurchaseUiType type;

  const IosVipTypeViewNew({
    super.key,
    required this.vipTypeBean,
    required this.onSelected,
    required this.index,
    required this.type,
  });

  ///按钮正常颜色
  btnNorMalColor({
    required bool selected,
    required Color contentColor,
  }) {
    return selected ? contentColor : const Color(0xff191c22);
  }

  ///最多人选择
  Widget _morePeopleSelectedView() {
    Color color = const Color(0XFFF74B9C);
    return Container(
      padding: EdgeInsets.only(top: 3.w, bottom: 3.w, left: 10.w, right: 10.w),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(12.w)),
      alignment: Alignment.center,
      child: Text(
        vipTypeBean.mark.isNotEmpty ? vipTypeBean.mark : "最多人选择",
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  ///购买套餐底部区域颜色
  Color _purchaseTextColor({
    required bool selected,
  }) {
    Color color = Colors.white.withOpacity(0.5);
    if (!selected) {
      color = const Color(0XFFFFFFFE).withOpacity(0.5);
    }

    return color;
  }

  @override
  Widget build(BuildContext context) {
    // final components = ByStringUtils.componentsWithDouble(vipTypeBean.money);
    final provider = context.read<IosPurchaseProvider>();
    final selectedVIPTypeIndex = context
        .select<IosPurchaseProvider, int>((val) => val.selectedVIPTypeIndex);
    final selected =
        provider.vipTypeBeans[selectedVIPTypeIndex].id == vipTypeBean.id;
    Get.log("vip type==== ${vipTypeBean.vipListStyle}");

    // item边框
    BoxBorder? border = type == PurchaseUiType.Blue
        ? null
        : Border.all(
            width: 2,
            color: selected
                ? const Color(
                    0xFFFF387A,
                  )
                : Colors.transparent,
          );
    // item背景颜色
    Color contentColor = type == PurchaseUiType.Blue
        ? const Color(0xFF5B4BF7)
        : Colors.transparent;
    // 价格字体颜色
    Color tvColor = type == PurchaseUiType.Blue
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
            child: Container(
              decoration: BoxDecoration(
                border: border,
                borderRadius: BorderRadius.circular(16.w),
                color: btnNorMalColor(
                    selected: selected, contentColor: contentColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 15.w),
                  ByWidgetsUtil.commonText(
                    fontSize: 14.sp,
                    text: vipTypeBean.title,
                    fontWeight: FontWeight.w700,
                    textColor: ByColorUtil.WhiteColor,
                  ),
                  SizedBox(height: 5.h),
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
                        textColorUnit: tvColor,
                        fontSizeIntegral:
                            vipTypeBean.vipListStyle == 1 ? 28.sp : 24.sp,
                        partIntegral: _getPrefixText(),
                        textColorIntegral: tvColor,
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
                  SizedBox(height: 5.h),
                  ByWidgetsUtil.commonText(
                    text: "¥${vipTypeBean.crossedMoney}",
                    fontSize: 12.sp,
                    decoration: TextDecoration.lineThrough,
                    decorationThickness: 1,
                    decorationColor: ByColorUtil.WhiteColor.withOpacity(0.5),
                    textColor: ByColorUtil.WhiteColor.withOpacity(0.5),
                  ),
                  const Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16.w),
                      bottomRight: Radius.circular(16.w),
                    ),
                    child: ByWidgetsUtil.commonContainer(
                      bgColor: ByColorUtil.WhiteColor.withOpacity(0.05),
                      borerRadius: 0,
                      child: Container(
                        width: double.infinity,
                        height: 30.h,
                        alignment: Alignment.center,
                        child: ByWidgetsUtil.commonText(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          text: _getSuffixText(),
                          textColor: _purchaseTextColor(selected: selected),
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
          left: 19.5.w,
          top: -12.h,
          child: Offstage(
            offstage: vipTypeBean.isDefault != 1,
            child: _morePeopleSelectedView(),
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
