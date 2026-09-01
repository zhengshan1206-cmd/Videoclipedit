import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/modules/profile/beans/mine_legalright_bean.dart';
import 'package:video_clip_edit/modules/profile/beans/mine_works_count_bean.dart';
import 'package:video_clip_edit/modules/profile/beans/mine_works_count_item_bean.dart';
import 'package:video_clip_edit/modules/profile/beans/my_work_bean.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/modules/home/beans/cloud_video_bean.dart'
    // ignore: library_prefixes
    as CloudVideoDetail;

class MinePageProvider extends BaseProvider {
  bool hasWorks = false;

  final ScrollController scrollController = ScrollController();

  /// 将我的作品转换为我的素材供二创或者混剪使用
  List<CloudVideoDetail.Detail> cloudVideoDetailBeans = [];
  updateVideoDetailBeans(List<CloudVideoDetail.Detail> beans) {
    cloudVideoDetailBeans = beans;
    notifyListeners();
  }

  loadMinePageData() {
    // loadWorkList(status: ["2", "3"].join(","));
    // loadMenuData();
    getWorksCount();
  }

  MineLegalrightBean? legalrightBean;
  updateMineLegalrightBean(MineLegalrightBean bean) {
    legalrightBean = bean;
    notifyListeners();
  }

  loadMineLegalright() {
    HttpUtils.get(
      APIs.legalright,
      {},
      success: (data) {
        final beanData = data["data"];
        final bean = MineLegalrightBean.fromJson(beanData);
        updateMineLegalrightBean(bean);
      },
      showMsgWhenFailed: false,
      fail: (code, msg) {},
    );
  }

  MyWorksCountBean? worksCountBean;
  updateWorksCountBean(MyWorksCountBean bean) {
    worksCountBean = bean;
    notifyListeners();
  }

  List<MyWorksCountItemBean> worksCountItemBeans = [
    MyWorksCountItemBean.fromJson({
      "icon": "assets/mine/mine_functons_cartoon.png",
      "title": "视频",
      "worksCount": 0
    }),
    MyWorksCountItemBean.fromJson({
      "icon": "assets/mine/mine_functons_draw.png",
      "title": "图片",
      "worksCount": 0
    }),
    MyWorksCountItemBean.fromJson({
      "icon": "assets/mine/mine_functons_copywriting.png",
      "title": "文案",
      "worksCount": 0
    }),
    MyWorksCountItemBean.fromJson(
      {
        "icon": "assets/mine/mine_functons_music.png",
        "title": "音乐",
        "worksCount": 0
      },
    ),
    MyWorksCountItemBean.fromJson(
      {
        "icon": "assets/mine/mine_functons_dubbing.png",
        "title": "配音",
        "worksCount": 0
      },
    ),
    MyWorksCountItemBean.fromJson(
      {
        "icon": "assets/mine/mine_functons_materials.png",
        "title": "素材",
        "worksCount": 0
      },
    ),
    // MyWorksCountItemBean.fromJson(
    //   {
    //     "icon": "assets/mine/mine_functons_videos.png",
    //     "title": "视频提取",
    //     "worksCount": 0
    //   },
    // ),
  ];
  updateMyWorksCountItemBeans(List<MyWorksCountItemBean> beans) {
    worksCountItemBeans = beans;
    notifyListeners();
  }

