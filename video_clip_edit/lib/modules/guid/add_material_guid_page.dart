import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/modules/guid/voiceover_subtitle_guid_page.dart';

class AddMaterialGuidPage extends StatefulWidget {
  const AddMaterialGuidPage({super.key});

  @override
  State<AddMaterialGuidPage> createState() => _AddMaterialGuidPageState();
}

class _AddMaterialGuidPageState extends State<AddMaterialGuidPage> {
  final List<String> imgs = [
    "assets/guid/1.jpg",
    "assets/guid/2.jpg",
    "assets/guid/3.jpg",
    "assets/guid/4.jpg",
    "assets/guid/5.jpg",
    "assets/guid/6.jpg",
    "assets/guid/7.jpg",
    "assets/guid/8.jpg",
    "assets/guid/9.jpg",
    "assets/guid/10.jpg",
  ];
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ByNavRouterUtils.pushReplacement(
            context, const VoiceoverSubtitleGuidPage());
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: ByWidgetsUtil.appBar(
                context: context, title: "添加素材", leaing: Container()),
            backgroundColor: ByColorUtil.CommonPageBgColor,
            body: Column(
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                  child: ByWidgetsUtil.commonTipsBar("长按可拖动调整视频顺序，最多可添加9个视频。"),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.h,
                      horizontal: 12.w,
                    ),
                    child: _buildGrideView(context),
                  ),
                ),
                Container(height: 66.h),
              ],
            ),
          ),
          Positioned.fill(
              child: Container(
            color: ByColorUtil.BlackColor.withOpacity(0.5),
          )),
          Positioned(
            top: ByScreenUtils.topSafeHeight + 56.h + 48.h + 85.h,
            left: 12.w,
            right: 12.w,
            child: Image.asset(
              "assets/guid/guid_recreate_add_tips_middle.png",
              fit: BoxFit.fitWidth,
            ),
          ),
          ByWidgetsUtil.closeBtnForGuid(
            onTap: () {
              ByNavRouterUtils.goBack(context);
            },
          ),
          Positioned(
            bottom: 10.h,
            left: 17.5,
            right: 12.w,
            child: Image.asset(
              "assets/guid/guid_recreate_add_tips_bottom.png",
              fit: BoxFit.fitWidth,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0.w,
            child: ScaleTransitionWidget(
              child: Image.asset(
                "assets/purchase/icon_pointer.png",
                width: 52.w,
                height: 45.h,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
    );
  }

  /// 推动排序的GrideView
  _buildGrideView(BuildContext context) {
    imgs.shuffle();
    return GridView.builder(
      itemCount: 3,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.w,
        crossAxisSpacing: 10.w,
      ),
      itemBuilder: (ctx, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12.w),
          child: Stack(
            children: [
              Container(),
              Positioned.fill(
                child: Image.asset(
                  imgs[index],
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 10.h,
                child: SizedBox(
                  width: (ByScreenUtils.screenWidth - 24.w) / 2,
                  child: Row(
                    children: [
                      SizedBox(width: 6.w),
                      ByWidgetsUtil.commonText(
                          text: "第${index + 1}集",
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          textColor: ByColorUtil.WhiteColor),
                      const Spacer(),
                      // ByWidgetsUtil.commonText(
                      //     text: "约148小时",
                      //     fontSize: 12,
                      //     textColor: ByColorUtil.WhiteColor),
                      // SizedBox(width: 8.w),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
