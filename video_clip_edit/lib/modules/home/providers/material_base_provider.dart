import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_clip_edit/modules/home/beans/cloud_video_bean.dart';
import 'package:video_clip_edit/modules/home/beans/function_item_bean.dart';
import 'package:video_clip_edit/modules/home/beans/subtitles_bean.dart';
import 'package:video_clip_edit/modules/home/clipped/beans/bgm_category_bean.dart';
import 'package:video_clip_edit/modules/home/clipped/beans/bgm_item_bean.dart';
import 'package:video_clip_edit/modules/home/clipped/beans/dubbing_bean.dart';
import 'package:video_clip_edit/modules/home/providers/clipped_provider.dart';
import 'package:video_clip_edit/modules/home/providers/forbidden_words_provider.dart';
import 'package:video_clip_edit/modules/home/providers/show_recreate_provider.dart';
import 'package:video_clip_edit/modules/home/providers/words_extract_provider.dart';
import 'package:video_clip_edit/modules/home/recreate/beans/role_bean.dart';
import 'package:video_clip_edit/modules/home/words/beans/audio_result_bean.dart';
import 'package:video_clip_edit/modules/home/words/beans/upload_info_bean.dart';
import 'package:video_clip_edit/providers/general_prohibite_words_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import 'package:video_clip_edit/utils/comon/by_ffmpeg_util.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_player/video_player.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_banner_mixin.dart';

/// provider的具体类型枚举
enum MaterialProviderType {
  /// 视频剪辑
  clip,

  /// 短剧二创
  recreate,

  /// 违禁词
  prohibited,

  general
}

typedef MaterialProviderTypeCallback = void Function(MaterialProviderType);

extension MaterialProviderTypeExt on MaterialProviderType {
  /// 获取枚举类型的真实类型:
  /// ClippedProvider、ShowRecreateProvider
  Type get realProviderType {
    switch (this) {
      case MaterialProviderType.clip:
        return ClippedProvider;
      case MaterialProviderType.recreate:
        return ShowRecreateProvider;
      case MaterialProviderType.prohibited:
        return ForbiddenWordsProvider;
      case MaterialProviderType.general:
        return GeneralProhibiteWordsProvider;
    }
  }

  static MaterialProviderType providerTypeFromType(Type t) {
    return MaterialProviderType.values.firstWhere(
      (e) => e.realProviderType == t,
    );
  }

  static void handleType({
    required Type type,
    required MaterialProviderTypeCallback callback,
  }) {
    callback(MaterialProviderTypeExt.providerTypeFromType(type));
  }
}

enum MaterialProviderGeneratingMode {
  /// 极速模式
  speedy,

  /// 精细模式
  delicate
}

extension MaterialProviderGeneratingModeExt on MaterialProviderGeneratingMode {}

abstract class MaterialBaseProvider extends AiBannerMixin {
  /// 缓存资源字幕
  Map<String, String> srtMap = {};

  /// 缓存资源字幕
  Map<String, String> audioFilePahMap = {};

  /// provider的类型：
  /// 视频混剪、短剧二创
  MaterialProviderType type = MaterialProviderType.clip;

  /// 视频的生成模式
  /// 极速模式、精细模式
  MaterialProviderGeneratingMode? generatingMode;

  /// 更新视频的生成模式
  changeGeneratingMode(MaterialProviderGeneratingMode mode) {
    generatingMode = mode;
    notifyListeners();
  }

  bool forbidden = false;

  void updateForbiddenState(bool state) {
    forbidden = state;
    notifyListeners();
  }

  String replacedResult = "";
  updateReplacedResult(String res) {
    replacedResult = res;
    notifyListeners();
  }

  final functionList = [
    FunctionItemBean.fromJson({
      "icon": "assets/home/watermark_upload.png",
      "title": "本地上传",
      "desc": "上传本地图片、视频文件"
    }),
    FunctionItemBean.fromJson({
      "icon": "assets/home/watermark_my_woks.png",
      "title": "我的作品",
      "desc": "上传我的作品文件"
    }),
    FunctionItemBean.fromJson({
      "icon": "assets/home/icon_cloud_art.png",
      "title": "云端素材",
      "desc": "上传云端素材"
    }),
  ];
  bool selectAll = false;
  changeSelectAllStatus(bool status) {
    selectAll = status;

    notifyListeners();
  }

