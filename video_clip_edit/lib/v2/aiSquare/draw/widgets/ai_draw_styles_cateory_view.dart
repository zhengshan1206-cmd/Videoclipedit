import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_provider.dart';

class AiDrawStylesCateoryView extends StatelessWidget {
  const AiDrawStylesCateoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final ratios = context.read<AiDrawProvider>().styleCategory;
    final selectedIndex = context.select<AiDrawProvider, int>(
        (value) => value.selectedStyleCategoryIndex);
    return SliverPadding(
      padding: EdgeInsets.only(left: 7.w, right: 7.w, bottom: 10.h, top: 3.h),
      sliver: SliverToBoxAdapter(
        child: SizedBox(
          height: 32.h,
          width: double.infinity,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: ratios.length,
            itemBuilder: (BuildContext context, int index) {
              final selected = index == selectedIndex;
              return GestureDetector(
                onTap: () {
                  context
                      .read<AiDrawProvider>()
                      .updateSelectedStyleCategoryIndex(index);
                },
                child: Container(
                  margin: EdgeInsets.only(right: 10.w),
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFEBEDFF)
                        : const Color(0xFFF8FAFB),
                    borderRadius: BorderRadius.circular(20.w),
                  ),
                  child: ByWidgetsUtil.commonText(
                    text: ratios[index],
                    textColor: selected
                        ? ByColorUtil.TabTextColorSelected
                        : ByColorUtil.CommonTextColor,
                    fontSize: 12.sp,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
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
