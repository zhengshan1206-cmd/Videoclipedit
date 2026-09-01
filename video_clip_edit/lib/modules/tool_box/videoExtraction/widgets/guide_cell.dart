import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_datetime_ext.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/tool_box/beans/video_tutor_bean.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/video_player_page.dart';

class GuideCell extends StatelessWidget {
  const GuideCell({
    super.key,
    required this.hideSeporator,
    required this.bean,
    required this.index,
  });
  final bool hideSeporator;
  final VideoTutorBean bean;
  final int index;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ByColorUtil.WhiteColor,
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 20.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 30.w,
                height: 30.w,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: bean.avatar,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 5.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ByWidgetsUtil.commonText(
                      text: bean.nickname,
                      fontSize: 12.sp,
                    ),
                    SizedBox(height: 3.h),
                    ByWidgetsUtil.commonText(
                        text: bean.createTime.formattedTime(),
                        fontSize: 10.sp,
                        textColor:
                            ByColorUtil.CommonTextColor.withOpacity(0.6)),
                    SizedBox(height: 14.h),
                    ByWidgetsUtil.commonText(
                      text: bean.content,
                      maxLines: 2,
                    ),
                    SizedBox(height: 9.h),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                            ) =>
                                VideoPlayerPage(
                              bean: bean,
                              index: index,
                            ),
                            transitionDuration:
                                const Duration(milliseconds: 150),
                            reverseTransitionDuration:
                                const Duration(milliseconds: 150),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              var begin = 0.8;
                              var end = 1.0;
                              var curve = Curves.easeInOut;
                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));

                              return FadeTransition(
                                opacity: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: Hero(
                        tag: "${bean.id}_${index}",
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.w),
                          child: CachedNetworkImage(
                            imageUrl: bean.videoCover,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15.h),
                  ],
                ),
              )
            ],
          ),
          Offstage(
            offstage: hideSeporator,
            child: Container(color: const Color(0xFFF8F8F8), height: 1),
          )
        ],
      ),
    );
  }
}
