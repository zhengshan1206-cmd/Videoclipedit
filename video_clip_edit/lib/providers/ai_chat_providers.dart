// ignore_for_file: non_constant_identifier_names
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/main.dart';
import 'package:video_clip_edit/modules/purchase/widgets/dailog_bonus_lowest_price.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/chat/beans/ai_chat_item_bean.dart';
import 'package:video_clip_edit/modules/home/story/beans/question_info_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/chat/beans/ai_chat_model_listbean.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';
import 'package:video_clip_edit/v2/toolBox/beans/new_tool_box_list_bean.dart';
import 'package:video_clip_edit/widgets/toast_util.dart';

class AiChatProviders extends BaseProvider {
  AiChatProviders() {
    editInputController.addListener(() {
      updateCanSend();
    });

    focusNode.addListener(
      () {
        updateHasFocus(focusNode.hasFocus);
      },
    );
  }
  // List<NewToolBoxCategoryBean> categoryBeans = [];
  // updateCategoryBeans(List<NewToolBoxCategoryBean> beans) {
  //   categoryBeans = beans;
  //   notifyListeners();
  // }

  // /// [postion] 数据所在的页面位置
  // /// 1=>'首页'
  // /// 2=>'首页AI助理'
  // /// 3=>'工具箱',
  // loadCategory() {
  //   HttpUtils.get(
  //     APIs.crumbsCategoryList,
  //     {"postion": 2},
  //     success: (data) {
  //       byDebugPrint(data);
  //       final list = data['data']["list"] ?? [];

  //       final beans = List<NewToolBoxCategoryBean>.from(
  //           list.map((e) => NewToolBoxCategoryBean.fromJson(e)));
  //       updateCategoryBeans(beans);
  //     },
  //     fail: (code, msg) {
  //       BotToast.showText(text: msg);
  //     },
  //   );
  // }

  List<NewToolBoxListBean> listBeans = [];
  updateListBeans(List<NewToolBoxListBean> beans) {
    listBeans = beans;
    notifyListeners();
  }

  int page = 1;
  int size = 10;