  final videoRatios = ["9:16", "16:9"];
  int selectedRatioIdx = 0;
  changeSelectedRatioIdx(int index) {
    selectedRatioIdx = index;
    notifyListeners();
  }

  Future<void> addNewWork(
    List<dynamic> assets, {
    void Function(dynamic)? onSuccess,
  });

  updateSrtForAsset(dynamic asset, String srtFilePath) async {
    if (asset is File) {
      srtMap[asset.path] = srtFilePath;
    } else if (asset is AssetEntity) {
      final file = await asset.file;
      if (file != null && file.path.isNotEmpty) {
        srtMap[file.path] = srtFilePath;
      }
    }
  }

  updateAudioFilePathForAsset(dynamic asset, String audioFilePath) async {
    if (asset is File) {
      audioFilePahMap[asset.path] = audioFilePath;
    } else if (asset is AssetEntity) {
      final file = await asset.file;
      if (file != null && file.path.isNotEmpty) {
        audioFilePahMap[file.path] = audioFilePath;
      }
    }
  }

  /// 选中的素材
  List<dynamic> selectedMaterials = [];

  /// 选中素材的字幕列表
  List<Map<String, String>> selectedMaterialSrts = [];

  indexOfMaterial(dynamic materials) {
    if (materials is AssetEntity) {
      return selectedMaterials.indexOf(materials);
    }

    int result = 0;
    for (var i = 0; i < selectedMaterials.length; i++) {
      final ma = selectedMaterials[i];
      if (ma is File && ma.path == materials.path) {
        result = i;
      }
    }
    return result;
  }

  /// 添加素材
  addNewMaterials(List<dynamic> materials) {
    final filePaths =
        selectedMaterials.whereType<File>().map((ele) => ele.path).toList();
    for (var e in materials) {
      if (e is AssetEntity && !selectedMaterials.contains(e)) {
        selectedMaterials.add(e);
      } else if (e is File && !filePaths.contains(e.path)) {
        selectedMaterials.add(e);
      }
    }
    notifyListeners();
  }

  /// 选中的对应名称下的素材列表
  List<Detail> selectedVideoDetailBeans = [];
  updateSelectedVideoDetailBeans(Detail bean) {
    final videoUrls = selectedVideoDetailBeans.map((e) => e.videoUrl).toList();
    final currentUrl = bean.videoUrl;
    if (videoUrls.contains(currentUrl)) {
      selectedVideoDetailBeans.removeAt(videoUrls.indexOf(currentUrl));
    } else {
      selectedVideoDetailBeans.add(bean);
    }
    notifyListeners();
  }

  /// 清空选中的素材
  clearSelectedMaterials() {
    selectedMaterials.clear();
    notifyListeners();
  }

  /// 移除素材
  removeMaterial(dynamic material) {
    final filePaths = selectedMaterials
        .whereType<File>()
        .map(
          (ele) => ele.path,
        )
        .toList();
    if (material is AssetEntity && selectedMaterials.contains(material)) {
      selectedMaterials.remove(material);
    } else if (material is File && filePaths.contains(material.path)) {
      selectedMaterials.remove(material);
      final selectedUrls =
          selectedVideoDetailBeans.map((e) => e.videoUrl).toList();
      bool selected = false;
      int selctedIndex = -1;
      for (var e in selectedUrls) {
        if (e.contains(material.path.split(Platform.pathSeparator).last)) {
          selected = true;
          selctedIndex = selectedUrls.indexOf(e);
        }
      }

      /// 如果 selectedVideoDetailBeans 中包含该资源，将其从 selectedVideoDetailBeans 中移除
      if (selected) {
        selectedVideoDetailBeans.removeAt(selctedIndex);
      }
    }
    notifyListeners();
  }

