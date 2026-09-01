import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/providers/video_extraction_provider.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/widgets/guide_cell.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  @override
  void initState() {
    super.initState();

    _loadTutors();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VideoExtractionProvider>();
    final tutorBeans = provider.tutorBeans;
    return Scaffold(
      backgroundColor: ByColorUtil.CommonPageBgColor,
      appBar: ByWidgetsUtil.appBar(context: context, title: "使用攻略"),
      body: EasyRefresh(
        onRefresh: () {
          provider.resetIntroPage();
          provider.loadTutors();
        },
        onLoad: () {
          provider.loadTutors();
        },
        child: ListView.builder(
          itemBuilder: (context, index) {
            return GuideCell(
              hideSeporator: index == tutorBeans.length - 1,
              bean: tutorBeans[index],
              index: index,
            );
          },
          itemCount: tutorBeans.length,
        ),
      ),
    );
  }

  void _loadTutors() {
    final provider = context.read<VideoExtractionProvider>();
    provider.loadTutors();
  }
}
