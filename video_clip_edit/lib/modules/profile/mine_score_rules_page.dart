import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_scores_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class MineScoreRulesPage extends StatelessWidget {
  const MineScoreRulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.transparent, //const Color(0xFF000000).withOpacity(0.7),
      body: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ByNavRouterUtils.goBack(context);
            },
            child: SizedBox(
              height: 200.h,
              width: double.infinity,
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(
                left: 14,
                right: 14,
                top: 15,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: ListView.builder(
                itemCount: context
                            .read<MineScoresProvider>()
                            .scoresInfoBean
                            ?.user
                            .integralRule
                            .length !=
                        null
                    ? (context
                            .read<MineScoresProvider>()
                            .scoresInfoBean!
                            .user
                            .integralRule
                            .length +
                        1)
                    : 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Spacer(),
                            SizedBox(
                              width: 40.w,
                              height: 4,
                              child: ByWidgetsUtil.commonContainer(
                                borerRadius: 2,
                                child: Container(),
                                bgColor:
                                    const Color(0xFF111E48).withOpacity(0.3),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Image.asset(
                              "assets/mine/score_icon_rules.png",
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 3),
                            ByWidgetsUtil.commonText(
                              text: "积分规则",
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            )
                          ],
                        ),
                        SizedBox(height: 14.h),
                      ],
                    );
                  }
                  return MineScoreRulesCell(index: index - 1);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MineScoreRulesCell extends StatelessWidget {
  const MineScoreRulesCell({
    super.key,
    required this.index,
  });

  final int index;

  @override
  Widget build(BuildContext context) {
    final marginTop = 3.h;
    final integralRules =
        context.read<MineScoresProvider>().scoresInfoBean!.user.integralRule;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 15.w,
            height: 15.w + marginTop,
            child: ByWidgetsUtil.commonContainer(
              bgColor: ByColorUtil.TabTextColorSelected,
              margin: EdgeInsets.only(top: marginTop),
              alignment: Alignment.center,
              borerRadius: 15,
              child: ByWidgetsUtil.commonText(
                text: "${index + 1}",
                fontSize: 10.sp,
                textColor: ByColorUtil.WhiteColor,
              ),
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: ByWidgetsUtil.commonText(
              height: 1.5,
              maxLines: 100,
              fontSize: 14.sp,
              textColor: ByColorUtil.CommonTextColor.withOpacity(0.6),
              text: integralRules[index],
            ),
          ),
        ],
      ),
    );
  }
}
