/*
  guide_pop_providers.dart
  Created by duncy on 25/4/16.
*/

import 'dart:io';

import 'package:get/get.dart';
import 'package:video_clip_edit/modules/guid/beans/guide_pop_beans.dart';
import '../../../utils/http/apis.dart';
import '../../../utils/http/http_utils.dart'; 


//已废弃，现用路由代替
enum GuideEntranceType {
  aiClip,  //混剪推文
  aiTweets, //AI动漫视频
  novelCreate, //民间故事/爆文创作
  shortPlayCreate, //短剧创作
  aiOralVideos, //AI口播视频/数字人
  aiTextToVideo, //文生视频
  aiImageToVideo, //图生视频
  aiDraw, //AI绘图
  aiEmbraceVideo, //拥抱视频
}


class GuideApi extends APIs {
  static const String guidePopPage = "/ComConfig/strategyGuideList";
}

class GuideController extends GetxController {
  var guideData = Rx<GuidePopBean>(GuidePopBean());
  String routeName = "";

  String getRouteName(GuideEntranceType type) {
    switch(type) {
      case GuideEntranceType.aiClip:
        return "ai_clip";
      case GuideEntranceType.aiTweets:
        return "ai_tweets";
      case GuideEntranceType.aiDraw:
        return "ai_draw";
      case GuideEntranceType.aiEmbraceVideo:
        return "ai_embrace_video";
      case GuideEntranceType.aiTextToVideo:
        return "ai_text_to_video";
      case GuideEntranceType.aiImageToVideo:
        return "ai_image_to_video";
        case GuideEntranceType.novelCreate:
        return "novel_create";
      case GuideEntranceType.shortPlayCreate:
        return "short_play_create";
      case GuideEntranceType.aiOralVideos:
        return "ai_oral_videos";
    }
  }

  String getGuideTitle(GuideEntranceType type) {
    switch(type) {
      case GuideEntranceType.aiClip:
        return "混剪推文";
      case GuideEntranceType.aiTweets:
        return "AI动漫视频";
      case GuideEntranceType.aiDraw:
        return "AI绘图";
      case GuideEntranceType.aiEmbraceVideo:
        return "时空拥抱";
      case GuideEntranceType.aiTextToVideo:
        return "AI动态视频";
      case GuideEntranceType.aiImageToVideo:
        return "AI视频";
        case GuideEntranceType.novelCreate:
        return "民间故事";
      case GuideEntranceType.shortPlayCreate:
        return "短剧创作";
      case GuideEntranceType.aiOralVideos:
        return "AI口播视频";
    }
  }

  //获取攻略数据
  getGuideData({
    required GuideEntranceType type,
    required void Function(GuidePopBean data) onSuccess,
  }) {
    HttpUtils.get(
      GuideApi.guidePopPage,
      {
        "type": getRouteName(type),
        "system": Platform.isIOS ? 1 : 2, 
      },
      showMsgWhenFailed: false,
      success: (data) {
        final success = data["status"] == 200;
        if (!success) {
          return onSuccess(GuidePopBean());
        }
        final Map<String, dynamic> items = data["data"] ?? {};
        // print("+++++++++++++=> $data");
        if (items.isEmpty) {
          guideData.value = GuidePopBean();
          
        }
        guideData.value = GuidePopBean.fromJson(items);
        onSuccess(guideData.value);
      },
    );
  }
}
