import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/erase/video_handle_page.dart';
import 'package:video_clip_edit/modules/home/erase/widgets/pen_size_view.dart';
import 'package:video_clip_edit/modules/home/providers/video_erase_provider.dart';

class VideoErasingPage extends StatelessWidget {
  const VideoErasingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(context: context, title: "视频擦除" * 2),
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Column(
        children: [
          /// 视频、图片预览
          _buildPreview(context),

          /// 笔触大小
          // _buildPenSize(context),

          /// 底部按钮
          _buildBottomBtn(context),
        ],
      ),
    );
  }

  /// 视频、图片预览
  Expanded _buildPreview(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.green[100],
        child: Image.asset(
          "assets/home/banner_deduplication.png",
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  /// 笔触大小
  _buildPenSize(BuildContext context) {
    return Container(
      color: ByColorUtil.CommonPageBgColor,
      height: 83.h,
      width: double.infinity,
      child: const PenSizeListView(),
    );
  }

  /// 底部按钮
  Container _buildBottomBtn(BuildContext context) {
    return Container(
      color: ByColorUtil.WhiteColor,
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 8.h,
        bottom: 8.h + ByScreenUtils.bottomSafeHeight,
      ),
      child: ByWidgetsUtil.commonBtn(
        title: "一键擦除",
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        borderRadius: 12.w,
        onClick: () {
          ByNavRouterUtils.push(
            context,
            ChangeNotifierProvider.value(
              value: context.read<VideoEraseProvider>(),
              child: const VideoHandlePage(type: VideoHandlePageType.picture),
            ),
          );
        },
      ),
    );
  }
}
