import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/profile/beans/mine_score_happys_bean.dart';
import 'package:video_clip_edit/modules/profile/beans/mine_scores_info_bean.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_scores_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class MineScoresNoticeView extends StatelessWidget {
  const MineScoresNoticeView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scoresInfoBean =
        context.select<MineScoresProvider, MineScoresInfoBean?>(
      (value) => value.scoresInfoBean,
    );
    final inform = (scoresInfoBean?.user.inform ?? "").replaceAll("购买须知：", "");
    final comps = inform.split("\n").where((e) => e.isNotEmpty);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: ByWidgetsUtil.commonContainer(
            bgColor: const Color(0xFFF5F8F9),
            borerRadius: 12,
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/mine/score_icon_pay_notice.png",
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 3),
                    ByWidgetsUtil.commonText(
                      text: "购买须知:",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                ByWidgetsUtil.commonText(
                  text: comps.join("\n"),
                  height: 1.8,
                  maxLines: 100,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  textColor: ByColorUtil.CommonTextColor.withOpacity(0.6),
                )
              ],
            )),
      ),
    );
  }
}

class MineScoresBalanceView extends StatelessWidget {
  const MineScoresBalanceView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scoresInfoBean =
        context.select<MineScoresProvider, MineScoresInfoBean?>(
      (value) => value.scoresInfoBean,
    );
    return SliverPadding(
      padding: EdgeInsets.only(
        top: 12.h,
        bottom: 20.h,
      ),
      sliver: SliverToBoxAdapter(
        child: Container(
          width: double.infinity,
          height: 104.h,
          padding: EdgeInsets.only(left: 16.w),
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                "assets/mine/mine_score_banner_bg.png",
              ),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ByWidgetsUtil.commonText(
                fontSize: 14.sp,
                text: "当前剩余积分",
                fontWeight: FontWeight.bold,
                textColor: const Color(0xFF56310E),
              ),
              SizedBox(height: 10.h),
              ByWidgetsUtil.commonText(
                fontSize: 32.sp,
                text: "${scoresInfoBean?.user.integral ?? 0}",
                fontWeight: FontWeight.bold,
                textColor: const Color(0xFF56310E),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScorePaymentMethodsView extends StatelessWidget {
  const ScorePaymentMethodsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scoreHappysBean =
        context.select<MineScoresProvider, MineScoreHappysBean?>(
      (value) => value.scoreHappysBean,
    );
    if (scoreHappysBean == null) {
      return SliverToBoxAdapter(child: Container());
    }
    bool wxEnabled = scoreHappysBean.pays.wxpay == 1;
    bool aliEnabled = scoreHappysBean.pays.alipay == 1;
    bool yeepayEnabled = scoreHappysBean.pays.yeepay == 1;
    final items = [];
    if (yeepayEnabled) {
      items.add({
        "icon": "assets/mine/score_icon_pay_wechat.png",
        "payName": "微信支付",
        "payType": "yeepay",
        "iconSelected": "assets/mine/score_icon_pay_wechat_selected.png"
      });
    } else if (wxEnabled) {
      items.add({
        "icon": "assets/mine/score_icon_pay_wechat.png",
        "payName": "微信支付",
        "payType": "wxpay",
        "iconSelected": "assets/mine/score_icon_pay_wechat_selected.png"
      });
    }
    if (aliEnabled) {
      items.add({
        "icon": "assets/mine/score_icon_pay_zfb.png",
        "payName": "支付宝",
        "payType": "alipay",
        "iconSelected": "assets/mine/score_icon_pay_zfb_selected.png"
      });
    }
    if (items.isNotEmpty &&
        context.select<MineScoresProvider, int>(
              (value) => value.selectedPayMethodIndex,
            ) ==
            -1) {
      final provider = context.read<MineScoresProvider>();
      provider.selectedPayMethodIndex = 0;
      provider.paymethods = items.first["payType"];
    }
    return SliverGrid.builder(
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 11.w,
        childAspectRatio: 85 / 22,
      ),
      itemBuilder: (context, index) {
        return ScorePaymentMethodsCell(
          index: index,
          item: items[index],
        );
      },
    );
  }
}

class ScorePaymentMethodsCell extends StatelessWidget {
  const ScorePaymentMethodsCell({
    super.key,
    required this.item,
    required this.index,
  });

  final int index;
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final selected = index ==
        context.select<MineScoresProvider, int>(
          (value) => value.selectedPayMethodIndex,
        );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final provider = context.read<MineScoresProvider>();
        provider.udateSelectedPayMethodIndex(index);
        provider.paymethods = item["payType"];
      },
      child: ByWidgetsUtil.commonContainer(
        bgColor: const Color(0xFFF5F8F9),
        borerRadius: 8.w,
        child: Row(
          children: [
            SizedBox(width: 15.w),
            Image.asset(
              item["icon"],
              width: 18,
              height: 18,
            ),
            const SizedBox(width: 9),
            ByWidgetsUtil.commonText(
              text: item["payName"],
              fontSize: 12.sp,
              textColor: const Color(0xFF999999),
            ),
            const Spacer(),
            Image.asset(
              selected
                  ? item["iconSelected"]
                  : "assets/mine/score_icon_pay_unselected.png",
              width: 12,
              height: 12,
            ),
            SizedBox(width: 15.w),
          ],
        ),
      ),
    );
  }
}

