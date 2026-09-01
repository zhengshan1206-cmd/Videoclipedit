import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_banner_mixin.dart';
import 'package:video_clip_edit/v2/aiSquare/song/beans/rights_by_type.dart';
import 'package:video_clip_edit/v2/aiSquare/song/beans/ai_song_getconfig_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/song/beans/ai_song_task_detail_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/song/beans/violations_content_check_bean.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';

//灵感
const int songStatusInspiration = 2;
const String songStatusInspirationTxt =
    "请输入您的灵感，例如：写一首描写儿时兄弟情谊的歌曲，要求中文，中国流行歌曲风格。";
//歌词
const int songStatusLyrics = 1;
const String songStatusLyricsTxt = "请输入歌词内容，例如：春天在哪里";

class AiSongProvider extends AiBannerMixin {
  TextEditingController aiSongTitleController = TextEditingController();
  TextEditingController aiSongContentController = TextEditingController();
  TextEditingController aiSongStyleCustomController = TextEditingController();

  int contentFondSize = 0;
  int aiSongContentControllerLength = 500;
  RightsByType? rghtsByType;

  String contentHindText = songStatusInspirationTxt;
  //true=灵感 false=歌词
  int nowSongStatus = songStatusInspiration;
  //音乐类型
  List<Mode> songAiModel = [];
  Mode? selectSongAiModel;

  //歌手类型
  List<Mode> songAiSinger = [];
  Mode? selectsongAiSinger;

  //风格
  List<Style> songAiStyle = [];
  List<Mode> selectSongAiStyleModel = [];

  // //音乐类型 0=歌曲 1=纯音乐
  // int songType = 0;
  //
  // //歌手性别 0=随机 1=男歌手 2=女歌手 3=童声
  // int singerGender = 0;

  final integralVipController = IntegralVipController.getOrPut();

  String? aiMusicHintText;

  setNowSongStatus(int status) {
    nowSongStatus = status;
    switch (status) {
      case songStatusInspiration:
        contentHindText = songStatusInspirationTxt;
        break;
      case songStatusLyrics:
        contentHindText = songStatusLyricsTxt;
        break;
    }
    notifyListeners();
  }

  setSelectSongAiModel(Mode status) {
    selectSongAiModel = status;
    notifyListeners();
  }

  setSelectsongAiSinger(Mode status) {
    selectsongAiSinger = status;
    notifyListeners();
  }

  updSongAiStyle(String title, Mode status) {
    for (int i = 0; i < songAiStyle.length; i++) {
      if (songAiStyle[i].title == title) {
        for (int j = 0; j < songAiStyle[i].items.length; j++) {
          if (songAiStyle[i].items[j].id == status.id) {
            songAiStyle[i].items[j].isSelect =
                !songAiStyle[i].items[j].isSelect;
          }
        }
      }
    }
    notifyListeners();
  }

  updSelectSongAiStyleModel() {
    selectSongAiStyleModel.clear();
    for (int i = 0; i < songAiStyle.length; i++) {
      for (int j = 0; j < songAiStyle[i].items.length; j++) {
        if (songAiStyle[i].items[j].isSelect) {
          selectSongAiStyleModel.add(songAiStyle[i].items[j]);
        }
      }
    }
    notifyListeners();
  }

  ///随机选中
  randomSelectSongAiStyleModel(Function callback) {
    selectSongAiStyleModel.clear();
    for (int i = 0; i < songAiStyle.length; i++) {
      int random = Random().nextInt(songAiStyle[i].items.length - 1);
      for (int j = 0; j < songAiStyle[i].items.length; j++) {
        songAiStyle[i].items[j].isSelect = false;
      }
      songAiStyle[i].items[random].isSelect = true;
    }
    notifyListeners();
    callback();
  }

