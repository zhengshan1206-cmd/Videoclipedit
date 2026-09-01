import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/purchase/widgets/vip_count_down_view.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class VipBannerView extends StatelessWidget {
  const VipBannerView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PurchaseProvider>(builder: (
      context,
      provider,
      child,
    ) {
      // final money = provider.vipSpecialBean?.money ?? "0.00";
      final money = provider.vipTypeBeans.first.money;
      final comps = money.split(".");
      return Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (provider.selectedVIPTypeIndex == 0) return;
              provider.changeSelectedVipTypeIndex(0);
            },
            child: Container(
              margin: EdgeInsets.only(
                top: 27.h,
                left: 10.w,
                right: 10.w,
              ),
              height: 90.h,
              width: double.infinity,
              child: Stack(
                children: [
                  Image.asset(
                    provider.selectedVIPTypeIndex == 0
                        ? "assets/purchase/banner_bg.png"
                        : "assets/purchase/banner_bg_unselected.png",
                    height: 90.h,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                  Positioned.fill(
                    child: Row(
                      children: [
                        SizedBox(width: 22.w),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ByWidgetsUtil.richText(
                              textColorUnit: ByColorUtil.PurchasePriceTextColor,
                              partIntegral: comps[0],
                              textColorIntegral:
                                  ByColorUtil.PurchasePriceTextColor,
                              partFractional:
                                  comps.length > 1 ? comps[1] : "00",
                              textColorFractional:
                                  ByColorUtil.PurchasePriceTextColor,
                            ),
                            SizedBox(height: 5.h),
                            Padding(
                              padding: EdgeInsets.only(left: 15.w),
                              child: ByWidgetsUtil.commonText(
                                text:
                                    "原价¥${provider.vipSpecialBean?.crossedMoney ?? ""}",
                                fontSize: 12.sp,
                                textColor: ByColorUtil.PurchasePriceDescColor,
                                decoration: TextDecoration.lineThrough,
                              ),
                            )
                          ],
                        ),
                        SizedBox(width: 19.w),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 2.h),
                            ByWidgetsUtil.commonText(
                              text: provider.vipSpecialBean?.des ?? "",
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              textColor: ByColorUtil.PurchasePriceDescColor,
                            ),
                            SizedBox(height: 10.h),
                            ByWidgetsUtil.commonText(
                              text:
                                  "限量发售 每天仅需${provider.vipSpecialBean?.dayMoney ?? 0}元",
                              fontSize: 12.sp,
                              textColor: ByColorUtil.PurchasePriceDescColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            left: 22.w,
            child: const VIPCountDownWidget(),
          ),
        ],
      );
    });
  }
}
