import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';

class ToolBoxPageProvider extends BaseProvider {
  List<SubFunction>? menuItemBeans;
  List<String> menuItemBeansImgs=[];


  loadMenuData() {
    HttpUtils.get(
      APIs.homeBanner,
      {"postion": 8},
      success: (data) {
        menuItemBeansImgs.clear();
        final List bannerData = data["data"]["item"] ?? [];
        List<SubFunction> beans =
        bannerData.map((e) => SubFunction.fromJson(e)).toList();
        menuItemBeans = beans;
        menuItemBeans?.forEach((data){
          menuItemBeansImgs.add(data.imgUrl);
        });

        notifyListeners();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }



}
