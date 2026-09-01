import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/modules/home/widgets/svga_player.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_bgm_local_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_item_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_audio_status_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_bgm_mixin.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_settings_mixin.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

import 'package:video_clip_edit/utils/channel/channel_operate.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_package_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

import '../../hotCreate/providers/new_short_play_list_controller.dart';

class AiBgmLocalPage<T extends AiSettingsMixin, S extends AiBgmMixin>
    extends StatefulWidget {
  const AiBgmLocalPage({
    super.key,
    required this.itemBean,
    this.controller,
  });

  final AiCartoonItemBean itemBean;
  final NewShortPlayListController? controller;

  @override
  State<AiBgmLocalPage<T, S>> createState() => _AiBgmLocalPageState<T, S>();
}

class _AiBgmLocalPageState<T extends AiSettingsMixin, S extends AiBgmMixin>
    extends State<AiBgmLocalPage<T, S>> {
  late final S provider = context.read<S>();

  @override
  void initState() {
    super.initState();

    provider.loadCustomBgmList();
  }

  @override
  Widget build(BuildContext context) {
    byDebugPrint("_AiBgmLocalPageState: build");
    return Scaffold(
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 7.h),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: _buildContents(context),
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
                child: _buildActions(context),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildContents(BuildContext context) {
    final bgmBeansLocal = context
        .select<S, List<AiCartoonBgmLocalBean>>((val) => val.bgmBeansLocal);
    if (bgmBeansLocal.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 100.h,
            width: double.infinity,
          ),
          Image.asset(
            "assets/mine/mine_no_data.png",
            width: 180.w,
            height: 100.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 3.h),
          ByWidgetsUtil.commonText(
            fontSize: 14.sp,
            text: "音乐库暂时没有音乐",
            fontWeight: FontWeight.normal,
            textColor: ByColorUtil.CommonTextColor.withOpacity(0.3),
          ),
          SizedBox(height: 22.h),
          GestureDetector(
            onTap: () {
              _selectMusic(context);
            },
            child: ByWidgetsUtil.commonText(
              text: "去上传",
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
              textColor: ByColorUtil.TabTextColorSelected,
            ),
          ),
        ],
      );
    }
    return AiCartoonLocalBgmListView<T, S>(
      itemBean: widget.itemBean,
      controller: widget.controller,
    );
  }

  _buildActions(BuildContext context) {
    final selectedLocalBgmId =
        context.select<S, int>((val) => val.selectedLocalBgmId);
    final selcted = selectedLocalBgmId != -1;
    return context
            .select<S, List<AiCartoonBgmLocalBean>>((val) => val.bgmBeansLocal)
            .isEmpty
        ? ByWidgetsUtil.commonBtn(
            fontSize: 16.sp,
            borderRadius: 12.w,
            title: "上传本地音乐",
            padding: EdgeInsets.zero,
            fontWeight: FontWeight.w500,
            onClick: () {
              _selectMusic(context);
            },
          )
        : Row(
            children: [
              Expanded(
                child: ByWidgetsUtil.commonBtn(
                  fontSize: 16.sp,
                  borderRadius: 12.w,
                  title: "上传本地音乐",
                  padding: EdgeInsets.zero,
                  fontWeight: FontWeight.w500,
                  bgColor: const Color(0xFFEAEEFF),
                  textColor: ByColorUtil.TabTextColorSelected,
                  onClick: () {
                    _selectMusic(context);
                  },
                ),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: ByWidgetsUtil.commonBtn(
                  fontSize: 16.sp,
                  title: selcted ? "确定" : "请选择音乐",
                  borderRadius: 12.w,
                  bgColor: ByColorUtil.LoginBtnBgColor.withOpacity(
                      selcted ? 1 : 0.5),
                  padding: EdgeInsets.zero,
                  fontWeight: FontWeight.w500,
                  textColor: ByColorUtil.WhiteColor,
                  onClick: () {
                    if (selcted) {
                      ByNavRouterUtils.goBack(context);
                    }
                  },
                ),
              )
            ],
          );
  }

  void _selectMusic(BuildContext context) async {
    AssetEntity? asset;
    File? file;
    if (ByPackageUtils.isOhos) {
      final List<dynamic> result = await ChannelOperate.getAudioPath(1);
      if (result.isEmpty) return;
      file = File(result.first.toString());
    } else {
      final List<AssetEntity> result = await ByCommonUtils.pickAudio(
        context,
        maxCount: 1,
      );
      if (result.isEmpty) return;
      asset = result.first;
      file = await asset.file;
    }

    if (file == null) {
      BotToast.showText(text: "选择文件时出错，请重新选择");
      return;
    }
    if (mounted) {
      provider.uploadMusic(
        asset: asset,
        file: file,
      );
    }
  }
}

