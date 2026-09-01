import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/purchase/beans/count_down_config.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/modules/purchase/widgets/count_down_view.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class DailogBonus extends StatelessWidget {
  const DailogBonus({
    super.key,
    required this.value,
  });

  final String value;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: 320,
                height: 350,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/purchase/dailog_bonus_bg.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 138,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF9DE8F),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: ByWidgetsUtil.commonText(
                        text: "恭喜获得",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        textColor: const Color(0xFFAB5300),
                      ),
                    ),
                    const SizedBox(height: 90),
                    Row(
                      children: [
                        const SizedBox(width: 33),
                        ByWidgetsUtil.richText(
                          fontWeight: FontWeight.w600,
                          textColorUnit: const Color(0xFFFFFBF5),
                          fontSizeUnit: 20,
                          partIntegral: value,
                          fontSizeIntegral: 60,
                          textColorIntegral: const Color(0xFFFFFBF5),
                          partFractional: "",
                          textColorFractional: const Color(0xFFFFFBF5),
                        ),
                        const SizedBox(width: 40),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ByWidgetsUtil.commonText(
                              text: "立减优惠券",
                              fontSize: 16,
                              textColor: const Color(0xFFFFFBF5),
                              fontWeight: FontWeight.bold,
                            ),
                            const SizedBox(height: 6),
                            ByWidgetsUtil.commonBtn(
                              title: "限今日使用",
                              fontSize: 12,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              bgColor: ByColorUtil.WhiteColor.withOpacity(0.3),
                              textColor: const Color(0xFFFFFBF5),
                              onClick: () {},
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 32,
                left: 9,
                child: ScaleTransitionWidget(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          ByNavRouterUtils.goBack(context);
                          context
                              .read<LaunchProvider>()
                              .gotoPay(context, closePay: true);
                          // ByNavRouterUtils.push(
                          //     context, const PurchasePageDark());
                        },
                        child: Container(
                          height: 96,
                          width: 302,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  "assets/purchase/dailog_obtain_btn.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 18,
                        right: 30,
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
              Positioned(
                  bottom: 18,
                  width: 320,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ByWidgetsUtil.commonText(
                        text: "倒计时",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        textColor: const Color(0xfFE74800),
                      ),
                      const SizedBox(width: 13),
                      CountDownView(
                        config: CountDownConfig(
                          dateTime: DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            DateTime.now().hour + 5,
                            DateTime.now().minute + 59,
                            DateTime.now().second + 59,
                          ),
                          timeItemWidh: 24,
                          timeItemBorderRadius: 4,
                          textColor: ByColorUtil.WhiteColor,
                          separatorPadding: 7,
                          separatorFontSize: 15,
                          separatorTextColor: const Color(0xFFE74800),
                          fontSize: 15,
                          timeItemBgColor:
                              ByColorUtil.PurchaseDialogTimeBgColor,
                        ),
                      ),
                    ],
                  ))
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
