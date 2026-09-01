import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/flavors/build_config.dart';
import 'package:video_clip_edit/modules/home/providers/stroy_create_provider.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/utils/channel/channel_config.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiClip/ai_clip_page.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_mine_materials_provider.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_opening_provider.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_provider.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_material_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_page.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_settings_mixin.dart';
import 'package:video_clip_edit/v2/hotCreate/beans/hot_create_novel_bean.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/novel_create_single_provider.dart';
import 'package:video_clip_edit/v2/hotCreate/widgets/video_type_select_dialog.dart';
import 'package:video_clip_edit/v2/promote/beans/promotion_category_bean.dart';

import '../../../utils/comon/by_navigator_util.dart';

class NovelListCell extends StatelessWidget {
  const NovelListCell({
    super.key,
    required this.index,
    required this.novelBean,
    required this.promoteType,
    this.noMore = false,
    this.isLast = false,
  });

  final int index;
  final bool noMore;
  final bool isLast;
  final HotCreateNovelBean novelBean;

  final PromotionCategoryType promoteType;

  ///立即创作的点击事件
  void startCreateEvent({required BuildContext context}) {
    ByNavigatorUtil.reportDataPoint(
      pageTag: "promotion_page_content_btn",
      operateType: "click",
      funcDetailTag: novelBean.id.toString(),
      funcDetailImg: novelBean.coverUrl,
    );
    ByNavigatorUtil.checkLogin(
      context: context,
      nextStepEvent: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true, // 允许高度自适应
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          builder: (ctx) => VideoTypeSelectDialog(
            onSelected: (VideoType type) {
              byDebugPrint("onSelected: $type");
              if (type == VideoType.clip) {
                // clip
                final providerClip = AiClipProvider();
                providerClip.desc = novelBean.detailsText!.trim();
                providerClip.entranceSource = EntranceSource.explosive;
                final providerMaterial = AiMaterialProvider();
                ByNavRouterUtils.push(
                  context,
                  ChangeNotifierProvider(
                    create: (context) => StroyCreateProvider(),
                    child: MultiProvider(
                      providers: [
                        ChangeNotifierProvider(
                          create: (context) => providerClip,
                        ),
                        ChangeNotifierProvider(
                          create: (BuildContext context) => providerMaterial,
                        ),
                        ChangeNotifierProvider(
                          create: (BuildContext context) =>
                              AiClipOpeningProvider(),
                        ),
                        ChangeNotifierProvider(
                          create: (BuildContext context) =>
                              AiClipMineMaterialsProvider(),
                        ),
                      ],
                      child: const AiClipPage(
                        loadCommentary: true,
                        fromPrompt: true,
                        source: EntranceSource.explosive,
                      ),
                    ),
                  ),
                );
              } else {
                final provider = AiCartoonProvider();
                provider.desc = novelBean.detailsText!.trim();
                provider.entranceSource = EntranceSource.explosive;
                ByNavRouterUtils.push(
                  context,
                  ChangeNotifierProvider(
                    create: (context) => provider,
                    child: const AiCartoonPage(
                      fromPrompt: true,
                      title: "文字成片",
                      source: EntranceSource.explosive,
                    ),
                  ),
                );
                // tweets
                // if (promoteType == PromotionCategoryType.folkStory) {
                //   Get.toNamed(Routes.createFolkStoryPage);
                // } else {
                //   final provider = AiCartoonProvider();
                //   provider.desc = novelBean.detailsText!.trim();
                //   provider.entranceSource =
                //       EntranceSource.explosive;
                //   ByNavRouterUtils.push(
                //     context,
                //     ChangeNotifierProvider(
                //       create: (context) => provider,
                //       child: const AiCartoonPage(
                //         fromPrompt: true,
                //         title: "文字成片",
                //         source: EntranceSource.explosive,
                //       ),
                //     ),
                //   );
                // }
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final showRank = [0, 1, 2].contains(index);
    String iconRank = "assets/ai/hot/rank_gold.png";
    if (index == 1) {
      iconRank = "assets/ai/hot/rank_silver.png";
    } else if (index == 2) {
      iconRank = "assets/ai/hot/rank_bronze.png";
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ByWidgetsUtil.commonContainer(
          padding: EdgeInsets.only(
            left: 10.w,
            right: 6.w,
            bottom: 6.h,
            top: 6.h,
          ),
          margin: EdgeInsets.only(bottom: 10.h, left: 12.w, right: 12.w),
          borerRadius: 12.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 94.h,
                child: Row(
                  children: [
                    novelBean.coverUrl.isEmpty
                        ? Container(
                            margin: EdgeInsets.only(top: 4.h),
                            width: 64.w,
                            height: 90.h,
                          )
                        : Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.w),
                              child: CachedNetworkImage(
                                imageUrl: novelBean.coverUrl,
                                width: 64.w,
                                height: 90.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                    SizedBox(width: 11.w),
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
                                  text: novelBean.title,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  textColor: ByColorUtil.CommonTextColor,
                                ),
                              ),
                              if (showRank)
                                Image.asset(
                                  iconRank,
                                  height: 25.h,
                                  fit: BoxFit.fitHeight,
                                ),
                            ],
                          ),
                          SizedBox(height: 5.h),
                          ByWidgetsUtil.commonText(
                            text: novelBean.desc.trim(),
                            fontSize: 12.sp,
                            maxLines: 2,
                            fontWeight: FontWeight.normal,
                            textColor: ByColorUtil.CommonTextColor.withOpacity(
                              0.6,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          // Row(
                          //   children: [
                          //     Image.asset(
                          //       "assets/ai/hot/icon_gift.png",
                          //       width: 13.w,
                          //       fit: BoxFit.fitWidth,
                          //     ),
                          //     SizedBox(width: 5.w),
                          //     ByWidgetsUtil.commonText(
                          //       text: "粉丝数≥${novelBean.fansNum}",
                          //       fontSize: 14.sp,
                          //       fontWeight: FontWeight.w500,
                          //       textColor: const Color(0xFFFF2973),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  ByWidgetsUtil.commonText(
                    text: "${novelBean.joinPeopleNum}人已推广",
                    fontSize: 12.sp,
                    fontWeight: FontWeight.normal,
                    textColor: ByColorUtil.CommonTextColor.withOpacity(0.6),
                  ),
                  if (!ChannelConfig.exclude_channel_earn.contains(
                    BuildConfig.instance.channelType.channel,
                  )) ...[
                    ByWidgetsUtil.commonText(
                      text: "   |   ",
                      fontSize: 12.sp,
                      fontWeight: FontWeight.normal,
                      textColor: ByColorUtil.CommonTextColor.withOpacity(0.6),
                    ),
                    Image.asset(
                      "assets/ai/hot/icon_coin.png",
                      width: 12.w,
                      fit: BoxFit.fitWidth,
                    ),
                    SizedBox(width: 3.w),
                    ByWidgetsUtil.commonText(
                      text: novelBean.maxIncome,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      textColor: const Color(0xFFFFB452),
                    ),
                  ],
                  const Spacer(),
                  SizedBox(
                    height: 32.h,
                    child: ByWidgetsUtil.commonBtn(
                      padding: EdgeInsets.symmetric(horizontal: 13.w),
                      borderRadius: 50,
                      title: "立即创作",
                      onClick: () {
                        startCreateEvent(context: context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (noMore && isLast)
          Center(
            child: SizedBox(
              width: 120.w,
              height: 32.h,
              child: ByWidgetsUtil.commonBtn(
                borderWidth: 1,
                fontSize: 14.sp,
                borderRadius: 50,
                title: "授权查看更多",
                padding: EdgeInsets.zero,
                fontWeight: FontWeight.normal,
                bgColor: ByColorUtil.WhiteColor,
                textColor: ByColorUtil.LoginBtnBgColor,
                borderColor: ByColorUtil.LoginBtnBgColor,
                onClick: () {
                  final provider = context.read<NovelCreateSingleProvider>();
                  provider.loadTuixiaoguoUrl(
                    onSuccess: (url) {
                      if (url.isNotEmpty) {
                        ByNavRouterUtils.jumpWebViewPage(context, "小说授权", url);
                      }
                    },
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
