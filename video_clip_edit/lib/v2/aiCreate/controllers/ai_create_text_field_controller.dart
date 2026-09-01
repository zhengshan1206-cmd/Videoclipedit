import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/base/controllers/base_controller.dart';
import 'package:video_clip_edit/core/network/api.dart';
import 'package:video_clip_edit/core/network/provider/ai_create_provider.dart';
import 'package:video_clip_edit/core/network/result.dart';
import 'package:video_clip_edit/flavors/build_config.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/bottom_sheet/ai_create_text_field_setting_view.dart';

class AiCreateTextFieldController extends BaseController {
  final _aiCreateProvider = Get.find<AiCreateProvider>();

  final scrollController = ScrollController();

  final textController = TextEditingController();

  int limit = 2000;

  var inputText = ''.obs;

  ///是否生成中
  var isGenerating = false.obs;

  ///是否生成过文案
  var hasGenerating = false.obs;

  ///是否显示提示文案
  bool get showHintText => inputText.value.isEmpty;

  ///是否显示展开按钮
  bool get showExpand => !isGenerating.value && inputText.value.isNotEmpty;

  ///是否显示重新生成按钮
  bool get showRegenerate => !isGenerating.value && hasGenerating.value;

  ///故事主题
  String? storyTheme;

  ///故事情节
  String? mainPlot;

  ///民间故事id
  String? folkStoryThemeId;

  StreamSubscription<String>? messageSubscription;

  bool? needConfig;

  @override
  void onInit() {
    super.onInit();
    _getFolkStoryTextFieldSetting();
  }

  ///ai生成文案
  void aiAutoGeneration({
    ValueChanged<dynamic>? onValueChanged,
    VoidCallback? onDone,
  }) {
    unfocus();
    
    if (needConfig ?? false) {
      AiCreateTextFieldSettingView.show((storyTheme, mainPlot) {
        this.storyTheme = storyTheme;
        this.mainPlot = mainPlot;
        subsequentAuto(
            storyTheme: storyTheme,
            mainPlot: mainPlot,
            onValueChanged: onValueChanged,
            onDone: onDone);
      }, folkStoryThemeId!); // Added the missing 'context' argument
      return;
    }
    subsequentAuto(onValueChanged: onValueChanged, onDone: onDone);
  }

  void subsequentAuto({
    String? storyTheme,
    String? mainPlot,
    int wordsLimit = 1500,
    ValueChanged<dynamic>? onValueChanged,
    VoidCallback? onDone,
  }) async {
    Map<String, dynamic>? params;
    if (storyTheme != null) {
      params = {
        'prompt': storyTheme,
        'describe': mainPlot,
        "word_num": wordsLimit,
      };
    }
    isGenerating.value = true;
    messageSubscription?.cancel();

    ///清除文案
    clear();

    final stream = await _aiCreateProvider.getStream(
        url: BuildConfig.instance.environment.domain +
            API.folkStoryAutoGenerate.path,
        body: params);
    messageSubscription = stream.listen((data) {
      textController.text += data;
      inputText.value = textController.text;
      _scrollToBottom();
      onValueChanged?.call(data);
    }, onDone: () {
      isGenerating.value = false;
      hasGenerating.value = true;
      messageSubscription?.cancel();
      Future.delayed(const Duration(milliseconds: 70), _scrollToBottom);
      onDone?.call();
    }, onError: (error) {
      if (error is APIError) {
        BotToast.showText(text: error.message);
        isGenerating.value = false;
        messageSubscription?.cancel();
      }
    });
  }

  ///粘贴
  void paste() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    var text = data?.text;
    if (data == null || text == null || text.isEmpty) {
      BotToast.showText(text: "当前没有复制任何内容");
      return;
    }

    // 限制粘贴内容不超过limit
    if (text.length + textController.text.length > limit) {
      text = text.substring(0, limit - textController.text.length);
    }

    final value = textController.value;
    // 获取当前光标位置
    final selection = value.selection;
    final cursorPosition = selection.start;
    // 如果光标有效，则在光标处插入文本
    if (cursorPosition != -1) {
      final newText = value.text.replaceRange(
        cursorPosition,
        cursorPosition,
        text,
      );

      // 更新文本并设置新的光标位置
      textController.value = value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(
          // 设置光标到粘贴内容末尾
          offset: cursorPosition + text.length,
        ),
      );
      inputText.value = textController.text;
      // controller.
    } else {
      textController.text += text;
      inputText.value = textController.text;
    }
  }

  ///清空
  void clear() {
    textController.text = '';
    inputText.value = '';
  }

  void textChanged(String value) {
    inputText.value = textController.text;
  }

  void _scrollToBottom() {
    // 确保在下一帧滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _getFolkStoryTextFieldSetting() async {
    HttpUtils.post(
      API.getFolkStoryTextFieldSetting.path,
      null,
      success: (data) {
        needConfig = data["data"]['is_show_form'];
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  @override
  void onClose() {
    scrollController.dispose();
    textController.dispose();
    messageSubscription?.cancel();
    super.onClose();
  }
}
