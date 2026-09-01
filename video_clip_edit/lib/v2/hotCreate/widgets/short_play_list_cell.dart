import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/home/beans/cloud_video_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_video_player.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/short_play_create_provider.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/short_show_details_provider.dart';
import 'package:video_clip_edit/v2/hotCreate/short_play_list_page.dart';
import 'package:video_clip_edit/flavors/build_config.dart';
import 'package:video_clip_edit/utils/channel/channel_config.dart';

import '../../../routes/app_pages.dart';
import '../providers/new_short_play_list_controller.dart';

class ShortPlayListCell extends StatelessWidget {
  const ShortPlayListCell({
    super.key,
    required this.index,
    this.fromPrompt = false,
    required this.shortPlayBean,
    this.noMore = false,
    this.isLast = false,
    this.prePagePath = "",
  });
  final int index;
  final bool fromPrompt;
  final bool noMore;
  final bool isLast;
  final CloudVideoListBean shortPlayBean;
  final String prePagePath;
  @override
  Widget build(BuildContext context) {
    final showRank = [0, 1, 2].contains(index);
    String iconRank = "assets/ai/hot/rank_gold.png";
    if (index == 1) {
      iconRank = "assets/ai/hot/rank_silver.png";
    } else if (index == 2) {
      iconRank = "assets/ai/hot/rank_bronze.png";
    }
    bool fromNewShortPlay = false;
    dynamic arguments = Get.arguments;
    if (arguments != null) {
      if (arguments["fromNewShortPlay"] != null) {
        if (arguments["fromNewShortPlay"] is bool) {
          fromNewShortPlay = arguments["fromNewShortPlay"];
        }
      }
    }

    ///立即创作的点击事件
    void startCreateEvent() {
      ByNavigatorUtil.checkLogin(
          context: context,
          nextStepEvent: () {
            ByNavigatorUtil.reportDataPoint(
              pageTag: "promotion_page_content_btn",
              operateType: "click",
              funcDetailTag: shortPlayBean.id.toString(),
              funcDetailImg: shortPlayBean.coverUrl,
            );
            if (fromNewShortPlay) {
              eventBus.fire(RefreshDataEvent(arguments: {
                "fromPrompt": fromPrompt,
                "videoListBean": shortPlayBean,
              }));
            }
            Get.toNamed(Routes.newShortPlayListPage, arguments: {
              "fromPrompt": fromPrompt,
              "videoListBean": shortPlayBean,
              "prePagePath": prePagePath
            });

            // ByNavRouterUtils.push(
            //     context,
            //     ChangeNotifierProvider(
            //       create: (BuildContext context) =>
            //           ShortShowDetailsProvider(),
            //       child: ShortPlayListPage(
            //         videoListBean: shortPlayBean,
            //         fromPrompt: fromPrompt,
            //       ),
            //     ));
          });
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ByWidgetsUtil.commonContainer(
          padding: EdgeInsets.only(
            left: 12.w,
            right: 12.w,
            bottom: 12.h,
            top: 6.h,
          ),
          margin: EdgeInsets.only(
            bottom: 10.h,
            left: 12.w,
            right: 12.w,
          ),
          borerRadius: 12.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 140.h,
                child: Row(
                  children: [
                    shortPlayBean.coverUrl.isEmpty
                        ? Container(
                            margin: EdgeInsets.only(top: 4.h),
                            width: 100.w,
                            height: 136.h,
                          )
                        : Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.w),
                              child: CachedNetworkImage(
                                imageUrl: shortPlayBean.coverUrl,
                                width: 100.w,
                                height: 136.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ByWidgetsUtil.commonText(
                                  text: shortPlayBean.materialName,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  textColor: ByColorUtil.CommonTextColor,
                                ),
                              ),
                              if (showRank)
                                Image.asset(iconRank,
                                    height: 25.h, fit: BoxFit.fitHeight)
                            ],
                          ),
                          SizedBox(height: 7.h),
                          Row(
                            children: [
                              ByWidgetsUtil.commonText(
                                text:
                                    "${shortPlayBean.otherConfig?.joinPeopleNum ?? 0}人已推广",
                                fontSize: 12.sp,
                                fontWeight: FontWeight.normal,
                                textColor:
                                    ByColorUtil.CommonTextColor.withOpacity(
                                        0.6),
                              ),
                              if (!ChannelConfig.exclude_channel_earn.contains(
                                  BuildConfig
                                      .instance.channelType.channel)) ...[
                                ByWidgetsUtil.commonText(
                                  text: "   |   ",
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.normal,
                                  textColor:
                                      ByColorUtil.CommonTextColor.withOpacity(
                                          0.6),
                                ),
                                Image.asset(
                                  "assets/ai/hot/icon_coin.png",
                                  width: 12.w,
                                  fit: BoxFit.fitWidth,
                                ),
                                SizedBox(width: 3.w),
                                ByWidgetsUtil.commonText(
                                  text: (shortPlayBean.otherConfig?.maxIncome ??
                                          0)
                                      .toString(),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  textColor: const Color(0xFFFFB452),
                                ),
                              ],
                              const Spacer(),
                            ],
                          ),
                          SizedBox(height: 9.h),

                          /// todo 增加快手和抖音渠道 粉丝数
                          // Row(
                          //   children: [
                          //     Image.asset(
                          //       "assets/ai/hot/icon_gift.png",
                          //       width: 13.w,
                          //       fit: BoxFit.fitWidth,
                          //     ),
                          //     SizedBox(width: 5.w),
                          //     ByWidgetsUtil.commonText(
                          //       text:
                          //           "粉丝数≥${shortPlayBean.otherConfig?.fansNum ?? 0}",
                          //       fontSize: 14.sp,
                          //       fontWeight: FontWeight.w500,
                          //       textColor: const Color(0xFFFF2973),
                          //     ),
                          //   ],
                          // ),

                          SizedBox(height: 18.h),
                          Row(
                            children: [
                              SizedBox(
                                height: 32.h,
                                child: ByWidgetsUtil.commonBtn(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 32.w),
                                  borderRadius: 50,
                                  title: "立即创作",
                                  onClick: () {
                                    startCreateEvent();
                                  },
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // if (noMore && isLast)
        //   Center(
        //     child: SizedBox(
        //       width: 120.w,
        //       height: 32.h,
        //       child: ByWidgetsUtil.commonBtn(
        //         borderWidth: 1,
        //         fontSize: 14.sp,
        //         borderRadius: 50,
        //         title: "授权查看更多",
        //         padding: EdgeInsets.zero,
        //         fontWeight: FontWeight.normal,
        //         bgColor: ByColorUtil.WhiteColor,
        //         textColor: ByColorUtil.LoginBtnBgColor,
        //         borderColor: ByColorUtil.LoginBtnBgColor,
        //         onClick: () {
        //           final provider = context.read<ShortPlayCreateProvider>();
        //           provider.loadTuixiaoguoUrl(
        //             onSuccess: (url) {
        //               if (url.isNotEmpty) {
        //                 ByNavRouterUtils.jumpWebViewPage(context, "小说授权", url);
        //               }
        //             },
        //           );
        //         },
        //       ),
        //     ),
        //   ),
      ],
    );
  }
}
