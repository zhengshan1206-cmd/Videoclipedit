import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/beans/ai_draw_config_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_provider.dart';

class AiDrawStylesView extends StatelessWidget {
  const AiDrawStylesView({super.key});

  @override
  Widget build(BuildContext context) {
    const crossCount = 3;
    final crossSpacing = 11.w;
    final itemH = 121.h;
    final itemW =
        (ByScreenUtils.screenWidth - 24.w - crossSpacing * (crossCount - 1)) /
            crossCount;

    final types = context.select<AiDrawProvider, List<ImgStyle>>(
        (value) => value.drawConfigBean?.imgStyles ?? []);
    final selectedStyleId =
        context.select<AiDrawProvider, int>((value) => value.selectedStyleId);
    print("selectedStyleId=======> $selectedStyleId");
    return SliverPadding(
      padding: EdgeInsets.only(
        left: 7.w,
        right: 7.w,
        top: 3.h,
        bottom: 12.h + ByScreenUtils.bottomSafeHeight + 66.h,
      ),
      sliver: SliverGrid.builder(
        itemCount: types.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossCount,
          crossAxisSpacing: crossSpacing,
          mainAxisSpacing: 10.h,
          childAspectRatio: itemW / itemH,
        ),
        itemBuilder: (context, index) {
          final type = types[index];
          final selected = type.id == selectedStyleId;
          return GestureDetector(
            onTap: () {
              context.read<AiDrawProvider>().updateSelectedStyleId(type.id);
            },
            child: Column(
              children: [
                Container(
                  height: 100.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.w),
                    border: Border.all(
                      color: selected
                          ? ByColorUtil.TabTextColorSelected
                          : Colors.transparent,
                      width: 2.w,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.w),
                    child: CachedNetworkImage(
                      imageUrl: types[index].url,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Spacer(),
                ByWidgetsUtil.commonText(
                  text: types[index].title,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.normal,
                  textColor: selected
                      ? ByColorUtil.TabTextColorSelected
                      : ByColorUtil.CommonTextColor,
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
