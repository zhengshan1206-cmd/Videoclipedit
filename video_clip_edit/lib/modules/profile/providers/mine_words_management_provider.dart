import 'package:flutter/material.dart';
import 'package:video_clip_edit/modules/home/words/words_extraction_tasks_page.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_videos_management_provider.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/writing/ai_writing_record_page.dart';

class MineWordsManagementProvider extends BaseProvider {
  List<MineVideosCategoryBean> mineVideos = [
    MineVideosCategoryBean.fromJson({"title": "一键提取文案", "id": 1}),
    MineVideosCategoryBean.fromJson({"title": "AI写作", "id": 2}),
  ];

  int selectedCategory = 0;
  updateSelectedCategory(int index) {
    selectedCategory = index;
    notifyListeners();
  }

  List<Widget> pages = [
    const WordsExtractionTasksPage(showAppBar: false),
    const AiWritingRecordPage(showAppBar: false),
  ];
}
