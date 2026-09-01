import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/modules/home/recreate/beans/step_bean.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

List<StepBean> stepBeans = [
  StepBean.fromJson({"title": "素材解析", "step": 1}),
  StepBean.fromJson({"title": "角色台词", "step": 2}),
  StepBean.fromJson({"title": "配置解说", "step": 3}),
  StepBean.fromJson({"title": "二创设置", "step": 4}),
];

class StepView<T extends MaterialBaseProvider> extends StatelessWidget {
  final int step;
  const StepView({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.h),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _buildChildren(),
      ),
    );
  }

  _buildChildren() {
    List<Widget> children = [];
    for (var e in stepBeans) {
      final idx = stepBeans.indexOf(e);
      final isCurrent = idx == step;
      final child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 13.w,
            height: 13.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCurrent
                  ? ByColorUtil.TabTextColorSelected
                  : ByColorUtil.CommonTextColor.withOpacity(0.6),
              borderRadius: BorderRadius.circular(100),
            ),
            child: ByWidgetsUtil.commonText(
              text: "${idx + 1}",
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              textColor: ByColorUtil.WhiteColor,
            ),
          ),
          SizedBox(width: 5.w),
          ByWidgetsUtil.commonText(
            text: e.title,
            fontSize: 10.sp,
            textColor: isCurrent
                ? ByColorUtil.TabTextColorSelected
                : ByColorUtil.CommonTextColor,
          ),
        ],
      );

      children.add(child);
      if (idx < stepBeans.length - 1) {
        children.add(Expanded(
            child: Container(
          height: .5,
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          color: ByColorUtil.CommonTextColor.withOpacity(0.3),
        )));
      }
    }
    return children;
  }
}
