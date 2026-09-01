import 'dart:math';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/v2/aiOralVideos/ai_oral_videos_create_page.dart';
import 'package:video_clip_edit/v2/aiOralVideos/beans/ai_oral_audio_bean.dart';
import 'package:video_clip_edit/v2/aiOralVideos/beans/ai_oral_audio_clone_detail_bean.dart';
import 'package:video_clip_edit/v2/aiOralVideos/beans/ai_oral_clone_bean.dart';
import 'package:video_clip_edit/v2/aiOralVideos/beans/ai_oral_dubbing_clone_detail_bean.dart';
import 'package:video_clip_edit/v2/aiOralVideos/beans/ai_oral_my_video_bean.dart';
import 'package:video_clip_edit/v2/aiOralVideos/beans/ai_oral_video_item_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/song/beans/rights_by_type.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_video_player.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';

class AiOralVideosProvider extends BaseProvider {
  AiOralVideosProvider() {
    getDefaultTxt();
    getVipRights();
    loadBanner();
  }

  MusicModel selectedMusicModel = MusicModel(
    id: -1,
    name: "",
    type: 0,
    demoUrl: "",
    refContent: null,
    coverUrl: "",
  );

  ///仅针对
  MusicModel? selectedMusicModel2;

  List<SubFunction> banners = [];
  updateBanners(List<SubFunction> beans) {
    banners = beans;
    notifyListeners();
  }

  bool showBanner = true;
  updateShowBanner(bool value) {
    showBanner = value;
    notifyListeners();
  }