  getWorksCount() {
    HttpUtils.get(
      APIs.getWorksCount,
      {},
      success: (data) {
        byDebugPrint(data);
        final beanData = data["data"];
        final bean = MyWorksCountBean.fromJson(beanData);
        final List<MyWorksCountItemBean> itemBeans = [];
        worksCountItemBeans.clear();
        itemBeans.add(
          MyWorksCountItemBean.fromJson({
            "icon": "assets/mine/mine_functons_cartoon.png",
            "title": "视频",
            "worksCount": 0
          }),
        );
        itemBeans.add(
          MyWorksCountItemBean.fromJson({
            "icon": "assets/mine/mine_functons_draw.png",
            "title": "图片",
            "worksCount": bean.aiImageCount
          }),
        );
        itemBeans.add(
          MyWorksCountItemBean.fromJson({
            "icon": "assets/mine/mine_functons_copywriting.png",
            "title": "文案",
            "worksCount": 0
          }),
        );
        itemBeans.add(
          MyWorksCountItemBean.fromJson(
            {
              "icon": "assets/mine/mine_functons_music.png",
              "title": "音乐",
              "worksCount": bean.aiMusicCount
            },
          ),
        );
        itemBeans.add(
          MyWorksCountItemBean.fromJson(
            {
              "icon": "assets/mine/mine_functons_dubbing.png",
              "title": "配音",
              "worksCount": 0
            },
          ),
        );
        itemBeans.add(
          MyWorksCountItemBean.fromJson(
            {
              "icon": "assets/mine/mine_functons_materials.png",
              "title": "素材",
              "worksCount": 0
            },
          ),
        );
        // itemBeans.add(MyWorksCountItemBean.fromJson(
        //   {
        //     "icon": "assets/mine/mine_functons_cartoon.png",
        //     "title": "漫画推文",
        //     "worksCount": bean.novelCount
        //   },
        // ));
        // itemBeans.add(MyWorksCountItemBean.fromJson(
        //   {
        //     "icon": "assets/mine/mine_functons_draw.png",
        //     "title": "AI绘图",
        //     "worksCount": bean.aiImageCount
        //   },
        // ));
        // itemBeans.add(MyWorksCountItemBean.fromJson(
        //   {
        //     "icon": "assets/mine/mine_functons_music.png",
        //     "title": "AI音乐",
        //     "worksCount": bean.aiMusicCount
        //   },
        // ));
        // itemBeans.add(MyWorksCountItemBean.fromJson(
        //   {
        //     "icon": "assets/mine/mine_functons_words.png",
        //     "title": "文案提取",
        //     "worksCount": bean.extractCount
        //   },
        // ));
        // itemBeans.add(MyWorksCountItemBean.fromJson(
        //   {
        //     "icon": "assets/mine/mine_functons_videos.png",
        //     "title": "视频提取",
        //     "worksCount": bean.parseVideoCount
        //   },
        // ));
        worksCountBean = bean;
        updateMyWorksCountItemBeans(itemBeans);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  List<SubFunction>? menuItemBeans;
  loadMenuData() {
    HttpUtils.get(
      APIs.homeBanner,
      {"postion": 7},
      success: (data) {
        final List bannerData = data["data"]["item"] ?? [];
        byDebugPrint(bannerData, tag: "Banner:---");
        List<SubFunction> beans =
            bannerData.map((e) => SubFunction.fromJson(e)).toList();
        menuItemBeans = beans;
        notifyListeners();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  refresh() {
    notifyListeners();
  }

  /// 当前页
  int currentPage = 1;
  List<MyWorkBean> myWorkBeans = [];
  bool loading = false;
  resetPages() {
    currentPage = 1;
    myWorkBeans.clear();
  }

  ///--------------------------------- 我的作品页面 - 管理 ---------------------------------
  resetSelectCnfigs() {
    selectAll = false;
    worksEditing = false;
    notifyListeners();
  }

  resetSelectCnfigsWithoutNotify() {
    selectAll = false;
    worksEditing = false;
  }

  String getSelectedWorkIds() {
    final selectedWorks = myWorkBeans.where((work) {
      return work.selected;
    }).toList();
    if (selectedWorks.isEmpty) return "";
    final res = selectedWorks.map((e) => e.id.toString()).join(",");
    return res;
  }

  bool selectAll = false;
  updateSelectAllStatus(bool select) {
    selectAll = select;
    notifyListeners();
  }

  bool worksEditing = false;
  updateWorksEditingState(bool state) {
    worksEditing = state;
    notifyListeners();
  }

  selectAllWorks() {
    _changeAllStatus(true);
    notifyListeners();
  }

  unselectAllWorks() {
    _changeAllStatus(false);
    notifyListeners();
  }

  _changeAllStatus(bool selected) {
    for (var e in myWorkBeans) {
      e.selected = selected;
    }
  }

  resetSelectedWorkBeans() {
    _changeAllStatus(false);
    worksEditing = false;
  }

  /// 当前选中的作品
  // List<MyWorkBean> selectedWorkBeans = [];

  // updateSelectedWorkBeans(List<MyWorkBean> beans) {
  //   selectedWorkBeans = beans;
  //   notifyListeners();
  // }

  // selectAllBeans() {
  //   selectedWorkBeans = myWorkBeans;
  //   notifyListeners();
  // }

  // deselectAllBeans() {
  //   selectedWorkBeans.clear();
  //   notifyListeners();
  // }

  /// [status] 作品状态，默认传-1表示查询所有状态的
  loadWorkList({
    String status = "",
  }) {
    if (loading) return;
    loading = true;
    HttpUtils.get(
      APIs.getWorkList,
      {"type": "1,2,3", "page": currentPage, "status": status},
      success: (data) {
        final pageData = data["data"];

        final List beansData = pageData["data"];
        final List<MyWorkBean> beans =
            beansData.map((e) => MyWorkBean.fromJson(e)).toList();
        currentPage = myWorkBeans.addElementsByRemovingLast(
          beans,
          currentPage: currentPage,
        );
        hasWorks = myWorkBeans.isNotEmpty;
        loading = false;
        List<CloudVideoDetail.Detail> cloudBeans = [];
        for (var e in myWorkBeans) {
          cloudBeans.add(CloudVideoDetail.Detail.fromWork(e.toJson()));
        }
        updateVideoDetailBeans(cloudBeans);
        notifyListeners();
      },
      fail: (code, msg) {
        loading = false;
        BotToast.showText(text: msg);
      },
    );
  }

  removeRecord({
    required String workId,
    void Function()? onSuccess,
  }) {
    HttpUtils.post(
      APIs.deleteWork,
      {"id": workId},
      success: (data) {
        byDebugPrint(data, tag: "删除结果:");
        if (data["status"] == 200) {
          onSuccess?.call();
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///--------------------------------- 我的作品页面 - 管理 ---------------------------------
}
