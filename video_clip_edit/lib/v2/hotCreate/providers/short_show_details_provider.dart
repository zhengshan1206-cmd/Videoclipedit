import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/modules/home/beans/cloud_video_bean.dart';

class ShortShowDetailsProvider extends BaseProvider {
  /// 对应名称下的素材列表
  List<Detail> videoDetailBeans = [];

  ///已经选择的剧集id集合
  final List<int> idList ;

  ShortShowDetailsProvider({this.idList = const [],});

  updateVideoDetailBeans(List<Detail> beans) {
    videoDetailBeans = beans;
    notifyListeners();
  }

  String getSelectedVideoContents() {
    if (videoDetailBeans.isEmpty || selectedVideoIdxs.isEmpty) return "";
    List<String> contents = selectedVideoIdxs.map((idx) {
      final content = videoDetailBeans[idx].content;
      if (content.isEmpty) return content;
      final jsonData = jsonDecode(content);
      final isList = jsonData != null && jsonData is List;
      if (!isList) return content;
      List res = jsonData.map((ele) {
        return ele["text"] ?? "";
      }).toList();
      return res.join("");
    }).toList();

    return contents.join("");
  }

  String getSelectedVideoIds() {
    if (videoDetailBeans.isEmpty || selectedVideoIdxs.isEmpty) return "";
    List<int> contents = selectedVideoIdxs.map((idx) {
      return videoDetailBeans[idx].id;
    }).toList();

    return contents.join(",");
  }


  List getSelectedVideoIdsList() {
    if (videoDetailBeans.isEmpty || selectedVideoIdxs.isEmpty) return [];
    List<int> contents = selectedVideoIdxs.map((idx) {
      return videoDetailBeans[idx].id;
    }).toList();

    return contents;
  }

  /// 选中的视频素材下表
  List<int> selectedVideoIdxs = [];
  updateSelectedVideoIdxs(List<int> idxs) {
    selectedVideoIdxs = idxs;
    notifyListeners();
  }

  updateSelectedVideoIdxsWithIndex(int idx) {
    List<int> currentIdxs = List<int>.from(selectedVideoIdxs);
    if (currentIdxs.contains(idx)) {
      currentIdxs.remove(idx);
    } else {
      currentIdxs.add(idx);
    }
    updateSelectedVideoIdxs(currentIdxs);
  }

  /// 根据视频id加载视频详情
  loadCloudVideosForName({
    required String id,
    required void Function(List<Detail>)? onSuccess,
  }) {
    HttpUtils.get(
      APIs.getMaterialDetail,
      {
        "id": id,
        "page": 1,
        "pageSize": 500,
      },
      showLoading: true,
      success: (data) {
        final List listData = data["data"]["data"] ?? [];
        List<Detail> beans = listData.map((e) => Detail.fromJson(e)).toList();

        updateVideoDetailBeans(beans);
        initSelectedShortPlay(list: beans);

        onSuccess?.call(beans);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///初始化选中剧的前三集
  void initSelectedShortPlay({required List<Detail> list}) {
    if(idList.isNotEmpty&&videoDetailBeans.isNotEmpty){
      selectedVideoIdxs = [];
      for (var e1 in idList) {
        for(var e2 in videoDetailBeans ){
          if(e1==e2.id){
            int index = videoDetailBeans.indexOf(e2);
            selectedVideoIdxs.add(index);
          }
        }
      }

      if(selectedVideoIdxs.isNotEmpty){
        notifyListeners();
        return;
      }
    }

    if (list.isNotEmpty && list.length >= 3) {
      selectedVideoIdxs = [];
      selectedVideoIdxs.add(0);
      selectedVideoIdxs.add(1);
      selectedVideoIdxs.add(2);
      notifyListeners();
    }
  }




}
