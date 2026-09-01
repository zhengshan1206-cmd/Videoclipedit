import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/core/network/api.dart';
import 'package:video_clip_edit/core/util/app_util.dart';
import 'package:video_clip_edit/data/model/aiCreate/ai_create_picture_style_bean.dart';
import 'package:video_clip_edit/data/model/aiCreate/ai_create_request.dart';
import 'package:video_clip_edit/data/model/aiCreate/folk_story_create_request.dart';
import 'package:video_clip_edit/flavors/app_values.dart';
import 'package:video_clip_edit/modules/profile/beans/user_info_bean.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/ai_create_text_field_controller.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/prohited/prohibited_words_dailog.dart';
import 'package:video_clip_edit/v2/aiSquare/ai_vip_guid_page.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/base_ai_create_controller.dart';
import 'package:video_clip_edit/v2/aiSquare/providers/ai_vip_guid_provider.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';
import 'package:video_clip_edit/widgets/common/multi_status_view.dart';

import '../../../routes/route_utils.dart';
import '../../../utils/consts/const.dart';
import '../../../utils/http/apis.dart';
import '../../aiSquare/cartoon/provider/ai_cartoon_provider.dart';
import '../../aiSquare/cartoon/widgets/ai_cartoon_prohibited_words_dailog.dart';
import '../../folkStory/beans/folk_story_bean.dart';
import '../../folkStory/widget/folk_story_success_create.dart';
import '../../hotCreate/providers/novel_create_provider.dart';
import '../../slicing/mixin/stream_data_mixin.dart';

