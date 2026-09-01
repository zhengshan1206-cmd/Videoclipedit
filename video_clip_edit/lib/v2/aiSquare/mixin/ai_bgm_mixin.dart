import 'dart:io';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_bgm_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_bgm_cat_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_bgm_local_bean.dart';

abstract class AiBgmMixin extends BaseProvider {
  final String bgmUrlInitial;
  AiBgmMixin({
    required this.bgmUrlInitial,
  }) {
    loadBgmCateoryList();
  }

  /// bgm分类列表
  loadBgmCateoryList();

  /// 加载bgm列表
  loadBgmList({bool reset = false});

  /// 获取本地bgm素材库列表
  /// 状态 1待审核 2审核通过 3审核失败  4系统推荐 不传为所有状态
  loadCustomBgmList({bool reset = false});

  /// 上传 bgm
  uploadMusic({
    required AssetEntity? asset,
    required File file,
  });

  final List<String> tabs = ["热门", "我的音乐库"];
  String selectedTab = "热门";
  updateSelectedTab(String tab) {
    selectedTab = tab;
    notifyListeners();
  }

  /// bgm分类列表
  List<AiCartoonBgmCatBean> bgmCateoryBeans = [];
  updateBgmCateoryBeans(List<AiCartoonBgmCatBean> beans) {
    bgmCateoryBeans = beans;
    notifyListeners();
  }

  /// 选中的bgm分类id
  int selectedBgmCatId = -1;
  updateSelectedBgmCatId(int id) {
    if (selectedBgmCatId == id) return;
    selectedBgmCatId = id;
    loadBgmList(reset: true);
    notifyListeners();
  }

  /// bgm列表
  List<AiCartoonBgmBean> bgmBeans = [];
  updateBgmBeans(List<AiCartoonBgmBean> beans) {
    bgmBeans = beans;
    notifyListeners();
  }

  /// 选中的bgm id
  int selectedBgmId = -1;
  updateSelectedBgmId(int id) {
    selectedBgmId = id;
    notifyListeners();
  }

  /// 正在试听的bgm id
  int listeningBgmId = -1;
  updateListeningBgmId(int id) {
    listeningBgmId = id;
    notifyListeners();
  }

  int bgmPage = 1;
  int bgmPageSize = 200;
  resetBgm() {
    bgmPage = 1;
    selectedBgmId = -1;
    bgmBeans.clear();
  }

  /// 本地bgm素材库列表
  List<AiCartoonBgmLocalBean> bgmBeansLocal = [];
  updateBbgmBeansLocal(List<AiCartoonBgmLocalBean> beans) {
    bgmBeansLocal = beans;
    notifyListeners();
  }

  /// 选中的bgm id
  int selectedLocalBgmId = -1;
  updateSelectedLocalBgmId(int id) {
    selectedLocalBgmId = id;
    notifyListeners();
  }

  /// 正在试听的bgm id
  int listeningLocalBgmId = -1;
  updateListeningLocalBgmId(int id) {
    listeningLocalBgmId = id;
    notifyListeners();
  }
}
