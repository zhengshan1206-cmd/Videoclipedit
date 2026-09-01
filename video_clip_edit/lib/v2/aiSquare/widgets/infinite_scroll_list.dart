import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/home_page_scroll_list_cell.dart';

import '../../aiVideo/models/ai_music_banner_model.dart';
import '../../aiVideo/models/ai_presets_model.dart';
import '../../aiVideo/models/ai_tips_model.dart';
import '../../aiVideo/models/ai_video_banner_model.dart';

class InfiniteScrollList extends StatefulWidget {
  final Duration duration;
  final int id;

  ///当前banner获取到的接口数据id
  ///首页智能绘图数据
  final List<AiTipsModel> aiTipsModelList;

  ///首页智能回答数据
  final List<AiPresetsModel> aiPresetsModelList;

  ///ai video 数据集合
  final List<AiVideoBannerModel> aiVideoBannerModelList;

  /// ai music 数据集合
  final List<AiMusicBannerModel> aiMusicBannerModelList;

  const InfiniteScrollList({
    super.key,
    this.duration = const Duration(milliseconds: 100),
    required this.id,
    required this.aiTipsModelList,
    required this.aiPresetsModelList,
    required this.aiVideoBannerModelList,
    required this.aiMusicBannerModelList,
  });

  @override
  State<InfiniteScrollList> createState() => _InfiniteScrollListState();
}

class _InfiniteScrollListState extends State<InfiniteScrollList> {
  ///当前展示的数据的集合总数
  int counts = 0;

  ///当前展示数据类型的id
  late int id;
  List<AiTipsModel> aiTipsModelList = [];
  List<AiPresetsModel> aiPresetsModelList = [];
  List<AiVideoBannerModel> aiVideoBannerModelList = [];
  List<AiMusicBannerModel> aiMusicBannerModelList = [];

  List<String> textList = [];

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() {
    id = widget.id;
    aiTipsModelList = widget.aiTipsModelList;
    aiPresetsModelList = widget.aiPresetsModelList;
    aiVideoBannerModelList = widget.aiVideoBannerModelList;
    aiMusicBannerModelList = widget.aiMusicBannerModelList;
    if (id == 1) {
      counts = aiTipsModelList.length;
    } else if (id == 2) {
      counts = aiPresetsModelList.length;
    } else if (id == 4) {
      counts = aiVideoBannerModelList.length;
    } else if (id == 5) {
      counts = aiMusicBannerModelList.length;
    }

    if (id == 1) {
      textList = aiTipsModelList.map((e) => e.tip ?? "").toList();
    } else if (id == 2) {
      textList = aiPresetsModelList.map((e) => e.des ?? "").toList();
    } else if (id == 4) {
      textList = aiVideoBannerModelList.map((e) => e.prompt ?? "").toList();
    } else if (id == 5) {
      textList = aiMusicBannerModelList.map((e) => e.prompt ?? "").toList();
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (counts == 0) {
      return const SizedBox();
    }
    return Marquee(
      texts: textList,
      scrollDuration: const Duration(milliseconds: 3000),
      textSize: 14.0,
      textColor: Colors.blue,
      highlightedColor: Colors.red,
      id: id,
    );
  }
}
