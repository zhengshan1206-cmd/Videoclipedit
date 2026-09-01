import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/main/controllers/main_controller.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/infinite_scroll_list.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/home_page_scroll_list_cell.dart';

import '../../../providers/ai_chat_providers.dart';
import '../../../routes/route_utils.dart';
import '../../../utils/comon/by_nav_router_utils.dart';
import '../../aiVideo/models/ai_music_banner_model.dart';
import '../../aiVideo/models/ai_presets_model.dart';
import '../../aiVideo/models/ai_tips_model.dart';
import '../../aiVideo/models/ai_video_banner_model.dart';
import '../ai_same_case_page.dart';
import '../beans/ai_home_scroll_list_config_bean.dart';
import '../draw/providers/ai_draw_provider.dart';

class HomePageScrollListView extends StatelessWidget {
  ///首页banner信息配置
  final List<AiHomeScrollListConfigBean> homeScrollListConfigBeans;

  ///首页智能绘图数据
  final List<AiTipsModel> aiTipsModelList;

  ///首页智能回答数据
  final List<AiPresetsModel> aiPresetsModelList;

  final List<AiVideoBannerModel> aiVideoBannerModelList;

 final List<AiMusicBannerModel> aiMusicBannerModelList;

  const HomePageScrollListView({
    super.key,
    required this.homeScrollListConfigBeans,
    required this.aiTipsModelList,
    required this.aiPresetsModelList,
    required this.aiVideoBannerModelList,
    required this.aiMusicBannerModelList,
  });

  @override
  Widget build(BuildContext context) {
    final int bannerCounts = homeScrollListConfigBeans.length;
    log("bannerCounts==== $bannerCounts");
    return Stack(
      children: [
        Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Image.asset(
            "assets/v2/home/list_bg.png",
            fit: BoxFit.fitWidth,
          ),
        ),
        Positioned.fill(
          child: Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.symmetric(horizontal: 22.w),
            child: Swiper(
              autoplay: false,
              itemCount: bannerCounts > 0 ? bannerCounts : 1,
              onTap: (index) {},
              itemBuilder: (context, index) {
                int id = 0;
                if (bannerCounts > 0) {
                  id = homeScrollListConfigBeans[index].id;
                }
                return Stack(
                  children: [
                    Positioned.fill(
                        child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              bannerCounts > 0
                                  ? SizedBox(
                                      height: 17.h,
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            homeScrollListConfigBeans[index]
                                                .icon,
                                        fit: BoxFit.fitHeight,
                                      ),
                                    )
                                  : Image.asset(
                                      "assets/v2/home/scroll_list_title.png",
                                      width: 72.w,
                                      fit: BoxFit.fitHeight,
                                    ),
                              const Spacer(),
                              if(id==1||id==2)
                              GestureDetector(
                                onTap: (){
                                  if(id==1){
                                    ///跳转Ai绘图页面
                                    RouteUtils.gotoPage(context, "/ai_draw");
                                  }else if(id==2){
                                    ///跳转Ai对话页面
                                    // RouteUtils.gotoPage(context, "/ai_chat");
                                    Get.find<MainController>().tabChanged(1);
                                    final provider2 = context.read<AiChatProviders>();
                                    provider2.firstDesQuestion = "";
                                  }
                                },

                                behavior: HitTestBehavior.opaque,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ByWidgetsUtil.commonText(
                                      text: "更多",
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    // SizedBox(width: 5.w),
                                    Image.asset(
                                      "assets/mine/arrow_right.png",
                                      height: 10.h,
                                      fit: BoxFit.fitHeight,
                                    ),
                                    SizedBox(width: 5.w),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            height: 0.5.h,
                            width: double.infinity,
                            color: const Color(0xFFD5D9E5).withOpacity(0.5),
                          ),
                          SizedBox(height: 10.h),
                          Expanded(
                            child: InfiniteScrollList(
                              aiTipsModelList: aiTipsModelList,
                              aiPresetsModelList: aiPresetsModelList,
                              aiVideoBannerModelList: aiVideoBannerModelList,
                              aiMusicBannerModelList: aiMusicBannerModelList,
                              id: id,
                              key: UniqueKey(),
                            ),
                          ),
                          SizedBox(height: 10.h),
                        ],
                      ),
                    ))
                  ],
                );
              },
              pagination: SwiperPagination(
                margin: EdgeInsets.zero,
                builder: SwiperCustomPagination(
                  builder: (BuildContext context, SwiperPluginConfig config) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 0.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                            bannerCounts > 0 ? bannerCounts : 1, (index) {
                          final isCurrent = index == config.activeIndex;
                          return Container(
                            width: isCurrent ? 8.w : 4.h,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: ByColorUtil.LoginBtnBgColor.withOpacity(
                                  isCurrent ? 1 : 0.2),
                              borderRadius: BorderRadius.circular(10.w),
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 1.5.w),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ClickAiChatPageEvent{
  const ClickAiChatPageEvent();
}