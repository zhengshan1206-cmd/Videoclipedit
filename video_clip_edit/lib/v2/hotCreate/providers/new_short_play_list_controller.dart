import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/modules/home/beans/cloud_video_bean.dart';
import 'package:video_clip_edit/modules/home/beans/home_broadcast_bean.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/kuaishou_douyin_model.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_settings_mixin.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_video_player.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/short_play_create_provider.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/short_show_details_provider.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';
import '../../../modules/home/beans/text_risk_bean.dart';
import '../../../modules/home/clipped/beans/dubbing_bean.dart';
import '../../../providers/launch_provider.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/comon/by_nav_router_utils.dart';
import '../../../utils/consts/const.dart';
import '../../aiClip/provider/ai_clip_opening_provider.dart';
import '../../aiClip/provider/ai_clip_provider.dart';
import '../../aiClip/provider/ai_material_provider.dart';
import '../../aiSquare/ai_vip_guid_page.dart';
import '../../aiSquare/cartoon/ai_cartoon_video_management_page.dart';
import '../../aiSquare/cartoon/beans/ai_cartoon_dubbing_bean.dart';
import '../../aiSquare/cartoon/beans/ai_cartoon_item_bean.dart';
import '../../aiSquare/cartoon/beans/ai_cartoon_video_font_bean.dart';
import '../../aiSquare/cartoon/beans/ai_cartoon_video_ratio_bean.dart';
import '../../aiSquare/cartoon/provider/ai_cartoon_video_management_provider.dart';
import '../../aiSquare/cartoon/widgets/ai_cartoon_prohibited_words_dailog.dart';
import '../../aiSquare/providers/ai_vip_guid_provider.dart';
import '../hot_short_play_create_page.dart';
import '../short_play_list_page.dart';
import '../../aiClip/ai_clip_page.dart';

///新的短剧展示业务逻辑
class NewShortPlayListController extends GetxController {
  ///1展示多个剧可选择的页面 2展示单个剧的详情页面
  int type = 1;

  /// 广播列表
  List<HomeBroadcastBean> broadcastBeans = [];

  /// 短剧列表
  List<CloudVideoListBean> shortPlayBeans = [];

  ///页码1 每页数量多少
  int page = 1;
  int size = 10;

  /// 对应名称下的素材列表
  List<Detail> selectedVideoDetailBeans = [];

  ///解说脚步 解说视频配置选项
  int selectCommentaryType = 1;

  ///首次进入默认选择第一个短剧 对应短剧的索引
  int selectedShortPlayBeansIndex = 0;

  ///选中的剧的id 集合
  List<int> idsList = [];

  ///是否可以进行下一步
  bool couldNextStep = false;

  /// 是否正在生成解说文案
  bool generatingCommentary = false;

  ///定时相关的业务 --这里只涉及到轮循查询
  Timer? _timer;

  /// 超时时间 10s
  int timeout = 10;
  double timeCost = 0;

  ///解说文案
  String desc = "";

  ///解说是否失败
  bool isDescError = false;

  /// 选中的画面风格id
  int selectedRatioId = 4;

  /// 配置选项
  List<List<AiCartoonItemBean>> sectionConfigBeans = [
    [
      AiCartoonItemBean.fromJson({
        "value": "",
        "placeholder": "请选择配音",
        "type": AiCartoonItemBeanType.voice,
        "shouldBold": false,
        "required": true,
        "imgPath": "assets/ai/icon_cartoon_voice.png",
        "title": "解说角色",
        "hasHeader": true,
      }),
      AiCartoonItemBean.fromJson({
        "value": "",
        "placeholder": "请选择视频比例",
        "type": AiCartoonItemBeanType.ratio,
        "shouldBold": false,
        "required": true,
        "imgPath": "assets/ai/icon_cartoon_ratio.png",
        "title": "视频比例",
        "hasHeader": true,
      }),
    ],
    [
      AiCartoonItemBean.fromJson({
        "value": "请选择背景音乐",
        "placeholder": "请选择背景音乐",
        "type": AiCartoonItemBeanType.bgm,
        "shouldBold": false,
        "imgPath": "assets/ai/icon_cartoon_bgm.png",
        "title": "背景音乐",
        "required": false,
        "hasHeader": true,
      }),
      AiCartoonItemBean.fromJson({
        "value": "(可选)",
        "placeholder": "请选择字幕样式",
        "type": AiCartoonItemBeanType.font,
        "shouldBold": false,
        "imgPath": "assets/ai/icon_cartoon_fonts.png",
        "title": "视频字幕",
        "required": false,
        "hasHeader": true,
      }),
    ],
    [
      AiCartoonItemBean.fromJson({
        "value": "更多设置",
        "placeholder": "更多设置",
        "type": AiCartoonItemBeanType.settings,
        "shouldBold": true,
        "imgPath": "assets/ai/icon_cartoon_settings.png",
        "title": "更多设置",
        "required": false,
        "hasHeader": false,
      }),
    ],
  ];

