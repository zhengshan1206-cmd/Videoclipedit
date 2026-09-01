import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/home/deduplication/widgets/video_edit_content_view.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class VideoEditPage extends StatefulWidget {
  const VideoEditPage({super.key});

  @override
  State<VideoEditPage> createState() => _VideoEditPageState();
}

class _VideoEditPageState extends State<VideoEditPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(context: context, title: "视频去重"),
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Column(
        children: [
          /// 视频预览
          _buildVideoPreview(),
          SizedBox(height: 20.h),
          const Expanded(child: VideoEditContentView())
        ],
      ),
    );
  }

  /// 视频预览
  _buildVideoPreview() {
    return Container(
      width: double.infinity,
      height: 210.h,
      color: Colors.green[100],
    );
  }
}
