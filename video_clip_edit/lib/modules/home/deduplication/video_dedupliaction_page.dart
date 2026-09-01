import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/core/util/manager/auth.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/widgets/banner_view.dart';
import 'package:video_clip_edit/modules/home/beans/function_item_bean.dart';
import 'package:video_clip_edit/modules/home/widgets/video_preview_widget.dart';
import 'package:video_clip_edit/modules/home/deduplication/recent_tasks_page.dart';
import 'package:video_clip_edit/modules/home/providers/words_extract_provider.dart';
import 'package:video_clip_edit/modules/home/providers/video_deduplication_provider.dart';

class VideoDedupliactionPage extends StatelessWidget {
  const VideoDedupliactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: Stack(
        children: [
          Column(
            children: [
              _buildBanner(context),
              SizedBox(height: 2.h),
              _buildVideos(),
              SizedBox(height: 20.h),
              _buildList(context),
            ],
          ),
          Positioned(child: _buildAppBar(context)),
        ],
      ),
    );
  }

  _buildBanner(BuildContext context) {
    return SizedBox(
      height: 200.h,
      width: double.infinity,
      child: BannerView(
        urls: const ["assets/home/banner_deduplication.png"],
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
          SizedBox(
            height: 30.h,
            child: ByWidgetsUtil.btnWithIcon(
              iconH: 12.w,
              iconW: 12.w,
              fontSize: 12.sp,
              title: "最近任务",
              borderRadius: 100.w,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 0.h),
              bgColor: ByColorUtil.WhiteColor,
              iconPath: "assets/home/icon_strategy.png",
              textColor: ByColorUtil.CommonTextColor,
              onClick: () {
                ByNavRouterUtils.push(
                    context,
                    ChangeNotifierProvider.value(
                      value: context.read<VideoDeduplicationProvider>(),
                      child: const RecentTasksPage(),
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 对比视频
  _buildVideos() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      height: 300.h,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.w),
              child: Stack(
                children: [
                  Container(
                    color: Colors.green[100],
                  ),
                  const Positioned.fill(
                    child: VideoPreviewWidget(
                      url: 'assets/home/normal_video.mp4',
                    ),
                  ),
                  Positioned(
                    bottom: 10.h,
                    left: 58.w,
                    child: ByWidgetsUtil.commonText(
                        text: "去重前",
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                        textColor: ByColorUtil.WhiteColor),
                  )
                ],
              ),
            ),
          ),
          SizedBox(width: 5.w),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.w),
              child: Stack(
                children: [
                  Container(
                    color: Colors.green[100],
                  ),
                  const Positioned.fill(
                    child: VideoPreviewWidget(
                      url: 'assets/home/normal_video1.mp4',
                    ),
                  ),
                  Positioned(
                    bottom: 10.h,
                    left: 58.w,
                    child: ByWidgetsUtil.commonText(
                        text: "去重后",
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                        textColor: ByColorUtil.WhiteColor),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildList(BuildContext context) {
    final functions =
        context.select<VideoDeduplicationProvider, List<FunctionItemBean>>(
      (p) => p.homeFunctions,
    );
    return Expanded(
        child: ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: functions.length,
      itemBuilder: (context, index) {
        final function = functions[index];
        return GestureDetector(
          onTap: () {
            AuthManager.materialAuth(onSuccess: () {
              ByCommonUtils.pickAssetsByType(
              context,
              maxCount: 1,
              type: MediaType.video.uploadFileType,
              onSelectedCallback: (asstes) async {
                if (asstes.isEmpty) return;
                File? file = await asstes.first.file;
                if (file == null) return;

                // ByNavRouterUtils.push(
                //   context,
                //   ChangeNotifierProvider.value(
                //     value: context.read<VideoDeduplicationProvider>(),
                //     child: const VideoEditPage(),
                //   ),
                // );
              },
            );
            },);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
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
                      function.icon,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 27.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        function.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: const Color(0xFF0E1840),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 9.h),
                      Text(
                        function.desc,
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
      },
    ));
  }
}
