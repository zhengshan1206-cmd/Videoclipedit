import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/modules/home/widgets/marquee_view.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_cases_view.dart';
import 'package:video_clip_edit/modules/home/beans/home_broadcast_bean.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/short_play_create_provider.dart';
import 'package:video_clip_edit/v2/promote/widgets/search_view.dart';

class ShortPlaySliverPinnedHeaderView extends StatelessWidget {
  const ShortPlaySliverPinnedHeaderView({
    super.key,
    this.type = "2",
  });

  final String type;

  @override
  Widget build(BuildContext context) {
    final List<HomeBroadcastBean> broadcastBeans =
        context.select<ShortPlayCreateProvider, List<HomeBroadcastBean>>(
      (val) => val.broadcastBeans,
    );

    final topPaddingH = ByScreenUtils.navigationBarHeight;

    final broadcastPaddingTop = 0.h;
    final broadcastH = broadcastBeans.isEmpty ? 0 : 32.h + broadcastPaddingTop;

    // final categoryH = 36.h;
    final categoryH = 60.h;

    final minH = topPaddingH + categoryH;
    final maxH = categoryH + broadcastH + topPaddingH;
    double offset = context.select<ShortPlayCreateProvider, double>(
      (value) => value.currentOffset,
    );
    // double opacity = offset / broadcastH;
    double opacity = broadcastH > 0 ? offset / broadcastH : 1;
    if (opacity >= 1) opacity = 0.99;
    if (opacity <= 0) opacity = 0.01;
    return SliverPersistentHeader(
      pinned: true,
      delegate: StickyHeaderDelegate(
        minHeight: minH,
        maxHeight: maxH,
        child: Stack(
          children: [
            SizedBox(
              height: maxH,
              width: double.infinity,
            ),
            Positioned.fill(
              // child: Container(color: Colors.white.withOpacity(opacity)),
              child: Container(
                color: const Color(0xFFF4F7F8),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildNotice(context,
                        broadcastBeans: broadcastBeans,
                        paddingTop: broadcastPaddingTop),
                    // Container(
                    //   height: categoryH,
                    //   padding: EdgeInsets.only(
                    //     bottom: 7.h,
                    //     top: 9.h,
                    //     left: 12.w,
                    //     right: 12.w,
                    //   ),
                    //   child: Row(
                    //     children: [
                    //       Image.asset(
                    //         "assets/ai/hot/icon_short_play.png",
                    //         width: 20.w,
                    //         height: 20.h,
                    //         fit: BoxFit.contain,
                    //       ),
                    //       SizedBox(width: 4.w),
                    //       ByWidgetsUtil.commonText(
                    //         text: type == "3" ? "漫剧" : "热门短剧",
                    //         fontSize: 16.sp,
                    //         fontWeight: FontWeight.bold,
                    //         textColor: ByColorUtil.CommonTextColor,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    SizedBox(
                      height: categoryH,
                      width: double.infinity,
                      child: SearchView(
                        shortPlayProvider:
                            context.read<ShortPlayCreateProvider>(),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNotice(
    BuildContext context, {
    required List<HomeBroadcastBean> broadcastBeans,
    required double paddingTop,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: paddingTop,
      ),
      child: MarqueeView(broadcastBeans: broadcastBeans),
    );
  }
}
