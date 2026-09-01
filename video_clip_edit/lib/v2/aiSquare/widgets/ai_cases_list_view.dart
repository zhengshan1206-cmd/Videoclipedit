import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/consts/const.dart';
import 'package:video_clip_edit/v2/aiSquare/ai_same_case_page.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/beans/ai_draw_style_case_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class AiCasesListView extends StatelessWidget {
  const AiCasesListView({
    super.key,
    // required this.caseBean,
  });

  // final AiDrawStyleCaseBean caseBean;

  ///做同款的点击事件
  void doSameCase(
      {required BuildContext context, required AiDrawStyleCaseBean caseBean}) {
    ByNavigatorUtil.checkLogin(
        context: context,
        nextStepEvent: () {
          ByNavRouterUtils.push(
              context,
              MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                      create: (context) => AiDrawProvider(),
                    )
                  ],
                  child: AiSameCasePage(
                    caseBean: caseBean,
                    preview: false,
                  )));
        });
  }

  @override
  Widget build(BuildContext context) {
    final beans = context.select<AiSquareProvider, List<AiDrawStyleCaseBean>>(
      (p) => p.aiSquareBeans,
    );

    return SliverToBoxAdapter(
      child: WaterfallFlow.builder(
        padding: EdgeInsets.only(
          left: 12.w,
          right: 12.w,
          bottom: ByScreenUtils.bottomSafeHeight,
        ),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 15.h,
        ),
        itemCount: beans.length,
        itemBuilder: (context, index) {
          final caseBean = beans[index];
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ByNavRouterUtils.push(
                  context,
                  MultiProvider(
                      providers: [
                        ChangeNotifierProvider(
                          create: (context) => AiDrawProvider(),
                        )
                      ],
                      child: AiSameCasePage(
                        caseBean: caseBean,
                        preview: false,
                      )));
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.only(bottom: 15.h),
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.w),
                        child: AspectRatio(
                          aspectRatio: Consts.ratiosMap[caseBean.ratio] ?? 1,
                          child: CachedNetworkImage(
                            imageUrl: caseBean.picUrl,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 5.w, right: 0, bottom: 10.h),
                        child: ByWidgetsUtil.commonText(
                          text: caseBean.prompt,
                          maxLines: 2,
                          fontSize: 12.sp,
                          textColor: ByColorUtil.CommonTextColor,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                doSameCase(
                                    context: context, caseBean: caseBean);

                                // ByNavRouterUtils.push(
                                //     context,
                                //     MultiProvider(
                                //         providers: [
                                //           ChangeNotifierProvider(
                                //             create: (context) =>
                                //                 AiDrawProvider(),
                                //           )
                                //         ],
                                //         child: AiSameCasePage(
                                //           caseBean: caseBean,
                                //           preview: false,
                                //         )));
                              },
                              child: SizedBox(
                                height: 32.h,
                                child: ByWidgetsUtil.commonContainer(
                                  alignment: Alignment.center,
                                  bgColor: const Color(0xFFEAEEFF),
                                  borerRadius: 20.h,
                                  child: ByWidgetsUtil.commonRichText(
                                    texts: [
                                      const TextSpan(text: "做同款"),
                                      TextSpan(
                                          text: "  ${caseBean.useTime}",
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.normal,
                                            color:
                                                ByColorUtil.TabTextColorSelected
                                                    .withOpacity(0.8),
                                          )),
                                    ],
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    textColor: ByColorUtil.TabTextColorSelected,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // SizedBox(width: 5.w),
                          // Stack(
                          //   clipBehavior: Clip.none,
                          //   children: [
                          //     SizedBox(
                          //       width: 65.w,
                          //       height: 32.h,
                          //       child: ByWidgetsUtil.commonContainer(
                          //         alignment: Alignment.center,
                          //         bgColor: const Color(0xFFF3F5F9),
                          //         borerRadius: 20.h,
                          //         child: ByWidgetsUtil.commonText(
                          //           text: caseBean.withdrawMoney,
                          //           fontSize: 14.sp,
                          //           fontWeight: FontWeight.w600,
                          //           textColor: ByColorUtil.CommonTextColor,
                          //         ),
                          //       ),
                          //     ),
                          //     Positioned(
                          //       right: 0,
                          //       top: -9.h,
                          //       child: ByWidgetsUtil.commonContainer(
                          //         bgColor: const Color(0xFFF49A2F),
                          //         padding: EdgeInsets.symmetric(
                          //             vertical: 2.h, horizontal: 4.w),
                          //         child: ByWidgetsUtil.commonText(
                          //             text: caseBean.withdrawMoneyTip,
                          //             fontSize: 10.sp,
                          //             fontWeight: FontWeight.normal,
                          //             textColor: const Color(0xFFFFFFFF)),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      )
                    ],
                  ),
                  Positioned(
                    right: 8.w,
                    top: 10.h,
                    width: 24.w,
                    height: 24.h,
                    child: Offstage(
                      offstage: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {},
                        child: Image.asset(
                          "assets/ai/ai_case_play.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