  loadBanner() {
    HttpUtils.get(
      APIs.homeBanner,
      {"postion": 13},
      success: (data) {
        banners.clear();
        final List bannerData = data["data"]["item"] ?? [];
        List<SubFunction> beans = bannerData
            .map((e) => SubFunction.fromJson(e))
            .toList();
        updateBanners(beans);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  bool uploading = false;
  changeUploading(bool value) {
    uploading = value;
    notifyListeners();
  }

  /// 是否开启画质增强
  bool enableEnhance = false;
  changeEnableEnhance(bool value) {
    enableEnhance = value;
    notifyListeners();
  }

  List<AiOralAudioBean> audioBeans = [
    AiOralAudioBean.fromJson({
      "title": "复刻音色配音",
      "icon": "assets/ai/oralVideos/ai_oral_videos_audio_copy.svg",
      "index": 0,
    }),
    AiOralAudioBean.fromJson({
      "title": "AI主播配音",
      "icon": "assets/ai/oralVideos/ai_oral_videos_audio_anchor.svg",
      "index": 1,
    }),
    // AiOralAudioBean.fromJson({
    //   "title": "从本地选择",
    //   "icon": "assets/ai/oralVideos/ai_oral_videos_audio_folder.svg",
    //   "index":2,
    //
    // }),
  ];

  /// 默认随机朗读文本列表
  List<String> defaultTxts = [];
  updateDefaultTxts(List<String> txts) {
    defaultTxts = txts;
    notifyListeners();
  }

  /// 默认随机朗读文本列表
  List<String> tips = [];
  updateTips(List<String> txts) {
    tips = txts;
    notifyListeners();
  }

  int currentDefaultTxtIndex = -1;
  updateCurrentDefaultTxtIndex(int index) {
    currentDefaultTxtIndex = index;
    notifyListeners();
  }

  pickRandomDefaultTxtIndex() {
    if (defaultTxts.isEmpty) {
      return;
    }
    int index = Random().nextInt(defaultTxts.length);
    while (index == currentDefaultTxtIndex) {
      index = Random().nextInt(defaultTxts.length);
    }
    updateCurrentDefaultTxtIndex(index);
  }

  getDefaultTxt({void Function()? onSuccess, void Function()? onFail}) {
    HttpUtils.get(
      APIs.getDefaultTxt,
      {},
      success: (data) {
        final List<String> defaultTxts = (data["data"]["content"] ?? [])
            .cast<String>();

        final List<String> tip = (data["data"]["tip"] ?? []).cast<String>();
        updateDefaultTxts(defaultTxts);
        updateTips(tip);
        if (defaultTxts.isNotEmpty) {
          pickRandomDefaultTxtIndex();
        }
        onSuccess?.call();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        onFail?.call();
      },
    );
  }

  /// 保存视频
  saveUserVideo({
    required String videoUrl,
    required int videoDuration,
    String? cover,
    void Function(dynamic data)? onSuccess,
  }) {
    HttpUtils.post(
      APIs.uploadBgm,
      {
        "type": "video",
        "url": videoUrl,
        "duration": videoDuration ~/ 1000,
        "needRisk": 1,
        "cover": cover,
        "remark": "视频口播数字人",
        "name":
            "VIDEO_${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}_${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}",
      },
      showLoading: false,
      success: (data) {
        byDebugPrint("上传结果:$data");
        // loadMyVideoList();
        Map? dataFromServer = data["data"];
        if (dataFromServer != null) {
          if (dataFromServer.isEmpty) {
            BotToast.showText(text: data["message"]);
            changeUploading(false);
            return;
          }
        }
        onSuccess?.call(data["data"]);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 删除视频
  deleteUserVideo(int videoId, {void Function()? onSuccess}) {
    HttpUtils.post(
      APIs.deleteUserVideo,
      {"id": videoId},
      showLoading: true,
      success: (data) {
        byDebugPrint("删除结果:$data");
        onSuccess?.call();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  int selectedUserVideoId = -1;
  updateSelectedUserVideoId(int id) {
    selectedUserVideoId = id;
    notifyListeners();
  }

  bool underReview = false;
  updateUnderReview(bool value) {
    underReview = value;
    notifyListeners();
  }

  /// 我的视频列表
  List<AiOralMyVideoBean> userVideoBeans = [];
  updateUserVideoBeans(List<AiOralMyVideoBean> beans) {
    userVideoBeans = beans;
    notifyListeners();
  }

  /// 获取我上传的视频列表
  /// 状态 1待审核 2审核通过 3审核失败  4系统推荐 不传为所有状态
  loadMyVideoList({
    bool reset = false,
    CancelToken? cancelToken,
    void Function(bool underReview)? onSuccess,
  }) {
    // if (reset) {
    //   userVideoBeans.clear();
    // }
    HttpUtils.get(
      APIs.customBgmList,
      cancelToken: cancelToken,
      {
        "page": 1,
        "size": 100,
        // "status": 2,
        "type": "video",
        "remark": "视频口播数字人",
      },
      showLoading: false,
      success: (data) {
        byDebugPrint(data["data"]["items"], tag: "本地bgm素材库列表:");
        final List videoData = data["data"]["items"] ?? [];
        final List<AiOralMyVideoBean> beans = videoData
            .map((e) => AiOralMyVideoBean.fromJson(e))
            .toList();
        updateUserVideoBeans(beans);
        // bool underReview = false;
        // for (var element in beans) {
        //   if (element.status == 1) {
        //     underReview = true;
        //     break;
        //   }
        // }

        checkUnderReview();

        onSuccess?.call(underReview);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  checkUnderReview() {
    bool underReview = false;
    if (selectedUserVideoId != -1) {
      for (var ele in userVideoBeans) {
        if (ele.id == selectedUserVideoId) {
          underReview = ele.status == 1;
          break;
        }
      }
      updateUnderReview(underReview);
    }
  }

  createUserAudioClone({
    required String url,
    void Function(int taskId, dynamic data)? onSuccess,
    void Function()? onFail,
    bool showLoading = true,
    int? directSave,

    ///1 为立即保存
  }) {
    HttpUtils.post(
      APIs.createUserAudioClone,
      {
        "audioUrl": url,
        "content": defaultTxts[currentDefaultTxtIndex],
        "direct_save": directSave,
      },
      showLoading: showLoading,
      success: (data) {
        // Get.log("创建的克隆音频文件====> ${data}");

        getVipRights();
        byDebugPrint(data);
        final taskId = data["data"]["id"] ?? -1;
        if (taskId != -1) {
          onSuccess?.call(taskId, data["data"]);
        } else {
          onFail?.call();
        }
      },
      fail: (code, msg) {
        onFail?.call();
        BotToast.showText(text: msg);
      },
    );
  }

  renameUserAudioClone({
    required String id,
    required String name,
    void Function()? onSuccess,
    void Function()? onFail,
  }) {
    HttpUtils.post(
      APIs.renameUserAudioClone,
      {"id": id, "title": name},
      showLoading: true,
      success: (data) {
        byDebugPrint(data);
        onSuccess?.call();
      },
      fail: (code, msg) {
        onFail?.call();
        BotToast.showText(text: msg);
      },
    );
  }

  /// 选择的我的声音下标
  int selectedCloneId = -1;
  updateSelectedCloneId(int index) {
    selectedCloneId = index;
    notifyListeners();
  }

  /// 选择的我的声音下标
  int listeningCloneIndex = -1;
  updateListeningCloneIndex(int index) {
    listeningCloneIndex = index;
    notifyListeners();
  }

  List<AiOralCloneBean> cloneBeans = [];
  updateCloneBeans(List<AiOralCloneBean> beans) {
    cloneBeans = beans;
    notifyListeners();
  }

  deleteUserAudioClone({required int id, Function()? onSuccess}) {
    HttpUtils.post(
      APIs.deleteUserAudioClone,
      {"id": id},
      showLoading: true,
      success: (data) {
        getUserAudioCloneList(reset: true);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  int clonePage = 1;
  int clonePageSize = 10;

  getUserAudioCloneList({
    bool reset = false,
    bool selectFirst = false,
    bool showLoading = false,
  }) {
    HttpUtils.get(
      APIs.getUserAudioCloneList,
      {
        "status": 3,

        ///1已保存 2未保存
        "isSaved": 1,
      },
      showLoading: showLoading,
      success: (data) {
        final List items = data["data"]["data"] ?? [];
        if (reset) cloneBeans.clear();

        final List<AiOralCloneBean> beans = items
            .map((e) => AiOralCloneBean.fromJson(e))
            .toList();

        final res = List<AiOralCloneBean>.from(cloneBeans);
        clonePage = res.addElementsByRemovingLast(
          beans,
          currentPage: clonePage,
          pageSize: clonePageSize,
        );
        updateCloneBeans(res);
        updateSelectMyCloneMusicIndex();
        if (selectFirst) {
          selectFirstData();
        }

        if (insertCloneMusicModel && res.isNotEmpty) {
          // selectedMusicModel2 = MusicModel(
          //     id: res.first.id,
          //     name: res.first.title,
          //     type: 1,
          //     demoUrl: res.first.audioUrl ?? "",
          //     refContent: res.first.refContent);

          Get.log("立即插入事件发送了====>");

          eventBus.fire(
            InsertCloneMusicModelEvent(
              model: MusicModel(
                coverUrl: res.first.coverUrl,
                id: res.first.id,
                name: res.first.title,
                type: 1,
                demoUrl: res.first.audioUrl ?? "",
                refContent: res.first.refContent,
              ),
            ),
          );
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  getUserAudioTTS({
    required String audioId,
    CancelToken? cancelToken,
    void Function(AiOralAudioCloneDetailBean bean)? onSuccess,
    void Function()? onFail,
  }) {
    HttpUtils.get(
      APIs.queryUserAudioClone,
      {"id": int.parse(audioId)},
      cancelToken: cancelToken,
      // showLoading: true,
      success: (data) {
        byDebugPrint(data, tag: "获取配音详情:");
        final bean = AiOralAudioCloneDetailBean.fromJson(data["data"]);
        if (bean.status == 3) {
          onSuccess?.call(bean);
        } else if (bean.status == 2) {
          onFail?.call();
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  renameUserAudioTTS({
    required String id,
    required String name,
    void Function()? onSuccess,
    void Function()? onFail,
  }) {
    HttpUtils.post(
      APIs.renameUserAudioTTS,
      {"id": id, "title": name},
      showLoading: true,
      success: (data) {
        byDebugPrint(data);
        onSuccess?.call();
      },
      fail: (code, msg) {
        onFail?.call();
        BotToast.showText(text: msg);
      },
    );
  }

  saveUserAudioClone({required int id, final void Function()? onSuccess}) {
    HttpUtils.post(
      APIs.saveUserAudioClone,
      {"id": id},
      showLoading: true,
      success: (data) {
        byDebugPrint(data);
        onSuccess?.call();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  bool audioCreateQuerying = false;
  // updateAudioCreateQuerying(bool value) {
  //   audioCreateQuerying = value;
  //   notifyListeners();
  // }

  /// [ttsType] 选择的配音类型1系统音色 2自己的音色 3手动上传音色
  /// [ttsParamId] 系统配音时，创建的配音任务ID
  /// [userAudioCloneId] 选择自己的音色时， 克隆的音色ID
  /// [referenceAudioUrl] 选择上传文件时， 文件地址
  /// [content] 朗读的文本
  /// [refContent] 上传的音频中的文本内容 用于参考 非必填，但ttsType为1,2时最好有
  createUserAudioTTS({
    required int ttsType,
    int? ttsParamId,
    int? userAudioCloneId,
    String? referenceAudioUrl,
    String? content,
    String? refContent,
    bool showLoading = true,
    void Function(int tid)? onSuccess,
    void Function()? onFail,
  }) {
    HttpUtils.post(
      APIs.createUserAudioTTS,
      showLoading: showLoading,
      {
        "ttsType": ttsType,
        "ttsParamId": ttsParamId,
        "userAudioCloneId": userAudioCloneId,
        "referenceAudioUrl": referenceAudioUrl,
        "content": refContent,
        "refContent": content,
      },
      success: (data) {
        getVipRights();
        byDebugPrint(data);
        final id = data["data"]["id"];
        audioCreateQuerying = true;
        onSuccess?.call(id);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 获取配音详情
  getUserDubbingAudioTTS({
    required int id,
    CancelToken? cancelToken,
    bool isShowLoading = true,
    void Function(AiOralDubbingCloneDetailBean bean)? onSuccess,
    void Function()? onFaild,
  }) {
    HttpUtils.get(
      APIs.getUserAudioTTS,
      {"id": id},
      showLoading: isShowLoading,
      success: (data) {
        byDebugPrint(data);
        AiOralDubbingCloneDetailBean bean =
            AiOralDubbingCloneDetailBean.fromJson(data["data"]);
        if (bean.status == 4) {
          audioCreateQuerying = false;
          onSuccess?.call(bean);
        } else {
          onFaild?.call();
        }
      },
      cancelToken: cancelToken,
      fail: (code, msg) {
        onFaild?.call();
        BotToast.showText(text: msg);
      },
    );
  }

  AiOralDubbingCloneDetailBean? dubbingCloneDetailBean;
  updateDubbingCloneDetailBean(AiOralDubbingCloneDetailBean? bean) {
    byDebugPrint("dubbingCloneDetailBean-------updateDubbingCloneDetailBean");
    dubbingCloneDetailBean = bean;
    if (bean != null) {
      ttsId = bean.id;
    } else {
      ttsId = null;
    }
    notifyListeners();
  }

  int listeningDubbingId = -1;
  updateListeningDubbingId(int id) {
    listeningDubbingId = id;
    notifyListeners();
  }

  List<AiOralDubbingCloneDetailBean> dubbingCloneDetailBeanList = [];
  updateDubbingCloneDetailBeanList(List<AiOralDubbingCloneDetailBean> beans) {
    dubbingCloneDetailBeanList = beans;
    notifyListeners();
  }

  deleteUserAudioTTS({required int id, void Function()? onSuccess}) {
    HttpUtils.post(
      APIs.deleteUserAudioTTS,
      {"id": id},
      showLoading: true,
      success: (data) {
        onSuccess?.call();
        getUserAudioTTSList();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  getUserAudioTTSList({bool resset = false}) {
    HttpUtils.get(
      APIs.getUserAudioTTSList,
      {"status": 4, "page": 1, "pageSize": 100},
      showLoading: true,
      success: (data) {
        byDebugPrint(data);
        final List items = data["data"]["data"];
        final List<AiOralDubbingCloneDetailBean> beans = items
            .map((e) => AiOralDubbingCloneDetailBean.fromJson(e))
            .toList();
        updateDubbingCloneDetailBeanList(beans);
      },
    );
  }

  createDigitalHuman({
    required String refVideoUrl,
    required String refAudioUrl,
    int? userAudioTTSId,
    void Function(int tid)? onSuccess,
    int taskType = 2,

    ///1 旧模式 2 新模式
    int ttsType = 1,

    ///1
    String? content,
    int? ttsParamId,
    String? userAudioCloneId,
    String? referenceAudioUrl,
    String? refContent,
  }) {
    HttpUtils.post(
      APIs.createDigitalHuman,
      {
        "refVideoUrl": refVideoUrl,
        "refAudioUrl": refAudioUrl,
        "userAudioTTSId": userAudioTTSId,
        "face_restoration": enableEnhance,
        "task_type": taskType,
        "ttsType": ttsType,
        "content": content,
        "ttsParamId": ttsParamId,
        "userAudioCloneId": userAudioCloneId,
        "referenceAudioUrl": referenceAudioUrl,
        "refContent": refContent,
      },
      showLoading: true,
      success: (data) {
        getVipRights();
        byDebugPrint(data);
        final id = data["data"]["id"] ?? 0;
        onSuccess?.call(id);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        final integralVipController = IntegralVipController.getOrPut();
        integralVipController.handleStatusCode(code, msg, "ai_oral_videos");
      },
    );
  }

  getDigitalHumanDetails({
    required int id,
    CancelToken? cancelToken,
    void Function(AiOralVideotemBean bean)? onSuccess,
    void Function()? onFail,
  }) {
    HttpUtils.get(
      APIs.getDigitalHuman,
      {"id": id},
      showLoading: true,
      cancelToken: cancelToken,
      success: (data) {
        byDebugPrint(data);
        AiOralVideotemBean bean = AiOralVideotemBean.fromJson(data["data"]);
        if (bean.status == 4) {
          onSuccess?.call(bean);
        } else {
          onFail?.call();
        }
      },
      fail: (code, msg) {
        onFail?.call();
        BotToast.showText(text: msg);
      },
    );
  }

  RightsByType? rightsByType;
  updateRightsByType(RightsByType? type) {
    rightsByType = type;
    notifyListeners();
  }

  /// 获取VIP权益
  getVipRights() {
    HttpUtils.post(
      APIs.getRightsByType,
      {"type": "digital_human"},
      showLoading: false,
      success: (data) {
        final rghtsByType = RightsByType.fromJson(data["data"]);
        updateRightsByType(rghtsByType);
      },
      fail: (code, msg) {
        BotToast.showText(text: "获取权益失败");
      },
    );
  }

  ///音频文件tts id
  int? ttsId;

  /// 鉴黄
  ///[type] 鉴黄类型: 2图片 3音频 4视频
  ///[url]  url地址
  contentsRisk({
    int type = 4,
    required String url,
    void Function()? onSuccess,
  }) {
    Get.log("==创建了扫黄任务==");
    HttpUtils.post(
      APIs.contentsRisk,
      showLoading: false,
      showMsgWhenFailed: false,
      {"type": type, "url": url},
      success: (data) {
        Get.log("扫黄任务创建成功===$data");
        onSuccess?.call();
      },
      fail: (code, msg) {
        Get.log("扫黄任务创建失败结果===$code");
        if (code == -1) {
          // BotToast.showText(text: "视频违规，请重新选择");
        } else {
          BotToast.showText(text: msg);
        }
      },
    );
  }

  ///

  selectFirstData() {
    if (cloneBeans.isNotEmpty) {
      updateSelectedCloneId(cloneBeans.first.id);
    }
  }

  bool insertCloneMusicModel = false;

  ///选择我的克隆音频index
  int selectMyCloneMusicIndex = -1;

  updateSelectMyCloneMusicIndex() {
    Get.log("更新我的克隆声音index====> ${selectedCloneId}  ${cloneBeans.length}");
    if (selectedCloneId != -1 && cloneBeans.isNotEmpty) {
      for (var e in cloneBeans) {
        if (e.id == selectedCloneId) {
          selectMyCloneMusicIndex = cloneBeans.indexOf(e);
          notifyListeners();
          return;
        }
      }
    }
  }
}

class InsertCloneMusicModelEvent {
  final MusicModel model;
  const InsertCloneMusicModelEvent({required this.model});
}
