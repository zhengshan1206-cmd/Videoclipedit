import 'package:get/get.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/data/model/slicing/prompt_item_bean.dart';
import 'package:video_clip_edit/core/base/controllers/base_controller.dart';

class SingleListController extends BaseController {
  final RxList<PromptItemBean> _promptItemBeans = <PromptItemBean>[].obs;

  List<PromptItemBean> get promptItemBeans => _promptItemBeans;

  /// 根据分类id加载提示词列表
  void loadPromptList(int categoryId) {
    HttpUtils.get(
      APIs.filmPrompt,
      {
        "category_id": categoryId,
      },
      success: (data) {
        final list = data['data']["data"] as List;
        _promptItemBeans.value =
            list.map((e) => PromptItemBean.fromJson(e)).toList();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }
}
