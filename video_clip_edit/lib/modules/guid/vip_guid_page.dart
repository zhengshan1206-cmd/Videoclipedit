import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';

class VipGuidPage extends StatefulWidget {
  const VipGuidPage({super.key});

  @override
  State<VipGuidPage> createState() => _VipGuidPageState();
}

class _VipGuidPageState extends State<VipGuidPage> {
  @override
  void initState() {
    _initTimer();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(),
          Positioned.fill(
            child: Image.asset(
              "assets/guid/vip_guid_bg.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 18.w,
            right: 18.w,
            top: 400.h,
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
                  "assets/guid/vip_guid_btn.png",
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
          Positioned(
            top: ByScreenUtils.topSafeHeight,
            left: 0.w,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                ByNavRouterUtils.goBack(context);
              },
              child: const SizedBox(
                width: 56,
                height: 56,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _initTimer() {
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        context.read<LaunchProvider>().gotoPay(
              context,
              closePay: true,
              replace: true,
            );
      }
    });
  }
}
