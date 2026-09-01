import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/v2/aiVideo/models/notice_model.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';

import '../../../controller/user_controller.dart';
import '../../../modules/profile/beans/user_info_bean.dart';
import '../../../providers/launch_provider.dart';

/// 首页顶部 2 大卡 + 右侧 N 小卡：按固定宽高比联算像素，窄屏缩小但不变形、不溢出。
class HomeTopBannerLayout {
  HomeTopBannerLayout({
    required this.largeW,
    required this.largeH,
    required this.smallW,
    required this.smallH,
  });

  final double largeW;
  final double largeH;
  final double smallW;
  final double smallH;

  static const double _rLarge = 150 / 128;
  static const double _rSmall = 79 / 71;

  /// [innerRowW] = 屏宽 − 左右页边距 − 左侧 12.w，用于大卡+小卡+间距之和。
  static HomeTopBannerLayout compute({
    required double innerRowW,
    required int nLarge,
    required int nSmall,
    required double gap,
  }) {
    final inner = innerRowW.clamp(200.0, 2000.0);
    if (nLarge <= 0) {
      return HomeTopBannerLayout(
          largeW: 0, largeH: 0, smallW: 0, smallH: 0);
    }
    if (nSmall <= 0) {
      if (nLarge == 1) {
        final lw = inner.clamp(80.0, inner);
        final lh = lw * _rLarge;
        return HomeTopBannerLayout(
            largeW: lw, largeH: lh, smallW: 0, smallH: 0);
      }
      final lw = ((inner - gap) / 2).clamp(60.0, inner);
      final lh = lw * _rLarge;
      return HomeTopBannerLayout(
          largeW: lw, largeH: lh, smallW: 0, smallH: 0);
    }
    // 2*largeW + 2*gap + smallW = inner ；小卡列总高 = largeH = nSmall*smallH + (nSmall-1)*gap
    final rhs = inner - 2 * gap;
    final coef = 2 + (_rLarge * _rSmall) / nSmall;
    final lw =
        ((rhs + ((nSmall - 1) * gap * _rSmall) / nSmall) / coef).clamp(48.0, inner);
    final lh = lw * _rLarge;
    final sh = ((lh - (nSmall - 1) * gap) / nSmall).clamp(24.0, lh);
    final sw = sh * _rSmall;
    return HomeTopBannerLayout(
        largeW: lw, largeH: lh, smallW: sw, smallH: sh);
  }
}

///首页 新的顶部区域 3.10.9
class NewHeaderView extends StatelessWidget {
  const NewHeaderView({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return const HomePageNewBannerView();
  }
}

class HomePageNewBannerView extends StatelessWidget {
  const HomePageNewBannerView({
    super.key,
  });

