import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_provider.dart';

class AiDrawRationsView extends StatelessWidget {
  const AiDrawRationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ratios =
        context.select<AiDrawProvider, List<String>>((p) => p.ratios);
    int selectedIndex = context
        .select<AiDrawProvider, int>((value) => value.selectedRatioIndex);
    final ratio = context.read<AiDrawProvider>().ratio;
    if (ratio != null) {
      selectedIndex = ratios.indexOf(ratio);
    }
    final maxWH = 30.w;

    getWidthAndHeightByRatio(String ratio) {
      switch (ratio) {
        case "1:1":
          return [maxWH, maxWH];
        case "1:2":
          return [maxWH * 0.5, maxWH];
        case "9:16":
          return [maxWH * 9 / 16, maxWH];
        case "16:9":
          return [maxWH, maxWH * 9 / 16];
        case "3:4":
          return [maxWH * 0.75, maxWH];
        case "4:3":
          return [maxWH, maxWH * 0.75];

        default:
          return [maxWH, maxWH];
      }
    }

    return SliverPadding(
      padding: EdgeInsets.only(left: 7.w, right: 7.w, bottom: 20.h, top: 3.h),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: ratios.map((e) {
            final index = ratios.indexOf(e);
            final selected = selectedIndex == index;
            final List<double> wh = getWidthAndHeightByRatio(e);
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  context
                      .read<AiDrawProvider>()
                      .updateSelectedRatioIndex(index);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFEBEDFF)
                        : const Color(0xFFF8FAFB),
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: maxWH,
                        height: maxWH,
                        alignment: Alignment.center,
                        child: Container(
                          width: wh[0],
                          height: wh[1],
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF5B4BF7)
                                : const Color(0xFF0E1840).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.w),
                          ),
                        ),
                      ),
                      SizedBox(height: 9.h),
                      ByWidgetsUtil.commonText(
                        text: e,
                        textColor: selected
                            ? ByColorUtil.TabTextColorSelected
                            : ByColorUtil.CommonTextColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.normal,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
