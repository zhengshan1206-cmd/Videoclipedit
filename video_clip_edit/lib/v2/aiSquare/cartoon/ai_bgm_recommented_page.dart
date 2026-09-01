import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_bgm_mixin.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/widgets/svga_player.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_settings_mixin.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_bgm_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_item_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_bgm_cat_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_audio_status_provider.dart';

import '../../hotCreate/providers/new_short_play_list_controller.dart';

class AiBgmRecommentedPage<T extends AiSettingsMixin, S extends AiBgmMixin>
    extends StatefulWidget {
  const AiBgmRecommentedPage({
    super.key,
    required this.itemBean,
    this.fromNewShortPlayPage = false,
    this.controller,
  });

  final AiCartoonItemBean itemBean;
  final bool fromNewShortPlayPage;
  final NewShortPlayListController? controller;



  @override
  State<AiBgmRecommentedPage<T, S>> createState() =>
      _AiBgmRecommentedPageState<T, S>();
}

class _AiBgmRecommentedPageState<T extends AiSettingsMixin,
    S extends AiBgmMixin> extends State<AiBgmRecommentedPage<T, S>> {
  @override
  Widget build(BuildContext context) {
    byDebugPrint("_AiBgmRecommentedPageState: build");
    return Scaffold(
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Stack(
        children: [
          Column(
            children: [
              // Container(
              //   height: 36.h,
              //   margin: EdgeInsets.only(left: 12.w),
              //   child: AiCartoonBgmCategoryView<T, S>(),
              // ),
              SizedBox(height: 7.h),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: AiCartoonBgmListView<T, S>(itemBean: widget.itemBean,fromNewShortPlayPage: widget.fromNewShortPlayPage,controller: widget.controller,),
                ),
              )
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            height: 86.h,
            child: PhysicalModel(
              color: Colors.black,
              child: Container(
                color: ByColorUtil.WhiteColor,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 18.h),
                child: ByWidgetsUtil.commonBtn(
                  borderRadius: 12.w,
                  padding: EdgeInsets.zero,
                  title: "确定",
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  onClick: () {
                    ByNavRouterUtils.goBack(context);
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AiCartoonBgmCategoryView<T extends AiSettingsMixin, S extends AiBgmMixin>
    extends StatelessWidget {
  const AiCartoonBgmCategoryView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    byDebugPrint("AiCartoonBgmCategoryView: build");
    final bgmCateoryBeans = context.select<S, List<AiCartoonBgmCatBean>>(
      (value) => value.bgmCateoryBeans,
    );
    return ListView.builder(
      // padding: EdgeInsets.only(left: 12.w),
      scrollDirection: Axis.horizontal,
      itemCount: bgmCateoryBeans.length,
      itemBuilder: (context, index) {
        final AiCartoonBgmCatBean bgmCatBean = bgmCateoryBeans[index];
        return AiBgmRecommentedCategoryCell<T, S>(
          index: index,
          bgmCatBean: bgmCatBean,
        );
      },
    );
  }
}

class AiCartoonBgmListView<T extends AiSettingsMixin, S extends AiBgmMixin>
    extends StatelessWidget {
  const AiCartoonBgmListView({
    super.key,
    required this.itemBean,
    this.fromNewShortPlayPage = false,
    this.controller,
  });

  final AiCartoonItemBean itemBean;
  final bool fromNewShortPlayPage;
  final NewShortPlayListController? controller;



  @override
  Widget build(BuildContext context) {
    byDebugPrint("AiCartoonBgmListView: build");
    final providers = context.watch<S>();
    final bgmBeans = providers.bgmBeans;
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 66.h),
      itemCount: bgmBeans.length,
      itemBuilder: (context, index) {
        final AiCartoonBgmBean bean = bgmBeans[index];
        return AiBgmRecommentedCell<T, S>(
          index: index,
          bean: bean,
          itemBean: itemBean,
          fromNewShortPlayPage: fromNewShortPlayPage,
          controller: controller,
        );
      },
    );
  }
}

class AiBgmRecommentedCategoryCell<T extends AiSettingsMixin,
    S extends AiBgmMixin> extends StatelessWidget {
  const AiBgmRecommentedCategoryCell({
    super.key,
    required this.index,
    required this.bgmCatBean,
  });

  final int index;
  final AiCartoonBgmCatBean bgmCatBean;

  @override
  Widget build(BuildContext context) {
    byDebugPrint("AiBgmRecommentedCategoryCell: build");
    final provider = context.read<S>();
    final selectedBgmCatId = context.select<S, int>(
      (p) => p.selectedBgmCatId,
    );
    final categories = provider.bgmCateoryBeans;
    final selected = selectedBgmCatId == bgmCatBean.id;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (bgmCatBean.id != selectedBgmCatId) {
          ByAudioPlayer.sharedInstance.stop();
        }
        provider.updateSelectedBgmCatId(bgmCatBean.id);
      },
      child: ByWidgetsUtil.commonContainer(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
        boxShadow: [
          BoxShadow(
            color: ByColorUtil.BlackColor.withOpacity(0.05),
            blurRadius: 2.w,
          )
        ],
        borerRadius: 8.w,
        bgColor: selected
            ? ByColorUtil.TabTextColorSelected
            : ByColorUtil.WhiteColor,
        child: ByWidgetsUtil.commonText(
          text: categories[index].title,
          textColor:
              selected ? ByColorUtil.WhiteColor : ByColorUtil.CommonTextColor,
        ),
      ),
    );
  }
}

class AiBgmRecommentedCell<T extends AiSettingsMixin, S extends AiBgmMixin>
    extends StatelessWidget {
  AiBgmRecommentedCell({
    super.key,
    required this.index,
    required this.bean,
    required this.itemBean,
    this.fromNewShortPlayPage = false,
    this.controller ,
  });

  final int index;
  final AiCartoonBgmBean bean;
  final AiCartoonItemBean itemBean;
  final ByAudioPlayer audioPlayer = ByAudioPlayer.sharedInstance;
  final bool fromNewShortPlayPage;
  final NewShortPlayListController? controller;


  @override
  Widget build(BuildContext context) {
    byDebugPrint("AiBgmRecommentedCell: build");
    final selectedBgmId =
        context.select<S, int>((value) => value.selectedBgmId);
    var selected = selectedBgmId == bean.id;
    // final provdier = context.read<AiCartoonBgmProvider>();
    // final cateName = provdier.bgmCateoryBeans
    //     .firstWhere((e) => e.id == provdier.selectedBgmCatId)
    //     .title;

    // if(fromNewShortPlayPage&&controller!=null){
    //   selected = controller!.selectedBgmId==bean.id;
    // }

    /// 试听的下标
    final listeningDubbingId =
        context.select<S, int>((value) => value.listeningBgmId);
    final currentListening = listeningDubbingId == bean.id;

    /// 播放状态
    final status =
        context.select<AiCartoonAudioStatusProvider, AiCartoonAudioStatus>(
      (val) => val.currentStatus,
    );

    final isPlaying = status == AiCartoonAudioStatus.playing ||
        status == AiCartoonAudioStatus.resume;

    return ByWidgetsUtil.commonContainer(
      boxShadow: [
        BoxShadow(
          color: ByColorUtil.BlackColor.withOpacity(0.05),
          blurRadius: 2.w,
        )
      ],
      margin: EdgeInsets.symmetric(
        horizontal: 2.w,
        vertical: 2.5.h,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 10.h,
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              final provider = context.read<S>();
              provider.updateListeningBgmId(bean.id);
              if (currentListening) {
                if (isPlaying) {
                  audioPlayer.pause();
                } else {
                  audioPlayer.resume();
                }
                return;
              }
              audioPlayer.play(bean.url);
            },
            child: ClipOval(
              child: Stack(
                children: [
                  SizedBox(
                    width: 50.w,
                    height: 50.w,
                    child: CachedNetworkImage(
                      errorWidget: (context, url, error) =>
                          Image.asset("assets/ai/bgm_default.png"),
                      imageUrl: bean.icon,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                        child: currentListening && isPlaying
                            ?
                            // Image.asset(
                            //     "assets/home/voice_pause.png",
                            //     width: 16.w,
                            //     height: 16.h,
                            //     fit: BoxFit.contain,
                            //   )
                            // : Image.asset(
                            //     "assets/home/voice_play.png",
                            //     width: 16.w,
                            //     height: 16.h,
                            //     fit: BoxFit.contain,
                            //   )
                            ByWidgetsUtil.svgAsset(
                                filePath: "assets/home/voice_pause.svg",
                                width: 15.w,
                                height: 15.h,
                              )
                            : ByWidgetsUtil.svgAsset(
                                filePath: "assets/home/voice_play.svg",
                                width: 15.w,
                                height: 15.h,
                              )),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ByWidgetsUtil.commonText(
                  text: bean.title.split(".").first,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  textColor: ByColorUtil.CommonTextColor,
                ),
                // SizedBox(height: 7.h),
                // ByWidgetsUtil.commonText(
                //   text: cateName,
                //   fontSize: 12.sp,
                //   fontWeight: FontWeight.normal,
                //   textColor: ByColorUtil.CommonTextColor,
                // ),
              ],
            ),
          ),
          Offstage(
            offstage: !(currentListening && isPlaying),
            child: SizedBox(
              width: 19.w,
              height: 15.h,
              child: const SvgaPlayer(url: "assets/ai/ai_music_play.svga"),
            ),
          ),
          SizedBox(width: 20.w),
          SizedBox(
            width: 60.w,
            height: 28.h,
            child: ByWidgetsUtil.commonBtn(
              padding: EdgeInsets.zero,
              borderColor: ByColorUtil.TabTextColorSelected,
              bgColor: selected
                  ? ByColorUtil.TabTextColorSelected
                  : ByColorUtil.WhiteColor,
              title: selected ? "已选" : "选择",
              textColor: selected
                  ? ByColorUtil.WhiteColor
                  : ByColorUtil.TabTextColorSelected,
              fontSize: 14.sp,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              onClick: () {
                final provider = context.read<T>();
                final name = selected ? "" : bean.title;
                provider.selectedBgmUrl = selected ? "" : bean.url;
                context.read<S>().updateSelectedBgmId(selected ? -1 : bean.id);
                provider.updateSectionConfigBeansFrom(itemBean, name);
                if(fromNewShortPlayPage&&controller!=null){
                  controller!.updateSelectedBgmId(selected ? -1 : bean.id);
                  controller!.updateSectionConfigBeansFrom(itemBean, name);
                  controller!.selectedBgmUrl  = selected ? "" : bean.url;
                }

              },
            ),
          ),
        ],
      ),
    );
  }
}
