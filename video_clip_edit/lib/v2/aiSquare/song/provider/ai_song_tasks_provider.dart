import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/song/beans/ai_song_task_detail_bean.dart';

class AiSongTasksProvider extends BaseProvider {
  //管理模式
  bool isEdit = false;

  //是否全选
  bool isEditAll = false;
  List<AiSongTaskDetailBean> aiSongTasksBean = [];

  int page = 1;
  int size = 10;

  setEdit(bool isEdit) {
    this.isEdit = isEdit;

    significanceData();
    notifyListeners();
  }

  setEditAll(bool isAll) {
    bool isSelect = false;
    if (isAll) {
      aiSongTasksBean.forEach((data) {
        if (checkIsSelect(data.status, isShowMsg: false)) {
          data.isSelect = true;
          isSelect = true;
        }
      });
      if (isSelect) {
        isEditAll = isAll;
        notifyListeners();
      } else {
        BotToast.showText(text: "不能操作正在生成中的视频!");
      }
    } else {
      aiSongTasksBean.forEach((data) {
        if (checkIsSelect(data.status, isShowMsg: false)) {
          data.isSelect = false;
        }
      });
      isEditAll = isAll;
      notifyListeners();
    }
  }

  //状态:0待提交 1已提交 2生成中 3生成成功 4生成失败
  bool checkIsSelect(int status, {bool isShowMsg = true}) {
    if (status != 2&&status != 0&&status != 1) {
      return true;
    } else {
      if (isShowMsg) {
        BotToast.showText(text: "该视频正在生成中");
      }
      return false;
    }
  }

  //删除选中
  deleteSelect() {
    String deleteIds = "";
    for (int i = 0; i < aiSongTasksBean.length; i++) {
      if (aiSongTasksBean[i].isSelect) {
        deleteIds += aiSongTasksBean[i].id.toString() +
            (i == aiSongTasksBean.length - 1 ? "" : ",");
      }
    }
    if (deleteIds.isNotEmpty) {
      batchDeleteDetails(deleteIds);
    } else {
      BotToast.showText(text: "请先选中要删除的作品!");
    }
  }

  //取消或完成复原数据
  significanceData() {
    for (int i = 0; i < aiSongTasksBean.length; i++) {
      aiSongTasksBean[i].isSelect = false;
    }
    isEditAll = false;
    notifyListeners();
  }

  ///最近任务
  getDetailList(bool reset) {
    if (reset) {
      page = 1;
      aiSongTasksBean.clear();
    }
    HttpUtils.get(
      APIs.getDetailList,
      {
        "page": page,
        "pageSize": size,
      },
      success: (data) {
        final List items = data["data"]["data"] ?? [];
        final caseBeans = List<AiSongTaskDetailBean>.from(items.map(
          (ele) => AiSongTaskDetailBean.fromJson(ele),
        ));

        final allBeans = List<AiSongTaskDetailBean>.from(aiSongTasksBean);

        page = allBeans.addElementsByRemovingLast(
          caseBeans,
          currentPage: page,
          pageSize: size,
        );

        aiSongTasksBean = allBeans;
        notifyListeners();

        // var  newData= data["data"]["data"]
        //       .map((e) => AiSongTaskDetailBean.fromJson(e))
        //       .toList()
        //       .cast<AiSongTaskDetailBean>();
        //   page = aiSongTasksBean.addElementsByRemovingLast(
        //     newData,
        //     currentPage: page,
        //     pageSize: size,
        //   );

        //状态:0待提交 1已提交 2生成中 3生成成功 4生成失败

        // aiSongTasksBean.add(aiSongTasksBean[0]);
        // aiSongTasksBean.add(aiSongTasksBean[0]);
        // aiSongTasksBean.add(aiSongTasksBean[0]);
        // aiSongTasksBean.add(aiSongTasksBean[0]);
        // aiSongTasksBean.add(aiSongTasksBean[0]);
        // aiSongTasksBean.add(aiSongTasksBean[0]);
        // aiSongTasksBean[0].status=0;
        // aiSongTasksBean[1].status=1;
        // aiSongTasksBean[2].status=2;
        // aiSongTasksBean[3].status=3;
        // aiSongTasksBean[4].status=4;
      },
      fail: (code, msg) {},
    );
  }

  //管理
  batchDeleteDetails(String deleteIds) {
    HttpUtils.post(
      APIs.batchDeleteDetails,
      {
        "ids": deleteIds,
      },
      showLoading: true,
      success: (data) {
        significanceData();
        getDetailList(true);
      },
      fail: (code, msg) {},
    );
  }
}
