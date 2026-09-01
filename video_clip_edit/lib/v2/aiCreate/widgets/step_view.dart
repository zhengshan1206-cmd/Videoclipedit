import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

enum StepType {
  /// 故事写作
  writting(0),

  /// 角色绘制
  // rolesDrawing(1),

  /// 分镜绘制jing
  sceneDrawing(1),

  /// 视频生成
  videoGenerate(2);

  const StepType(
    this.rawValue,
  );

  final int rawValue;

  String get title {
    switch (this) {
      case StepType.writting:
        return "故事写作";
      // case StepType.rolesDrawing:
        // return "角色绘制";
      case StepType.sceneDrawing:
        return "分镜绘制";
      case StepType.videoGenerate:
        return "视频生成";
    }
  }

  static StepType fromRawValue(int rawValue) {
    for (var element in StepType.values) {
      if (element.rawValue == rawValue) {
        return element;
      }
    }
    return StepType.writting;
  }
}

class StepView extends StatelessWidget {
  const StepView({
    super.key,
    required this.currentStep,
  });

  final StepType currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildStepItems(context),
    );
  }

  List<Widget> _buildStepItems(BuildContext context) {
    final List<Widget> res = [];
    List<Widget> items = StepType.values.map(
      (step) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 44.w,
              height: 44.w,
              child: ByWidgetsUtil.commonContainer(
                borerRadius: 100,
                bgColor: step.rawValue <= currentStep.rawValue
                    ? const Color(0xFFEAEEFF)
                    : const Color(0xFFF4F8F9),
                padding: EdgeInsets.all(6.w),
                alignment: Alignment.center,
                child: ByWidgetsUtil.commonContainer(
                  bgColor: step.rawValue <= currentStep.rawValue
                      ? ByColorUtil.LoginBtnBgColor
                      : const Color(0xFF81899F),
                  padding: EdgeInsets.all(6.w),
                  borerRadius: 100,
                  alignment: Alignment.center,
                  child: Image.asset(
                    "assets/v2/folk/step_icon_${step.rawValue}.png",
                    width: 20.w,
                    height: 20.w,
                  ),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            ByWidgetsUtil.commonText(
              text: step.title,
              fontSize: 12.sp,
              textColor: step.rawValue <= currentStep.rawValue
                  ? ByColorUtil.LoginBtnBgColor
                  : ByColorUtil.CommonTextColor,
            )
          ],
        );
      },
    ).toList();

    res.addAll(items);

    for (var element in StepType.values.reversed) {
      if (element.rawValue > 0) {
        final undo = element.rawValue > currentStep.rawValue;
        res.insert(
          element.rawValue,
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  height: 44.w,
                  width: 70.w,
                  child: Image.asset(
                    "assets/v2/folk/step_arrow_${undo ? "undo" : "finished"}.png",
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return res;
  }
}
