// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/consts/const.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:video_clip_edit/utils/comon/by_ffmpeg_util.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/providers/clipped_provider.dart';
import 'package:video_clip_edit/modules/home/words/beans/upload_info_bean.dart';
import 'package:video_clip_edit/modules/home/words/beans/audio_result_bean.dart';
import 'package:video_clip_edit/modules/home/clipped/voiceover_subtitle_page.dart';
import 'package:video_clip_edit/modules/home/providers/words_extract_provider.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';

class VideoClipParsingPage<T extends MaterialBaseProvider>
    extends StatefulWidget {
  final bool compositionOnly;
  final AssetEntity? assetEntity;

  const VideoClipParsingPage({
    super.key,
    required this.compositionOnly,
    this.assetEntity,
  });

  @override
  State<VideoClipParsingPage> createState() => _VideoClipParsingPageState<T>();
}

class _VideoClipParsingPageState<T extends MaterialBaseProvider>
    extends State<VideoClipParsingPage<T>> {
  @override
  void initState() {
    super.initState();

    _parseVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(context: context, title: ""),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 153.h),
            Image.asset(
              "assets/common/loading_large.gif",
              width: 120.w,
              height: 124.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 43.h),
            ByWidgetsUtil.commonText(
              text: "视频正在解析中...",
              fontSize: 15.sp,
              textColor: ByColorUtil.CommonTextColor,
            ),
          ],
        ),
      ),
    );
  }

  /// 视频解析
  /// 1、视频合成 45%
  /// 2、提取音频 70%
  /// 3、解析音频文本 100%
  void _parseVideos() async {
    /// 视频混剪
    // if (MaterialProviderTypeExt.providerTypeFromType(T) ==
    //     MaterialProviderType.clip) {
    //   final provider = context.read<T>() as ClippedProvider;
    //   List assets = provider.selectedMaterials;
    //   if (assets.isEmpty) {
    //     BotToast.showText(text: "请先添加素材");
    //     return;
    //   }

    //   if (widget.compositionOnly) {
    //     /// 1、视频合成
    //     String videoPath = await provider.videoComposition(assets) ?? "";
    //     if (videoPath.isEmpty) {
    //       // BotToast.showText(text: "视频合成失败，请稍后再试");
    //       ByNavRouterUtils.goBack(context);
    //       return;
    //     }
    //     final asset = File(videoPath);
    //     final exists = await asset.exists();
    //     if (!exists) {
    //       BotToast.showText(text: "视频合成失败，请稍后再试");
    //       ByNavRouterUtils.goBack(context);
    //       return;
    //     }

    //     provider.updateAssetSpeedy(asset);

    //     ChannelOperate.getVideoToAudioAndTxt(videoPath).then((data) {
    //       if (data != null) {
    //         final String content = data[ChannelApi.videoTextResult];
    //         ByNavRouterUtils.pushReplacement(
    //           context,
    //           name: Consts.kVoiceoverSubtitlePage,
    //           ChangeNotifierProvider.value(
    //             value: provider,
    //             child: VoiceoverSubtitlePage<T>(
    //               contents: content.withoutSpecialCharacter(),
    //               workID: provider.workId,
    //               assetEntity: asset,
    //             ),
    //           ),
    //         );
    //       }
    //     }).onError((c, d) {
    //       ByNavRouterUtils.pushReplacement(
    //         context,
    //         name: Consts.kVoiceoverSubtitlePage,
    //         ChangeNotifierProvider.value(
    //           value: provider,
    //           child: VoiceoverSubtitlePage<T>(
    //             contents: "",
    //             workID: provider.workId,
    //             assetEntity: asset,
    //           ),
    //         ),
    //       );
    //     });

    //     return;
    //   }
    //   if (widget.assetEntity == null) {
    //     BotToast.showText(text: "视频解析失败");
    //     return;
    //   }

    //   /// 3、提取音频
    //   final File? file = await widget.assetEntity!.file;
    //   if (file == null) {
    //     BotToast.showText(text: "文件解析失败,请重试");
    //     return;
    //   }

    //   /// 分离音频
    //   await ByFfmpegUtil.splitAudioFileFromVideo(
    //     file,
    //     onSuccess: (audioTuple) {
    //       /// 解析音频内容
    //       _uploadFile(
    //         provider,
    //         audioTuple.item2,
    //         context,
    //       );
    //     },
    //     onErro: (e) {
    //       ByNavRouterUtils.goBack(context);
    //     },
    //   );
    // }
  }

  void _uploadFile(
    ClippedProvider provider,
    String filePath,
    BuildContext context,
  ) {
    ByFfmpegUtil.loadUploadInfo(
      type: MediaType.audio,
      onSuccess: (UploadInfoBean infoBean) {
        byDebugPrint(filePath, tag: "音频路径：");

        /// 上传
        ByFfmpegUtil.uploadFile(
          infoBean: infoBean,
          filePath: filePath,
          onSuccess: (resp) {
            /// 识别语音
            ByFfmpegUtil.textExtractByAudio(
              audioUrl: infoBean.objectUrl,
              onSuccess: (String requestID) {
                ///轮询解析进度
                qurreyParingProgress(provider, requestID);
              },
            );
          },
        );
      },
    );
  }

  /// 查询语音解析的进度
  void qurreyParingProgress(
    ClippedProvider provider,
    String requestID,
  ) {
    byDebugPrint("查询中....", tag: "解析状态：");
    ByFfmpegUtil.queryAudioRecognitionTask(
      requestID: requestID,
      onSuccess: (data) {
        byDebugPrint(data["status"], tag: "当前解析状态结果：");
        final status = data["status"];
        if (status == 2) {
          byDebugPrint("2s后重新查询", tag: "解析状态：");
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              qurreyParingProgress(provider, requestID);
            }
          });
        } else if (status == 3) {
          final List beansData = data["content"] ?? [];
          List<AudioResultBean> beans =
              beansData.map((e) => AudioResultBean.fromJson(e)).toList();
          var res = "";
          for (var e in beans) {
            res += e.text;
          }
          byDebugPrint("解析完成--$res", tag: "识别结果：");
          final provider = context.read<T>();
          provider.updateSubtitle(res);
          if (mounted) {
            List<AssetEntity> assets =
                provider.selectedMaterials.cast<AssetEntity>();

            /// 跳转到配音页面
            ByNavRouterUtils.pushReplacement(
              context,
              name: Consts.kVoiceoverSubtitlePage,
              ChangeNotifierProvider.value(
                value: provider,
                child: VoiceoverSubtitlePage<T>(
                  contents: res,
                  workID: provider.workId,
                  assetEntity: assets.first,
                ),
              ),
            );
          }
        }
      },
    );
  }
}
