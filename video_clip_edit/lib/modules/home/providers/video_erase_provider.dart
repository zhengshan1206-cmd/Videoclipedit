import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/home/beans/function_item_bean.dart';
import 'package:video_clip_edit/modules/home/erase/beans/pen_size_bean.dart';
import 'package:video_clip_edit/modules/home/erase/beans/erease_record_bean.dart';

class VideoEraseProvider extends BaseProvider {
  List<FunctionItemBean> homeFunctions = [
    FunctionItemBean.fromJson({
      "icon": "assets/home/watermark_video.png",
      "title": "视频擦除",
      "desc": "上传本地视频文件"
    }),
    FunctionItemBean.fromJson({
      "icon": "assets/toolbox/icon_image_erase.png",
      "title": "图片擦除",
      "desc": "上传本地图片文件"
    })
  ];

  /// 笔触列表
  List<PenSizeBean> penSizeBeans = [
    PenSizeBean.fromJson({"penSize": 15.w, "radius": 15.w, "selected": false}),
    PenSizeBean.fromJson({"penSize": 20.w, "radius": 20.w, "selected": false}),
    PenSizeBean.fromJson({"penSize": 25.w, "radius": 25.w, "selected": false}),
    PenSizeBean.fromJson({"penSize": 30.w, "radius": 30.w, "selected": false}),
    PenSizeBean.fromJson({"penSize": 35.w, "radius": 35.w, "selected": false})
  ];

  PenSizeBean? selectBean;

  updatePensize(PenSizeBean bean) {
    for (var e in penSizeBeans) {
      e.selected = e.radius == bean.radius;
      if (e.selected == true) {
        selectBean = e;
      }
    }
    // notifyListeners();
  }

  List<EreaseRecordBean> ereaseRecordBean = [];

  updateEreaseRecordBeans(List<EreaseRecordBean> beans) {
    ereaseRecordBean = beans;
    notifyListeners();
  }

  int ereasePage = 1;
  int ereasePageSize = 10;
  loadEreaseRecords() {
    HttpUtils.get(
      APIs.getEraseRecords,
      {
        "page": ereasePage,
        "page_size": ereasePageSize,
      },
      success: (data) {
        final List records = data["data"]["data"] ?? [];
        final List<EreaseRecordBean> beans =
            records.map((e) => EreaseRecordBean.fromJson(e)).toList();
        updateEreaseRecordBeans(beans);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }
}
