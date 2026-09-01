import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/home/story/assistant/beans/creator_bean.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

typedef AssistantItemCellOntapCallback = void Function(CreatorBean bean);

class AssistantItemCell extends StatelessWidget {
  const AssistantItemCell({
    super.key,
    required this.bean,
    required this.index,
    required this.callback,
  });

  final int index;
  final CreatorBean bean;
  final AssistantItemCellOntapCallback callback;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        callback(bean);
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/home/bg_assistant_${index % 4 + 1}.png"),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),
              ByWidgetsUtil.commonText(
                fontSize: 16.sp,
                text: bean.title,
                fontWeight: FontWeight.bold,
                textColor: ByColorUtil.WhiteColor,
              ),
              SizedBox(height: 5.h),
              ByWidgetsUtil.commonText(
                fontSize: 12.sp,
                text:
                    "热度值：${bean.hotNum > 10000 ? "${(bean.hotNum / 10000).toStringAsFixed(2)}w" : bean.hotNum}",
                textColor: ByColorUtil.WhiteColor,
              ),
              SizedBox(height: 5.h),
              Image.asset(
                "assets/home/icon_assistant_more.png",
                width: 20.w,
                height: 20.h,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
