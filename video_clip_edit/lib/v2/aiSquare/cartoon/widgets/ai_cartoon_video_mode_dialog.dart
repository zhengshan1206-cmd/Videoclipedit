import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_screen_config_page.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_video_management_page.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_video_management_provider.dart';

class AiCartoonVideoModeDialog extends StatelessWidget {
  const AiCartoonVideoModeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    byDebugPrint("AiCartoonVideoModeDialog_build");
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: ByColorUtil.WhiteColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.w),
                topRight: Radius.circular(18.w),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20.h),
                _buildTitle(context),
                SizedBox(height: 15.h),
                _buildModes(context),
                SizedBox(height: 25.h),
                Container(
                  padding: EdgeInsets.only(
                    left: 12.w,
                    right: 12.w,
                    bottom: 8.h,
                  ),
                  height: 50.h,
                  child: ByWidgetsUtil.commonBtn(
                    title: "下一步",
                    fontSize: 16.sp,
                    borderRadius: 12.w,
                    padding: EdgeInsets.zero,
                    fontWeight: FontWeight.w500,
                    textColor: ByColorUtil.WhiteColor,
                    onClick: () {
                      context.read<AiCartoonProvider>().saveArticleSplits(
                        onSuccess: () {
                          ByNavRouterUtils.goBack(context);
                          final provider = context.read<AiCartoonProvider>();
                          if (provider.selectedVideoModeIndex == 0) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext ctx) => MultiProvider(
                                  providers: [
                                    ChangeNotifierProvider(
                                        create: (context) =>
                                            AiCartoonVideoManagementProvider()),
                                  ],
                                  child: AiCartoonVideoManagementPage(
                                    source: provider.entranceSource,
                                    type:
                                        AiCartoonVideoManagementPageType.normal,
                                  ),
                                ),
                              ),
                              (route) => route.isFirst,
                            );
                          } else {
                            ByNavRouterUtils.push(
                              context,
                              ChangeNotifierProvider.value(
                                value: provider,
                                child: const AiCartoonScreenConfigPage(),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  _buildTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          SizedBox(
            width: 18.w,
            height: 14.h,
          ),
          const Spacer(),
          ByWidgetsUtil.commonText(
            text: "选择模式",
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              width: 32.w,
              height: 32.w,
              // color: Colors.red,
              child: Center(
                child: SizedBox(
                  width: 18.w,
                  height: 14.h,
                  child: Image.asset(
                    "assets/home/icon_close_dark.png",
                    width: 14.w,
                    height: 14.h,
                    fit: BoxFit.contain,
                  ),
                ),
              )
            ),
          )
        ],
      ),
    );
  }

  _buildModes(BuildContext context) {
    final modeBeans = context.read<AiCartoonProvider>().modeBeans;
    return ListView.builder(
      itemCount: modeBeans.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      itemBuilder: (context, index) {
        return AiCartoonVideoModeCell(index: index);
      },
    );
  }
}

class AiCartoonVideoModeCell extends StatelessWidget {
  const AiCartoonVideoModeCell({
    super.key,
    required this.index,
  });

  final int index;

  @override
  Widget build(BuildContext context) {
    byDebugPrint("AiCartoonVideoModeCell_build");
    final provider = context.read<AiCartoonProvider>();
    final modeBeans = provider.modeBeans;
    final selectedVideoModeIndex = context.select<AiCartoonProvider, int>(
      (p) => p.selectedVideoModeIndex,
    );
    final currentMode = modeBeans[index];
    final selected = selectedVideoModeIndex == index;
    final selectedColor = ByColorUtil.hexToColor(currentMode.selectedColor);
    return GestureDetector(
      onTap: () {
        provider.updateSelectedVideoModeIndex(index);
      },
      child: Stack(
        children: [
          ByWidgetsUtil.commonContainer(
            alignment: Alignment.center,
            borerRadius: 12.w,
            margin: EdgeInsets.symmetric(vertical: 5.h),
            padding: EdgeInsets.only(
              left: 12.w,
              bottom: 14.h,
              right: 9.w,
              top: 11.h,
            ),
            border: Border.all(
              width: 2.w,
              color: selected ? selectedColor : const Color(0xFFF3F5F9),
            ),
            bgColor: ByColorUtil.CommonPageBgColor,
            child: Column(
              children: [
                Row(
                  children: [
                    ByWidgetsUtil.commonText(
                      text: currentMode.title,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(width: 6.w),
                    SizedBox(
                      height: 24.h,
                      child: ByWidgetsUtil.commonContainer(
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(horizontal: 7.w, vertical: 0),
                        bgColor: selectedColor,
                        child: ByWidgetsUtil.commonText(
                          fontSize: 12.sp,
                          text: currentMode.tag,
                          textColor: ByColorUtil.WhiteColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 12.h),
                ByWidgetsUtil.commonText(
                  text: currentMode.desc,
                  maxLines: 100,
                  fontSize: 14.sp,
                  textColor: ByColorUtil.CommonTextColor.withOpacity(0.6),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 5.h,
            child: Offstage(
              offstage: !selected,
              child: Image.asset(
                currentMode.selectedIcon,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
