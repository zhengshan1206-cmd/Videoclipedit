import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/base/controllers/base_controller.dart';
import 'package:video_clip_edit/core/network/api.dart';
import 'package:video_clip_edit/core/network/provider/ai_create_provider.dart';
import 'package:video_clip_edit/core/network/result.dart';
import 'package:video_clip_edit/flavors/build_config.dart';

class AiCreateTextFieldSettingController extends BaseController{

  final _aiCreateProvider = Get.find<AiCreateProvider>();

  final scrollController = ScrollController();

  final storyThemeController = TextEditingController();
  final mainPlotController = TextEditingController();

  final FocusNode focusNode = FocusNode();

  var inputText = ''.obs;
  ///是否生成中
  var isGenerating = false.obs;

  ///是否显示提示文案
  bool get showHintText => inputText.value.isEmpty;

  StreamSubscription<String>? messageSubscription;

  ///ai生成文案
  void aiAutoGeneration({
    String? storyId,
  }) {
    unfocus();
    subsequentAuto(storyId: storyId);
  }

  void subsequentAuto({
    String? storyId,
  }) async {
    Map<String, dynamic>? params;
    if (storyId != null) {
      params = {
        'type': storyId,
      };
    }
    isGenerating.value = true;
    messageSubscription?.cancel();

    ///清除文案
    clear();

    final stream = await _aiCreateProvider.getStream(
        url: BuildConfig.instance.environment.domain + API.folkStoryThemeAutoGenerate.path,
        body: params
    );
    messageSubscription = stream.listen((data) {
      storyThemeController.text += data;
      inputText.value = storyThemeController.text;
      _scrollToBottom();
    }, onDone: () {
      isGenerating.value = false;
      messageSubscription?.cancel();
      Future.delayed(const Duration(milliseconds: 70), _scrollToBottom);
    }, onError: (error) {
      if (error is APIError) {
        BotToast.showText(text: error.message);
        isGenerating.value = false;
        messageSubscription?.cancel();
      }
    });
  }

  void clear() {
    storyThemeController.text = '';
    inputText.value = '';
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

  @override
  void onClose() {
    focusNode.dispose();
    storyThemeController.dispose();
    mainPlotController.dispose();
    messageSubscription?.cancel();
    super.onClose();
  }
}
