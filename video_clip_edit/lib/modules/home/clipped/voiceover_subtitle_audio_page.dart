// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/consts/const.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/widgets/audio_play_bar.dart';
import 'package:video_clip_edit/modules/home/clipped/audio_transfer_page.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';

class VoiceoverSubtitleAudioPage<T extends MaterialBaseProvider>
    extends StatefulWidget {
  String recordingFilePath;
  String mVideoUrl;
  final dynamic assetEntity;

  VoiceoverSubtitleAudioPage(
    this.recordingFilePath,
    this.mVideoUrl, {
    super.key,
    this.assetEntity,
  });

  // const VoiceoverSubtitleAudioPage({super.key});

  @override
  State<VoiceoverSubtitleAudioPage> createState() =>
      _VoiceoverSubtitleAudioPageState<T>();
}

class _VoiceoverSubtitleAudioPageState<T extends MaterialBaseProvider>
    extends State<VoiceoverSubtitleAudioPage<T>> {
  final TextEditingController wordsEditingController = TextEditingController();
  get colorEnd => null;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColorUtil.CommonPageBgColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 8.h,
              horizontal: 12.w,
            ),
            child: ByWidgetsUtil.commonTipsBar("为保证视频效果，语音输入时长请小于视频时长。"),
          ),
          // SizedBox(height: 10.h),
          // Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 12.w),
          //   child: ClipRRect(
          //     borderRadius: BorderRadius.circular(8.w),
          //     child: CachedNetworkImage(
          //       imageUrl: APIs.testimgUrl,
          //       width: double.infinity,
          //       height: 206.h,
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),
          SizedBox(height: 10.h),
          Expanded(
            child: Container(
              color: ByColorUtil.WhiteColor,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(height: 12.h),
                  _buildAudioBar(),
                  Expanded(child: Container()),
                  _buildActions(context),
                  SizedBox(height: 10.h + ByScreenUtils.bottomSafeHeight),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ByWidgetsUtil.commonBtn(
            title: "语音转文字",
            textColor: ByColorUtil.LoginBtnBgColor,
            bgColor: const Color(0xFF2E54FF).withOpacity(0.1),
            onClick: () {
              ByNavRouterUtils.push(
                context,
                ChangeNotifierProvider.value(
                  value: context.read<T>(),
                  child: AudioTransferPage<T>(
                    recordingFilePath: widget.recordingFilePath,
                    assetEntity: widget.assetEntity,
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(width: 11.w),
        Expanded(
          child: ByWidgetsUtil.commonBtn(
            title: "重新录入语音",
            textColor: ByColorUtil.LoginBtnBgColor,
            bgColor: const Color(0xFF2E54FF).withOpacity(0.1),
            onClick: () async {
              // await ChannelOperate.toRecordingRequest().then((data) {
              //   if (data != null) {
              //     setState(() {
              //       widget.recordingFilePath = data[ChannelApi.recordingResult];
              //     });
              //   }
              // });
            },
          ),
        ),
      ],
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: ByWidgetsUtil.commonText(
        text: "字幕配音",
        fontWeight: FontWeight.w600,
        fontSize: 16.sp,
      ),
      leading: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          child: Image.asset(
            "assets/home/icon_back.png",
            width: 16,
            height: 16,
          ),
        ),
      ),
      actions: [
        SizedBox(
          width: 50.w,
          height: 30.h,
          child: ByWidgetsUtil.commonBtn(
            padding: EdgeInsets.zero,
            title: "确定",
            onClick: () {
              // final bool isClip =
              //     MaterialProviderTypeExt.providerTypeFromType(T) ==
              //         MaterialProviderType.clip;
              // if (!isClip) {
              //   ByNavRouterUtils.push(
              //     context,
              //     ChangeNotifierProvider.value(
              //       value: context.read<T>(),
              //       child: VideoClipHandlePage<T>(),
              //     ),
              //   );
              //   return;
              // }
              // final provider = context.read<T>();
              // provider.words2Audio(
              //   wordsEditingController.text,
              // );
              // 返回文案识别界面，将文本输入框替换为语音条
              context.read<T>().changeShowAudioStatus(true);
              context
                  .read<T>()
                  .updateReordingFilePath(widget.recordingFilePath);
              ByNavRouterUtils.goBackUntilName(
                  context, Consts.kVoiceoverSubtitlePage);
            },
          ),
        ),
        SizedBox(width: 12.w),
      ],
    );
  }

  /// 录音条
  _buildAudioBar() {
    return AudioPlayBar(widget.recordingFilePath);
  }
}
