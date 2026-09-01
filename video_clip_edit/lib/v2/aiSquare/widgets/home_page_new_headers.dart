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
import 'package:video_clip_edit/v2/aiVideo/models/notice_model.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';

import '../../../controller/user_controller.dart';
import '../../../modules/profile/beans/user_info_bean.dart';
import '../../../providers/launch_provider.dart';

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
    return Column(
      children: [
        // noticeView(model: noticeModel,showNotice:showNotice ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 12.w,
            ),
            ...bannerBeansLarge.map((e) {
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
                  // itemClickEvent(context: context, e: e);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.w),
                  child: Container(
                    height: 150.h,
                    width: 128.w,
                    margin: EdgeInsets.only(right: 8.w),
                    child: CachedNetworkImage(
                      imageUrl: e.imgUrl,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              );
            }),
            // Column(
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   children: [
            //     ...bannerBeansSmall.sublist(0,2).map((e) {
            //       return GestureDetector(
            //           behavior: HitTestBehavior.opaque,
            //           onTap: () {
            //             e.jumpUrl = 'anime';
            //             ByCommonUtils.subFunctionCase(context, e);
            //             // itemClickEvent(context: context, e: e);
            //           },
            //           child: Container(
            //               width: 128.w,
            //               height: 71.w,
            //               margin: EdgeInsets.only(bottom: 8.w, right: 8.w),
            //               child: ClipRRect(
            //                 borderRadius: BorderRadius.circular(12.w),
            //                 child: CachedNetworkImage(
            //                     imageUrl: e.imgUrl, fit: BoxFit.cover),
            //               ),
            //             ));
            //     })
            //   ],
            // ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ...bannerBeansSmall.map((e) {
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
                              // itemClickEvent(context: context, e: e);
                            });
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.w),
                        child: Container(
                          width: 79.w,
                          height: 71.w,
                          margin: EdgeInsets.only(bottom: 8.w),
                          child: CachedNetworkImage(
                              imageUrl: e.imgUrl, fit: BoxFit.cover),
                        ),
                      ));
                })
              ],
            )
          ],
        ),
      ],
    );
  }
}
