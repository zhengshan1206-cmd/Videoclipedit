import 'dart:io';

import 'package:get/get.dart';
// import 'package:shanyan/shanyan.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/flavors/build_config.dart';
import 'package:video_clip_edit/modules/login/controller/login_manager.dart';
import 'package:video_clip_edit/modules/profile/beans/mine_scores_info_bean.dart';
import 'package:video_clip_edit/modules/profile/mine_score_page.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_scores_provider.dart';
import 'package:video_clip_edit/providers/mine_page_provider.dart';
import 'package:video_clip_edit/utils/channel/channel_config.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/login/login_page.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_datetime_ext.dart';
import 'package:video_clip_edit/modules/home/widgets/banner_view.dart';
import 'package:video_clip_edit/modules/profile/beans/user_info_bean.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

import '../../login/login_page_ex.dart';

class MinePageHeader extends StatefulWidget {
  const MinePageHeader({super.key});

  @override
  State<MinePageHeader> createState() => _MinePageHeaderState();
}

class _MinePageHeaderState extends State<MinePageHeader> {
  UserController get userController => Get.find<UserController>();

  UserInfoBean? get userInfo => userController.user.value;

  @override
  void initState() {
    super.initState();
    // OneKeyLoginManager oneKeyLoginManager = OneKeyLoginManager();
    //"tA75VwxF"
    // oneKeyLoginManager.init(appId: "fCS7ETTA");
    // oneKeyLoginManager.getPhoneInfo();
  }

  Widget userHead(UserInfoBean? userInfoBean, BuildContext context) {
    // int isFormal = context.read<LaunchProvider>().launchInfo?.isFormal ?? 0;
    int isFormal = userInfo?.isFormal ?? 0;
    return GestureDetector(
      onTap: () {
        if (isFormal != 0) return;
        ///显示登录页面
        LoginManager.showLoginPage(isScrollControlled: false);
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          SizedBox(width: 12.w),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1.w),
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.w),
              child: userInfoBean?.avatar == null
                  ? Image.asset(
                      "assets/mine/mine_avarta.png",
                      width: 64.w,
                      height: 64.w,
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(
                      width: 64.w,
                      height: 64.w,
                      fit: BoxFit.cover,
                      imageUrl: userInfoBean!.avatar,
                    ),
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    isFormal == 0 ? "立即登录" : userInfoBean?.nickName ?? "",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: ByColorUtil.CommonTextColor,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Offstage(
                    offstage: (userInfoBean?.isVip ?? 0) == 0,
                    child: Image.asset(
                      "assets/mine/icon_vip.png",
                      width: 20,
                      height: 20,
                    ),
                  )
                ],
              ),
              SizedBox(height: 14.h),
              Text(
                userInfoBean?.userId != null
                    ? "ID: ${userInfoBean?.userId}"
                    : "",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: ByColorUtil.CommonTextColor.withOpacity(0.6),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 220.h,
            child: const BannerView(
              urls: ["assets/mine/mine_banner.png"],
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 90.h),
            userHead(userInfo, context),
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.only(
                    top: 20.h,
                  ),
                  child: (userInfo?.isVip ?? 0) != 0
                      ? GestureDetector(
                          onTap: () {
                            // context.read<LaunchProvider>().gotoPay(context);
                            // ByNavRouterUtils.push(
                            //     context, const PurchasePageDark());
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 7.h),
                            width: 351.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.w),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF5C4CF7), Color(0xFF7E71FE)],
                                begin: Alignment.bottomRight,
                                end: Alignment.topLeft,
                              ),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  "assets/mine/vip_logo.png",
                                  width: 35.w,
                                  height: 35.w,
                                ),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (userInfo?.isVip ?? 0) == 0
                                            ? ""
                                            : VIPLevelValue
                                                .typeNameFromRawValue(
                                                    userInfo!.vipLevel),
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: ByColorUtil.WhiteColor,
                                        ),
                                      ),
                                      SizedBox(height: 6.h),
                                      Text(
                                        "会员截止时间：${userInfo?.vipEndTime?.formattedTime(format: "yyyy-MM-dd") ?? ""}",
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                          color: ByColorUtil.WhiteColor
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    ByNavRouterUtils.push(
                                      context,
                                      MultiProvider(
                                        providers: [
                                          ChangeNotifierProvider(
                                              create: (BuildContext context) =>
                                                  MinePageProvider()),
                                          ChangeNotifierProvider.value(
                                              value: context
                                                  .read<MineScoresProvider>()),
                                        ],
                                        child: const MineScorePage(),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 20.w),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        // SizedBox(height: 2.h),
                                        Row(
                                          children: [
                                            ByWidgetsUtil.commonText(
                                              text: "积分",
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.bold,
                                              textColor: ByColorUtil.WhiteColor,
                                            ),
                                            const SizedBox(width: 2),
                                            ByWidgetsUtil.svgAsset(
                                              filePath:
                                                  "assets/mine/mine_score_arrow.svg",
                                              width: 10,
                                              height: 10,
                                            ),
                                          ],
                                        ),
                                        // SizedBox(height: 2.h),
                                        ByWidgetsUtil.commonText(
                                          text: (context
                                                      .select<
                                                          MineScoresProvider,
                                                          MineScoresInfoBean?>(
                                                        (value) => value
                                                            .scoresInfoBean,
                                                      )
                                                      ?.user
                                                      .integral ??
                                                  0)
                                              .toString(),
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.bold,
                                          textColor: ByColorUtil.WhiteColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                // GestureDetector(
                                //   behavior: HitTestBehavior.opaque,
                                //   onTap: () {
                                //     // ByNavRouterUtils.push(
                                //     //     context, const PurchasePageDark());
                                //     context
                                //         .read<LaunchProvider>()
                                //         .gotoPay(context);
                                //   },
                                //   child: Container(
                                //     padding: EdgeInsets.symmetric(
                                //       horizontal: 12.w,
                                //       vertical: 7,
                                //     ),
                                //     decoration: BoxDecoration(
                                //       borderRadius: BorderRadius.circular(8.w),
                                //       border: Border.all(
                                //         color: ByColorUtil.WhiteColor,
                                //         width: 0.5,
                                //       ),
                                //     ),
                                //     child: Text(
                                //       "查看权益",
                                //       style: TextStyle(
                                //         fontSize: 12.sp,
                                //         color: ByColorUtil.WhiteColor,
                                //       ),
                                //     ),
                                //   ),
                                // )
                              ],
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            // ByNavRouterUtils.push(
                            //     context, const PurchasePageDark());
                            context.read<LaunchProvider>().gotoPay(context);
                          },
                          child: Image.asset(
                            "assets/mine/vip_banner.png",
                            width: 351.w,
                            height: 48.h,
                          ),
                        ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
