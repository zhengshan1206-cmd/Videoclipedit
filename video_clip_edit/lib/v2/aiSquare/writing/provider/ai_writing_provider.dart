import 'package:flutter/cupertino.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/modules/home/story/assistant/beans/creator_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/writing/beans/ai_writing_record_bean.dart';
import 'package:video_clip_edit/modules/home/story/assistant/beans/assistant_record_item_bean.dart';

class AiWritingProvider extends BaseProvider {
  TextEditingController evaluationContentEditingController =
      TextEditingController();
  EasyRefreshController assistantController = EasyRefreshController();

  bool isEdit = false;
  bool isEditAll = false;
  List<CreatorBean> mAiWritingListBean = [];
  List<AssistantRecordItemBean> mAiWritingRecordBean = [];
  setEdit(bool isEdit) {
    this.isEdit = isEdit;
    notifyListeners();
  }

  setEditAll(bool isAll) {
    if (isAll) {
    } else {}
  }

  loadaiWritingListData({Function? call}) {
    HttpUtils.get(
      APIs.creators,
      {},
      success: (data) {
        final List creators = data["data"] ?? [];
        mAiWritingListBean =
            creators.map((e) => CreatorBean.fromJson(e)).toList();
        notifyListeners();
        if (call != null) call();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  int assistantPage = 1;
  int assistantPageSize = 10;

  /// 创作助手纪录
  void loadAssistantRecord({
    bool reset = false,
  }) {
    if (reset) {
      assistantPage = 1;
      mAiWritingRecordBean.clear();
    }
    HttpUtils.get(
      APIs.assistantRecord,
      {
        "history": 1,
        "page": assistantPage,
        "limit": assistantPageSize,
      },
      success: (data) {
        final List items = data["data"]["data"] ?? [];

        final beans = List<AssistantRecordItemBean>.from(items.map(
          (ele) => AiWritingRecordBean.fromJson(ele),
        ));
        final allBeans =
            List<AssistantRecordItemBean>.from(mAiWritingRecordBean);

        assistantPage = allBeans.addElementsByRemovingLast(
          beans,
          currentPage: assistantPage,
          pageSize: assistantPageSize,
        );

        mAiWritingRecordBean = beans;
        notifyListeners();
      },
      fail: (code, msg) {
        assistantController.finishLoad(IndicatorResult.fail, true);
        BotToast.showText(text: msg);
      },
    );
  }
}
