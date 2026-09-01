import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/purchase/rotate_transition_widget.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/providers/ai_vip_guid_provider.dart';

class AiVipGuidPage extends StatefulWidget {
  const AiVipGuidPage({
    super.key,
  });

  @override
  State<AiVipGuidPage> createState() => _AiVipGuidPageState();
}

class _AiVipGuidPageState extends State<AiVipGuidPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 11), () {
      context.read<LaunchProvider>().gotoPay(
            context,
            closePay: true,
            replace: true,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasksDisplay =
        context.select<AiVipGuidProvider, List<AiVipGuidTaskBean>>(
      (value) => value.tasksDisplay,
    );
    return Scaffold(
      body: Stack(
        children: [
          Container(),
          Positioned.fill(
            child: Image.asset(
              "assets/ai/ai_vip_guid_bg.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 11,
            top: ByScreenUtils.topSafeHeight + (kToolbarHeight - 32) * 0.5,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                ByNavRouterUtils.goBack(context);
              },
              child: Image.asset(
                "assets/ai/ai_vip_guid_back.png",
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              children: [
                SizedBox(height: 100.h),
                Image.asset(
                  "assets/ai/ai_vip_guid.gif",
                  width: 101,
                  height: 110,
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasksDisplay.length,
                    itemBuilder: (context, index) {
                      final task = tasksDisplay[index];
                      final inprogress = task.staus == 0;
                      return Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: ByColorUtil.CommonTextColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 5.h,
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: 45.w,
                          vertical: 5.h,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ByWidgetsUtil.commonText(
                                text: inprogress
                                    ? task.taskName
                                    : task.taskNameFinished,
                                textColor: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 10),
                            inprogress
                                ? RotateTransitionWidget(
                                    child: Image.asset(
                                      "assets/ai/ai_vip_guid_loading.png",
                                      width: 16,
                                      height: 16,
                                    ),
                                  )
                                : Image.asset(
                                    "assets/ai/ai_vip_guid_finished.png",
                                    width: 16,
                                    height: 16,
                                  ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Image.asset(
                    "assets/ai/ai_vip_guid_bg_bottom.png",
                    fit: BoxFit.fitWidth,
                  ),
                ),
                Positioned(
                  child: Stack(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          context.read<LaunchProvider>().gotoPay(
                                context,
                                closePay: true,
                                replace: true,
                              );
                        },
                        child: Image.asset(
                          "assets/ai/ai_vip_guid_unlock.png",
                          width: 302,
                          height: 97,
                        ),
                      ),
                      Positioned(
                        top: 33,
                        right: 41,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            context.read<LaunchProvider>().gotoPay(
                                  context,
                                  closePay: true,
                                  replace: true,
                                );
                          },
                          child: ScaleTransitionWidget(
                            child: Image.asset(
                              "assets/purchase/icon_pointer.png",
                              width: 52,
                              height: 45,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
