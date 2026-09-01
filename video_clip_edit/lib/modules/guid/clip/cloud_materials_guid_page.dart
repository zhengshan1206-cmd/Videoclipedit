import 'package:flutter/material.dart';
import 'package:video_clip_edit/modules/guid/clip/clip_voiceover_subtitle_guid_page.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class CloudMaterialsGuidPage extends StatefulWidget {
  const CloudMaterialsGuidPage({
    super.key,
  });

  @override
  State<CloudMaterialsGuidPage> createState() => _CloudMaterialsGuidPageState();
}

class _CloudMaterialsGuidPageState extends State<CloudMaterialsGuidPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ByNavRouterUtils.pushReplacement(
          context,
          const ClipVoiceoverSubtitleGuidPage(),
        );
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: ByColorUtil.CommonPageBgColor,
            appBar: _buildAppbar(),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 15.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  Expanded(
                    child: GridView.builder(
                      itemCount: 6,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10.w,
                        crossAxisSpacing: 10.w,
                      ),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12.w),
                          child: Stack(
                            children: [
                              Container(),
                              Positioned.fill(
                                child: Image.asset(
                                  "assets/guid/${index + 1}.jpg",
                                  fit: BoxFit.fitHeight,
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
                                          text: "糖豆人游戏",
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
                    ),
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ),
          Positioned.fill(
              child: Container(
            color: ByColorUtil.BlackColor.withOpacity(0.5),
          )),
          Positioned(
            top: ByScreenUtils.topSafeHeight + 56.h + 130.h,
            left: 10.w,
            right: 10.w,
            child: Image.asset(
              "assets/guid/clip_guid_materials_middle.png",
              fit: BoxFit.fitWidth,
            ),
          ),
          Positioned(
            bottom: 8.h,
            left: 12.w,
            right: 12.w,
            child: Image.asset(
              "assets/guid/clip_guid_materials_bottom.png",
              fit: BoxFit.fitWidth,
            ),
          ),
          ByWidgetsUtil.closeBtnForGuid(
            onTap: () {
              ByNavRouterUtils.goBack(context);
            },
          ),
        ],
      ),
    );
  }

  AppBar _buildAppbar() {
    return AppBar(
      title: const Text(
        "云端素材",
        style: TextStyle(
          color: ByColorUtil.CommonTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
