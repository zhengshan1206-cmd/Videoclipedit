// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_clip_edit/modules/home/clipped/audio_transfer_page.dart';
import 'package:video_clip_edit/modules/home/clipped/beans/dubbing_bean.dart';
import 'package:video_clip_edit/modules/home/clipped/video_clip_hyber_page.dart';
import 'package:video_clip_edit/modules/home/widgets/audio_play_bar.dart';
import 'package:video_clip_edit/modules/home/widgets/prohibited_words_input_view.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import 'package:video_clip_edit/utils/comon/by_ffmpeg_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/voice_select_dailog.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/select_style_dailog.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/prohibited_words_dailog.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/widgets/video_player_widget.dart';
import 'package:video_clip_edit/widgets/pan_to_unfocus.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class VoiceoverSubtitlePage<T extends MaterialBaseProvider>
    extends StatefulWidget {
  const VoiceoverSubtitlePage({
    super.key,
    required this.contents,
    required this.workID,
    required this.assetEntity,
  });

  final String contents;
  final String workID;
  final dynamic assetEntity;

  @override
  State<VoiceoverSubtitlePage> createState() =>
      _VoiceoverSubtitlePageState<T>();
}

class _VoiceoverSubtitlePageState<T extends MaterialBaseProvider>
    extends State<VoiceoverSubtitlePage<T>> {
  File? videoFile;
  dynamic workBean;
  String fileUrl = "";
  String words = "952-1119";
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final provider = context.read<T>();
      provider.updateSubtitle(widget.contents);
      provider.changeShowAudioStatus(false);
      _calculateWords(provider);

      videoFile = await (widget.assetEntity is File
          ? Future.value(widget.assetEntity as File)
          : (widget.assetEntity! as AssetEntity).file);

      setState(() {});
    });
  }

  @override
  void dispose() {
    EasyLoading.dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isClip = MaterialProviderTypeExt.providerTypeFromType(T) ==
        MaterialProviderType.clip;
    final bool isSpeedy = context.select<T, bool>(
      (p) {
        return p.generatingMode == null
            ? false
            : p.generatingMode == MaterialProviderGeneratingMode.speedy;
      },
    );
    return Scaffold(
      backgroundColor:
          isClip ? ByColorUtil.CommonPageBgColor : ByColorUtil.WhiteColor,
      appBar: _buildAppBar(context, isSpeedy),
      resizeToAvoidBottomInset: false,
      body: PanToUnfocus(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 12.w,
                right: 12.w,
                top: 8.h,
                bottom: isClip ? 8.h : 0,
              ),
              child: ByWidgetsUtil.commonRichTextTipsBar(textSpans: [
                const TextSpan(text: "建议文案字数"),
                TextSpan(
                  text: words,
                  style: const TextStyle(
                    color: Color(0xFFF62B60),
                  ),
                ),
                const TextSpan(text: "字，可基本适配画面时长。"),
              ]),
            ),
            if (isClip) SizedBox(height: 10.h),
            if (isClip) _buildVideoPreview(),
            if (isClip) SizedBox(height: 10.h),
            _buildContets(context),
          ],
        ),
      ),
    );
  }

  ClipRRect _buildVideoPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.w),
      child: SizedBox(
        height: 100.h,
        child: videoFile == null
            ? ByWidgetsUtil.activityIndicator()
            : VideoPlayerWidget(url: videoFile!.path),
      ),
    );
  }

  Expanded _buildContets(BuildContext context) {
    final showAudioBar = context.select<T, bool>((p) => p.showAudioBar);
    return Expanded(
      child: Container(
        color: ByColorUtil.WhiteColor,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (!showAudioBar) Expanded(child: _buildInputWidget(context)),
            if (showAudioBar) _buildAudioBar(context),
            if (showAudioBar) const Spacer(),
            if (!showAudioBar) SizedBox(height: 10.h),
            if (showAudioBar) _buildAudioAction(context),
            if (!showAudioBar) SizedBox(height: 10.h),
            if (!showAudioBar) _buildActionsOne(context),
            if (!showAudioBar) SizedBox(height: 10.h),
            if (!showAudioBar) _buildActionsTwo(context),
            SizedBox(height: ByScreenUtils.bottomSafeHeight),
          ],
        ),
      ),
    );
  }

  /// 输入框组件
  _buildInputWidget(BuildContext context) {
    return ProhibitedInputView<T>(
      padding: EdgeInsets.only(left: 0.w, right: 0.w, top: 5.h, bottom: 30.h),
      extractCallback: () async {
        EasyLoading.show();
        final file = widget.assetEntity is File
            ? widget.assetEntity
            : await widget.assetEntity?.file;
        EasyLoading.dismiss();
        if (file == null) {
          BotToast.showText(text: "视频解析失败");
          return;
        }
        EasyLoading.show(status: "音频分离中...");
        ByFfmpegUtil.splitAudioFileFromVideo(
          file,
          onSuccess: (audioInfo) {
            byDebugPrint(audioInfo.item2, tag: "识别结果：");
            final provider = context.read<T>();

            /// 使用火山接口获取音频文案
            context.read<T>().audio2text(
                  file: file,
                  onSuccess: (res) {
                    provider.updateSubtitle(res.withoutSpecialCharacter());
                    // wordsEditingController.text = res.withoutSpecialCharacter();
                    setState(() {});
                  },
                );
          },
          onErro: (erro) {
            EasyLoading.dismiss();
          },
        );
      },
    );
  }

  /// 按钮行
  Row _buildActionsTwo(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: aloneBtnWithIcon(
              iconH: 16.w,
              iconW: 16.w,
              title: "选择音色",
              textColor: ByColorUtil.LoginBtnBgColor,
              iconPath: "assets/home/icon_one_key_dubbing.png",
              bgColor: const Color(0xFF2E54FF).withOpacity(0.1),
              onClick: () {
                showDialog(
                  context: context,
                  useSafeArea: false,
                  builder: (ctx) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(value: context.read<T>()),
                    ],
                    child: VoiceSelectDailog<T>(),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(width: 11.w),
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: aloneBtnWithIcon(
              iconH: 16.w,
              iconW: 16.w,
              title: "语音输入文字",
              textColor: ByColorUtil.LoginBtnBgColor,
              iconPath: "assets/home/icon_input_voice.png",
              bgColor: const Color(0xFF2E54FF).withOpacity(0.1),
              onClick: () async {
                // await ChannelOperate.toRecordingRequest().then((data) {
                //   if (data != null) {
                //     ByNavRouterUtils.push(
                //       context,
                //       ChangeNotifierProvider.value(
                //         value: context.read<T>(),
                //         child: VoiceoverSubtitleAudioPage<T>(
                //           data[ChannelApi.recordingResult],
                //           "",
                //           assetEntity: widget.assetEntity,
                //         ),
                //       ),
                //     );
                //   }
                // });
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 按钮行
  Row _buildActionsOne(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: aloneBtnWithIcon(
              iconH: 16.w,
              iconW: 16.w,
              title: "违禁词检测",
              textColor: ByColorUtil.LoginBtnBgColor,
              iconPath: "assets/home/icon_prohibited_words.png",
              bgColor: const Color(0xFF2E54FF).withOpacity(0.1),
              onClick: () {
                showDialog(
                  context: context,
                  useSafeArea: false,
                  barrierDismissible: true,
                  builder: (ctx) => ChangeNotifierProvider.value(
                    value: context.read<T>(),
                    child: ProhibitedWordsDailog<T>(),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(width: 11.w),
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: aloneBtnWithIcon(
              iconH: 16.w,
              iconW: 16.w,
              title: "风格改写",
              textColor: ByColorUtil.LoginBtnBgColor,
              iconPath: "assets/home/icon_style_edit.png",
              bgColor: const Color(0xFF2E54FF).withOpacity(0.1),
              onClick: () {
                showDialog(
                  context: context,
                  useSafeArea: false,
                  barrierDismissible: false,
                  builder: (ctx) => ChangeNotifierProvider.value(
                    value: context.read<T>(),
                    child: SelectStyleDialog<T>(
                      showRoles: false,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 语音条转换按钮
  Widget _buildAudioAction(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ByWidgetsUtil.commonBtn(
            title: "语音转文字",
            textColor: ByColorUtil.LoginBtnBgColor,
            bgColor: const Color(0xFF2E54FF).withOpacity(0.1),
            onClick: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => ChangeNotifierProvider.value(
                        value: context.read<T>(),
                        child: AudioTransferPage<T>(
                          recordingFilePath:
                              context.read<T>().recordingFilePath,
                          assetEntity: widget.assetEntity,
                        ),
                      )));
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
              //     ByNavRouterUtils.push(
              //       context,
              //       ChangeNotifierProvider.value(
              //         value: context.read<T>(),
              //         child: VoiceoverSubtitleAudioPage<T>(
              //           data[ChannelApi.recordingResult],
              //           "",
              //           assetEntity: widget.assetEntity,
              //         ),
              //       ),
              //     );
              //   }
              // });
            },
          ),
        ),
      ],
    );
  }

  /// 录音条
  _buildAudioBar(BuildContext context) {
    return AudioPlayBar(context.read<T>().recordingFilePath);
  }

  /// App Bar
  AppBar _buildAppBar(BuildContext context, bool isSpeedy) {
    final bool isClip = MaterialProviderTypeExt.providerTypeFromType(T) ==
        MaterialProviderType.clip;
    return AppBar(
      centerTitle: true,
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
      title: ByWidgetsUtil.commonText(
        text: isClip ? "字幕配音" : "解说文案",
        fontWeight: FontWeight.w600,
        fontSize: 16.sp,
      ),
      actions: [
        SizedBox(
          width: 50.w,
          height: 30.h,
          child: ByWidgetsUtil.commonBtn(
            padding: EdgeInsets.zero,
            title: "确定",
            onClick: () {
              // if (isClip) {
              FocusScope.of(context).unfocus();
              Future.delayed(const Duration(milliseconds: 100), () {
                final provider = context.read<T>();
                final navigator = Navigator.of(context);
                if (provider.showAudioBar &&
                    provider.recordingFilePath.isNotEmpty) {
                  _combine(
                    provider.recordingFilePath,
                    provider,
                    navigator,
                    context,
                    isSpeedy: isSpeedy,
                    urlSrt: null,
                  );
                  return;
                }
                final text = provider.subtitlesBean.wordsOrigin;
                if (text.isEmpty) {
                  BotToast.showText(text: "请先输入文案");
                  return;
                }

                /// 判断是否有选择配音角色
                final dubbingBeans = provider.dubbingBeans;
                if (dubbingBeans == null || dubbingBeans.isEmpty) {
                  provider.loadSpeakers(
                    onSuccess: (speakers) {
                      if (speakers.isEmpty) {
                        BotToast.showText(text: "当前配音角色不可用");
                        return;
                      }

                      provider.words2Audio(
                        text,
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
                                    isSpeedy: isSpeedy,
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
                } else {
                  int index = provider.selectedDubbingIdx;
                  if (index == -1) {
                    index = 0;
                  }
                  provider.words2Audio(
                    text,
                    speaker: dubbingBeans[index].speaker,
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
                                isSpeedy: isSpeedy,
                                urlSrt: urlSrt,
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                }
              });
            },
          ),
        ),
        SizedBox(width: 12.w),
      ],
    );
  }

  /// 将音频和视频合成为欣的视频
  Future<void> _combine(
    String audioFilePath,
    T provider,
    NavigatorState navigator,
    BuildContext context, {
    bool isSpeedy = false,
    String? urlSrt,
  }) async {
    final video = widget.assetEntity is File
        ? widget.assetEntity
        : await widget.assetEntity!.file;

    if (urlSrt != null) {
      await provider.updateSrtForAsset(video, urlSrt);
    }

    if (audioFilePath.isNotEmpty && File(audioFilePath).existsSync()) {
      await provider.updateAudioFilePathForAsset(video, audioFilePath);
    }

    /// 二创精细+极速、混剪极速
    if (isSpeedy) {
      final exists = await video.exists();
      if (!exists) {
        BotToast.showText(text: "合成视频失败");
        return;
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

    /// 混剪精细
    else {
      // final index = provider.indexOfMaterial(widget.assetEntity);
      // provider.updateSelectedMaterialAtIndex(video, index);
      navigator.pop();
    }
  }

  void _calculateWords(T provider) async {
    final seconds = await provider.calculateVideoDuration(widget.assetEntity);
    provider.loadSpeakers(
      onSuccess: (List<DubbingBean> speakers) {
        if (speakers.isEmpty) return;
        final speaker = speakers.first;
        if (provider.selectedDubbingIdx == -1) {
          final speed = double.parse(speaker.speakSpeed);
          final wordsCount = (speed * seconds).ceil();
          const delta = 50;
          setState(() {
            words = "${max(10, wordsCount - delta)}-${wordsCount + delta}";
          });
        }
      },
    );
  }

  GestureDetector aloneBtnWithIcon({
    required String title,
    required String iconPath,
    required void Function() onClick,
    double? iconW,
    double? iconH,
    double? fontSize,
    double? borderRadius,
    FontWeight? fontWeight,
    EdgeInsetsGeometry? padding,
    Color? textColor = ByColorUtil.WhiteColor,
    Color? bgColor = ByColorUtil.LoginBtnBgColor,
    BoxDecoration? boxDecoration,
  }) {
    boxDecoration ??= BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius ?? 8.w),
      color: bgColor,
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        Future.delayed(const Duration(milliseconds: 200), () {
          onClick();
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 50.h,
        alignment: Alignment.centerLeft,
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
        decoration: boxDecoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              iconPath,
              fit: BoxFit.contain,
              width: iconW ?? 18.w,
              height: iconH ?? 18.w,
            ),
            SizedBox(width: 7.w),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize ?? 14.sp,
                fontWeight: fontWeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
