import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/main/controllers/main_controller.dart';
import 'package:video_clip_edit/modules/main/main_page.dart';
import 'package:video_clip_edit/modules/purchase/beans/count_down_config.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/modules/purchase/widgets/count_down_view.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class DailogBonusGivnup extends StatelessWidget {
  const DailogBonusGivnup({super.key});

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
                height: 420,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: ByColorUtil.lineareGradient(
                    colorStart: const Color(0xFFF9F8F6),
                    colorEnd: const Color(0xFFFFFFEB),
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 283,
                      width: 304,
                      child: ByWidgetsUtil.gradientBgContainer(
                        borderRadius: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        border: Border.all(
                          color: const Color(0xFFFFF1E5),
                          width: 3,
                        ),
                        gradient: ByColorUtil.lineareGradient(
                          colorStart: const Color(0xFFFFF6E7),
                          colorEnd: const Color(0xFFFAE4CE),
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        child: _buildContents(context),
                      ),
                    ),
                    const SizedBox(height: 9),
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
                        timeItemWidh: 30,
                        timeItemBorderRadius: 8,
                        textColor: const Color(0xFFFEFBF8),
                        separatorPadding: 9,
                        separatorFontSize: 16,
                        separatorTextColor: const Color(0xFF7A4502),
                        fontSize: 16,
                        timeItemBgColor: const Color(0xFFF98C55),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 333,
                left: 9,
                child: ScaleTransitionWidget(
                  child: GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        ByNavRouterUtils.goBack(context);
                      } else {
                        Get.offNamed(Routes.main);
                      }
                      context.read<PurchaseProvider>().createOrder(
                            onSuccess: (payOrderBean) {},
                            context: context,
                          );
                    },
                    child: Stack(
                      children: [
                        Container(
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
              ),
            ],
          ),
          const SizedBox(height: 15),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.pop(context, true);
              if (Navigator.canPop(context)) {
                Navigator.pop(context, true);
              } else {
                Get.offNamed(Routes.main);
              }
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

  Stack _buildContents(BuildContext context) {
    final provider = context.read<PurchaseProvider>();
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 15),
            Image.asset(
              "assets/purchase/dailog_bonus_title.png",
              height: 48,
              fit: BoxFit.fitHeight,
            ),
            const SizedBox(height: 34),
            Container(
              width: 252,
              height: 134,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/purchase/dailog_bonus_amount.png"),
                  fit: BoxFit.fitHeight,
                ),
              ),
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      ByWidgetsUtil.commonText(
                        text:
                            "¥${provider.vipSpecialBean?.crossedMoney ?? '0'}",
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        textColor: const Color(
                          0xFF741D0C,
                        ),
                      ),
                      const Spacer(),
                      ByWidgetsUtil.commonText(
                        text:
                            "¥${provider.vipSpecialBean?.crossedMoney ?? '0'}",
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        textColor: const Color(
                          0xFF741D0C,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ByWidgetsUtil.commonText(
                    text: "限时立减",
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    textColor: const Color(
                      0xFF741D0C,
                    ),
                  ),
                  const SizedBox(height: 2),
                  ByWidgetsUtil.commonText(
                    text:
                        "¥${int.parse(provider.vipSpecialBean!.crossedMoney) - int.parse(provider.vipSpecialBean!.money)}",
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    textColor: const Color(
                      0xFF741D0C,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            ByWidgetsUtil.richTextThree(
              partPre: "折扣到手平均仅≈¥",
              fontSizePre: 16,
              textColorPre: const Color(0xFF7A4502),
              partMiddle: provider.vipSpecialBean!.dayMoney,
              fontSizeMiddle: 30,
              textColorMiddle: const Color(0xFFEF382E),
              partTail: "/天",
              fontSizeTail: 16,
              textColorTail: const Color(0xFFEF382E),
            ),
          ],
        ),
        Positioned(
          left: 26,
          top: 56,
          child: Container(
            width: 240,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ByColorUtil.WhiteColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ByWidgetsUtil.commonText(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              text: "一键干完3天的活 工作不加班",
              textColor: const Color(0xFF7A4502),
            ),
          ),
        ),
      ],
    );
  }
}
