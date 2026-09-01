import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/core/util/logger.dart';
import 'package:video_clip_edit/flavors/app_values.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/modules/home/widgets/svga_player.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/slider/ai_create_slider_view.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_dubbing_bean.dart';
import 'package:video_clip_edit/widgets/common_button.dart';
import 'package:video_clip_edit/widgets/image/by_image_view.dart';

typedef VoiceSelectAction = void Function(
    AiCartoonDubbingBean? voiceBean, double voiceSpeed, double voiceVolume);

///音色配音设置弹窗
class AiCreateVoiceSettingView extends StatefulWidget {
  const AiCreateVoiceSettingView({
    super.key,
    required this.voiceList,
    this.selectVoiceBean,
    this.voiceSpeed,
    this.voiceVolume,
    this.selectAction,
  });

  final List<AiCartoonDubbingBean> voiceList;
  final AiCartoonDubbingBean? selectVoiceBean;
  final double? voiceSpeed;
  final double? voiceVolume;
  final VoiceSelectAction? selectAction;

  static void show(
      {required List<AiCartoonDubbingBean> voiceList,
      AiCartoonDubbingBean? selectVoiceBean,
      double? voiceSpeed,
      double? voiceVolume,
      VoiceSelectAction? selectAction}) {
    Get.bottomSheet(
      AiCreateVoiceSettingView(
          voiceList: voiceList,
          selectVoiceBean: selectVoiceBean,
          voiceSpeed: voiceSpeed,
          voiceVolume: voiceVolume,
          selectAction: selectAction),
      barrierColor: ByColorUtil.BlackColor.withOpacity(0.3),
      ignoreSafeArea: true,
      isScrollControlled: true,
    );
  }

  @override
  State<AiCreateVoiceSettingView> createState() =>
      _AiCreateVoiceSettingViewState();
}

class _AiCreateVoiceSettingViewState extends State<AiCreateVoiceSettingView> {
  final ByAudioPlayer audioPlayer = ByAudioPlayer.sharedInstance;

  final selectVoiceBean = Rx<AiCartoonDubbingBean?>(null);

  var playingId = -1;

  ///播放状态
  final playingStatus = Rx<ByAudioPlayerStatus>(ByAudioPlayerStatus.stop);

  ///是否加载中
  bool get isLoading => playingStatus.value == ByAudioPlayerStatus.loading;

  ///是否播放中
  bool get isPlaying =>
      playingStatus.value == ByAudioPlayerStatus.playing ||
      playingStatus.value == ByAudioPlayerStatus.resume;

  late double voiceSpeed;
  late double voiceVolume;

  late StreamSubscription<ByAudioPlayerStatus> _subscription;

