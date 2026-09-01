import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/v2/toolBox/beans/new_tool_box_category_bean.dart';

class NewToolBoxProvider extends BaseProvider {
  NewToolBoxProvider() {
    loadCategory();

    loadBannerData();
  }

  /// 当前页面竖直方向的滚动偏移量
  double currentOffset = 0;
  updateOffset(double offset) {
    currentOffset = offset;
    notifyListeners();
  }

  /// 当前选中的标签索引
  int selectedIndex = -1;
  updateSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  List<NewToolBoxCategoryBean> categoryBeans = [];
  updateCategoryBeans(List<NewToolBoxCategoryBean> beans) {
    categoryBeans = beans;
    notifyListeners();
  }

  /// [postion] 数据所在的页面位置
  /// 1=>'首页'
  /// 2=>'首页AI助理'
  /// 3=>'工具箱',
  loadCategory() {
    HttpUtils.get(
      APIs.crumbsCategoryList,
      {"postion": 3},
      success: (data) {
        byDebugPrint(data);
        final list = data['data']["list"] ?? [];
        final beans = List<NewToolBoxCategoryBean>.from(
            list.map((e) => NewToolBoxCategoryBean.fromJson(e)));
        updateCategoryBeans(beans);

        if (beans.isNotEmpty) {
          updateSelectedIndex(0);
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  List<SubFunction> bannerBeans = [];
  updateBannerBeans(List<SubFunction> beans) {
    bannerBeans = beans;
    notifyListeners();
  }

  loadBannerData() {
    HttpUtils.get(
      APIs.homeBanner,
      {"postion": 8},
      success: (data) {
        final List bannerData = data["data"]["item"] ?? [];
        List<SubFunction> beans =
            bannerData.map((e) => SubFunction.fromJson(e)).toList();
        updateBannerBeans(beans);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }
}
