import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/home/providers/stroy_create_provider.dart';

class StoryHomeTitleView extends StatelessWidget {
  const StoryHomeTitleView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StroyCreateProvider>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _createTabItem(provider, 0),
        _createTabItem(provider, 1),
      ],
    );
  }

  GestureDetector _createTabItem(StroyCreateProvider provider, int index) {
    final titles = ["创作", "助手"];
    return GestureDetector(
      onTap: () {
        if (provider.selectedTabIndex == index) return;
        provider.updateSelectedTabIndex(index);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 13.w),
        child: ByWidgetsUtil.commonText(
          text: titles[index],
          fontWeight: FontWeight.bold,
          fontSize: 18.sp,
          textColor: provider.selectedTabIndex == index
              ? ByColorUtil.TabTextColorSelected
              : ByColorUtil.CommonTextColor,
        ),
      ),
    );
  }
}