class AiCartoonLocalBgmListView<T extends AiSettingsMixin, S extends AiBgmMixin>
    extends StatelessWidget {
  const AiCartoonLocalBgmListView({
    super.key,
    required this.itemBean,
    this.controller,
  });

  final AiCartoonItemBean itemBean;
  final NewShortPlayListController? controller;

  @override
  Widget build(BuildContext context) {
    final bgmBeansLocal = context
        .select<S, List<AiCartoonBgmLocalBean>>((val) => val.bgmBeansLocal);
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 66.h),
      itemCount: bgmBeansLocal.length,
      itemBuilder: (context, index) {
        final bean = bgmBeansLocal[index];
        return AiBgmLocalCell<T, S>(
          index: index,
          localBean: bean,
          itemBean: itemBean,
          controller: controller,
        );
      },
    );
  }
}

enum AiBgmLocalStaus {
  /// 1待审核
  underReview,

  /// 2审核通过
  reviewApproved,

  /// 3审核失败
  reviewRejected,

  /// 4系统推荐
  recommented,
}

extension AiBgmLocalStausExt on AiBgmLocalStaus {
  static AiBgmLocalStaus fromRawValue(int rawValue) {
    /// 1待审核 2审核通过 3审核失败 4系统推荐
    switch (rawValue) {
      case 1:
        return AiBgmLocalStaus.underReview;
      case 2:
        return AiBgmLocalStaus.reviewApproved;
      case 3:
        return AiBgmLocalStaus.reviewRejected;
      default:
        return AiBgmLocalStaus.recommented;
    }
  }

  int rawValue() {
    /// 1待审核 2审核通过 3审核失败 4系统推荐
    switch (this) {
      case AiBgmLocalStaus.underReview:
        return 1;
      case AiBgmLocalStaus.reviewApproved:
        return 2;
      case AiBgmLocalStaus.reviewRejected:
        return 3;
      default:
        return 4;
    }
  }
}

