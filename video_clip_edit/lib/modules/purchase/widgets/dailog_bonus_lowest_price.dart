import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class DailogBonusLowestPrice extends StatelessWidget {
  const DailogBonusLowestPrice({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PurchaseProvider>();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: 320,
                height: 377,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/purchase/dailog_bonus_lowet_price_bg.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 180),
                    SizedBox(
                      height: 95,
                      width: 272,
                      child: ByWidgetsUtil.gradientBgContainer(
                        borderRadius: 20,
                        padding: const EdgeInsets.all(7),
                        gradient: ByColorUtil.lineareGradient(
                          colorStart: const Color(0xFFED7682),
                          colorEnd: const Color(0xFFFFBFC5),
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: ByColorUtil.WhiteColor,
                          ),
                          child: Row(
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ByWidgetsUtil.commonText(
                                    text: "特价优惠",
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    textColor: const Color(0xFFF4593F),
                                  ),
                                  SizedBox(height: 2.h),
                                  Container(
                                    height: 15.h,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4593F),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: ByWidgetsUtil.commonText(
                                      text:
                                          "¥${provider.vipSpecialBean!.money}",
                                      textColor: ByColorUtil.WhiteColor,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 15),
                              Container(
                                width: 1,
                                height: 50,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFFFF8F5),
                                      Color(0xFFF4D3BF),
                                      Color(0xFFFFF8F5),
                                    ],
                                    stops: [0, 0.5, 1],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              ByWidgetsUtil.richTextThree(
                                partPre: "≈¥",
                                textColorPre: const Color(0xFFF86C55),
                                partMiddle: provider.vipSpecialBean!.dayMoney,
                                textColorMiddle: const Color(0xFFF86C55),
                                partTail: "/天",
                                textColorTail: const Color(0xFFF86C55),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 12,
                left: 19,
                child: ScaleTransitionWidget(
                  child: GestureDetector(
                    onTap: () {
                      ByNavRouterUtils.goBack(context);
                      // ByNavRouterUtils.push(
                      //     context, const PurchasePageDark());

                      context
                          .read<LaunchProvider>()
                          .gotoPay(context, closePay: true);
                    },
                    child: Stack(
                      children: [
                        Container(
                          height: 76,
                          width: 282,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  "assets/purchase/dailog_obtain_btn2.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 31,
                          child: Image.asset(
                            "assets/purchase/icon_pointer.png",
                            width: 52,
                            height: 45,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ByNavRouterUtils.goBack(context);
            },
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              child: Image.asset(
                "assets/purchase/dailog_bonus_close.png",
                width: 32,
                height: 32,
              ),
            ),
          )
        ],
      ),
    );
  }
}