  updateSelectedMaterials(List<dynamic> materials) {
    selectedMaterials = materials;
    notifyListeners();
  }

  updateSelectedMaterialAtIndex(dynamic material, int index) {
    selectedMaterials[index] = material;
    notifyListeners();
  }

  dynamic assetSpeedy;
  updateAssetSpeedy(dynamic asset) {
    assetSpeedy = asset;
    notifyListeners();
  }

  /// 是否在配音界面显示录音后的语音条，默认为false
  bool showAudioBar = false;
  changeShowAudioStatus(bool show) {
    if (showAudioBar == show) return;
    showAudioBar = show;
    notifyListeners();
  }

  Future<int> calculateVideoDuration(dynamic asset) async {
    final isFile = asset is File;
    File? file;
    if (isFile) {
      file = asset;
    } else if (asset is AssetEntity) {
      file = await asset.file;
    }
    final controller = VideoPlayerController.file(file!);
    await controller.initialize();
    return controller.value.duration.inSeconds;
  }

  String recordingFilePath = "";
  updateReordingFilePath(String path) {
    recordingFilePath = path;
    notifyListeners();
  }

  /// 字幕特效
  bool removeVideoAudio = false;
  updateRemoveVideoAudioStatus(bool status) {
    removeVideoAudio = status;
    notifyListeners();
  }

  final ratios = [
    "原始",
    "16:9",
    "9:16",
    "1:1",
    "3:4",
    "4:3",
  ];
  late String selectedRatio = ratios[0];
  void updateSelectedRatio(String e) {
    selectedRatio = e;
    notifyListeners();
  }

  String updateMultiSelectableElements<E>(E ele, String source) {
    // if (source.contains(ele)) {
    //   if (source.length > 1) {
    //     source.remove(ele);
    //   }
    // } else {
    //   source.add(ele);
    // }
    // source=ele;
    return source;
  }

  final subTitles = ["无字幕", "有字幕"];
  late String selectedSubTitle = subTitles[0];
  void updateSelectedSubTitle(String e) {
    selectedSubTitle = e;
    notifyListeners();
  }

  final modes = ["雪花开幕", "粒子模糊", "泡泡变焦", "噪点"];
  late String selectedModes = modes[0];
  void updateSelectedModes(String e) {
    selectedModes = e;
    // updateMultiSelectableElements(e, selectedModes);
    notifyListeners();
  }

  // , "随机加速"
  final speciaEffects = ["基础去重", "智能调色", "画面锐化"];
  late String selectedSpeciaEffect = speciaEffects[0];
  void updateSelectedSpeciaEffect(String e) {
    selectedSpeciaEffect = e;
    // updateMultiSelectableElements(e, selectedSpeciaEffect);
    notifyListeners();
  }

  final bgms = [
    "无",
    "智能配乐",
    "本地上传",
  ];
  late int selectedBgmIndex = 0;
  late String selectedBgm = bgms[selectedBgmIndex];
  late String bgmFilePath = '';

  void updateSelectedBgm(String bfp, int index) {
    selectedBgmIndex = index;
    bgmFilePath = bfp;
    notifyListeners();
  }

  /// ====================================== 字幕内容 ======================================
  /// 字幕内容实体
  SubtitlesBean subtitlesBean = SubtitlesBean.fromJson({
    "wordsOrigin": "",
    "wordsDisplay": "",
  });

  /// 更新字幕内容实体
  updateSubtitlesBean(SubtitlesBean bean) {
    subtitlesBean = bean;

    notifyListeners();
  }

  /// 将选中的违禁词替换为[word]
  replaceWord(String word, Function call) {
    final bean = subtitlesBean.copyWith();
    final contents = bean.wordsOrigin.replaceAll(selectedProhibiteWord, word);
    byDebugPrint(contents);
    prohibiteWords.removeWhere((item) => item == selectedProhibiteWord);
    updateProhibiteWords(prohibiteWords);
    bean.wordsOrigin = contents;
    updateSubtitlesBean(bean);

    call();
  }