class CreateFolkStoryController extends BaseAiCreateController
    with StreamDataMixin {
  UserController get userController => Get.find<UserController>();

  UserInfoBean? get userInfo => userController.user.value;

  var isExpand = false.obs;

  var multiStatus = MultiStatusType.statusLoading;

  var nextOperateEnable = true.obs;

  var isSlicingGenerating = false.obs;

  final FolkStoryCreateRequest folkStoryCreateRequest =
      FolkStoryCreateRequest();

  //民间故事风格
  var themeId = '1';

  ///画面风格数据
  var pictureStyleList = <AICreatePictureStyleBean>[];

  //推文默认信息
  var normalText = '';

  @override
  AiCreateRequest get aiCreateRequest => folkStoryCreateRequest;

  final integralVipController = IntegralVipController.getOrPut();

  @override
  handArguments(dynamic arguments) {
    if (arguments == null) {
      return;
    }

    if (arguments is Map) {
      if (arguments.keys.contains('theme_id')) {
        themeId = arguments['theme_id'];
        normalText = arguments['normal_text'] ?? '';

        Get.log("===themeId=== $themeId");

        return;
      }
      final fromSlicing = arguments["fromSlicing"] ?? "";
      final expand = arguments["expand"] ?? false;
      isExpand.value = expand;
      if (fromSlicing) {
        isSlicingGenerating.value = true;
      }
    }
  }

  @override
  void fetchData() {
    getDataFromServer();
  }

  void getDataFromServer() {
    ///公告
    getNoticeList();

    ///获取背景音乐并设置默认值
    // getPlatformRecommendCategoryList();

    ///获取视频比例并设置默认值
    getVideoRatioList();

    ///获取字幕配置
    // getCaptionsConfig();

    //获取主题风格
    loadFolkStoryTheme();
  }

  ///获取画面风格列表
  void _getPictureStyleList() async {
    HttpUtils.get(
      FolkStoryApi.FolkStoryModelStyle,
      {'module': themeBean?.module},
      success: (data) {
        if (data['data'] is List) {
          final List items = (data["data"] ?? []);
          final List<AICreatePictureStyleBean> beans =
              List<AICreatePictureStyleBean>.from(items.map(
            (ele) => AICreatePictureStyleBean.fromJson(ele),
          ));
          folkStoryCreateRequest.selectStyleBean.value = beans.first;
          pictureStyleList.assignAll(beans);
        }
        multiStatus = MultiStatusType.statusContent;
        update();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        multiStatus = MultiStatusType.statusError;
      },
    );
  }

  ///创作记录
  creationRecord() {
    // RouteUtils.gotoPage(Get.context!, '/explosive_video_works',
    //                                   params:{});
    Get.toNamed(Routes.storyManagementPage);
  }

  back() {
    var textFieldController = Get.find<AiCreateTextFieldController>();
    if (textFieldController.isGenerating.value || isSlicingGenerating.value) {
      Get.normalDialog(
        width: Get.width * 0.85,
        title: '温馨提示',
        content: '文案生成中，退出后无法保存，\n确定要退出吗？',
        confirmText: '退出',
        confirmAction: () {
          Get.back();
        },
      );
      return;
    }
    Get.back();
  }

  //输入框清空操作
  clearORNot() {
    var textFieldController = Get.find<AiCreateTextFieldController>();
    if (textFieldController.isGenerating.value ||
        isSlicingGenerating.value ||
        textFieldController.inputText.value.isNotEmpty) {
      Get.normalDialog(
        width: Get.width * 0.85,
        title: '温馨提示',
        content: '文案生成中，清空后无法保存，\n确定要清空吗？',
        confirmText: '确定',
        confirmAction: () {
          textFieldController.clear();
        },
      );
      return;
    }
  }

  ///下一步按钮操作
  nextBtnOperate() {

    final textFieldController = Get.find<AiCreateTextFieldController>();
    if (textFieldController.isGenerating.value) {
      BotToast.showText(text: "文案正在生成中...");
      return;
    }

    //文案内容必须大于等于100字
    if (textFieldController.inputText.value.length < 100) {
      BotToast.showText(text: "文案必须大于100字");
      return;
    }
    _checkIllegelWords();

  }

  _promptDialog() {
    Get.normalDialog(
      width: Get.width * 0.85,
      title: '温馨提示',
      content: '文案正在生成中，\n确定要继续吗？',
      confirmAction: () {
        final textFieldController = Get.find<AiCreateTextFieldController>();
        textFieldController.isGenerating.value = false;
        textFieldController.hasGenerating.value = true;
        textFieldController.messageSubscription?.cancel();
        _checkIllegelWords();
      },
    );
  }

  //违禁词检测
  _checkIllegelWords() {
    final textFieldController = Get.find<AiCreateTextFieldController>();
    //文案内容必须大于等于100字
    if (textFieldController.inputText.value.length < 100) {
      BotToast.showText(text: "文案必须大于100字");
      return;
    }
    final cartoonProvider = AiCartoonProvider();
    cartoonProvider.desc = textFieldController.inputText.value; // 设置当前内容
    cartoonProvider.detect(Get.context!, cartoonProvider.desc, onSuccess: () {
      if (cartoonProvider.bandedWords.isNotEmpty) {
        BotToast.showText(text: "当前存在违禁词");
        showDialog(
          context: Get.context!,
          useSafeArea: false,
          barrierDismissible: true,
          builder: (ctx) => ChangeNotifierProvider.value(
            value: cartoonProvider,
            child: const AiCartoonProhibitedWordsDailog<AiCartoonProvider>(),
          ),
        ).then((value) {
          if (value != null) {
            if (value["desc"] != null) {
              textFieldController.textController.text = value["desc"];
              textFieldController.inputText.value = textFieldController.textController.text;
            }
          }
        });
      } else {
        folkStoryCreateRequest.content = textFieldController.inputText.value;
        // if ((userInfo?.isVip ?? 0) == 1 && integralVipController.isTest <= 0) {
        //   createFolkStory(false);
        // } else {
        //   Get.to(() => const FolkStorySuccessCreate());
        // }
        if (integralVipController.isTest > 0) {
          createFolkStory(false);
        } else {
          if ((userInfo?.isVip ?? 0) == 1 &&
              integralVipController.isTest <= 0) {
            createFolkStory(false);
          } else {
            Get.to(() => FolkStorySuccessCreate(
                  themeId: themeId,
                ));
          }
        }
      }
    });
  }

  void createFolkStory(bool replace) async {
    // 检查积分是否足够
    if (!integralVipController.canContinueUse()) {
      integralVipController.showIntegralPayDialog();
      return;
    }

    HttpUtils.post(
      API.createFolkStory.path,
      folkStoryCreateRequest.toJson(),
      showLoading: true,
      success: (data) {
        final num? id = data["data"]["id"];

        integralVipController.init(
          requiredPoints: 0,
          type: "folk_story",
        );

        ///智能模式
        if (folkStoryCreateRequest.isAuto.value) {
          // RouteUtils.gotoPage(Get.context!, '/explosive_video_works',
          //                             params:{});
          if (replace) {
            Get.offNamed(Routes.storyManagementPage);
          } else {
            Get.toNamed(Routes.storyManagementPage);
          }
        } else {
          if (replace) {
            Get.offNamed(Routes.stepsPage, arguments: {'id': id, 'theme': themeBean});
          } else {
            Get.toNamed(Routes.stepsPage, arguments: id);
          }
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        integralVipController.handleStatusCode(code, msg, "folk_story");
      },
    );
  }

  //画面风格
  FolkStoryThemeBean? themeBean;
  loadFolkStoryTheme({
    void Function()? onSuccess,
  }) {
    HttpUtils.get(
      FolkStoryApi.FolkStoryTheme,
      {'id': themeId},
      showLoading: false,
      success: (data) {
        final success = data["status"] == 200;
        if (!success) {
          return;
        }
        final Map<String, dynamic> theme = data["data"] ?? {};
        themeBean = FolkStoryThemeBean.fromJson(theme);

        ///画风
        _getPictureStyleList();
        getBgmListWithCategory(themeBean!.bgmID);
        

        ///获取音色配音并设置默认值
        getVoiceList(module: themeBean?.module);
        onSuccess?.call();
      },
      fail: (code, msg) {},
    );
  }

  ///小说推文 儿童绘本 民间故事 功能点击上报
  actionClickReport(){
    String eventFunction = "";
    if (themeId == "5") {
      eventFunction = Consts.FUNCTION_FOLK_STORY;
    } else if (themeId == "6") {
      eventFunction = Consts.FUNCTION_PICTURE_BOOK;
    } else if (themeId == "7") {
      eventFunction = Consts.FUNCTION_NOVEL_TWEETS;
    }

    Get.log("eventFunction===$eventFunction themeId===$themeId");

    HttpUtils.post(APIs.apiPost, {
      "event": Consts.EVENT_PAID_PAGE,
      "event_function": eventFunction,
      "event_action": Consts.ACTION_FUNCTION_CLICK_REPORT,
      "page_path": "/create_fold_story",
      "pre_page_path": "/",
      "payment_page_tag":"",
      "middle_page_tag":"",
    });
  }

  @override
  void onInit() {
    super.onInit();
    actionClickReport();
  }

}
