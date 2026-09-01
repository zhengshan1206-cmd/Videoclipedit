import 'dart:async';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/core/network/result.dart';
import 'package:video_clip_edit/flavors/build_config.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/v2/slicing/mixin/stream_data_mixin.dart';
import 'package:video_clip_edit/data/model/slicing/slicing_item_bean.dart';
import 'package:video_clip_edit/core/base/controllers/base_controller.dart';

import '../../../widgets/toast_util.dart';

class SlicingHomeController extends BaseController with StreamDataMixin {
  final double bottomViewHeight = 222.h;
  final RxList<SlicingItemBean> categoryBeans = <SlicingItemBean>[].obs;

  /// 当前选中的标签页索引
  final RxInt currentTabIndex = 0.obs;

  /// 当前的提示词
  RxString currentPrompt = ''.obs;

  /// AI生成的民间故事内容
  RxString contentsAiGenerated = ''.obs;

  /// 刷新特定标签页数据的流
  final _tabRefreshStream = PublishSubject<int>();
  Stream<int> get tabRefreshStream => _tabRefreshStream.stream;

  ///是否生成中
  var isGenerating = false.obs;

  /// 是否手动编辑
  var manualEditing = false.obs;

  /// 键盘是否可见
  var keyboardVisible = false.obs;

  /// 键盘高度
  var keyboardHeight = 0.0.obs;

  /// 消息流订阅
  StreamSubscription<String>? messageSubscription;

  @override
  void fetchData() {
    HttpUtils.get(
      APIs.filmCategory,
      {},
      success: (data) {
        byDebugPrint(data);
        final list = data['data'] as List;
        final beans = list.map((e) => SlicingItemBean.fromJson(e)).toList();
        categoryBeans.value = beans;
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  /// 随机热门灵感
  void fetchRandomPrompt() {
    HttpUtils.get(
      APIs.randomPrompt,
      {},
      showLoading: true,
      success: (data) {
        final prompt = data['data']["prompt"];
        currentPrompt.value = prompt;
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  /// 随机热门灵感数据流
  void fetchRandomPromptStreamData({
    int wordsLimit = 1500,
    ValueChanged<dynamic>? onValueChanged,
    VoidCallback? onDone,
  }) async {
    // Map<String, dynamic>? params;
    // if (storyTheme != null) {
    //   params = {
    //     "word_num": wordsLimit,
    //   };
    // }
    isGenerating.value = true;
    messageSubscription?.cancel();
    currentPrompt.value = '';

    ///清除文案
    // clear();

    final stream = await getStream(
        url: BuildConfig.instance.environment.domain + APIs.randomPrompt);
    messageSubscription = stream.listen((data) {
      currentPrompt.value += data;
      onValueChanged?.call(currentPrompt.value);
    }, onDone: () {
      isGenerating.value = false;
      messageSubscription?.cancel();
      onDone?.call();
    }, onError: (error) {
      if (error is APIError) {
        // BotToast.showText(text: error.message);
        ToastUtil().showToast(error.message);
        isGenerating.value = false;
        messageSubscription?.cancel();
      }
    });
  }

  /// 刷新当前标签页数据
  void refreshCurrentTabData(int index) {
    currentTabIndex.value = index;
    // 通过流通知当前标签页刷新数据
    _tabRefreshStream.add(index);
  }

  @override
  void onClose() {
    _tabRefreshStream.close();
    super.onClose();
  }
}
