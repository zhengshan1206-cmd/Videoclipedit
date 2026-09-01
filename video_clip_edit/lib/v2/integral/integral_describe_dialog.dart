import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/v2/integral/integral_controller.dart';

class IntegralDescribeDialog extends StatefulWidget {
  const IntegralDescribeDialog({super.key});

  @override
  State<IntegralDescribeDialog> createState() => _IntegralDescribeDialogState();
}

class _IntegralDescribeDialogState extends State<IntegralDescribeDialog>
    with WidgetsBindingObserver {
  final IntegralController controller = IntegralController.getOrPut();

  //标题
  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Padding(
        padding: EdgeInsets.only(top: 20.h, bottom: 30.h),
        child: Row(
          children: [
            SizedBox(width: 18.w, height: 14.h),
            const Spacer(),
            Text(
              "积分说明",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0B1843),
              ),
            ),
            const Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.pop(context);
              },
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
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 20.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTitle(context),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 400.h),
              child: SingleChildScrollView(
                child: Obx(() {
                  final String text = controller.integralIllustrate.value;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF0B1843),
                        height: 1.5,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
