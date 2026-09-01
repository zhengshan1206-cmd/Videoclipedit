/*
 * @Author: duncy
 * @Date: 2025-07-24 10:08:42
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-12-30 16:20:57
 * @FilePath: /video_clip_edit/lib/v2/aiSquare/mixin/ai_banner_mixin.dart
 * @Description: 
 */
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';

class AiBannerMixin extends BaseProvider {
  List<SubFunction> bannerBeans = [];
  updateBannerBeans(List<SubFunction> beans) {
    bannerBeans = beans;
    notifyListeners();
  }

  bool showBanner = true;
  updateShowBanner(bool show) {
    showBanner = show;
    notifyListeners();
  }

  /// [postion] banner所处的位置
  /// 1:  首页
  /// 2:  AI文案
  /// 3:  AI绘图
  /// 4:  AI视频
  /// 5:  智能混剪
  /// 6:  照片播报
  /// 7:  个人中心
  /// 8:  flutter-工具箱
  /// 9:  短剧混剪
  /// 10: 短剧二创
  /// 11: AI音乐
  /// 12: AI视频(可灵)
  loadBanners({
    required int postion,
  }) {
    HttpUtils.get(
      APIs.homeBanner,
      {
        "postion": postion,
      },
      showMsgWhenFailed: false,
      success: (data) {
        bannerBeans.clear();
        final List bannerData = data["data"]["item"] ?? [];
        List<SubFunction> beans =
            bannerData.map((e) => SubFunction.fromJson(e)).toList();
        updateBannerBeans(beans);
      },
      fail: (code, msg) {},
    );
  }
}
