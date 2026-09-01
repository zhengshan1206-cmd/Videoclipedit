import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/widgets/common/common_sliver_persistent_header.dart';
import 'package:video_clip_edit/widgets/common_button.dart';
import 'package:video_clip_edit/widgets/image/by_image_view.dart';

///推广中间非吸顶部分
class PromotionMiddleView extends StatelessWidget {
  const PromotionMiddleView({
    super.key,
    required this.bannerList,
  });

  final List<SubFunction> bannerList;

  @override
  Widget build(BuildContext context) {
    final largeImageHeight = 175.w * 186 / 175;
    final normalImageHeight = 170.w * 90 / 170;

    final hasBanner = bannerList.isNotEmpty;
    final double bannerH = hasBanner ? largeImageHeight : 0;
    return CommonSliverPersistentHeader(
      pinned: false,
      minHeight: bannerH,
      maxHeight: bannerH,
      child: !hasBanner
          ? Container()
          : Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
              ),
              child: Row(
                children: [
                  _buildImage(175.w, largeImageHeight, bannerList[0], context),
                  SizedBox(width: 6.w),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildImage(
                          170.w, normalImageHeight, bannerList[1], context),
                      _buildImage(
                          170.w, normalImageHeight, bannerList[2], context),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  _buildImage(double width, double height, SubFunction bannerBean,
      BuildContext context) {
    return CommonButton(
      minSize: 0,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.zero,
      onPressed: () {
        log("点击短剧创作===> ${bannerBean.toJson()}");

        ByCommonUtils.subFunctionCase(Get.context!, bannerBean);
        // checkLoginEvent(context: context, bannerBean: bannerBean);
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.w),
            border: Border.all(color: ByColorUtil.WhiteColor, width: 2.w),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5B4BF7).withOpacity(0.15),
                blurRadius: 4.w,
              )
            ]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.w),
          child: BYImageView.normal(
            imageUrl: bannerBean.imgUrl,
            width: width,
            height: height,
          ),
        ),
      ),
    );
  }

  checkLoginEvent(
      {required BuildContext context, required SubFunction bannerBean}) {
    ByNavigatorUtil.checkLogin(
        context: context,
        nextStepEvent: () {
          ByCommonUtils.subFunctionCase(Get.context!, bannerBean);
        });
  }
}
