

import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class AnimeNoIntergralDialog extends StatelessWidget {
  const AnimeNoIntergralDialog({super.key, this.action});

  final Function()? action;

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Container(
        height: 494.w,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/v2/anime/anime_no_intergral_bg.png'))
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ByWidgetsUtil.commonText(
              text: '获取积分',
              textColor: ByColorUtil.BlackColor,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 6,),
            ByWidgetsUtil.commonText(
              text: '生成同款视频',
              textColor: ByColorUtil.BlackColor.withOpacity(0.7),
              fontSize: 18.sp,
            ),
            const SizedBox(height: 20,),
            GestureDetector(
              onTap: () {
                Get.back();
                action?.call();
              },
              child: SizedBox(
                height: 52.w,
                child: Image.asset('assets/v2/anime/anime_no_intergral_btn.png'),
              ),
            ),
            SizedBox(height: 32.w,),
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Image.asset(
                'assets/v2/anime/anime_btn_close.png',
                width: 40.w,
                height: 40.w,),
              ),
            SizedBox(height: 33.w,),
          ],
        ),
      ),
    );
  }
}