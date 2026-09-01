import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class VideosExtractionDetailsPage extends StatelessWidget {
  const VideosExtractionDetailsPage({
    super.key,
    required this.videoFilePath,
  });

  final String videoFilePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(context: context, title: "视频提取"),
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
          Container(
            height: 64.h,
            color: ByColorUtil.WhiteColor,
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 10.h,
            ),
            child: Row(
              children: [
                Expanded(
                  child: ByWidgetsUtil.commonBtn(
                    title: "视频去重",
                    fontSize: 14.sp,
                    borderRadius: 10.w,
                    fontWeight: FontWeight.normal,
                    textColor: ByColorUtil.TabTextColorSelected,
                    bgColor: const Color(0xFF3753FF).withOpacity(0.1),
                    onClick: () {},
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ByWidgetsUtil.commonBtn(
                    title: "视频二创",
                    fontSize: 14.sp,
                    borderRadius: 10.w,
                    fontWeight: FontWeight.normal,
                    textColor: ByColorUtil.TabTextColorSelected,
                    bgColor: const Color(0xFF3753FF).withOpacity(0.1),
                    onClick: () {},
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: ByColorUtil.WhiteColor,
            padding: EdgeInsets.only(
              left: 12.w,
              right: 12.w,
              bottom: 8.h + ByScreenUtils.bottomSafeHeight,
            ),
            child: ByWidgetsUtil.commonBtn(
              title: "保存到相册",
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
