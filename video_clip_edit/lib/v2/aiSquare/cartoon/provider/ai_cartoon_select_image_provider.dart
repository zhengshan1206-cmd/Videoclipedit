import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';

class AiCartoonSelectImageProvider extends BaseProvider {
  /// 搜索的关键字
  String keywords = "";
  updateKeywords(String content) {
    keywords = content;
    notifyListeners();
  }

  bool hasFocus = false;
  updateHasFocus(bool has) {
    hasFocus = has;
    notifyListeners();
  }

  List<String> images = [];
  updateImages(List<String> imgs) {
    images = imgs;
    notifyListeners();
  }

  int selectedImageIndex = -1;
  updateSelectedImageIndex(int index) {
    selectedImageIndex = index;
    notifyListeners();
  }

  int page = 1;
  int pageSize = 10;
  resetPages() {
    page = 1;
    images.clear();
  }

  loadImages({
    required String pid,
    required int imgId,
    String? keyword,
  }) {
    HttpUtils.post(
      APIs.searchSplitImg,
      {
        "pid": pid,
        "img_id": imgId,
        "keyword": keyword ?? keywords,
        "page": page,
        "pageSize": pageSize,
      },
      success: (data) {
        final List<String> items = data["data"]["items"].cast<String>() ?? [];
        byDebugPrint(data);
        final res = List<String>.from(images);
        page = res.addElementsByRemovingLast(
          items,
          currentPage: page,
          pageSize: pageSize,
        );
        updateImages(res);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }
}