  /// 视频比例
  List<AiCartoonVideoRatioBean> videoRatioBeans = [];

  /// 选中的字幕样式id
  int selectedFontId = -1;

  /// 画面字幕样式
  List<AiCartoonVideoFontBean> videoFontBeans = [];

  /// 角色配音
  List<AiCartoonDubbingBean> dubbingBeans = [];

  /// 选中的配音角色id
  int selectedDubbingId = -1;

  /// 选中的背景音乐url
  String selectedBgmUrl = "";

  /// 选中的bgm id
  int selectedBgmId = -1;

  ///更多设置
  double videoTimes = 1.0;
  double voiceSpeed = 1.0;
  double voiceVolume = 1.0;
  double bgmSpeed = 1.0;
  double bgmVolume = 1.0;

  List<String> bandedWords = [];

  ///当前的短剧
  CloudVideoListBean? cloudVideoListBean;

  late StreamSubscription streamSubscription;

  //存储已经生成的短剧解说脚本
  Map<String, String> generatedScripts = {};
  //存储已经生成的短剧解说剧集
  Map<String, List<Detail>> generatedVideos = {};

  String prePagePath = "";

  /// 是否从短剧引导页进入
  bool fromShortDramaGuide = false;

  @override
  void onInit() {
    super.onInit();
    initData();
    loadVideoFonts();
    loadDubbingList();
    streamSubscription = eventBus.on<RefreshDataEvent>().listen((e) {
      desc = "";
      initData(arguments1: e.arguments);
    });
    actionClickReport();
  }

  @override
  void onClose() {
    streamSubscription.cancel();
    super.onClose();
  }

  initData({dynamic arguments1}) {
    var arguments = Get.arguments;
    if (arguments1 != null) {
      arguments = arguments1;
      prePagePath = arguments1["prePagePath"] ?? "";
      fromShortDramaGuide = arguments1["fromShortDramaGuide"] ?? false;
    }
    if (arguments != null) {
      // 接收 fromShortDramaGuide 参数
      fromShortDramaGuide = arguments["fromShortDramaGuide"] ?? false;
      prePagePath = arguments["prePagePath"] ?? prePagePath;

      dynamic videoListBeanJson = arguments["videoListBean"];
      if (videoListBeanJson != null) {
        cloudVideoListBean = videoListBeanJson;
        type = 2;
        selectedVideoDetailBeans = cloudVideoListBean!.details;
        loadCloudVideosForName(
          id: cloudVideoListBean!.id.toString(),
          onSuccess: (List<Detail> value) {},
        );
        update();
      }
    } else {
      loadCloudVideos();
      loadDesc();
    }
  }

