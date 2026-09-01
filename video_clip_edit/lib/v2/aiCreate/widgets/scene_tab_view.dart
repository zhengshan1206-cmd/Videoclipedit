import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/data/model/folk/story_scene_bean.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class SceneTabView extends StatefulWidget {
  const SceneTabView({
    super.key,
    required this.tabs,
    required this.scene,
    this.initialIndex = 0,
    required this.onTabSelected,
  });

  final void Function(int, StorySceneBean)? onTabSelected;
  final int initialIndex;
  final List<String> tabs;
  final StorySceneBean scene;

  @override
  State<SceneTabView> createState() => _SceneTabViewState();
}

class _SceneTabViewState extends State<SceneTabView> {
  late RxInt selectedIndex = widget.initialIndex.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          Row(
            children: widget.tabs.map((e) {
              final index = widget.tabs.indexOf(e);
              final selected = selectedIndex.value == index;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  selectedIndex.value = index;
                  widget.onTabSelected?.call(index, widget.scene);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ByWidgetsUtil.commonText(
                        text: e,
                        textColor: selected
                            ? ByColorUtil.LoginBtnBgColor
                            : ByColorUtil.CommonTextColor,
                        fontSize: 14.sp,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.bold,
                      ),
                      SizedBox(height: 1.h),
                      SizedBox(
                        width: 15.w,
                        height: 3.h,
                        child: ByWidgetsUtil.commonContainer(
                          borerRadius: 3,
                          bgColor: selected
                              ? ByColorUtil.LoginBtnBgColor
                              : Colors.transparent,
                          child: const SizedBox.shrink(),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    });
  }
}
