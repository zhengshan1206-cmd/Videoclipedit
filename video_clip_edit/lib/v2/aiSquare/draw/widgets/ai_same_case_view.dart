import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/ai_same_style_cases_page.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/beans/ai_draw_style_case_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_provider.dart';

class AiSameCaseView extends StatelessWidget {
  const AiSameCaseView({super.key});

  @override
  Widget build(BuildContext context) {
    final cases = context.select<AiDrawProvider, List<AiDrawStyleCaseBean>>(
        (value) => value.styleCases);
    // final selectedId =
    //     context.select<AiDrawProvider, int>((value) => value.selectedCaseId);
    return SliverPadding(
      padding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 19.h),
      sliver: SliverToBoxAdapter(
        child: SizedBox(
          height: 100.h,
          child: ListView.builder(
            itemCount: cases.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final caseI = cases[index];
              // final selected = caseI.id == selectedId;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  final provider = context.read<AiDrawProvider>();

                  /// 更新
                  provider.updateSelectedCaseId(caseI.id);
                  FocusScope.of(context).unfocus();
                  ByNavRouterUtils.push(
                    context,
                    ChangeNotifierProvider.value(
                      value: provider,
                      child: const AiSameStyleCasesPage(),
                    ),
                  );
                  // final modelId = caseI.modelId;
                  // provider.updateSelectedStyleId(modelId);

                  // final ratio = caseI.ratio;
                  // final ratioIndex = provider.ratios.indexOf(ratio);
                  // provider.updateSelectedRatioIndex(ratioIndex);

                  // final prompt = caseI.prompt;
                  // provider.updateDesc(prompt);
                },
                child: Container(
                  width: 80.w,
                  margin: EdgeInsets.only(right: 8.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.w),
                    child: Stack(
                      children: [
                        Container(),
                        Positioned.fill(
                          child: CachedNetworkImage(
                            imageUrl: caseI.picUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Positioned(
                        //   top: 0,
                        //   right: 0,
                        //   child: Offstage(
                        //     offstage: !selected,
                        //     child: Image.asset(
                        //       "assets/ai/ai_case_selected.png",
                        //       width: 30.w,
                        //       height: 30.w,
                        //       fit: BoxFit.contain,
                        //     ),
                        //   ),
                        // ),
                        // Positioned.fill(
                        //   child: Offstage(
                        //     offstage: !selected,
                        //     child: Container(
                        //       decoration: BoxDecoration(
                        //         borderRadius: BorderRadius.circular(12.w),
                        //         border: Border.all(
                        //           color: ByColorUtil.TabTextColorSelected,
                        //           width: 2.w,
                        //         ),
                        //         color: const Color(0xFF020C2A).withOpacity(0.3),
                        //       ),
                        //     ),
                        //   ),
                        // )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
