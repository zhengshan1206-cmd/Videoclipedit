import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/v2/toolBox/beans/new_tool_box_list_bean.dart';

class HomeGrideViewProvider extends BaseProvider {
  List<NewToolBoxListBean> listBeans = [];
  updateListBeans(List<NewToolBoxListBean> beans) {
    listBeans = beans;
    notifyListeners();
  }

  int page = 1;
  int size = 10;

  int loadTimes = 0;
  // updateLoadTimes() {}

  resetPages() {
    page = 1;
    listBeans.clear();
  }

  /// [categoryId] 分类id
  /// [isRefresh] 是否下拉刷新
  /// [page] 分页
  /// [size] 每页数量
  loadList({
    required int categoryId,
    bool isRefresh = false,
    void Function(bool hasMore)? onSuccess,
    void Function()? onFailed,
  }) {
    if (isRefresh) {
      resetPages();
    }
    HttpUtils.get(
      APIs.crumbsList,
      {
        "page": page,
        "size": size,
        "category_id": categoryId,
      },
      // showLoading: true,
      success: (data) {
        loadTimes++;
        final list = data['data']["items"] ?? [];
        final beans = List<NewToolBoxListBean>.from(
          list.map(
            (e) => NewToolBoxListBean.fromJson(e),
          ),
        );
        final results = List<NewToolBoxListBean>.from(listBeans);
        page = results.addElementsByRemovingLast(beans,
            pageSize: size, currentPage: page);
        updateListBeans(results);
        if (results.isEmpty) {
          notifyListeners();
        }
        onSuccess?.call(beans.isNotEmpty && beans.length % 10 == 0);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        onFailed?.call();
      },
    );
  }
}