  /// [categoryId] 分类id
  /// [isRefresh] 是否下拉刷新
  /// [page] 分页
  /// [size] 每页数量
  loadList({
    bool isRefresh = false,
    void Function(bool hasMore)? onSuccess,
    void Function()? onFailed,
  }) {
    page = 1;

    HttpUtils.get(
      APIs.crumbsList,
      {
        "page": page,
        "size": size,
        "postion": 2,
      },
      success: (data) {
        final list = data['data']["items"] ?? [];
        final beans = List<NewToolBoxListBean>.from(
          list.map(
            (e) => NewToolBoxListBean.fromJson(e),
          ),
        );
        listBeans.clear();
        final results = List<NewToolBoxListBean>.from(listBeans);
        page = results.addElementsByRemovingLast(beans,
            pageSize: size, currentPage: page);
        updateListBeans(results);
        onSuccess?.call(beans.isNotEmpty && beans.length % 10 == 0);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg, onlyOne: true);
      },
    );
  }

  bool hasFocus = false;
  updateHasFocus(bool value) {
    hasFocus = value;
    notifyListeners();
  }

  FocusNode focusNode = FocusNode();

  /// 输入框控制器
  TextEditingController editInputController = TextEditingController();

  /// 消息列表控制器
  ScrollController messageContentDatasScrollController = ScrollController();

  /// 消息模型列表
  List<AiChatItemBean> messages = [];

  /// 更新消息列表
  updateMessages(List<AiChatItemBean> beans) {
    messages = beans;
    notifyListeners();
  }

  /// 添加新问题
  addNewQuestion(AiChatItemBean message) {
    final messagesCopy = List<AiChatItemBean>.from(messages);
    messagesCopy.add(message);
    messages = messagesCopy;
    notifyListeners();
  }

  /// 添加新回答
  addNewAnswer(AiChatItemBean message) {
    messages.add(message);
    notifyListeners();
  }

  /// 更新最后一个回答
  updateLastAnswer(String content) {
    final messagesCopy =
        List<AiChatItemBean>.from(messages.map((e) => e.copyWith()));
    final answer = messagesCopy.last;
    answer.contet = content;
    messages = messagesCopy;
    notifyListeners();
  }

  /// 是否显示模型列表
  bool showModelList = false;
  setShowModel(bool show) {
    showModelList = show;
    notifyListeners();
  }

  /// socket 连接重试次数
  int retryTimes = 0;
  int MaxRetryTimes = 3;
  String SocketMsgEnd = "D:[DONE]";

  ///新增加传入的问题
  String firstDesQuestion = "";

  /// 是否正在创作中
  bool inCreation = false;
  updateInCreation(bool value) {
    inCreation = value;
    notifyListeners();
  }

  /// AI生成的创作内容
  String aiCreatContents = "";

  /// 更新AI生成的创作内容
  updateAiCreatContents(String content) {
    aiCreatContents = aiCreatContents + content;
    updateLastAnswer(aiCreatContents);
  }

  bool isScrollByUser = false;
  updateScrollByUser(bool scroll) {
    isScrollByUser = scroll;
    notifyListeners();
  }

  /// 是否可以发送
  bool canSend = false;
  updateCanSend({bool? value}) {
    if (value != null) {
      canSend = value;
    } else {
      canSend = editInputController.text.isNotEmpty && !inCreation;
    }

    notifyListeners();
  }

  int selectedModelIndex = -1;
  updateSelectedModelIndex(int index) {
    selectedModelIndex = index;
    notifyListeners();
  }

  sendMessageContentDatas(
    String msg, {
    void Function()? callback,
  }) {
    if (!canSend) {
      BotToast.showText(text: "正在回答中，请等待上一个问题回答结束");
      return;
    }
    aiCreatContents = "";

    addNewQuestion(
      AiChatItemBean.fromJson({
        "contet": msg,
        "isAnswer": false,
      }),
    );

    addNewAnswer(
      AiChatItemBean.fromJson({
        "contet": "",
        "isAnswer": true,
      }),
    );

    if (editInputController.text.isNotEmpty) {
      editInputController.clear();
    } else {
      /// 更新发送按钮状态
      updateCanSend(value: false);
    }

    /// 开始获取消息id，并连接socket获取回答
    loadMessageID(
      ask: msg,
      onSuccess: (infoBean) {
        List<AiChatItemBean> msgsCopy = List<AiChatItemBean>.from(
          messages.map(
            (e) => e.copyWith(),
          ),
        );
        msgsCopy.last.messageId = infoBean.token;
        msgsCopy[msgsCopy.length - 2].messageId = infoBean.token;
        callback?.call();
        updateMessages(msgsCopy);
      },
    );
  }

  // 计算输入框区域的高度的方法
  calculateTextFieldHeight(
    String value,
    BuildContext context,
  ) {
    final textSpan = TextSpan(
      text: value,
      style: TextStyle(fontSize: 15.sp),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 10,
    )..layout(maxWidth: MediaQuery.of(context).size.width - 62.w);
    double lineCount =
        (textPainter.size.height / textPainter.preferredLineHeight);

    byDebugPrint(lineCount, tag: "当前行数:");
    return textPainter.height;
  }

  cleanMessageContentDatas() {
    messages.clear();
    notifyListeners();

    /// 延迟500毫秒，再进行滑动
    Future.delayed(const Duration(milliseconds: 500), () async {
      await messageContentDatasScrollController.animateTo(
          duration: const Duration(milliseconds: 200),
          messageContentDatasScrollController.position.maxScrollExtent + 1,
          curve: Curves.ease);
    });
  }

  /// 消息大模型列表
  List<AiChatModelListBean> aiChatModelListBeans = [];

  /// 默认的提示语列表
  List<String> aiChatDefaultPrompts = [];

  /// 随机的提示语
  List<String> aiChatDefaultPromptsRandom = [];

  updateAiChatDefaultPromptRandom(List<String> prompts) {
    aiChatDefaultPromptsRandom = prompts;
    notifyListeners();
  }

  getRandomPrompt() {
    if (aiChatDefaultPrompts.isNotEmpty) {
      final List<String> resuts = [];

      if (aiChatDefaultPrompts.length <= 3) {
        return List<String>.from(aiChatDefaultPrompts);
      }

      while (resuts.length < 3) {
        int index = Random().nextInt(aiChatDefaultPrompts.length);
        if (!resuts.contains(aiChatDefaultPrompts[index])) {
          resuts.add(aiChatDefaultPrompts[index]);
        }
      }
      return resuts;
    } else {
      return [];
    }
  }

  /// 获取模型列表
  getModelList({
    bool reset = false,
  }) {
    HttpUtils.get(
      APIs.getModelList,
      {},
      success: (data) {
        final List items = data["data"] ?? [];
        aiChatModelListBeans = List<AiChatModelListBean>.from(items.map(
          (ele) {
            final bean = AiChatModelListBean.fromJson(ele);
            if (bean.isDefault == 1) {
              updateSelectedModelIndex(items.indexOf(ele));
            }
            return bean;
          },
        ));
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  /// 获取默认的提问示例列表
  getDefaultPrompt({
    bool reset = false,
  }) {
    HttpUtils.get(
      APIs.getDefaultPrompt,
      {},
      success: (data) {
        aiChatDefaultPrompts = List<String>.from(data["data"] ?? []);
        updateAiChatDefaultPromptRandom(getRandomPrompt());
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        // BotToast.showText(text: msg,onlyOne: true);
      },
    );
  }

  QuestionInfoBean? questionInfoBean;
  updateQuestionInfoBean(QuestionInfoBean bean) {
    questionInfoBean = bean;
    notifyListeners();
  }

  loadMessages() {
    HttpUtils.get(
      APIs.chatList,
      {"history": 0},
      showLoading: true,
      success: (data) {
        final list = data["data"]["list"] ?? [];
        List<AiChatItemBean> beans = [];
        for (var ele in list) {
          beans.add(AiChatItemBean.fromJson({
            "contet": ele["ask"] ?? "",
            "isAnswer": false,
            "time": ele["answer_start_time"],
            "messageId": ele["token"] ?? "",
          }));

          beans.add(AiChatItemBean.fromJson({
            "contet": ele["answer"] ?? "",
            "isAnswer": true,
            "time": ele["answer_start_time"],
            "messageId": ele["token"] ?? "",
          }));
        }

        updateMessages(beans);

        WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) {
            // messageContentDatasScrollController.jumpTo(
            //     messageContentDatasScrollController.position.maxScrollExtent);
            Future.delayed(const Duration(milliseconds: 100)).then((value) {
              messageContentDatasScrollController.jumpTo(
                  messageContentDatasScrollController.position.maxScrollExtent);
            });
          },
        );
      },
      fail: (code, msg) {
        EasyLoading.dismiss();
      },
    );
  }

  cleanUpAllChats() {
    HttpUtils.get(
      APIs.cleanUpChat,
      {},
      showLoading: true,
      success: (data) {
        updateMessages([]);
      },
      fail: (code, msg) {
        EasyLoading.dismiss();
      },
    );
  }

  deleteMessage({
    required String msgID,
    void Function()? onSuccess,
  }) {
    HttpUtils.post(
      APIs.generalDelMsg,
      {"id": msgID},
      showLoading: true,
      success: (dynamic data) {
        byDebugPrint(data, tag: "消息删除：");
        onSuccess?.call();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
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
      APIs.generalMessage,
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
        if (infoBean.isMoney == 1) {
          final context = navigatorKey.currentContext;
          context!.read<PurchaseProvider>().loadVIPItems(
            onSuccess: () {
              // showDialog(
              //   context: context,
              //   builder: (context) {
              //     return const DailogBonusLowestPrice();
              //   },
              // );
              final provider = context.read<AiSquareProvider>();
              String mark = 'ai_dialogue';
              provider.showModelPayDialog(context, mark);
            },
          );
          return;
        }
        final integralVipController = IntegralVipController.getOrPut();
        //积分购买
        if (infoBean.isMoney == 0 && infoBean.needIntegral == 1) {
          integralVipController.showIntegralPayDialog();
          return;
        }
        integralVipController.init(
          requiredPoints: 0,
          type: "txt_knows",
        );
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
}