class AiBgmLocalCell<T extends AiSettingsMixin, S extends AiBgmMixin>
    extends StatelessWidget {
  AiBgmLocalCell({
    super.key,
    required this.index,
    required this.localBean,
    required this.itemBean,
    this.controller,
  });

  final int index;
  final AiCartoonBgmLocalBean localBean;
  final AiCartoonItemBean itemBean;
  final ByAudioPlayer audioPlayer = ByAudioPlayer.sharedInstance;
  final NewShortPlayListController? controller;

  @override
  Widget build(BuildContext context) {
    byDebugPrint("AiBgmRecommentedCell: build");

    /// 1待审核 2审核通过 3审核失败 4系统推荐
    final statusValue = localBean.status;
    final status = AiBgmLocalStausExt.fromRawValue(statusValue);

    /// 试听的下标
    final listeningDubbingId =
        context.select<S, int>((value) => value.listeningLocalBgmId);

    /// 选择的 bgm id
    final selectedLocalBgmId =
        context.select<S, int>((value) => value.selectedLocalBgmId);
    final currentListening = listeningDubbingId == localBean.id;
    final selected = localBean.id == selectedLocalBgmId;

    /// 播放状态
    final audioStatus =
        context.select<AiCartoonAudioStatusProvider, AiCartoonAudioStatus>(
      (val) => val.currentStatus,
    );

    final isPlaying = audioStatus == AiCartoonAudioStatus.playing ||
        audioStatus == AiCartoonAudioStatus.resume;

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
          ClipOval(
            child: Stack(
              children: [
                SizedBox(
                  width: 50.w,
                  height: 50.w,
                  child: CachedNetworkImage(
                    imageUrl: localBean.cover,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Offstage(
                    offstage: status != AiBgmLocalStaus.reviewApproved,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        final provider = context.read<S>();
                        provider.updateListeningLocalBgmId(localBean.id);
                        if (currentListening) {
                          if (isPlaying) {
                            audioPlayer.pause();
                          } else {
                            audioPlayer.resume();
                          }
                          return;
                        }
                        audioPlayer.play(localBean.url);
                      },
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
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ByWidgetsUtil.commonText(
                  text: localBean.name ?? "我的音乐",
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
                // SizedBox(height: 7.h),
                // ByWidgetsUtil.commonText(
                //   text: "我的音乐",
                //   fontSize: 12.sp,
                //   fontWeight: FontWeight.normal,
                // ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Offstage(
            offstage: !(isPlaying && currentListening),
            child: SizedBox(
              width: 19.w,
              height: 15.h,
              child: const SvgaPlayer(url: "assets/ai/ai_music_play.svga"),
            ),
          ),
          SizedBox(width: 20.w),
          Offstage(
            offstage: status != AiBgmLocalStaus.reviewApproved,
            child: SizedBox(
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
                  print('=======>>>${localBean.name}');
                  final prvider = context.read<T>();
                  final name = localBean.name ?? "我的音乐";
                  prvider.selectedBgmUrl = selected ? "" : localBean.url;
                  context
                      .read<S>()
                      .updateSelectedLocalBgmId(selected ? -1 : localBean.id);
                  prvider.updateSectionConfigBeansFrom(
                      itemBean, selected ? "" : name);
                  if (controller != null) {
                    controller!
                        .updateSelectedBgmId(selected ? -1 : localBean.id);
                    controller!.updateSectionConfigBeansFrom(itemBean, name);
                    controller!.selectedBgmUrl = selected ? "" : localBean.url;
                  }
                },
              ),
            ),
          ),
          Offstage(
            offstage: status != AiBgmLocalStaus.underReview,
            child: Row(
              children: [
                Container(
                  width: 20.w,
                  height: 20.h,
                  margin: EdgeInsets.only(right: 5.w),
                  child: Image.asset(
                    "assets/ai/ai_cartoon_bgm_under_review.png",
                    fit: BoxFit.cover,
                  ),
                ),
                ByWidgetsUtil.commonText(
                  text: "审核中",
                  textColor: const Color(0xFFFFA10C),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(width: 20.w),
              ],
            ),
          ),
          Offstage(
            offstage: status != AiBgmLocalStaus.reviewRejected,
            child: Row(
              children: [
                Container(
                  width: 15.w,
                  height: 15.h,
                  margin: EdgeInsets.only(right: 6.w),
                  child: Image.asset(
                    "assets/ai/ai_cartoon_bgm_rejected.png",
                    fit: BoxFit.cover,
                  ),
                ),
                ByWidgetsUtil.commonText(
                  text: "未通过审核，存在违规信息",
                  textColor: const Color(0xFFF43148),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
          Offstage(
            offstage: status != AiBgmLocalStaus.underReview,
            child: SizedBox(
              width: 60.w,
              height: 32.h,
              child: ByWidgetsUtil.commonBtn(
                padding: EdgeInsets.zero,
                borderColor: const Color(0xFFFFA10C),
                bgColor: const Color(0xFFFFA10C),
                title: "刷新状态",
                textColor: ByColorUtil.WhiteColor,
                fontSize: 12.sp,
                borderRadius: 6.w,
                fontWeight: FontWeight.bold,
                onClick: () {
                  context.read<S>().loadCustomBgmList();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
