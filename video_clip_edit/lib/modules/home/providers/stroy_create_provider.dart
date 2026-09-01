// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/modules/home/story/beans/question_info_bean.dart';
import 'package:video_clip_edit/modules/home/story/beans/story_example_bean.dart';
import 'package:video_clip_edit/modules/home/story/create/story_create_page.dart';
import 'package:video_clip_edit/modules/home/story/assistant/assistant_page.dart';
import 'package:video_clip_edit/modules/home/story/create/beans/ai_create_bean.dart';
import 'package:video_clip_edit/modules/home/story/assistant/beans/creator_bean.dart';
import 'package:video_clip_edit/modules/home/story/assistant/beans/assistant_page_info_bean.dart';
import 'package:video_clip_edit/modules/home/story/assistant/beans/assistant_record_item_bean.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';

const String SocketMsgEnd = "D:[DONE]";

/// 最大重试次数
const int MaxRetryTimes = 3;

class StroyCreateProvider extends BaseProvider {
  int retryTimes = 0;
  String typeID = "";

  updateTypeId(String id) {
    typeID = id;
    notifyListeners();
  }

  bool isScrollByUser = false;
  updateScrollByUser(bool scroll) {
    isScrollByUser = scroll;
    notifyListeners();
  }

  /// [type] txt / word
  exportDoc({
    String? ids,
    required String type,
    void Function(String url)? onSuccess,
  }) {
    HttpUtils.post(
      APIs.export,
      {
        "ids": ids ??
            selectedVideoIdxs.map((e) {
              return assistantRecordBeans[e].token;
            }).join(","),
        "type": type,
      },
      success: (data) {
        final url = data["data"]["url"];
        onSuccess?.call(url);
      },
      fail: (code, msg) {
        BotToast.showText(text: "导出失败，请稍后再试");
      },
    );
  }