  /// 将字幕更新为指定的内容 [content]
  updateSubtitle(
    String content, {
    void Function()? onsSuccess,
  }) {
    final bean = subtitlesBean.copyWith();

    /// 将字幕bean的原内容更新为 [content] 去除违禁词标记的后内容
    bean.wordsOrigin = content; //content.withoutProhibitedTag;
    updateSubtitlesBean(bean);

    onsSuccess?.call();
  }

  /// 任意内容替换
  replaceAnyWord(String source, String word) {
    final bean = subtitlesBean.copyWith();
    final contents = bean.wordsOrigin.replaceAll(source, word);
    byDebugPrint(contents);
    bean.wordsOrigin = contents;
    updateSubtitlesBean(bean);
  }

  /// 是否包含违禁词
  bool hasProhibiteWords() {
    for (var e in prohibiteWords) {
      if (subtitlesBean.wordsOrigin.contains(e)) {
        return true;
      }
    }
    return false;
  }

  /// 违禁词列表
  List<String> prohibiteWords = [];
  updateProhibiteWords(List<String> words) {
    prohibiteWords = [];
    prohibiteWords = words;
    if (prohibiteWords.isNotEmpty) {
      selectedProhibiteWord = prohibiteWords.first;
    } else {
      selectedProhibiteWord = "";
    }
    notifyListeners();
  }

  /// 当前选中的违禁词
  late String selectedProhibiteWord = "";

  /// 更新当前选中的违禁词
  void updateSelectedProhibiteWord(String e) {
    selectedProhibiteWord = e;
    notifyListeners();
  }

  void detect(
    BuildContext context,
    String content, {
    void Function()? onSuccess,
  });

  textRisk({
    String? type,
    String? needMark,
    required String content,
    void Function(dynamic)? onSuccess,
  });

  replaceWithInitialLetterOfPinyin() {
    final bean = subtitlesBean.copyWith();
    String content = bean.wordsOrigin;
    for (var e in prohibiteWords) {
      content = content.replaceAll(e, e.getFirstLetters());
    }
    return content;
  }

  /// ==========================================================================================

  List<String> styles = [];

  loadStyles({
    void Function(List<String>)? onSuccess,
  }) {}

  updateStyles(List<String> stls) {
    styles = stls;
    notifyListeners();
  }

  String? selectedStyle;
  void updateSelectedStyle(String e) {
    selectedStyle = e;
    notifyListeners();
  }

  /// 修改风格
  changeVoiceStyle({void Function(String taskId)? onSuccess}) {}

  /// 查询风格修改进度
  queryVoiceStyleOptimizeState(
      {required String taskId, void Function(String result)? onSuccess}) {}

  List<RoleBean> roles = [
    RoleBean.fromJson({
      "userId": "1",
      "name": "角色1",
      "avatar": "https://koc-img.lizhibj.cn/xgfx/app/douyin.png"
    }),
    RoleBean.fromJson({
      "userId": "2",
      "name": "角色2",
      "avatar": "https://koc-img.lizhibj.cn/xgfx/app/douyin.png"
    }),
    RoleBean.fromJson({
      "userId": "3",
      "name": "角色3",
      "avatar": "https://koc-img.lizhibj.cn/xgfx/app/douyin.png"
    }),
    RoleBean.fromJson({
      "userId": "4",
      "name": "角色4",
      "avatar": "https://koc-img.lizhibj.cn/xgfx/app/douyin.png"
    }),
  ];

  updateRoles(RoleBean role) {
    RoleBean roleFind = roles.firstWhere((e) => e.userId == role.userId);
    roles[roles.indexOf(roleFind)] = role;
    notifyListeners();
  }

  int cloudPage = 1;
  int cloudPageSize = 100;
  List<CloudVideoListBean> cloudVidesBeans = [];
  updateCloudVidesBeans(List<CloudVideoListBean> beans) {
    cloudVidesBeans = beans;
    notifyListeners();
  }

  List<CloudVideoListBean> listBeans = [];
  updateListBeans(List<CloudVideoListBean> beans) {
    listBeans = beans;
    notifyListeners();
  }

