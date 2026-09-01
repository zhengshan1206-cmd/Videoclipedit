import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/util/page_helper.dart';

abstract class BaseController extends GetxController {
  final EasyRefreshController _easyRefreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  EasyRefreshController get refreshController => _easyRefreshController;

  final PageHelper _pageHelper = PageHelper();

  PageHelper get pageHelper => _pageHelper;

  @override
  void onInit() {
    super.onInit();
    handArguments(Get.arguments);
    handRegister();
  }

  @override
  void onReady() {
    super.onReady();
    fetchData();
  }

  ///处理传递数据
  void handArguments(dynamic arguments) {}

  ///初始化注册（EventBus、通知、数据流等）
  void handRegister() {}

  ///初始化数据
  void fetchData() {}

  void refreshSuccess(bool isRefresh, bool hasMore) {
    if (isRefresh) {
      _easyRefreshController.finishRefresh(IndicatorResult.success, false);
      if (hasMore) {
        _easyRefreshController.resetFooter();
      }
    } else {
      _easyRefreshController.finishLoad(
          hasMore ? IndicatorResult.success : IndicatorResult.noMore, true);
    }
  }

  void refreshFailed(bool isRefresh) {
    if (isRefresh) {
      _easyRefreshController.finishRefresh(IndicatorResult.fail, false);
    } else {
      _easyRefreshController.finishLoad(IndicatorResult.fail, false);
    }
  }

  void unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