class ScoreListView extends StatelessWidget {
  const ScoreListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scoreHappysBean =
        context.select<MineScoresProvider, MineScoreHappysBean?>(
      (value) => value.scoreHappysBean,
    );
    if (scoreHappysBean == null) {
      return SliverToBoxAdapter(child: Container());
    }
    return SliverGrid.builder(
      itemCount: scoreHappysBean.items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 15.h,
        crossAxisSpacing: 11.w,
        childAspectRatio: 17 / 8,
      ),
      itemBuilder: (context, index) {
        return ScoreListCell(
          index: index,
          item: scoreHappysBean.items[index],
        );
      },
    );
  }
}

class ScoreListCell extends StatelessWidget {
  const ScoreListCell({
    super.key,
    required this.item,
    required this.index,
  });
  final int index;
  final Item item;

  @override
  Widget build(BuildContext context) {
    final selected = index ==
        context.select<MineScoresProvider, int>(
          (value) => value.selectedHappyIndex,
        );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.read<MineScoresProvider>().udateSelectedHappyIndex(index);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ByWidgetsUtil.commonContainer(
              bgColor:
                  selected ? const Color(0xFFFEF2E1) : const Color(0xFFF3F5F9),
              borerRadius: 12,
              border: Border.all(
                color: selected
                    ? const Color(0xFFF9A000)
                    : const Color(0xFFF3F5F9),
                width: 1,
              ),
              child: Row(
                children: [
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              "assets/mine/mine_score_coin.png",
                              width: 20,
                              height: 20,
                              fit: BoxFit.fill,
                            ),
                            const SizedBox(width: 7),
                            ByWidgetsUtil.commonText(
                              text: "${item.integral}",
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              textColor: const Color(0xFFF9A101),
                            ),
                            const SizedBox(width: 4),
                            ByWidgetsUtil.commonText(
                              text: "积分",
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              textColor: const Color(0xFFF9A101),
                            ),
                          ],
                        ),
                        SizedBox(height: 5.h),
                        Padding(
                          padding: const EdgeInsets.only(left: 27),
                          child: ByWidgetsUtil.commonText(
                            text: "¥${item.money}",
                            fontSize: 14.sp,
                            fontWeight: FontWeight.normal,
                            textColor: const Color(0xFFF9A101),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Offstage(
                    offstage: !selected,
                    child: ByWidgetsUtil.svgAsset(
                      filePath: "assets/mine/mine_score_selected.svg",
                      width: 20,
                      height: 20,
                    ),
                  ),
                  SizedBox(width: 11.w)
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            height: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 6,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFF9A200)
                    : const Color(0xFFDEE2E9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: ByWidgetsUtil.commonText(
                text: "≈${item.unitIntegralMoney}/积分",
                fontSize: 12.sp,
                fontWeight: FontWeight.normal,
                textColor: selected
                    ? const Color(0xFFFFFFFF)
                    : ByColorUtil.CommonTextColor,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: -12.h,
            height: 24.h,
            child: Offstage(
              offstage: item.mark.isEmpty,
              child: ByWidgetsUtil.commonContainer(
                alignment: Alignment.center,
                bgColor: const Color(0xFFFF2F5F),
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: ByWidgetsUtil.commonText(
                  text: item.mark,
                  textColor: ByColorUtil.WhiteColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
