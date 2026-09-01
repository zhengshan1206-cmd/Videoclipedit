import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/widgets/common/common_sliver_persistent_header.dart';

///推广顶部吸顶部分
class PromotionPinnedTopView extends StatelessWidget {
  const PromotionPinnedTopView({super.key});

  @override
  Widget build(BuildContext context) {
    final topSafeHeight = ByScreenUtils.topSafeHeight;
    return CommonSliverPersistentHeader(
      pinned: true,
      minHeight: topSafeHeight,
      maxHeight: topSafeHeight,
      child: Container(
        decoration: const BoxDecoration(
          color: ByColorUtil.colorF4F7F8,
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage(Assets.homeHomePageBgTop),
          ),
        ),
        // padding: EdgeInsets.only(
        //   top: safeAreaEdgeInsets.top,
        //   left: 12.w,
        //   right: 12.w,
        // ),
        padding: EdgeInsets.only(top: topSafeHeight),
        child: Container(),
        //  Row(
        //   children: [
        //     Column(
        //       mainAxisSize: MainAxisSize.min,
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         Image.asset(
        //           // Assets.promotePromoteLeading,
        //           "assets/v2/home/home_top_icon_new.png",
        //           height: 28.h,
        //           fit: BoxFit.fitHeight,
        //         ),
        //         // BYText.instance(
        //         //   '爆款短剧、热门小说',
        //         //   12.sp,
        //         //   color: ByColorUtil.CommonTextColor.withOpacity(0.8),
        //         // ),
        //       ],
        //     ),
        //     const Spacer(),
        //     Obx(() {
        //       return (userController.user.value?.isVip ?? 0) == 0
        //           ? CommonButton(
        //               minSize: 0,
        //               padding: EdgeInsets.zero,
        //               borderRadius: BorderRadius.zero,
        //               onPressed: () {
        //                 final purchaseProvider =
        //                     context.read<PurchaseProvider>();
        //                 if (purchaseProvider.preLoginCheck(context) == false) {
        //                   return;
        //                 }
        //                 context
        //                     .read<LaunchProvider>()
        //                     .gotoPay(context, closePay: true);
        //               },
        //               child: Image.asset(
        //                 "assets/ai/aiVideo/new_ai_video_app_bar_trailing.png",
        //                 height: 36.h,
        //                 fit: BoxFit.fitHeight,
        //               ),
        //             )
        //           : Container();
        //     })
        //   ],
        // ),
      ),
    );
  }
}
