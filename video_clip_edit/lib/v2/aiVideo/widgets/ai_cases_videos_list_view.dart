import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_video_player.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../../utils/comon/by_nav_router_utils.dart';
import '../pages/ai_videos_same_case_page.dart';
import '../models/ai_video_square_model.dart';

class AiCasesVideosListView extends StatelessWidget {
  const AiCasesVideosListView({
    super.key,
    this.prePagePath = "",
  });

  final String prePagePath;

  @override
  Widget build(BuildContext context) {
    final beans = context.select<AiSquareProvider, List<AiVideoSquareModel>>(
      (p) => p.videosBeans,
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
              _doSameCase(caseBean, context);
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
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.w),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: 50.0.h,
                              ),
                              child: CachedNetworkImage(
                                imageUrl: caseBean.coverUrl,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 8.w,
                            top: 10.h,
                            child: Image.asset(
                              "assets/ai/ai_case_play.png",
                              fit: BoxFit.contain,
                              width: 24.w,
                              height: 24.h,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      if (caseBean.prompt != null)
                        Padding(
                          padding: EdgeInsets.only(
                              left: 5.w, right: 0, bottom: 10.h),
                          child: ByWidgetsUtil.commonText(
                            text: caseBean.prompt!,
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
                                _doSameCase(caseBean, context);
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
                          SizedBox(width: 5.w),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              SizedBox(
                                width: 65.w,
                                height: 32.h,
                                child: ByWidgetsUtil.commonContainer(
                                  alignment: Alignment.center,
                                  bgColor: const Color(0xFFF3F5F9),
                                  borerRadius: 20.h,
                                  child: ByWidgetsUtil.commonText(
                                    text: caseBean.withdrawMoney,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    textColor: ByColorUtil.CommonTextColor,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: -9.h,
                                child: ByWidgetsUtil.commonContainer(
                                  bgColor: const Color(0xFFF49A2F),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 2.h, horizontal: 4.w),
                                  child: ByWidgetsUtil.commonText(
                                      text: caseBean.withdrawMoneyTip,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.normal,
                                      textColor: const Color(0xFFFFFFFF)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  ///做同款的点击事件
  void _doSameCase(AiVideoSquareModel caseBean, BuildContext context) {
    ByNavigatorUtil.checkLogin(context: context, nextStepEvent: (){
      ByNavRouterUtils.push(
          context,
          AiVideosSameCasePage(
            caseBean: caseBean,
            preview: false,
            prePagePath: prePagePath,
          ));
    });
  }
}