  ///音乐相关配置
  myLoadCloudVideos({AiSongTaskDetailBean? aiSongTaskDetailBean}) {
    HttpUtils.get(
      APIs.musicAiGetConfig,
      {},
      showLoading: true,
      success: (data) {
        AiSongGetconfigBean aiSongGetconfigBean =
            AiSongGetconfigBean.fromJson(data["data"][0]);
        songAiModel = aiSongGetconfigBean.mode;
        // if (songAiStyle.length <= 1) {
        //   songAiStyle = aiSongGetconfigBean.style;
        // }
        songAiStyle = aiSongGetconfigBean.style;
        songAiSinger = aiSongGetconfigBean.singer;
        // print("dddddd1${songAiModel}");
        // print("dddddd2${songAiStyle}");
        // print("dddddd3${songAiSinger}");

        if (aiSongTaskDetailBean != null) {
          // print("asdqeqw535${aiSongTaskDetailBean.toString()}");
          setNowSongStatus(aiSongTaskDetailBean.customMode);
          aiSongTitleController.text = aiSongTaskDetailBean.title;
          aiSongContentController.text = aiSongTaskDetailBean.prompt;

          for (int i = 0; i < songAiModel.length; i++) {
            // print("d22222222224${songAiModel[i].id},${aiSongTaskDetailBean.customMode}");
            if (songAiModel[i].id == aiSongTaskDetailBean.customMode) {
              setSelectSongAiModel(songAiModel[i]);
            }
          }

          for (int i = 0; i < songAiSinger.length; i++) {
            if (songAiSinger[i].id == aiSongTaskDetailBean.singerSex) {
              setSelectsongAiSinger(songAiSinger[i]);
            }
          }
          String style = aiSongTaskDetailBean.style;
          // String style="decelerating,free,pop,custom:asd123";
          // print("asdase1215415${style}");
          try {
            if (style.isNotEmpty) {
              // style="喜喜";
              // print("asdase1215415${"哈哈 喜喜"}");
              List<String> styleModelSplit = style.split(",");
              // print("asdase1215415${styleModelSplit}");
              String styleContentSplit = "";
              /*   styleModelSplit.forEach((data){
                if(data.contains("custom:")){
                  styleContentSplit=data.replaceAll("custom:","");
                }
              });*/
              if (styleModelSplit.isNotEmpty) {
                for (int i = 0; i < songAiStyle.length; i++) {
                  List<Mode> model = songAiStyle[i].items;
                  for (int j = 0; j < model.length; j++) {
                    Mode songAiStyleModel = model[j];
                    // print("asd23215${styleModelSplit.contains(songAiStyleModel.tag)},${songAiStyleModel.tag}");
                    if (styleModelSplit.contains(songAiStyleModel.tag)) {
                      songAiStyleModel.isSelect = true;
                      styleModelSplit.remove(songAiStyleModel.tag);
                    }
                  }
                }
              }

              // print("asd123125${styleContentSplit.toString()},${styleContentSplit.length}");
              if (styleModelSplit.isNotEmpty) {
                styleModelSplit.forEach((data) {
                  styleContentSplit += data;
                });
                aiSongStyleCustomController.text = styleContentSplit;
              }
              updSelectSongAiStyleModel();
            }
          } catch (e) {}
        } else {
          setNowSongStatus(songStatusInspiration);
          setSelectSongAiModel(songAiModel[0]);
          setSelectsongAiSinger(songAiSinger[0]);
        }
        notifyListeners();
      },
      fail: (code, msg) {},
    );
  }

  ///创建
  musicAiCreateTask(
    void Function() onSuccess, {
    void Function()? onErro,
  }) {
    String style = "";
    for (int i = 0; i < selectSongAiStyleModel.length; i++) {
      style += selectSongAiStyleModel[i].tag +
          (i == selectSongAiStyleModel.length - 1 ? "" : ",");
    }
    if (aiSongStyleCustomController.text.isNotEmpty) {
      style += (style.isNotEmpty ? "," : "") + aiSongStyleCustomController.text;
    }
    print("musicAiCreateTask<><><><><><><>${style}");
    HttpUtils.post(
      APIs.musicAiCreateTask,
      {
        "custom_mode": nowSongStatus,
        "style": style,
        //是否纯音乐
        "is_instrumental": selectSongAiModel?.id,
        //性别
        "singer_sex": selectsongAiSinger?.id,
        //content
        "prompt": aiSongContentController.text,
        "title": aiSongTitleController.text,
      },
      success: (data) {
        integralVipController.init(
          requiredPoints: 0,
          type: "ai_music",
        );
        onSuccess();
        getTaskList();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        integralVipController.handleStatusCode(code, msg, "ai_music");
      },
    );
  }

  //歌词
  musicAiLyrics(
    String prompt,
  ) {
    HttpUtils.post(
      APIs.aiLyrics,
      {
        "type": nowSongStatus == 1 ? 2 : 1,
        // "style": selectSongAiStyle?.,
        "prompt": aiSongContentController.text,
      },
      showLoading: true,
      success: (data) {
        String aiSongContentTitle = data["data"]["title"];
        String aiSongContentText = data["data"]["text"];
        aiSongTitleController.text = aiSongContentTitle;
        aiSongContentController.text = aiSongContentText;
      },
      fail: (code, msg) {},
    );
  }

  getTaskList() {
    HttpUtils.post(
      APIs.getRightsByType,
      {
        "type": "ai_music",
      },
      showLoading: true,
      success: (data) {
        rghtsByType = RightsByType.fromJson(data["data"]);
        aiSongContentControllerLength = rghtsByType!.textLength;
        notifyListeners();
      },
      fail: (code, msg) {},
    );
  }

  checkContent({
    String? type,
    String? needMark,
    required String content,
    void Function(bool violationsContentCheckBean)? onSuccess,
  }) {
    HttpUtils.post(
      APIs.textRisk,
      {
        "type": type ?? "3",
        "needMark": needMark ?? "2",
        "labelType": "499001",
        "content": content,
      },
      showLoading: true,
      forceData: true,
      success: (data) {
        ViolationsContentCheckBean violationsContentCheckBean =
            ViolationsContentCheckBean.fromJson(data["data"]);
        onSuccess?.call(violationsContentCheckBean.isRisk);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  getAiMusicHintText() {
    if (aiMusicHintText != null) {
      aiSongContentController.text = aiMusicHintText ?? "";
    }
  }
}
