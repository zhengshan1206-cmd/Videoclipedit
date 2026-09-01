import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/modules/home/beans/function_item_bean.dart';
import 'package:video_clip_edit/modules/home/beans/words_task_cell_bean.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';

class WaterMarkProvider extends BaseProvider {
  WaterMarkProvider() {
    _loadRecords();
  }

  final functionList = [
    FunctionItemBean.fromJson({
      "icon": "assets/home/watermark_links.png",
      "title": "链接提取",
      "desc": "提取短视频链接里面的文案"
    }),
    FunctionItemBean.fromJson({
      "icon": "assets/home/watermark_video.png",
      "title": "视频提取",
      "desc": "提取视频里面的文案"
    }),
    FunctionItemBean.fromJson({
      "icon": "assets/home/watermark_upload.png",
      "title": "图片提取",
      "desc": "提取图片里面的文案"
    }),
    FunctionItemBean.fromJson({
      "icon": "assets/home/watermark_my_woks.png",
      "title": "音频提取",
      "desc": "提取音频里面的文案"
    }),
  ];

  int page = 1;
  int pageSize = 10;

  /// 加载提取纪录
  void _loadRecords() {
    HttpUtils.get(
      APIs.getExtractTextList,
      {
        "page": page,
        "pageSize": pageSize,
        "type": "Table",
        "file_type": 1,
      },
      success: (data) {
        byDebugPrint(data, tag: "_loadRecords");
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  List<WordsTaskCellBean>? taskBeans = [
    WordsTaskCellBean.fromJson({
      "contents": "啊还是看见电话卡就是贷款啊是电话卡就是的科技啊还是打开啊接口是电话卡是贷记卡还是肯德基啊是电话卡就啊啥的科技",
      "date": "2023-09-19 10:22",
    }),
    WordsTaskCellBean.fromJson({
      "contents": "啊还是看见电话卡就是贷款啊是电话卡就是的科技啊还是打开啊接口是电话卡是贷记卡还是肯德基啊是电话卡就啊啥的科技",
      "date": "2023-09-19 10:22",
    }),
    WordsTaskCellBean.fromJson({
      "contents": "啊还是看见电话卡就是贷款啊是电话卡就是的科技啊还是打开啊接口是电话卡是贷记卡还是肯德基啊是电话卡就啊啥的科技",
      "date": "2023-09-19 10:22",
    }),
  ];
}
