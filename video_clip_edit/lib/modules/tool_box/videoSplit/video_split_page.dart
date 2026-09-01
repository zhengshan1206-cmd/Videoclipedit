import 'package:flutter/material.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class VideoSplitPage extends StatefulWidget {
  const VideoSplitPage({super.key});

  @override
  State<VideoSplitPage> createState() => _VideoSplitPageState();
}

class _VideoSplitPageState extends State<VideoSplitPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(context: context, title: "视频拆分"),
    );
  }
}
