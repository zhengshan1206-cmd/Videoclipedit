import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/novelwriting/beans/ai_novel_singelchoice_bean.dart';

import '../../../utils/comon/by_common_utils.dart';
import '../../../utils/http/apis.dart';
import '../../../utils/http/http_utils.dart';
import '../../../widgets/toast_util.dart';
import '../../aiSquare/song/beans/rights_by_type.dart';

class AiNovelProvider extends BaseProvider {
  TextEditingController titleCreateEditingController = TextEditingController();
  TextEditingController contentCreateEditingController = TextEditingController();
  List<(
    String title,
    List<AiNovelSingelchoiceBean> choices,
    int chooseMinNum,
    int chooseMaxNum,
  )> choiceConfig = [];

  void updateChoice(
    String title,
    List<AiNovelSingelchoiceBean> choices,
  ) {
    var text = contentCreateEditingController.text.trim();
    final selected = choices.where((e) => e.isSelect).map((e) => e.txt).join("、");
    final pattern = RegExp("^${title}：.+\$", unicode: true, multiLine: true);
    if(pattern.hasMatch(text)) {
      text = text.replaceFirst(pattern, "$title：$selected；");
    } else {
      text = "$text\n$title：$selected；";
    }
    contentCreateEditingController.text = "${text.trim()}\n";
  }

  void loadRights(
      {required void Function(RightsByType) onSuccess}) {
    HttpUtils.post(
      APIs.getRightsByType,
      {
        "type": "ai_novel",
      },
      success: (data) {
        byDebugPrint(data["data"]);
        final rghtsByType = RightsByType.fromJson(data["data"]);
        onSuccess(rghtsByType);
      },
      fail: (code, msg) {
        /// BotToast.showText(text: msg);
      },
    );
  }

  void generate({
    String? title,
    String? prompt,
    bool isAuto = true,
    int? chapterNum,
    void Function()? onSuccess,
  }) {
    final args = {
      "title": title,
      "prompt": prompt,
      "is_auto": isAuto ? "1" : "2",
      if(chapterNum != null) "chapter_nums": chapterNum,
    };
    HttpUtils.post(
      "AiNovel/createTask",
      args,
      showLoading: true,
      success: (data) {
        byDebugPrint(data);
        onSuccess?.call();
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  void loadConfig({
    VoidCallback? onSuccess
  }) async {
    HttpUtils.get(
      "AiNovel/getConfig",
      {},
      showLoading: true,
      success: (data) {
        // byDebugPrint(data);
        final configs = data["data"];
        if (configs is List) {
          choiceConfig.clear();
          for (final config in configs) {
            final title = config["title"];
            final choices = (config["config"] as List)
                .map((e) => AiNovelSingelchoiceBean(e["id"], e["title"]))
                .toList();
            choiceConfig.add((
              title,
              choices,
              config["choose_min_num"],
              config["choose_max_num"]
            ));
          }
        }
        notifyListeners();
        onSuccess?.call();
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  void loadDefaultPrompt({
    VoidCallback? onSuccess
  }) async {
    HttpUtils.get(
      "AiNovel/getDefaultPrompt",
      {},
      showLoading: true,
      success: (data) {
        // byDebugPrint(data);
        final configs = data["data"];
        if (configs is List && configs.isNotEmpty) {
          final config = configs[Random().nextInt(configs.length)];
          titleCreateEditingController.text = config["title"];
          contentCreateEditingController.text = config["prompt"];
          final configIds = config["config_id"];
          if (configIds is List && configIds.isNotEmpty) {
            for (final configGroup in choiceConfig) {
              for(final configItem in configGroup.$2) {
                configItem.isSelect = configIds.contains(configItem.id);
              }
            }
          }
        }
        notifyListeners();
        onSuccess?.call();
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }
}