  @override
  void initState() {
    super.initState();
    selectVoiceBean.value = widget.selectVoiceBean;
    voiceSpeed =
        widget.voiceSpeed ?? AiCreateVoiceSliderType.voiceSpeed.defaultValue;
    voiceVolume =
        widget.voiceVolume ?? AiCreateVoiceSliderType.voiceVolume.defaultValue;

    _subscription = audioPlayer.statusFutuer().asBroadcastStream().listen(
        (audioPlayStatus) {
      playingStatus.value = audioPlayStatus;
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      BYDebugPrint('onError ... $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: Get.height * 0.75),
      padding: EdgeInsets.only(
          left: 12.w, right: 12.w, bottom: safeAreaBottomDistance(15.h)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.h), topRight: Radius.circular(18.h)),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: BYText.instance('选择配音', 16.sp,
                    fontWeight: BYFontWeight.semiBold),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: CommonButton(
                  padding: EdgeInsets.only(
                      left: 10.w, top: 20.h, right: 3.w, bottom: 20.h),
                  minSize: 0,
                  borderRadius: BorderRadius.zero,
                  onPressed: Get.back,
                  child: Image.asset(Assets.commonIconBottomSheetClose,
                      width: 14.w, height: 14.w),
                ),
              ),
            ],
          ),
          // _buildSliderView(),
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 每行的列
                mainAxisSpacing: 10.h, // 垂直间隔
                crossAxisSpacing: 12.w, // 水平间隔
                childAspectRatio: 109 / 125,
              ),
              itemCount: widget.voiceList.length,
              itemBuilder: (context, index) {
                var voiceBean = widget.voiceList[index];
                return _buildVoiceItem(voiceBean);
              },
            ),
          ),
          _buildButton(),
        ],
      ),
    );
  }

  ///滑块
  _buildSliderView() {
    return Column(
      children: [
        AiCreateSliderView(
          sliderType: AiCreateVoiceSliderType.voiceSpeed,
          currentValue: voiceSpeed,
          valueChanged: (value) {
            voiceSpeed = value;
            audioPlayer.setPlaybackRate(voiceSpeed);
          },
        ),
        SizedBox(height: 10.h),
        AiCreateSliderView(
          sliderType: AiCreateVoiceSliderType.voiceVolume,
          currentValue: voiceVolume,
          valueChanged: (value) {
            voiceVolume = value;
            audioPlayer.setVolume(voiceVolume);
          },
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  ///配音列表
  _buildVoiceItem(AiCartoonDubbingBean voiceBean) {
    return Obx(() {
      final selectId = selectVoiceBean.value?.id;
      final isSelected = selectId != null && selectId == voiceBean.id;
      return GestureDetector(
        onTap: () {
          if (playingId == voiceBean.id) {
            if (audioPlayer.isPlaying) {
              audioPlayer.pause();
            } else {
              audioPlayer.resume(
                playbackRate: voiceSpeed,
                volume: voiceVolume,
              );
            }
            return;
          }
          audioPlayer.play(
            voiceBean.demoUrl,
            playbackRate: voiceSpeed,
            volume: voiceVolume,
          );
          playingId = voiceBean.id;
          if (isSelected) return;
          selectVoiceBean.value = voiceBean;
        },
        child: Container(
          decoration: BoxDecoration(
            color:
                isSelected ? ByColorUtil.WhiteColor : ByColorUtil.colorF8FAFB,
            borderRadius: BorderRadius.circular(12.h),
            border: isSelected
                ? Border.all(color: ByColorUtil.LoginBtnBgColor, width: 2.w)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipOval(
                    child: BYImageView.normal(
                      imageUrl: voiceBean.headerImage,
                      width: 72.w,
                      height: 72.w,
                    ),
                  ),
                  isSelected
                      ? Obx(() {
                          return Align(
                            alignment: Alignment.center,
                            child: isLoading
                                ? ByWidgetsUtil.activityIndicator(
                                    radius: 8.w,
                                    color: const Color(0xFFED3F8D),
                                  )
                                : isPlaying
                                    ? SizedBox(
                                        width: 19.w,
                                        height: 15.h,
                                        child: const SvgaPlayer(
                                            url: Assets.aiAiMusicPlay),
                                      )
                                    : ByWidgetsUtil.svgAsset(
                                        filePath: Assets.assetsHomeVoicePlay,
                                        width: 15.w,
                                        height: 15.h,
                                      ),
                          );
                        })
                      : const SizedBox(),
                ],
              ),
              SizedBox(height: 12.h),
              BYText.instance(voiceBean.name, 14.sp,
                  color: isSelected
                      ? ByColorUtil.LoginBtnBgColor
                      : ByColorUtil.CommonTextColor.withOpacity(0.5)),
            ],
          ),
        ),
      );
    });
  }

  _buildButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 8.h),
      child: CommonButton(
        padding: EdgeInsets.zero,
        minSize: 50.h,
        borderRadius: BorderRadius.circular(12.h),
        color: ByColorUtil.LoginBtnBgColor,
        onPressed: () {
          Get.back();
          widget.selectAction
              ?.call(selectVoiceBean.value, voiceSpeed, voiceVolume);
        },
        child: BYText.instance('确定', 16.sp,
            color: Colors.white, fontWeight: BYFontWeight.medium),
      ),
    );
  }

  @override
  void dispose() {
    audioPlayer.stop();
    _subscription.cancel();
    super.dispose();
  }
}
