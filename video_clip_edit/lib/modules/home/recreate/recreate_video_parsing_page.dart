// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/clipped/video_clip_hyber_page.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/modules/home/providers/show_recreate_provider.dart';
import 'package:video_clip_edit/modules/home/providers/words_extract_provider.dart';
import 'package:video_clip_edit/modules/home/recreate/recreate_edit_step_two_page.dart';
import 'package:video_clip_edit/modules/home/words/beans/audio_result_bean.dart';
import 'package:video_clip_edit/modules/home/words/beans/upload_info_bean.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_ffmpeg_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

enum VideoParsingStatus {
  failed,
  parsing,
  done,
}

class RecreateVideoParsingPage<T extends MaterialBaseProvider>
    extends StatefulWidget {
  const RecreateVideoParsingPage({
    super.key,
    this.mergeOnly = false,
  });

  /// 只是视频合并,精细模式下值为true
  final bool? mergeOnly;

  @override
  State<RecreateVideoParsingPage<T>> createState() =>
      _RecreateVideoParsingPageState<T>();
}

class _RecreateVideoParsingPageState<T extends MaterialBaseProvider>
    extends State<RecreateVideoParsingPage<T>> {
  @override
  void initState() {
    super.initState();

    /// 视频混剪
    _parseVideos();
  }

  bool parseFailed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              fontSize: 14.sp,
              textColor: ByColorUtil.CommonTextColor,
            ),
            SizedBox(height: 150.h),
            _buildStatusWidgt(
              status: VideoParsingStatus.done,
              title: "视频合成完毕",
            ),
            SizedBox(height: 10.h),
            _buildStatusWidgt(
              status: VideoParsingStatus.done,
              title: "音频提取完成",
            ),
            SizedBox(height: 10.h),
            _buildStatusWidgt(
              status: VideoParsingStatus.done,
              title: "人物对话提取成功",
            ),
            SizedBox(height: 10.h),
            _buildStatusWidgt(
              status: parseFailed
                  ? VideoParsingStatus.failed
                  : VideoParsingStatus.parsing,
              title: parseFailed ? "解析人物对话失败" : "正在分析人物对话中···",
            ),
            if (parseFailed) SizedBox(height: 10.h),
            if (parseFailed)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  ByNavRouterUtils.goBack(context);
                },
                child: _buildStatusWidgt(
                  status: VideoParsingStatus.failed,
                  title: "返回重新选择视频或者重试",
                ),
              ),
          ],
        ),
      ),
    );
  }

  _buildStatusWidgt({
    required VideoParsingStatus status,
    required String title,
  }) {
    const textColorDone = Color(0xFF1CCB71);
    const textColorParsing = Color(0xFF5B4BF7);
    const textColorError = ByColorUtil.HomeHotAuthNumberColor;
    var isDone = status == VideoParsingStatus.done;
    var isFailed = status == VideoParsingStatus.failed;
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 35.w),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDone
              ? textColorDone.withOpacity(0.2)
              : isFailed
                  ? textColorError.withOpacity(0.2)
                  : textColorParsing.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ByWidgetsUtil.commonText(
            text: title,
            textColor: isDone
                ? textColorDone
                : isFailed
                    ? textColorError
                    : textColorParsing,
          ),
          const Spacer(),
          isDone
              ? Image.asset(
                  "assets/home/video_parse_done.png",
                  width: 16.h,
                  height: 16.h,
                )
              : isFailed
                  ? Container()
                  : const CupertinoActivityIndicator(
                      color: textColorParsing,
                    ),
        ],
      ),
    );
  }

  /// 视频解析
  /// 1、视频合成 45%
  /// 2、提取音频 70%
  /// 3、解析音频文本 100%
  void _parseVideos() async {
    if (MaterialProviderTypeExt.providerTypeFromType(T) ==
        MaterialProviderType.recreate) {
      final provider = context.read<T>() as ShowRecreateProvider;
      List selectedMaterials = provider.selectedMaterials;
      if (selectedMaterials.isEmpty) {
        BotToast.showText(text: "请先添加素材");
        return;
      }

      /// 1、视频合成
      String videoPath =
          await provider.videoComposition(selectedMaterials) ?? "";

      if (videoPath.isEmpty) {
        // BotToast.showText(text: "视频合成失败，请稍后再试");
        ByNavRouterUtils.goBack(context);
        return;
      }

      final File asset = File(videoPath);
      final isExists = await asset.exists();
      if (!isExists) {
        BotToast.showText(text: "视频合成失败，请稍后再试");
        return;
      }

      /// 更新合并后资源
      provider.updateAssetSpeedy(asset);

      if (widget.mergeOnly == true) {
        ByNavRouterUtils.pushReplacement(
          context,
          ChangeNotifierProvider.value(
            value: provider,
            child: RecreateEditStepTwoPage<T>(),
          ),
        );
        return;
      }

      /// 2、提取音频
      await ByFfmpegUtil.splitAudioFileFromVideo(
        asset,
        onSuccess: (audioTuple) {
          /// 解析音频内容
          _uploadFile(
            provider,
            audioTuple.item2,
            context,
          );
        },
        onErro: (e) {
          ByNavRouterUtils.goBack(context);
        },
      );
    }
  }

  void _uploadFile(
    ShowRecreateProvider provider,
    String filePath,
    BuildContext context,
  ) {
    ByFfmpegUtil.loadUploadInfo(
      type: MediaType.audio,
      onSuccess: (UploadInfoBean infoBean) {
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
                qurreyParingProgress(provider, requestID, context: context);
              },
            );
          },
        );
      },
    );
  }

  /// 查询语音解析的进度
  void qurreyParingProgress(
    ShowRecreateProvider provider,
    String requestID, {
    bool isCommentary = false,
    required BuildContext context,
  }) {
    ByFfmpegUtil.queryAudioRecognitionTask(
      requestID: requestID,
      onSuccess: (data) {
        byDebugPrint(data["status"], tag: "当前解析状态结果：");
        final status = data["status"];
        if (status == 2) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              qurreyParingProgress(
                provider,
                requestID,
                isCommentary: isCommentary,
                context: context,
              );
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
          if (!isCommentary) {
            /// 不是解说文案查询，创建解说文案
            provider.getCommentarySimpleText(
              text: res,
              onSuccess: (taskId) {
                if (taskId.isEmpty) {
                  BotToast.showText(text: "生成解说文案失败，请稍后再试");
                  return;
                }
                // qurreyParingProgress(provider, taskId, isCommentary: true);
                provider.queryVoiceStyleOptimizeState(
                  taskId: taskId,
                  onSuccess: (result) {
                    if (result.isNotEmpty) {
                      /// 转换解说文案
                      provider.updateSubtitle(result);

                      /// 开始转语音和字幕
                      _generateAudioAndSrt(
                        result,
                        provider,
                        context,
                      );
                      // if (mounted) {
                      //   /// 跳转到最后的选择参数页面
                      //   ByNavRouterUtils.pushReplacement(
                      //     context,
                      //     ChangeNotifierProvider.value(
                      //       value: provider,
                      //       child: VideoClipHyberPage<T>(),
                      //     ),
                      //   );
                      // }
                    }
                  },
                );
              },
              onFailed: () {
                setState(() {
                  parseFailed = true;
                });
              },
            );
          } else {
            // /// 转换解说文案
            // provider.updateSubtitle(res);
            // if (mounted) {
            //   /// 跳转到最后的选择参数页面
            //   ByNavRouterUtils.pushReplacement(
            //     context,
            //     ChangeNotifierProvider.value(
            //       value: provider,
            //       child: VideoClipHyberPage<T>(),
            //     ),
            //   );
            // }
          }
        }
      },
    );
  }

  /// 开始转语音和字幕
  void _generateAudioAndSrt(
    String content,
    ShowRecreateProvider provider,
    BuildContext context,
  ) {
    final navigator = Navigator.of(context);
    provider.loadSpeakers(
      onSuccess: (speakers) {
        if (speakers.isEmpty) {
          BotToast.showText(text: "当前配音角色不可用");
          return;
        }

        provider.words2Audio(
          content,
          speaker: speakers.first.speaker,
          onSuccess: (taskId) {
            EasyLoading.show();
            provider.queryWords2AudioStatus(
              taskId,
              onSuccess: (url, urlSrt) {
                EasyLoading.dismiss();
                ByFfmpegUtil.downloadAudio(
                  url,
                  null,
                  deleteWhenFinished: false,
                  saveToAlbum: false,
                  onSuccess: (filePath, asset) async {
                    final exists = await File(filePath).exists();
                    if (filePath.isEmpty || !exists) {
                      BotToast.showText(text: "配音生成失败!");
                      return;
                    }
                    await _combine(
                      filePath,
                      provider,
                      navigator,
                      context,
                      isSpeedy: true,
                      urlSrt: urlSrt,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  /// 将音频和视频合成为欣的视频
  Future<void> _combine(
    String audioFilePath,
    ShowRecreateProvider provider,
    NavigatorState navigator,
    BuildContext context, {
    bool isSpeedy = false,
    String? urlSrt,
  }) async {
    final asset = provider.assetSpeedy as File;
    final video = asset;

    if (video.existsSync()) {
      if (urlSrt != null) {
        await provider.updateSrtForAsset(video, urlSrt);
      }

      if (audioFilePath.isNotEmpty && File(audioFilePath).existsSync()) {
        await provider.updateAudioFilePathForAsset(video, audioFilePath);
      }

      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            return ChangeNotifierProvider.value(
              value: provider,
              child: VideoClipHyberPage<T>(
                showCommentary: false,
                type: 1,
              ),
            );
          },
        ),
      );
    }
  }
}
