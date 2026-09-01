import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/home/widgets/banner_view.dart';
import 'package:video_clip_edit/modules/home/words/words_extraction_tasks_page.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';

class WatermarkErasePage extends StatelessWidget {
  const WatermarkErasePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hotAuthList = [];
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: Stack(
        children: [
          _buildBanner(context),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: 189.h)),

              /// 热门授权
              SliverList.builder(
                itemCount: hotAuthList.length + 1,
                itemBuilder: (context, index) {
                  if (index < hotAuthList.length) {
                    final auth = hotAuthList[index];
                    return GestureDetector(
                      onTap: () {
                        // if (auth.dramaName == "短视频链接") {
                        //   showDialog(
                        //     context: context,
                        //     useSafeArea: false,
                        //     barrierDismissible: true,
                        //     builder: (context) {
                        //       return ShortVideoLinkView();
                        //     },
                        //   );
                        // } else {
                        //   EasyLoading.show();
                        // }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.w, vertical: 28.h),
                        margin: EdgeInsets.only(
                          bottom: 8.h,
                          left: 12.w,
                          right: 12.w,
                        ),
                        decoration: BoxDecoration(
                          color: ByColorUtil.WhiteColor,
                          borderRadius: BorderRadius.circular(16.w),
                          border: Border.all(
                            color: ByColorUtil.MainTextColor.withOpacity(0.05),
                          ),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16.w),
                              child: SizedBox(
                                width: 44.w,
                                height: 44.w,
                                child: Image.asset(
                                  auth.coverUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 24.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    auth.dramaName,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: const Color(0xFF0E1840),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  Text(
                                    auth.describe,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: const Color(0xFF0E1840),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Image.asset(
                              "assets/home/arrow_right_bold.png",
                              width: 16.w,
                              height: 16.w,
                            )
                          ],
                        ),
                      ),
                    );
                  }

                  /// 最后一个现实最近任务
                  return GestureDetector(
                    onTap: () {
                      ByNavRouterUtils.push(
                        context,
                        const WordsExtractionTasksPage(),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 15.h),
                      margin: EdgeInsets.only(
                        bottom: 8.h,
                        left: 12.w,
                        right: 12.w,
                      ),
                      decoration: BoxDecoration(
                        color: ByColorUtil.WhiteColor,
                        borderRadius: BorderRadius.circular(16.w),
                        border: Border.all(
                          color: ByColorUtil.MainTextColor.withOpacity(0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "最近任务",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF0E1840),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "7个",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF0E1840),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Image.asset(
                            "assets/mine/arrow_right.png",
                            width: 8.w,
                            height: 13.w,
                          )
                        ],
                      ),
                    ),
                  );
                },
              )
            ],
          ),
          Positioned(child: _buildAppBar(context)),
        ],
      ),
    );
  }

  _buildBanner(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      width: MediaQuery.of(context).size.width,
      height: 200.h,
      child: BannerView(
        urls: const ["assets/home/banner.png"],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      height: statusBarHeight + 44,
      padding: EdgeInsets.only(left: 12.w, right: 12.w, top: statusBarHeight),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ByNavRouterUtils.goBack(context);
            },
            child: Container(
              width: 44.w,
              height: 44,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 5.w),
              child: Image.asset(
                "assets/home/icon_back.png",
                width: 16,
                height: 16,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: Image.asset(
              "assets/home/home_vip.png",
              width: 30.w,
              height: 30.w,
            ),
          )
        ],
      ),
    );
  }
}
