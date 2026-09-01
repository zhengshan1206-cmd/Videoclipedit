import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/v2/hotCreate/beans/hot_create_novel_details_bean.dart';

class NovelCreateDetailsProvider extends BaseProvider {
  int page = 1;
  int size = 10;
  List<HotCreateNovelDetailsBean> novelBeans = [];
  updateNovelBeans(List<HotCreateNovelDetailsBean> beans) {
    novelBeans = beans;
    notifyListeners();
  }

  /// [novelId] 小说id
  getNovelList({
    bool refresh = false,
    required String novelId,
  }) {
    if (refresh) {
      page = 1;
    }

    HttpUtils.get(
      APIs.getNovelDetailList,
      {
        "page": page,
        "size": size,
        "novel_id": novelId,
      },
      success: (data) {
        byDebugPrint(data);
        final items = data["data"]["items"];
        if (refresh) {
          novelBeans.clear();
        }
        final results = List.from(novelBeans);

        final List<HotCreateNovelDetailsBean> beans =
            List<HotCreateNovelDetailsBean>.from(
                items.map((e) => HotCreateNovelDetailsBean.fromJson(e)));

        page = results.addElementsByRemovingLast(
          beans,
          currentPage: page,
          pageSize: size,
        );
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }
}
