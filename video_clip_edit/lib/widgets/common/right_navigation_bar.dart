/*
  right_navition_bar.dart
  右上角导航栏组件
  Created by duncy on 25/4/16.
*/
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import '../../modules/guid/beans/guide_pop_beans.dart';
import '../../modules/guid/providers/guide_pop_providers.dart';
import '../../modules/guid/widgets/guide_pop_page.dart';
import '../../modules/tool_box/videoExtraction/guide_page.dart';
import '../../modules/tool_box/videoExtraction/providers/video_extraction_provider.dart';
import '../../utils/comon/by_colors.dart';
import '../../utils/comon/by_common_utils.dart';
import '../../utils/comon/by_nav_router_utils.dart';
import '../../utils/comon/by_widgets_util.dart';

class RightNavigationBar extends StatefulWidget {
  const RightNavigationBar({
    super.key,
    required this.entranceType,
    this.hasMultipilePage = false,
  });
  //页面入口类型
  //展示位置 1：文生视频，2：图生视频，3：小说推文，4：短剧混剪，5：短剧解说，6：音乐生成，7：小说生成，8：数字人，9：文生图 10：爆文创作 (已废弃)
  final GuideEntranceType entranceType;
  //是否有多页面
  final bool? hasMultipilePage;

  @override
  State<RightNavigationBar> createState() => _RightNavigationBarState();
}

class _RightNavigationBarState extends State<RightNavigationBar> {
  final GuideController controller = Get.put(GuideController());
  Map<String, GuidePopBean> guidePopBeans = {};
  late final String routeName;

  @override
  void initState() {
    // controller = Get.put(GuideController());
    routeName = controller.getRouteName(widget.entranceType);
    addGuideBean(widget.entranceType);
    super.initState();
  }

  //添加攻略弹窗数据
  void addGuideBean(GuideEntranceType type) {
    controller.getGuideData(
      type: widget.entranceType,
      onSuccess: (data) {
        if (data.jumpType != null) {
          setState(() {
            guidePopBeans[routeName] = data;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildRightBar(context);
  }

  //初始化右上角导航栏按钮
  Widget _buildRightBar(BuildContext context) {
    final userController = Get.find<UserController>();
    //多页面时需要重新获取新的页面数据
    if (guidePopBeans.isEmpty || guidePopBeans[routeName] == null) {
      return Container();
    }
    GuidePopBean guidePopBean = guidePopBeans[routeName]!;
    //异常数据处理
    if (guidePopBean.jumpType == null) {
      return Container();
    }
    //判断跳转类型是否是已知的
    if (![1, 3, 4].contains(guidePopBean.jumpType)) {
      return Container();
    }
    return Obx(() => userController.isShowSpringStyle.value
        ? GestureDetector(
            onTap: () {
              _routerPush(guidePopBean, context);
            },
            child: Container(
              height: 30.h,
              margin: EdgeInsets.only(right: 12.w),
              child: SizedBox(
                width: 80.w,
                height: 30.h,
                child: Image.asset(
                  "assets/springFestival/springFestival-5.png",
                  fit: BoxFit.fill,
                ),
              ),
            ),
          )
        : Container(
            height: 30.h,
            margin: EdgeInsets.only(right: 12.w),
            child: ByWidgetsUtil.btnWithIcon(
              context: context,
              iconH: 12.w,
              iconW: 12.w,
              fontSize: 12.sp,
              title: "使用攻略",
              borderRadius: 100.w,
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10.w),
              bgColor: ByColorUtil.WhiteColor,
              iconPath: "assets/home/icon_strategy.png",
              textColor: ByColorUtil.CommonTextColor,
              onClick: () {
                _routerPush(guidePopBean, context);
                // _showNormalGuidePage(context);
              },
            ),
          )
    );
  }

  //跳转到不同的页面
  _routerPush(GuidePopBean bean, BuildContext context) {
    //异常处理
    int? type = bean.jumpType;
    String? url = bean.url;
    if (type == null || url == null) {
      // _showNormalGuidePage(context);
      return;
    }

    // 1:内部链接 3:视频播放 4:外部网页
    if (type == 3) {
      // 跳转到视频播放页面
      //  Get.to(GuidePopPage(url: url));
      showGuidePopDialog(
        context,
        url,
        topHintText: "${controller.getGuideTitle(widget.entranceType)}教程",
      );
    } else if (type == 4) {
      // 跳转到外部链接页面
      ByCommonUtils.launchWebURL(url);
    } else if (type == 1) {
      // 跳转到内嵌网页页面
      ByNavRouterUtils.jumpWebViewPage(context, "", url, isRisk: false);
    }
  }

  // 跳转到默认攻略页(旧页面，已废弃)
  _showNormalGuidePage(BuildContext context) {
    ByNavRouterUtils.push(
      context,
      ChangeNotifierProvider(
        create: (context) => VideoExtractionProvider(),
        child: const GuidePage(),
      ),
    );
  }
}
