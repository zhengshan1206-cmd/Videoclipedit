import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/novel_create_provider.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/short_play_create_provider.dart';
import 'package:video_clip_edit/v2/promote/beans/platform_bean.dart';

class SearchViewController extends GetxController {
  ///平台列表
  List<Platformbean> platformList = [];

  ///筛选平台
  int selectedPlatformIndex = 0;

  ///输入内容
  final TextEditingController textController = TextEditingController();

  ///输入框是否有焦点
  final FocusNode focusNode = FocusNode();
  bool hasFocus = false;

  ///下拉菜单显示状态
  bool showDropdown = false;

  ///输入框内容
  String get keyword => textController.text;

  /// ShortPlayCreateProvider引用
  ShortPlayCreateProvider? _shortPlayProvider;

  /// NovelCreateProvider引用
  NovelCreateProvider? _novelCreateProvider;

  /// 是否是短剧
  bool isShortPlay = false;

  @override
  void onInit() {
    super.onInit();
    // 重置所有状态
    resetState();
    getMaterialConfig();
    focusNode.addListener(() {
      hasFocus = focusNode.hasFocus;
      update();
    });
    textController.addListener(() {
      update();
      // 移除实时搜索，只在点击搜索按钮时执行
    });
  }

  @override
  void onClose() {
    // 重置状态
    resetState();
    // 释放资源
    focusNode.dispose();
    textController.dispose();
    super.onClose();
  }

  ///设置ShortPlayCreateProvider引用
  void setShortPlayProvider(ShortPlayCreateProvider provider) {
    isShortPlay = true;
    update();
    _shortPlayProvider = provider;
  }

  ///设置NovelCreateProvider引用
  void setNovelCreateProvider(NovelCreateProvider provider) {
    isShortPlay = false;
    update();
    _novelCreateProvider = provider;
  }

  ///获取平台
  void getMaterialConfig() async {
    HttpUtils.get(
      APIs.getMaterialConfig,
      {},
      success: (data) {
        byDebugPrint("获取平台===> $data");
        final List items = data["data"]["platform"] ?? [];
        platformList =
            List<Platformbean>.from(items.map((e) => Platformbean.fromJson(e)));
        update();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///选择平台
  void selectPlatform(int index) {
    if (platformList.isEmpty || index >= platformList.length) {
      selectedPlatformIndex = 0;
    } else {
      selectedPlatformIndex = index;
    }
    update();
    _updateProviderWithCurrentValues();
    // 触发数据刷新
    if (isShortPlay) {
      _shortPlayProvider?.loadCloudVideos(isRefresh: true);
    } else {
      // 对于爆文创作，通过NovelCreateProvider通知所有页面刷新
      _notifyNovelCreateRefresh();
    }
  }

  ///清除输入
  void clearInput() {
    textController.clear();
    _updateProviderWithCurrentValues();
    update();
  }

  ///搜索
  void doSearch() {
    _updateProviderWithCurrentValues();
    // 触发数据刷新
    if (isShortPlay) {
      _shortPlayProvider?.loadCloudVideos(isRefresh: true);
    } else {
      // 对于爆文创作，通过NovelCreateProvider通知所有页面刷新
      _updateProviderWithCurrentValues();
      // _notifyNovelCreateRefresh();
    }
  }

  ///切换下拉菜单显示
  void toggleDropdown() {
    showDropdown = !showDropdown;
    update();
  }

  ///关闭下拉菜单
  void closeDropdown() {
    showDropdown = false;
    update();
  }

  ///更新Provider中的搜索内容
  void _updateProviderWithCurrentValues() {
    if (_shortPlayProvider != null && isShortPlay) {
      int platformId = 0;
      if (platformList.isNotEmpty &&
          selectedPlatformIndex < platformList.length) {
        platformId = platformList[selectedPlatformIndex].id;
      }
      _shortPlayProvider!.updatePlatformAndSearchContent(platformId, keyword);
    }
    if (_novelCreateProvider != null && !isShortPlay) {
      _novelCreateProvider!.updateSearchContent(keyword);
    }
  }

  /// 通知爆文创作页面刷新
  void _notifyNovelCreateRefresh() {
    if (_novelCreateProvider != null) {
      // 通过更新搜索内容来触发所有页面的刷新
      _novelCreateProvider!.updateSearchContent(keyword);
    }
  }

  ///重置所有状态
  void resetState() {
    platformList.clear();
    selectedPlatformIndex = 0;
    textController.clear();
    hasFocus = false;
    showDropdown = false;
    update();
  }
}
