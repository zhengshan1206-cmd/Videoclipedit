import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/v2/aiClip/beans/ai_sample_video_item.dart';

import '../../../widgets/toast_util.dart';

class AiClipSampleProvider extends BaseProvider {
  int page = 1;
  List<AiSampleVideoItemBean> sampleVideoItemBeans = [];
  updateSampleVideoItemBeans(List<AiSampleVideoItemBean> beans) {
    sampleVideoItemBeans = beans;
    notifyListeners();
  }

  /// 按照视频比例获取素材列表
  /// [page] 当前页数
  /// [pageSize] 每页记录数
  /// [pid]
  aiSampleVideoList({
    required int pid,
    bool reset = false,
    required EasyRefreshController controller,
  }) {
    if (reset) {
      page = 1;
      sampleVideoItemBeans.clear();
    }
    HttpUtils.get(
      APIs.aiMaterialDemoList,
      {
        "pid": pid,
        "page": page,
        "pageSize": 10,
      },
      showLoading: false,
      success: (data) {
        final List items = data["data"]["items"] ?? [];
        final List<AiSampleVideoItemBean> beans =
            List<AiSampleVideoItemBean>.from(
                items.map((e) => AiSampleVideoItemBean.fromJson(e)));
        if (reset) {
          controller.finishRefresh();
          controller.resetFooter();
        } else {
          controller.finishLoad(
            beans.length % 10 == 0
                ? IndicatorResult.success
                : IndicatorResult.noMore,
          );
        }
        final results = List<AiSampleVideoItemBean>.from(sampleVideoItemBeans);
        page = results.addElementsByRemovingLast(
          beans,
          pageSize: 10,
          currentPage: page,
        );
        updateSampleVideoItemBeans(results);
      },
      fail: (code, msg) {
        controller.finishLoad(IndicatorResult.fail);
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);

      },
    );
  }
}
