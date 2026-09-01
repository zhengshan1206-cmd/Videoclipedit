import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/widgets/svga_player.dart';
import 'package:video_clip_edit/modules/home/widgets/banner_view.dart';
import 'package:video_clip_edit/modules/home/erase/recent_tasks_page.dart';
import 'package:video_clip_edit/modules/home/beans/function_item_bean.dart';
import 'package:video_clip_edit/modules/home/erase/picture_erase_page.dart';
import 'package:video_clip_edit/modules/home/providers/video_erase_provider.dart';

class VideoErasePage extends StatelessWidget {
  const VideoErasePage({
    super.key,
  });

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
              _buildVideos(context),
              SizedBox(height: 20.h),
              _buildList(context),
            ],
          ),
          Positioned(
            child: _buildAppBar(context),
          ),
        ],
      ),
    );
  }

  _buildBanner(BuildContext context) {
    return SizedBox(
      height: 200.h,
      width: double.infinity,
      child: const BannerView(
        urls: ["assets/home/banner_erase.png"],
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
                      value: context.read<VideoEraseProvider>(),
                      child: const PictureRecentTasksPage(),
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 对比视频
  _buildVideos(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      height: 300.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.w),
        child: const SvgaPlayer(url: "assets/home/erase_example.svga"),
      ),
    );
  }

  _buildList(BuildContext context) {
    final functions =
        context.select<VideoEraseProvider, List<FunctionItemBean>>(
      (p) => p.homeFunctions,
    );
    return Expanded(
        child: ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: functions.length,
      itemBuilder: (ctx, index) {
        final function = functions[index];
        return GestureDetector(
          onTap: () {
            switch (function.title) {
              case "图片擦除":
                ByCommonUtils.pickAssetsOnType(
                  context,
                  maxCount: 1,
                  onSelectedCallback: (List<AssetEntity> assets) {
                    if (assets.isEmpty) return;
                    ByNavRouterUtils.goBack(context);
                    ByNavRouterUtils.push(
                      context,
                      ChangeNotifierProvider.value(
                        value: context.read<VideoEraseProvider>(),
                        child: PictureErasePage(assets: assets),
                      ),
                    );
                  },
                );
                break;
              case "视频擦除":
                // showDialog(
                //   context: context,
                //   useSafeArea: false,
                //   builder: (ctx) {
                //     return ChangeNotifierProvider<VideoEraseProvider>.value(
                //       value: context.read<VideoEraseProvider>(),
                //       child: AssetsPickerDailog(
                //         onSelected: (int idx) {
                //           ByNavRouterUtils.goBack(context);
                //           ByNavRouterUtils.push(
                //             context,
                //             ChangeNotifierProvider.value(
                //               value: context.read<VideoEraseProvider>(),
                //               child: const VideoErasingPage(),
                //             ),
                //           );
                //         },
                //       ),
                //     );
                //   },
                // );

                ByCommonUtils.pickAssetsOnTypeVideo(
                  context,
                  maxCount: 1,
                  onSelectedCallback: (assets) async {
                    // if (assets.isEmpty) return;
                    // // ByNavRouterUtils.goBack(context);
                    // // ByNavRouterUtils.push(
                    // //   context,
                    // //   ChangeNotifierProvider.value(
                    // //     value: context.read<VideoEraseProvider>(),
                    // //     child: PictureErasePage(assets: assets),
                    // //   ),
                    // // );
                    // final file = await assets[0].file;
                    // if (file != null) {
                    //   await ChannelOperate.toCleanWatermark(file.path)
                    //       .then((data) {
                    //     if (data != null) {
                    //       // BotToast.showText(text: "作品已保存到相册中!");
                    //       try {
                    //         ByNavRouterUtils.push(
                    //           context,
                    //           VideoClipHyberPrevicew(
                    //               data[ChannelApi.editResult]),
                    //         );
                    //       } catch (e) {
                    //         byDebugPrint(e);
                    //       }
                    //     }
                    //   });
                    // }
                  },
                );
                break;
              default:
            }
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