  /// 加载云端视频
  loadCloudVideos({
    required void Function(List<CloudVideoListBean>)? onSuccess,
    String? type,
  }) {
    HttpUtils.get(
      APIs.cloudVideosList,
      {
        "pageSize": cloudPageSize.toString(),
        "page": cloudPage.toString(),
        "type": type ?? "1",
      },
      showLoading: true,
      success: (data) {
        byDebugPrint(data["data"], tag: "云端素材：");
        List listData = data["data"]["data"] ?? [];
        List<CloudVideoListBean> beans =
            listData.map((e) => CloudVideoListBean.fromJson(e)).toList();
        cloudPage = cloudVidesBeans.addElementsByRemovingLast(
          beans,
          currentPage: cloudPage,
          pageSize: cloudPageSize,
        );

        updateListBeans(beans);
        onSuccess?.call(beans);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 对应名称下的素材列表
  List<Detail> videoDetailBeans = [];
  updateVideoDetailBeans(List<Detail> beans) {
    videoDetailBeans = beans;
    notifyListeners();
  }

  /// 根据视频id加载视频详情
  loadCloudVideosForName({
    required String id,
    required void Function(List<Detail>)? onSuccess,
  }) {
    HttpUtils.get(
      APIs.getMaterialDetail,
      {
        "id": id,
        "pageSize": 100,
      },
      success: (data) {
        final List listData = data["data"]["data"] ?? [];
        List<Detail> beans = listData.map((e) => Detail.fromJson(e)).toList();

        updateVideoDetailBeans(beans);
        onSuccess?.call(beans);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  loadSpeakers({
    String? domainId = "影视",
    String? sex = "男",
    String? age = "少年",
    String? platform = "volcengine",
    void Function(List<DubbingBean>)? onSuccess,
  }) {
    HttpUtils.post(
      APIs.speakerList,
      {
        // "domainId": domainId,
        // "mainEmotion": "",
        // "sex": sex,
        // "age": age,
        "platform": platform,
        "page": 1,
        "size": 999,
      },
      showLoading: true,
      success: (data) {
        byDebugPrint(data);
        if (data["status"] == 200) {
          final items = data["data"]["items"] ?? [];
          List<DubbingBean> speakerBeans = List<DubbingBean>.from(
              (items).map((x) => DubbingBean.fromJson(x)));
          updateDubbingBeans(speakerBeans);
          onSuccess?.call(speakerBeans);
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 文字转音频
  words2Audio(
    String text, {
    // 配音人参数
    String? speaker,
    // 文件名
    String? name,
    // 语速 0.5-2.0
    double? speed = 0,
    // 音调
    int? pitch = 0,
    String? pid,
    bool? startTask = true,
    String? platform = "volcengine",
    void Function(String taskId)? onSuccess,
  }) {
    HttpUtils.post(
      APIs.createDubbingTask,
      {
        "text": text,
        "speaker": speaker ?? "",
        "name": "文件_${DateTime.now().millisecondsSinceEpoch}",
        "speed": speed,
        "pitch": pitch,
        "pid": pid ?? "",
        "startTask": startTask,
        "platform": platform,
        "need_risk": 1,
      },
      showLoading: true,
      success: (data) {
        final taskID = data["data"];
        byDebugPrint(taskID, tag: "文字转音频taskID:");
        onSuccess?.call(taskID.toString());
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  queryWords2AudioStatus(
    String taskId, {
    void Function(String url, String urlSrt)? onSuccess,
  }) {
    HttpUtils.post(
      APIs.getDubbingTaskDetails,
      {"pid": taskId},
      // showLoading: true,
      showMsgWhenFailed: false,
      success: (data) {
        final url = data["data"]["order"]["audio_link"] ?? "";
        final urlSrt = data["data"]["order"]["srt_link"] ?? "";
        onSuccess?.call(url, urlSrt);
      },
      fail: (code, msg) {
        Future.delayed(
          const Duration(seconds: 1),
          () {
            queryWords2AudioStatus(taskId, onSuccess: onSuccess);
          },
        );
      },
    );
  }

  /// 获取配音列表
  loadDubbingList({
    void Function(List<DubbingBean>)? onSuccess,
  }) {}
  List<DubbingBean>? dubbingBeans;

  /// 选中的试听下标
  int selectedAuditionDubbingIdx = -1;
  updateSelectedAuditionDubbingIdx(int index) {
    selectedAuditionDubbingIdx = index;
    notifyListeners();
  }

  int selectedDubbingIdx = -1;
  updateSelectedDubbingIdx(int index) {
    selectedDubbingIdx = index;
    notifyListeners();
  }

  updateDubbingBeans(List<DubbingBean> beans) {
    dubbingBeans = beans;
    notifyListeners();
  }

  /// 获取配音列表
  loadBgmList({
    bool reset = false,
  }) {}
  List<BgmItemBean> bgmBeans = [];
  updateBgmBeans(List<BgmItemBean> beans) {
    bgmBeans = beans;
    notifyListeners();
  }

  int selectedBgmIdx = -1;
  updateSelectedBgmIdx(int index) {
    selectedBgmIdx = index;
    notifyListeners();
  }

  int selectedAuditionBgmIdx = -1;
  updateSelectedAuditionsBgmIdx(int index) {
    selectedAuditionBgmIdx = index;
    notifyListeners();
  }

  /// 获取配音分类列表
  loadBgmCateoryList() {}

  List<BgmCategoryBean>? bgmCategoryBeans;
  updateBgmCategoryBeans(List<BgmCategoryBean> beans) {
    bgmCategoryBeans = beans;
    notifyListeners();
  }

  int selectedBgmCategoryIdx = -1;
  updateSelectedBgmCategoryIdx(int index) {
    selectedBgmCategoryIdx = index;
    notifyListeners();
  }

  /// 角色台词列表
  List<AudioResultBean> speakerQuotesBeans = [];
  updateSpeakerQuotesBeans(List<AudioResultBean> beans) {
    speakerQuotesBeans = beans;
    notifyListeners();
  }

  /// 更新作品 - status: 0待处理 1处理中 2成功 3失败
  updateWork({
    dynamic params,
    void Function(dynamic)? onSuccess,
  }) {
    HttpUtils.post(
      APIs.updateWorkLog,
      params,
      showMsgWhenFailed: false,
      success: (data) {
        onSuccess?.call(data);
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
      },
    );
  }

  audio2text({
    required File file,
    required void Function(String res) onSuccess,
  }) {
    EasyLoading.show(status: "声音解析中...");
    ByFfmpegUtil.splitAudioFileFromVideo(
      file,
      onSuccess: (audioInfo) {
        final audioPath = audioInfo.item2;

        /// 使用火山接口获取音频文案
        ByFfmpegUtil.loadUploadInfo(
          type: MediaType.audio,
          onSuccess: (UploadInfoBean infoBean) {
            /// 上传
            ByFfmpegUtil.uploadFile(
              infoBean: infoBean,
              filePath: audioPath,
              onSuccess: (resp) {
                EasyLoading.show(status: "文字识别中...");
                ByFfmpegUtil.textExtractByAudio(
                  audioUrl: infoBean.objectUrl,
                  onSuccess: (String requestID) {
                    /// 轮询状态
                    _loadParsingProgress(requestID, onSuccess: onSuccess);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  /// 查询文字解析状态
  void _loadParsingProgress(
    String requestID, {
    void Function(String res)? onSuccess,
  }) {
    ByFfmpegUtil.queryAudioRecognitionTask(
      requestID: requestID,
      onSuccess: (data) {
        final status = data["status"];
        if (status != 3) {
          Future.delayed(const Duration(seconds: 1), () {
            _loadParsingProgress(requestID, onSuccess: onSuccess);
          });
        } else if (status == 3) {
          EasyLoading.dismiss();
          final List beansData = data["content"] ?? [];
          List<AudioResultBean> beans =
              beansData.map((e) => AudioResultBean.fromJson(e)).toList();
          var res = "";
          for (var e in beans) {
            res += e.text;
          }
          onSuccess?.call(res);
        }
      },
    );
  }

  String workId = "";
}