  deleteRecords(
    List<String> ids, {
    void Function()? onSuccess,
  }) {
    HttpUtils.post(
      APIs.batchDeleteMsg,
      {"ids": ids.join(",")},
      showLoading: true,
      success: (data) {
        onSuccess?.call();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 创作详情界面底部的操作按钮能否被点击
  bool aiCreateFinshed = false;
  updateaAiCreateFinshed(bool finished) {
    aiCreateFinshed = finished;
    notifyListeners();
  }

  updateHandleDisabledWithoutNotify(bool disable) {
    aiCreateFinshed = disable;
  }

  StroyCreateProvider() {
    wordsEditingController.addListener(() {
      creatTitle = wordsEditingController.text;
      notifyListeners();
    });
  }
  final List<Widget> pages = [
    const StoryCreatePage(),
    const AssistantPage(),
  ];

  /// 首页选中的tab下标
  int selectedTabIndex = 0;
  updateSelectedTabIndex(int idx) {
    selectedTabIndex = idx;
    notifyListeners();
  }

  List<String> answers = [];
  updateAnswers(List<String> ans) {
    answers = ans;
    notifyListeners();
  }

  /// 创作示例标题颜色
  List<Color> exampleColors = [
    const Color(0xFFF27E57),
    const Color(0xFF0EBC85),
    const Color(0xFF697EF6),
    const Color(0xFFFF5B83),
  ];

  final TextEditingController wordsEditingController = TextEditingController();
  updateWords(String text) {
    wordsEditingController.text = text;
    creatTitle = text;
    notifyListeners();
  }

  loadExamples() {
    HttpUtils.get(
      APIs.generalPresets,
      {},
      success: (data) {
        byDebugPrint(data, tag: "预设列表：");
        final List chats = data["data"]["chats"] ?? [];
        List<StoryExampleBean> beans =
            chats.map((e) => StoryExampleBean.fromJson(e)).toList();
        updateExampleBeans(beans);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  sendSocketMsg() {
    HttpUtils.post(
      APIs.generalMessage,
      {},
      success: (data) {
        final List chats = data["data"]["chats"] ?? [];
        List<StoryExampleBean> beans =
            chats.map((e) => StoryExampleBean.fromJson(e)).toList();
        updateExampleBeans(beans);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  List<AiCreateBean> aiCreateBeans = [];
  updateaAiCreateBeans(List<AiCreateBean> beans) {
    aiCreateBeans = beans;
    notifyListeners();
  }

  int aiPage = 1;
  int aiPageSize = 10;

  EasyRefreshController aiController = EasyRefreshController();

  /// AI创作纪录
  loadAIRecords({
    void Function(List<AiCreateBean>)? onSuccess,
  }) {
    HttpUtils.get(
      APIs.generalChats,
      {
        "history": 1,
        "page": aiPage,
        "limit": aiPageSize,
      },
      success: (data) {
        final List chats = data["data"]["items"] ?? [];
        List<AiCreateBean> beans =
            chats.map((e) => AiCreateBean.fromJson(e)).toList();
        byDebugPrint(chats, tag: "AIliebiao:");
        byDebugPrint(beans.length);
        if (aiPage == 1) {
          aiCreateBeans.clear();
        }
        final len = aiCreateBeans.length;
        final remain = len % aiPageSize;
        if (remain < aiPage) {
          aiCreateBeans.removeRange(aiPageSize * (aiPage - 1), len);
          aiController.finishRefresh(IndicatorResult.success, true);
          aiController.finishLoad(IndicatorResult.noMore, true);
        } else {
          aiPage++;
          aiController.finishLoad(IndicatorResult.success, true);
        }
        aiCreateBeans.addAll(beans);
        onSuccess?.call(beans);
        updateaAiCreateBeans(aiCreateBeans);
        notifyListeners();
      },
      fail: (code, msg) {
        aiController.finishLoad(IndicatorResult.fail, true);
        BotToast.showText(text: msg);
      },
    );
  }

  /// 故事创作示例
  List<StoryExampleBean> exampleBeans = [
    // StoryExampleBean.fromJson({
    //   "title": "分镜脚本",
    //   "content": "你是一名专业的美食博主，请帮我写一个 重庆火锅的探店短视频脚本",
    // }),
    // StoryExampleBean.fromJson({
    //   "title": "创作选题",
    //   "content": "请根据大学生开学季策划 5条美妆博主抖音选题",
    // }),
    // StoryExampleBean.fromJson({
    //   "title": "内容提炼",
    //   "content": "请帮我总结一下小米汽车雷军三小时激情演讲的内容",
    // }),
    // StoryExampleBean.fromJson({
    //   "title": "电影影评",
    //   "content": "请帮为《肖申克的救赎》写一篇影评，强调电影给我带来的感受",
    // }),
    // StoryExampleBean.fromJson({
    //   "title": "分镜脚本",
    //   "content": "你是一名专业的美食博主，请帮我写一个 重庆火锅的探店短视频脚本",
    // }),
    // StoryExampleBean.fromJson({
    //   "title": "内容提炼",
    //   "content": "请帮我总结一下小米汽车雷军三小时激情演讲的内容",
    // }),
  ];
  updateExampleBeans(List<StoryExampleBean> beans) {
    exampleBeans = beans;
    notifyListeners();
  }

  QuestionInfoBean? questionInfoBean;
  updateQuestionInfoBean(QuestionInfoBean bean) {
    questionInfoBean = bean;
    notifyListeners();
  }

  loadMessageID({
    ///示例的id
    String? configId,

    /// 问题
    String? ask,

    /// 返回的问题ID
    String? parentId,

    /// 操作(proceed:续写,rewrite：改写,enlarge：扩写,refine:缩写)
    String? opt,
    String? optParam,
    void Function(QuestionInfoBean infoBean)? onSuccess,
  }) {
    HttpUtils.post(
      APIs.generalRichmessage,
      {
        "config_id": configId,
        "ask": ask,
        "parent_id": parentId,
        "opt": opt,
        "opt_param": optParam,
      },
      showLoading: true,
      success: (data) {
        final QuestionInfoBean infoBean =
            QuestionInfoBean.fromJson(data["data"]);
        updateQuestionInfoBean(infoBean);
        questionInfoBean = infoBean;
        onSuccess?.call(infoBean);
        notifyListeners();
      },
      fail: (code, msg) {
        EasyLoading.dismiss();
        BotToast.showText(text: msg);
      },
    );
  }

  loadRichMessageConfig({
    void Function(dynamic data)? onSuccess,
  }) {
    HttpUtils.post(
      APIs.richmessageconfig,
      {},
      success: (dynamic data) {
        byDebugPrint(data, tag: "消息配置");
        final configData = data["data"] ?? {};
        onSuccess?.call(configData);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  deleteMessage({
    required String msgID,
    void Function(dynamic data)? onSuccess,
  }) {
    HttpUtils.post(
      APIs.generalDelMsg,
      {"id": msgID},
      showLoading: true,
      success: (dynamic data) {
        byDebugPrint(data, tag: "消息删除：");
        aiPage = 1;
        loadAIRecords();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  deleteAssistantMessage({
    required String msgID,
    void Function(dynamic data)? onSuccess,
  }) {
    HttpUtils.get(
      APIs.assistantDelMsg,
      {"id": msgID},
      showLoading: true,
      success: (dynamic data) {
        byDebugPrint(data, tag: "消息删除：");
        assistantPage = 1;
        loadAssistantRecord();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  loadMessageDetails({
    required String msgID,
    void Function(dynamic data)? onSuccess,
  }) {
    HttpUtils.get(
      APIs.generaIlnfo,
      {"id": msgID},
      success: (dynamic data) {
        byDebugPrint(data, tag: "消息详情：");
        onSuccess?.call(data);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 创作的标题
  String creatTitle = "";
  String pid = "";

  /// AI生成的创作内容
  String aiCreatContents = "";
  clearAiCreatContents() {
    aiCreatContents = "";
    notifyListeners();
  }

  updateAiCreatContents(String content) {
    aiCreatContents = aiCreatContents + content;
    notifyListeners();
  }

  /// 编辑弹窗的菜单选项
  List<String> menuItems = [];
  updateMenuItems(List<String> items) {
    menuItems = items;
    notifyListeners();
  }

  String selectedItem = "";
  updateSelectedItem(String item) {
    selectedItem = item;
    notifyListeners();
  }

  /// 助手列表
  List<CreatorBean> assisntItemBeans = [];
  updateAssisntItemBeans(List<CreatorBean> beans) {
    assisntItemBeans = beans;
    notifyListeners();
  }

  loadCreators({Function? call}) {
    HttpUtils.get(
      APIs.creators,
      {},
      success: (data) {
        final List creators = data["data"] ?? [];
        List<CreatorBean> beans =
            creators.map((e) => CreatorBean.fromJson(e)).toList();
        updateAssisntItemBeans(beans);
        if (call != null) call();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  AssitantPageInfoBean? pageInfoBean;
  updateAssitantPageInfoBean(AssitantPageInfoBean bean) {
    pageInfoBean = bean;
    notifyListeners();
  }

  /// 创作助手模板值
  updateTemplate(List<String> template) {
    final items = pageInfoBean!.items;
    for (var element in items) {
      final index = items.indexOf(element);
      if (template.length > index) {
        final value = template[index];
        element.updateUserValue(value);
      }
    }
    notifyListeners();
  }

  /// 读取页面结构配置
  loadPageConfig({
    required creatorID,
    void Function(AssitantPageInfoBean bean)? onSuccess,
  }) {
    HttpUtils.get(
      APIs.creatorPageInfo,
      {"id": creatorID},
      success: (data) {
        AssitantPageInfoBean infoBean =
            AssitantPageInfoBean.fromJson(data["data"]);
        updateAssitantPageInfoBean(infoBean);
        onSuccess?.call(infoBean);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  creatorMessage({
    required creatorID,
    required dynamic values,
    void Function(QuestionInfoBean bean)? onSuccess,
  }) {
    HttpUtils.post(
      "${APIs.creatorMessage}?short=1",
      {
        "id": creatorID,
        "values": jsonEncode(values),
      },
      success: (data) {
        QuestionInfoBean infoBean = QuestionInfoBean.fromJson(data["data"]);
        onSuccess?.call(infoBean);

        final integralVipController = IntegralVipController.getOrPut();
        integralVipController.init(
          requiredPoints: 0,
          type: "txt_creators",
        );
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  int assistantPage = 1;
  int assistantPageSize = 10;

  EasyRefreshController assistantController = EasyRefreshController();

  bool recordsEditing = false;
  updateRecordsEditingState(bool state) {
    recordsEditing = state;
    notifyListeners();
  }

  bool selectAll = false;
  updateSelectAllStatus(bool select) {
    selectAll = select;
    if (select) {
      selectAllBeans();
    } else {
      deselectAllBeans();
    }
    notifyListeners();
  }

  List<int> selectedVideoIdxs = [];
  updateSelectedVideoIdxsWithIndex(int id) {
    final selectedIdx = List<int>.from(selectedVideoIdxs);
    if (selectedIdx.contains(id)) {
      selectedIdx.remove(id);
    } else {
      selectedIdx.add(id);
    }
    selectedVideoIdxs = selectedIdx;
    notifyListeners();
  }

  selectAllBeans() {
    final selectedIdx = List<int>.from(selectedVideoIdxs);
    selectedIdx.clear();
    for (var bean in assistantRecordBeans) {
      selectedIdx.add(assistantRecordBeans.indexOf(bean));
    }
    selectedVideoIdxs = selectedIdx;
    notifyListeners();
  }

  deselectAllBeans() {
    final selectedIdx = List<int>.from(selectedVideoIdxs);
    selectedIdx.clear();
    selectedVideoIdxs = selectedIdx;
    notifyListeners();
  }

  List<AssistantRecordItemBean> assistantRecordBeans = [];

  updateAssistantRecord(List<AssistantRecordItemBean> beans) {
    assistantRecordBeans = beans;
    notifyListeners();
  }

  /// 创作助手纪录
  void loadAssistantRecord({
    void Function(List<AssistantRecordItemBean>)? onSuccess,
  }) {
    HttpUtils.get(
      APIs.assistantRecord,
      {
        "history": 1,
        "page": assistantPage,
        "limit": assistantPageSize,
      },
      success: (data) {
        final List chats = data["data"]["items"] ?? [];
        List<AssistantRecordItemBean> beans =
            chats.map((e) => AssistantRecordItemBean.fromJson(e)).toList();
        byDebugPrint(chats, tag: "loadAssistantRecord:");
        byDebugPrint("len:${beans.length}");
        if (assistantPage == 1) {
          assistantRecordBeans.clear();
        }
        final len = assistantRecordBeans.length;
        final remain = len % assistantPageSize;
        if (remain < assistantPage) {
          assistantRecordBeans.removeRange(
              assistantPageSize * (assistantPage - 1), len);
          assistantController.finishRefresh(IndicatorResult.success, true);
          assistantController.finishLoad(IndicatorResult.noMore, true);
        } else {
          assistantPage++;
          assistantController.finishLoad(IndicatorResult.success, true);
        }
        assistantRecordBeans.addAll(beans);
        onSuccess?.call(beans);
        updateAssistantRecord(assistantRecordBeans);
        notifyListeners();
      },
      fail: (code, msg) {
        assistantController.finishLoad(IndicatorResult.fail, true);
        BotToast.showText(text: msg);
      },
    );
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
        EasyLoading.dismiss();
        BotToast.showText(text: msg);
      },
    );
  }
}
