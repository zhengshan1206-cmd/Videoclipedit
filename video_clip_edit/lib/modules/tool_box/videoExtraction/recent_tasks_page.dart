import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class RecentTasksPage extends StatelessWidget {
  const RecentTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(context: context, title: "最近任务"),
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Column(
        children: [
          SizedBox(height: 44.h),
          Expanded(
            child: CarouselSlider(
                items: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12.w)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12.w)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12.w)),
                  ),
                ],
                options: CarouselOptions(
                  height: double.infinity,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.8,
                  initialPage: 0,
                  enableInfiniteScroll: false,
                  reverse: false,
                  autoPlay: false,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.3,
                  onPageChanged: (index, reason) {},
                  scrollDirection: Axis.horizontal,
                )),
          ),
          SizedBox(height: 44.h),
          Container(
            color: ByColorUtil.WhiteColor,
            padding: EdgeInsets.only(
              left: 12.w,
              right: 12.w,
              top: 10.h,
              bottom: 8.h + ByScreenUtils.bottomSafeHeight,
            ),
            child: ByWidgetsUtil.commonBtn(
              title: "全部保存到相册(20)",
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              onClick: () {},
            ),
          )
        ],
      ),
    );
  }
}
