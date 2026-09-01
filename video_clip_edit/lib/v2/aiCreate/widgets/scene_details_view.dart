import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/data/model/folk/story_scene_bean.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/scene_tab_view.dart';

class SceneDetailsView extends StatefulWidget {
  const SceneDetailsView({
    super.key,
    required this.scene,
    this.onRegenerate,
  });

  final StorySceneBean? scene;
  final void Function(StorySceneBean)? onRegenerate;

  @override
  State<SceneDetailsView> createState() => _SceneDetailsViewState();
}

class _SceneDetailsViewState extends State<SceneDetailsView> {
  ///底部描述的内容
  RxInt index = 0.obs;

  @override
  Widget build(BuildContext context) {
    if (widget.scene == null) return const SizedBox();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// tab
        Padding(
          padding: EdgeInsets.only(
            left: 2.w,
            right: 12.w,
            top: 5.h,
            bottom: 10.h,
          ),
          child: Row(
            children: [
              Expanded(
                child: SceneTabView(
                  tabs: const ["对应剧情", "场景描述"],
                  scene: widget.scene!,
                  onTabSelected: (idx, scene) {
                    index.value = idx;
                  },
                ),
              ),
              SizedBox(
                height: 32.h,
                child: ByWidgetsUtil.btnWithIcon(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  borderRadius: 8.w,
                  title: "重新绘制",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  textColor: ByColorUtil.LoginBtnBgColor,
                  bgColor: const Color(0xFFEAEEFF),
                  iconPath: "assets/v2/folk/scene_regenerate.png",
                  iconW: 12.w,
                  iconH: 12.w,
                  onClick: () {
                    widget.onRegenerate?.call(widget.scene!);
                  },
                ),
              ),
            ],
          ),
        ),

        /// 描述详情
        _buildDescDetais(context),
      ],
    );
  }

  _buildDescDetais(BuildContext context) {
    return ByWidgetsUtil.commonContainer(
      bgColor: const Color(0xFFF8FAFB),
      borerRadius: 10.w,
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      padding: EdgeInsets.symmetric(
        vertical: 10.h,
        horizontal: 13.w,
      ),
      child: Obx(() {
        return SizedBox(
          width: double.infinity,
          child: ByWidgetsUtil.commonText(
            fontSize: 14.sp,
            maxLines: 100000,
            text: index.value == 0
                ? widget.scene!.original
                : widget.scene!.prompt,
            fontWeight: FontWeight.normal,
            textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
          ),
        );
      }),
    );
  }
}