  /// 加载广播
  loadBroadcast() {
    HttpUtils.get(
      APIs.homeBroadcast,
      {},
      success: (data) {
        final List bannerData = data["data"] ?? [];
        List<HomeBroadcastBean> beans = bannerData
            .map((e) => HomeBroadcastBean.fromJson(e))
            .toList();
        updateBroadcastBeans(beans);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  updateBroadcastBeans(List<HomeBroadcastBean> beans) {
    broadcastBeans = beans;
    update(['broadcastBeans']);
  }

  /// 加载云端视频
  /// [type] 1普通素材 2短剧
  loadCloudVideos({
    bool isRefresh = false,
    bool showLoading = false,
    void Function(bool hasMore)? onSuccess,
    void Function()? onFail,
  }) {
    if (isRefresh) {
      page = 1;
    }
    HttpUtils.get(
      APIs.cloudVideosList,
      {"type": "2", "page": page.toString(), "pageSize": size.toString()},
      showLoading: showLoading,
      success: (data) {
        byDebugPrint(data["data"], tag: "云端素材：");
        List listData = data["data"]["data"] ?? [];

        if (isRefresh) {
          shortPlayBeans.clear();
        }
        final List<CloudVideoListBean> results = List.from(shortPlayBeans);

        List<CloudVideoListBean> beans = listData
            .map((e) => CloudVideoListBean.fromJson(e))
            .toList();

        page = results.addElementsByRemovingLast(
          beans,
          currentPage: page,
          pageSize: size,
        );

        updateShortPlayBeansBeans(results);
        onSuccess?.call(beans.isNotEmpty && beans.length == size);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        onFail?.call();
      },
    );
  }

  ///刷新短剧素材
  updateShortPlayBeansBeans(List<CloudVideoListBean> beans) {
    shortPlayBeans = beans;
    if (shortPlayBeans.isNotEmpty) {
      loadCloudVideosForName(
        id: shortPlayBeans.first.id.toString(),
        onSuccess: (value) {},
      );
    }

    update();
  }

  /// 根据视频id加载视频详情
  loadCloudVideosForName({
    required String id,
    required void Function(List<Detail>)? onSuccess,
  }) {
    if (generatedVideos.keys.contains(id)) {
      selectedVideoDetailBeans = generatedVideos[id]!;
      initSelectedShortPlay(list: selectedVideoDetailBeans);
      changeShortPlayAndGetAiText();
      update();
      onSuccess?.call(selectedVideoDetailBeans);
    } else {
      loadDetailCloudVideosForName(id: id, onSuccess: onSuccess);
    }
  }

  /// 根据视频id加载视频详情
  loadDetailCloudVideosForName({
    required String id,
    required void Function(List<Detail>)? onSuccess,
  }) {
    HttpUtils.get(
      APIs.getMaterialDetail,
      {"id": id, "page": 1, "pageSize": 500},
      showLoading: false,
      success: (data) {
        final List listData = data["data"]["data"] ?? [];
        List<Detail> beans = listData.map((e) => Detail.fromJson(e)).toList();
        selectedVideoDetailBeans = beans;
        //存储生成的短剧剧集
        generatedVideos[id] = selectedVideoDetailBeans;
        initSelectedShortPlay(list: selectedVideoDetailBeans);
        changeShortPlayAndGetAiText();
        update();
        onSuccess?.call(beans);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///选择不同的配置
  void changeMode({required int modeValue}) {
    selectCommentaryType = modeValue;
    update();
  }

  ///选择不同的剧
  void selectedNewShortPlayBeans({required int index, required int id}) {
    if (generatingCommentary) {
      BotToast.showText(text: "正在生成AI解说文案,请耐心等待~");
      return;
    }
    selectedShortPlayBeansIndex = index;
    desc = "";
    couldNextStep = false;
    loadCloudVideosForName(id: id.toString(), onSuccess: (value) {});
    update();
  }

  ///初始化选中剧的前三集
  void initSelectedShortPlay({required List<Detail> list}) {
    if (list.isNotEmpty && list.length >= 3) {
      idsList = [];
      idsList.add(list[0].id);
      idsList.add(list[1].id);
      idsList.add(list[2].id);
    }
  }

  ///改变选中的剧集
  changeSelectedShortPlay({required int id}) {
    if (idsList.isEmpty) {
      idsList.add(id);
    } else {
      bool hasIt = idsList.contains(id);
      if (hasIt) {
        idsList.remove(id);
      } else {
        idsList.add(id);
      }
    }
    update();
  }

  ///得到被选中的视频内容
  String getSelectedVideoContents() {
    if (selectedVideoDetailBeans.isEmpty || idsList.isEmpty) return "";
    List<String> contents = [];
    for (var e1 in idsList) {
      for (var e in selectedVideoDetailBeans) {
        if (e1 == e.id) {
          final content = e.content;
          if (content.isNotEmpty) {
            final jsonData = jsonDecode(content);
            final isList = jsonData != null && jsonData is List;
            if (isList) {
              List res = jsonData.map((ele) {
                return ele["text"] ?? "";
              }).toList();
              contents.add(res.join(""));
            }
          }
        }
      }
    }
    return contents.join("");
  }

  ///选中的视频id
  String getSelectedVideoIds() {
    final selectedIds = idsList.join(',');
    return selectedIds;
  }

  void _initTimer() {
    _timer?.cancel();

    /// 初始化一个定时器，每0.5秒，让进度增加0.1
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      timeCost += 0.1;
      if (timeCost >= timeout) {
        _timer?.cancel();

        /// todo 请求超时 需要增加
      }
    });
  }

  ///第一次调用文案解说接口
  getCommentarySimpleText({
    required String text,
    void Function(String taskId)? onSuccess,
    void Function()? onFailed,
  }) {
    HttpUtils.post(
      APIs.getCommentarySimpleText,
      {"text": text},
      success: (data) {
        byDebugPrint(data, tag: "getCommentarySimpleText------:");
        final taskId = data["data"]["task_id"] ?? "";
        onSuccess?.call(taskId);
      },
      showMsgWhenFailed: false,
      fail: (code, msg) {
        onFailed?.call();
      },
    );
  }

  ///生成解说文案
  void generateCommentary(String text) {
    final selectedIds = getSelectedVideoIds();
    if (selectedIds.isEmpty) {
      return;
    }
    //是否有本地缓存记录
    if (generatedScripts.keys.contains(selectedIds)) {
      String? savedDesc = generatedScripts[selectedIds];
      updateIsDescError(value: false);
      updateGeneratingCommentary(false);
      updateDesc(savedDesc!);
    } else {
      updateGeneratingCommentary(true);
      //重新请求刷新数据
      rewriteCommentarySimpleTextByAI(ids: selectedIds);
    }
  }

  ///生成解说文案
  // void generateCommentary(
  //   String commentaryDesc, {
  //   void Function()? onSuccess,
  //   void Function()? onFailed,
  // }) {
  //   getCommentarySimpleText(
  //     text: commentaryDesc,
  //     onSuccess: (taskId) {
  //       if (taskId.isEmpty) {
  //         onFailed?.call();
  //         BotToast.showText(text: "生成解说文案失败，请稍后再试");
  //         return;
  //       }

  //       /// 轮询查询生成结果
  //       queryVoiceStyleOptimizeState(
  //         taskId: taskId,
  //         onSuccess: (result) {
  //           if (result.isNotEmpty) {
  //             /// 转换解说文案
  //             Get.log("转换解说文案的结果===> $result");
  //             updateGeneratingCommentary(false);
  //             updateDesc(result);
  //             rewriteCommentarySimpleTextByAI(ids: getSelectedVideoIds());
  //             updateIsDescError(value: false);
  //             onSuccess?.call();
  //           }
  //         },
  //       );
  //     },
  //     onFailed: () {
  //       onFailed?.call();
  //       updateIsDescError(value: true);
  //       BotToast.showText(text: "生成解说文案失败，请稍后再试");
  //     },
  //   );
  // }

  ///查询解说文案 会被轮循调用
  queryVoiceStyleOptimizeState({
    required String taskId,
    void Function(String result)? onSuccess,
  }) {
    HttpUtils.get(
      APIs.queryOptimizeTextState,
      {"task_id": taskId},
      success: (data) {
        final resData = data["data"];
        final status = resData["status"] ?? "-1";

        if (status == "200") {
          final wordsStr = resData["data"];
          // 将 JSON 字符串转换为 Dart 对象 (Map)
          Map<String, dynamic> result = json.decode(wordsStr);
          final words = result["text"];
          onSuccess?.call(words ?? "");
          return;
        } else if (status == "500") {
          BotToast.showText(text: "获取解说文案失败，请稍后再试");
        } else {
          Future.delayed(const Duration(milliseconds: 1000), () {
            queryVoiceStyleOptimizeState(taskId: taskId, onSuccess: onSuccess);
          });
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///更新解说文案内容
  updateDesc(String txt) {
    if (txt.length > 2000) {
      txt = txt.substring(0, 2000);
    }
    desc = txt;

    //存储更新文案
    final String selectedIds = getSelectedVideoIds();
    generatedScripts[selectedIds] = desc;

    ///在这里对下一步按钮做刷新操作
    if (selectedDubbingId != -1) {
      couldNextStep = true;
    }
    update();
  }

  ///更新是否正在进行解说
  updateGeneratingCommentary(bool value) {
    generatingCommentary = value;
    update();
  }

  ///首次进入加载解说文案
  loadDesc() {
    Future.delayed(const Duration(seconds: 3)).then((value) {
      String text = getSelectedVideoContents();
      generateCommentary(text);
      // updateGeneratingCommentary(true);
    });
  }

  ///解说脚本是否失败
  void updateIsDescError({required bool value}) {
    isDescError = value;
    update();
  }

  ///调用AI重写接口
  rewriteCommentarySimpleTextByAI({
    required String ids,
    void Function(String taskId)? onSuccess,
    void Function()? onFailed,
    bool isClicked = false,
  }) {
    final isVip = Get.context!.read<LaunchProvider>().launchInfo?.isVip ?? 0;
    if (isClicked) {
      if (isVip == 1) {
        HttpUtils.post(
          APIs.explanationDramaText,
          {"ids": ids},
          success: (data) {
            String text = data["data"]["text"] ?? "";
            Get.log("===Ai改写data=== $data");

            if (text.isEmpty) {
              updateGeneratingCommentary(false);
              BotToast.showText(text: "AI改写文案失败，请稍后再试");
              return;
            }
            updateGeneratingCommentary(false);
            updateDesc(text);
            onSuccess?.call(text);
          },
          showMsgWhenFailed: false,
          fail: (code, msg) {
            onFailed?.call();
            updateGeneratingCommentary(false);
            BotToast.showText(text: "AI改写文案失败，请稍后再试");
          },
        );
      } else {
        final provider = Provider.of<AiSquareProvider>(
          Get.context!,
          listen: false,
        );
        String mark = 'short_play_create_djcz';
        provider.showModelPayDialog(Get.context, mark);
      }
    } else {
      HttpUtils.post(
        APIs.explanationDramaText,
        {"ids": ids},
        success: (data) {
          String text = data["data"]["text"] ?? "";
          if (text.isEmpty) {
            updateGeneratingCommentary(false);
            BotToast.showText(text: "AI改写文案失败，请稍后再试");
            return;
          }
          updateGeneratingCommentary(false);
          updateDesc(text);
          onSuccess?.call(text);
        },
        showMsgWhenFailed: false,
        fail: (code, msg) {
          onFailed?.call();
          updateGeneratingCommentary(false);
          BotToast.showText(text: "AI改写文案失败，请稍后再试");
        },
      );
    }
  }

  ///重写文案方法
  void rewriteCommentary({
    void Function()? onSuccess,
    void Function()? onFailed,
  }) {
    updateGeneratingCommentary(true);
    rewriteCommentarySimpleTextByAI(
      ids: getSelectedVideoIds(),
      onSuccess: (taskId) {
        if (taskId.isEmpty) {
          onFailed?.call();
          updateGeneratingCommentary(false);
          BotToast.showText(text: "AI改写文案失败，请稍后再试");
          return;
        }
        updateGeneratingCommentary(false);
        updateDesc(taskId);
        onSuccess?.call();
      },
      onFailed: () {
        onFailed?.call();
        updateGeneratingCommentary(false);
        BotToast.showText(text: "AI改写文案失败，请稍后再试");
      },
    );
  }

  /// 加载画面风格数据
  void loadVideoRatios() {
    HttpUtils.get(
      APIs.aiVideoScaleList,
      {"page": 1, "pageSize": 100},
      success: (data) {
        final List items = data["data"]["items"] ?? [];
        byDebugPrint(items);
        final List<AiCartoonVideoRatioBean> beans = List.from(
          items.map((ele) => AiCartoonVideoRatioBean.fromJson(ele)),
        );
        if (selectedRatioId == -1 && beans.isNotEmpty) {
          selectedRatioId = beans.first.id;
          final scale = beans.first.scale;
          updateSectionConfigBeansFrom(sectionConfigBeans[0][1], scale);
        }
        updateVideoRatioBeans(beans);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  updateSelectedRatioId(int id) {
    selectedRatioId = id;
    update();
  }

  /// 更新设置项数据
  updateSectionConfigBeansFrom(AiCartoonItemBean itemBean, String value) {
    List<List<AiCartoonItemBean>> beans = sectionConfigBeans
        .map(
          (ele) => ele.map((bean) {
            bool isCurrent = bean.type == itemBean.type;
            return bean.copyWith(value: isCurrent ? value : bean.value);
          }).toList(),
        )
        .toList();
    sectionConfigBeans = beans;
    update();
  }

  ///更新视频比例
  updateVideoRatioBeans(List<AiCartoonVideoRatioBean> beans) {
    videoRatioBeans = beans;
    update();
  }

  /// 加载字幕样式列表
  loadVideoFonts() {
    HttpUtils.get(
      APIs.videoFontList,
      {},
      success: (data) {
        final List items = data["data"]["items"] ?? [];
        byDebugPrint(items);
        final List<AiCartoonVideoFontBean> beans = List.from(
          items.map((ele) => AiCartoonVideoFontBean.fromJson(ele)),
        );
        if (beans.isNotEmpty) {
          selectedFontId = beans.first.id;
        }
        updateVideoFontBeans(beans);
        Get.log(
          "字幕样式===> ${beans.first.toJson()}  已经存在的数据==> ${sectionConfigBeans.first.first.toJson()} ",
        );
        if (beans.isNotEmpty) {
          if (sectionConfigBeans.length >= 2) {
            if (sectionConfigBeans[1].length >= 2) {
              updateSectionConfigBeansFrom(
                sectionConfigBeans[1][1],
                beans.first.title,
              );
              updateSelectedFontId(beans.first.id);
            }
          }
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///更新选中的字幕id
  updateSelectedFontId(int id) {
    selectedFontId = id;
    update();
  }

  ///更新画面字幕样式
  updateVideoFontBeans(List<AiCartoonVideoFontBean> beans) {
    videoFontBeans = beans;
    update();
  }

  /// 加载角色配音
  loadDubbingList({void Function(List<DubbingBean>)? onSuccess}) {
    HttpUtils.post(
      APIs.aiSpeakerList,
      // {"platform": "volcengine", "size": 999},
      {"page": 1, "size": 999},
      success: (data) {
        final List speakerList = data["data"]["items"] ?? [];
        List<AiCartoonDubbingBean> beans = speakerList
            .map((e) => AiCartoonDubbingBean.fromJson(e))
            .toList();
        if (selectedDubbingId == -1 && beans.isNotEmpty) {
          selectedDubbingId = beans.first.id;
          final name = beans.first.name;
          updateSectionConfigBeansFrom(sectionConfigBeans[0][0], name);
        }
        updateDubbingBeans(beans);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///更新选中的角色id
  updateSelectedDubbingId(int id) {
    selectedDubbingId = id;
    update();
  }

  ///更新角色配音集合数据
  updateDubbingBeans(List<AiCartoonDubbingBean> beans) {
    dubbingBeans = beans;
    update();
  }

  ///更新bgmId
  updateSelectedBgmId(int id) {
    selectedBgmId = id;
    update();
  }

  ///查看全部点击事件
  clickLookAllShortPlayEvent() {
    if (generatingCommentary) {
      BotToast.showText(text: "正在生成AI解说文案,请耐心等待~");
      return;
    }
    Get.to(
      arguments: {"fromNewShortPlay": true},
      ChangeNotifierProvider(
        create: (context) => ShortPlayCreateProvider(),
        child: const HotShortPlayCreatePage(),
      ),
    );
  }

  ///切换剧集 重新获取AI文本
  changeShortPlayAndGetAiText() {
    String text = getSelectedVideoContents();
    generateCommentary(text);
    // updateGeneratingCommentary(true);
  }

  ///重新选择剧集的点击事件
  newClickSelectShortPlayEvent() {
    if (generatingCommentary) {
      BotToast.showText(text: "正在生成AI解说文案,请耐心等待~");
      return;
    }

    Get.log("ids=====>$idsList");

    Get.to(
      ChangeNotifierProvider(
        create: (BuildContext context) =>
            ShortShowDetailsProvider(idList: idsList),
        child: ShortPlayListPage(
          videoListBean: type == 1
              ? shortPlayBeans[selectedShortPlayBeansIndex]
              : cloudVideoListBean!,
          fromPrompt: true,
        ),
      ),
    )?.then((value) {
      if (value != null) {
        List<int> ids = value;

        ///在这里重新加载新的剧集并重新获取AI总结数据
        if (ids.isNotEmpty) {
          idsList = [];
          idsList.addAll(ids);
          desc = "";
          couldNextStep = false;
          String text = getSelectedVideoContents();
          //排序已选剧集
          sortSelectedVideos();
          generateCommentary(text);
          update();
        }
        Get.log("获取返回的id集合=====> ${ids}");
      }
    });
  }

  //对已选剧集进行排序，优先显示已选剧集
  void sortSelectedVideos() {
    List<Detail> videos = [];
    //已选剧集的插入位置
    var selectCount = 0;

    selectedVideoDetailBeans.sort((a, b) => a.sort.compareTo(b.sort));
    for (Detail e in selectedVideoDetailBeans) {
      //是否已选
      if (idsList.contains(e.id)) {
        videos.insert(selectCount, e);
        selectCount++;
      } else {
        videos.add(e);
      }
    }
    selectedVideoDetailBeans = videos;
  }

  List sortSelectedVideos1() {
    return [];
  }

  ///检查是否正在生成解说文案
  // void checkIsAiWriting() {
  //   if (generatingCommentary) {
  //     BotToast.showText(text: "正在生成AI解说文案,请耐心等待~");
  //     return;
  //   }
  // }

  ///点击下一步
  clickNextStepEvent({
    required AiClipProvider provider,
    required LaunchProvider provider2,
    required BuildContext context,
  }) {
    final isVip = provider2.launchInfo?.isVip ?? 0;
    bool check = checkParams(provider: provider);
    videoTimes = provider.videoTimes;
    voiceSpeed = provider.voiceSpeed;
    voiceVolume = provider.voiceVolume;
    bgmSpeed = provider.bgmSpeed;
    bgmVolume = provider.bgmVolume;

    // final purchaseProvider =
    //     Provider.of<PurchaseProvider>(Get.context!, listen: false);
    // if (purchaseProvider.preLoginCheck(Get.context!) == false) return;

    final integralVipController = IntegralVipController.getOrPut();

    if (check) {
      ///不是会员并且无试用-付费弹窗
      if (isVip == 1 && integralVipController.isTest <= 0 ||
          integralVipController.isTest > 0) {
        // 检查积分是否足够
        if (!integralVipController.canContinueUse()) {
          integralVipController.showIntegralPayDialog();
          return;
        }

        ///违禁词检测
        provider.desc = desc;
        textRisk(
          content: desc,
          onSuccess: (data) {
            byDebugPrint(data, tag: "排查序列1:");
            Get.log("违禁词检查结果===> $data");
            final status = data["status"] ?? 0;
            if (status == 1002) {
              Get.to(
                ChangeNotifierProvider(
                  create: (BuildContext context) => AiVipGuidProvider(),
                  child: const AiVipGuidPage(),
                ),
              );
              return;
            }
            if (status == -1 || status == 200) {
              ///todo 这里还需要做违禁词更新操作
              final TextRiskBean riskBean = TextRiskBean.fromJson(data["data"]);
              final riskWords = riskBean.labelName;
              provider.updateBandedWords(riskWords);

              provider.selectedDubbingId = selectedDubbingId;

              ///违禁词id fix音色角色bug
              provider.selectedRatioId = selectedRatioId;

              ///视频比例id

              // byDebugPrint(bandedWords, tag: "违禁词列表:");
              if (provider.bandedWords.isNotEmpty) {
                // 非会员用户：不弹窗，直接执行首字母替换并继续下一步
                if (isVip != 1) {
                  // 自动执行首字母替换
                  final replacedDesc = provider
                      .replaceWithInitialLetterOfPinyin();
                  provider.updateDesc(replacedDesc);
                  desc = replacedDesc;
                  // 继续执行下一步操作（直接调用接口）
                  _startTtsAndSave(context);
                } else {
                  // 会员用户：显示对话框让用户手动处理
                  BotToast.showText(text: "当前存在违禁词");
                  showDialog(
                    context: context,
                    useSafeArea: false,
                    barrierDismissible: true,
                    builder: (ctx) => ChangeNotifierProvider.value(
                      value: provider,
                      child:
                          const AiCartoonProhibitedWordsDailog<
                            AiClipProvider
                          >(),
                    ),
                  ).then((value) {
                    if (value != null) {
                      Get.log("返回新的经过检测的文本===> ${value["desc"]}");
                      desc = value["desc"];
                      update();
                      // 用户处理完违禁词后，继续执行下一步操作
                      _startTtsAndSave(context);
                    }
                  });
                }
              } else {
                ///没有违禁词 开始接口调用
                _startTtsAndSave(context);
              }
            }
          },
        );
      } else {
        print("===点击会员弹窗===");
        Get.log("===点击会员弹窗===");
        final launchProvider = context.read<LaunchProvider>();
        HttpUtils.post(APIs.apiPost, {
          "event": Consts.EVENT_PAID_PAGE,
          "event_function": Consts.FUNCTION_SKIT_COMMENTARY,
          "event_action": Consts.ACTION_OPEN_PAY_PAGE_REPORT,
          "page_path": Routes.newShortPlayListPage,
          "pre_page_path": prePagePath,
          "middle_page_tag": "",
          "payment_page_tag":
              launchProvider.launchInfo?.verConfig.halfScreenPage,
        });
        final provider = Provider.of<AiSquareProvider>(
          Get.context!,
          listen: false,
        );
        String mark = 'short_play_create_djcz';
        provider.showModelPayDialog(
          context,
          mark,
          eventFunction: Consts.FUNCTION_SKIT_COMMENTARY,
          pagePath: Routes.newShortPlayListPage,
          prePagePath: prePagePath,
        );
      }
    }
  }

  /// 开始TTS并保存（违禁词检测通过后的后续操作）
  void _startTtsAndSave(BuildContext context) {
    final integralVipController = IntegralVipController.getOrPut();
    HttpUtils.post(
      APIs.aiTtsVideo,
      {
        "text": desc,
        "speaker": dubbingBeans.firstWhere((bean) {
          return bean.id == selectedDubbingId;
        }).speaker,
        "name": "",
        "speed": voiceSpeed,
        "pitch": 0,
        "pid": "",
        "startTask": true,
        "is_video_tts": 1,
      },
      showLoading: true,
      success: (data) {
        byDebugPrint(data, tag: "排查序列5:");
        int taskID = data["data"];
        String videoUrls = getVideoUrls();
        HttpUtils.post(
          APIs.aiClipSave,
          {
            "title": "",
            "text": desc,
            "entrance_source": 2,
            "bgm_url": selectedBgmUrl,
            "video_template": selectedRatioId,
            "font_style": selectedFontId == -1 ? 0 : selectedFontId,
            "tts_volume": voiceVolume,

            /// 表示传入id(1)还是urls(2)
            "video_source": 1,
            "tts_param": taskID,
            "bgm_speed": bgmSpeed,
            "bgm_volume": bgmVolume,
            "video_speed": videoTimes,
            "is_show_srt": selectedFontId == -1 ? 2 : 1,
            "is_show_tts": selectedDubbingId == -1 ? 2 : 1,
            "is_show_bgm": selectedBgmUrl.isEmpty ? 2 : 1,
            "dub_speed": voiceSpeed,
            // "material_pack_id": packId,
            "video_urls": videoUrls,
            // "video_head_urls": headUrls,
          },
          showLoading: true,
          success: (data) {
            byDebugPrint(data, tag: "排查序列6:");
            integralVipController.init(requiredPoints: 0, type: "video_mixed");
            byDebugPrint(data);
            ByNavRouterUtils.pushReplacement(
              context,
              MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                    create: (context) => AiCartoonVideoManagementProvider(),
                  ),
                ],
                child: const AiCartoonVideoManagementPage(
                  type: AiCartoonVideoManagementPageType.clip,
                  source: EntranceSource.shortPlay,
                ),
              ),
            );
          },
          fail: (code, msg) {
            byDebugPrint(msg, tag: "排查序列3:");
            BotToast.showText(text: msg);
            final integralVipController = IntegralVipController.getOrPut();
            integralVipController.handleStatusCode(
              code,
              msg,
              "short_play_create_djcz",
            );
          },
        );

        // onSuccess?.call(data["data"]);
      },
      fail: (code, msg) {
        byDebugPrint(code, tag: "排查序列4:");
        BotToast.showText(text: msg);
        if (code == 1002) {
          final integralVipController = IntegralVipController.getOrPut();
          integralVipController.handleStatusCode(
            code,
            msg,
            "short_play_create_djcz",
          );
        }
      },
    );
  }

  ///检查参数
  bool checkParams({required AiClipProvider provider}) {
    if (desc.isEmpty) {
      BotToast.showText(text: "请输入解说脚本");
      return false;
    }
    if (selectedDubbingId == -1) {
      BotToast.showText(text: "请选择解说角色");
      return false;
    }

    return true;
  }

  ///违禁词检测
  textRisk({
    String? type,
    String? needMark,
    required String content,
    void Function(dynamic)? onSuccess,
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
      loadingText: "违禁词检测中",
      forceData: true,
      success: (data) {
        onSuccess?.call(data);
      },
      fail: (code, msg) {
        byDebugPrint(code, tag: "排查序列2:");
        byDebugPrint(msg, tag: "排查序列2:");

        EasyLoading.dismiss();
        BotToast.showText(text: msg);
      },
    );
  }

  ///videoUrls
  String getVideoUrls() {
    List<int> videoId = [];
    List<String> videoUrlList = [];
    String videoUrls = "";
    videoId.addAll(idsList);
    videoId.sort();
    for (var e1 in selectedVideoDetailBeans) {
      for (var e2 in videoId) {
        if (e1.id == e2) {
          videoUrlList.add(e1.videoUrl);
        }
      }
    }
    videoUrls = videoUrlList.join(",");
    return videoUrls;
  }

  /// 创作记录按钮点击事件
  void clickCreationRecordEvent(BuildContext context) {
    ByNavRouterUtils.push(
      context,
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => AiCartoonVideoManagementProvider(),
          ),
        ],
        child: const AiCartoonVideoManagementPage(
          type: AiCartoonVideoManagementPageType.clip,
          source: EntranceSource.shortPlay,
        ),
      ),
    );
  }

  ///短剧解说功能点击上报
  actionClickReport() {
    ByNavigatorUtil.reportDataPoint(
      pageTag: "drama_creation_page",
      operateType: "view",
      funcDetailTag: "0",
      funcDetailImg: "",
      extra: {"drama_detail_ids": idsList},
    );
    HttpUtils.post(APIs.apiPost, {
      "event": Consts.EVENT_PAID_PAGE,
      "event_function": Consts.FUNCTION_SKIT_COMMENTARY,
      "event_action": Consts.ACTION_FUNCTION_CLICK_REPORT,
      "page_path": Routes.newShortPlayListPage,
      "pre_page_path": prePagePath,
      "payment_page_tag": "",
      "middle_page_tag": "",
    });
  }
}

class RefreshDataEvent {
  final dynamic arguments;
  const RefreshDataEvent({required this.arguments});
}