  ///公告
  Widget noticeView({
    required NoticeModel model,
    required bool showNotice,
  }) {
    if (!showNotice || model.content == null) {
      return const SizedBox();
    }
    return Padding(
      padding: EdgeInsets.only(left: 12.w, right: 12.w),
      child: Stack(
        children: [
          Image.asset(
            "assets/home/img.png",
            height: 32.w,
          ),
          Align(
            alignment: Alignment.center,
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 12.w,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5.w),
                  child: CachedNetworkImage(
                    width: 24.w,
                    height: 24.w,
                    imageUrl: model.icon ?? "",
                  ),
                ),
                SizedBox(
                  width: 7.w,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 3.w),
                    child: Text(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      model.content ?? "",
                      style: TextStyle(
                        color: const Color(0XFF0B1843),
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 2.w),
                    child: GestureDetector(
                      onTap: () {
                        SpUtil.putBool("close_notice", true);
                      },
                      child: Image.asset(
                        "assets/home/home_notice_close.png",
                        width: 16.w,
                        height: 16.w,
                      ),
                    )),
                SizedBox(
                  width: 10.w,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  ///点击事件
  void itemClickEvent(
      {required BuildContext context, required SubFunction e}) async {
    ByNavigatorUtil.itemClickEvent(context: context, e: e);

    // final UserController controller = Get.find<UserController>();
    // UserInfoBean? userInfo = controller.user.value;
    // if ((userInfo?.isFormal ?? 0) == 1) {
    //   ByCommonUtils.subFunctionCase(context, e);
    // } else {
    //   controller.login().then((value) {
    //     userInfo = controller.user.value;
    //     if ((userInfo?.isFormal ?? 0) == 1) {
    //       ByCommonUtils.subFunctionCase(context, e);
    //     }
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    final bannerBeans = context.select<AiSquareProvider, List<SubFunction>>(
      (value) => value.bannerBeans,
    );
    final noticeModel = context.select<AiSquareProvider, NoticeModel>(
      (value) => value.noticeModel,
    );

    final showNotice = context.select<AiSquareProvider, bool>(
      (value) => value.showNotice,
    );

    log("bannerBeans:====> $bannerBeans");
    if (bannerBeans.isEmpty) {
      return const SizedBox();
    }
    List<SubFunction> bannerBeansLarge = [];
    List<SubFunction> bannerBeansSmall = [];
    if (bannerBeans.length > 2) {
      bannerBeansLarge = bannerBeans.sublist(0, 2);
      bannerBeansSmall = bannerBeans.sublist(2);
    } else {
      bannerBeansLarge = bannerBeans;
    }
    final gap = 8.w;
    final contentW = ByScreenUtils.screenWidth - 24.w;
    final innerRowW = (contentW - 12.w).clamp(120.0, 2000.0);
    final layout = HomeTopBannerLayout.compute(
      innerRowW: innerRowW,
      nLarge: bannerBeansLarge.length,
      nSmall: bannerBeansSmall.length,
      gap: gap,
    );

    Widget largeCard(SubFunction e, {required bool addGapAfter}) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ByNavigatorUtil.reportDataPoint(
            pageTag: "home_top_func",
            operateType: "click",
            funcDetailTag: e.id.toString(),
            funcDetailImg: e.imgUrl,
          );
          ByNavigatorUtil.checkLogin(
              context: context,
              nextStepEvent: () {
                ByCommonUtils.subFunctionCase(context, e);
              });
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.w),
          child: Container(
            height: layout.largeH,
            width: layout.largeW,
            margin: EdgeInsets.only(right: addGapAfter ? gap : 0),
            alignment: Alignment.center,
            child: CachedNetworkImage(
              imageUrl: e.imgUrl,
              fit: BoxFit.cover,
              width: layout.largeW,
              height: layout.largeH,
            ),
          ),
        ),
      );
    }

    final largeChildren = <Widget>[
      SizedBox(width: 12.w),
      for (var i = 0; i < bannerBeansLarge.length; i++)
        largeCard(
          bannerBeansLarge[i],
          addGapAfter: i < bannerBeansLarge.length - 1 ||
              bannerBeansSmall.isNotEmpty,
        ),
    ];

    if (bannerBeansSmall.isNotEmpty) {
      largeChildren.add(
        SizedBox(
          width: layout.smallW,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var j = 0; j < bannerBeansSmall.length; j++) ...[
                if (j > 0) SizedBox(height: gap),
                () {
                  final e = bannerBeansSmall[j];
                  return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    ByNavigatorUtil.reportDataPoint(
                      pageTag: "home_top_func",
                      operateType: "click",
                      funcDetailTag: e.id.toString(),
                      funcDetailImg: e.imgUrl,
                    );
                    ByNavigatorUtil.checkLogin(
                        context: context,
                        nextStepEvent: () {
                          ByCommonUtils.subFunctionCase(context, e);
                        });
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.w),
                    child: SizedBox(
                      width: layout.smallW,
                      height: layout.smallH,
                      child: CachedNetworkImage(
                        imageUrl: e.imgUrl,
                        fit: BoxFit.cover,
                        width: layout.smallW,
                        height: layout.smallH,
                      ),
                    ),
                  ),
                );
                }(),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: largeChildren,
        ),
        // 与下方「工具箱」四宫格之间的留白（阔折内屏等宽屏上易贴死）
        SizedBox(height: 12.h),
      ],
    );
  }
}
