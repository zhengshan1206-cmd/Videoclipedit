import 'package:flutter/cupertino.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/novelwriting/beans/ai_novel_singelchoice_bean.dart';

class AiNovelWritingProviders extends BaseProvider {
  TextEditingController contentCreateEditingController =
      TextEditingController();
  TextEditingController titleCreateEditingController = TextEditingController();

  List<AiNovelSingelchoiceBean> targetAudienceData = [
    AiNovelSingelchoiceBean(1,"女频", isSelect: true),
    AiNovelSingelchoiceBean(2,"男频")
  ];
  List<AiNovelSingelchoiceBean> lengthData = [
    AiNovelSingelchoiceBean(3,"短篇"),
    AiNovelSingelchoiceBean(4,"中长篇", isSelect: true)
  ];
  List<AiNovelSingelchoiceBean> storyPerspectiveData = [
    AiNovelSingelchoiceBean(4,"第一人称"),
    AiNovelSingelchoiceBean(6,"第三人称", isSelect: true)
  ];

}
