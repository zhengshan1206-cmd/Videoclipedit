import 'package:get/get.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/v2/minorMode/beans/minor_feature_item.dart';
import 'package:video_clip_edit/v2/minorMode/controllers/minor_mode_controller.dart';

class MinorController extends GetxController {
  static const String backgroundAsset = 'assets/minor/minor-1.png';
  static const String headerAsset = 'assets/minor/minor-2.png';

  static const String noticePrefix = '更多信息可阅读';
  static const String noticeTitle = '《未成年人使用须知》';
  static const String enableButtonText = '开启未成年人模式';

  final String noticeUrl = APIs.minorAgreementUrl;

  final List<MinorFeatureItem> features = const [
    MinorFeatureItem(
      icon: 'assets/minor/minor-3.png',
      title: '防止沉迷安全护航',
      description: '默认每天使用40分钟、禁用时间段无法使用妙笔工坊',
    ),
    MinorFeatureItem(
      icon: 'assets/minor/minor-4.png',
      title: '分龄定制更懂孩子',
      description: '细分年龄段推荐适龄主题内容，更精准满足孩子身心健康成长需要',
    ),
    MinorFeatureItem(
      icon: 'assets/minor/minor-5.png',
      title: '海量知识 妙趣横生',
      description: '科学科普、兴趣素养、国学诗词、传统文化、安全教育，各类知识应有尽有',
    ),
  ];

  void openMinorNotice() {
    final context = Get.context;
    if (context == null) return;

    ByNavRouterUtils.jumpWebViewPage(context, '未成年人使用须知', noticeUrl);
  }

  void enableMinorMode() {
    MinorModeController.to.openEnableMinorModeFlow();
  }
}
