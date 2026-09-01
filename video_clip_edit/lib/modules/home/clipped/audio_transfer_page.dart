import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_clip_edit/modules/home/providers/words_extract_provider.dart';
import 'package:video_clip_edit/modules/home/widgets/audio_play_bar.dart';
import 'package:video_clip_edit/modules/home/words/beans/audio_result_bean.dart';
import 'package:video_clip_edit/modules/home/words/beans/upload_info_bean.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_ffmpeg_util.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/utils/consts/const.dart';

class AudioTransferPage<T extends MaterialBaseProvider> extends StatefulWidget {
  const AudioTransferPage({
    super.key,
    required this.recordingFilePath,
    this.assetEntity,
  });

  final String recordingFilePath;
  final dynamic assetEntity;

  @override
  State<AudioTransferPage> createState() => _AudioTransferPageState<T>();
}

class _AudioTransferPageState<T extends MaterialBaseProvider>
    extends State<AudioTransferPage<T>> {
  final TextEditingController wordsEditingController = TextEditingController();

  get colorEnd => null;

  bool _parsing = true;
  String _result = "";

  @override
  void initState() {
    super.initState();

    /// 解析语音
    Future.microtask(() {
      _parseAudio();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColorUtil.CommonPageBgColor,
      appBar: _buildAppBar(context),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            _buildAudioBar(),
            SizedBox(height: 12.h),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                    color: ByColorUtil.WhiteColor,
                    borderRadius: BorderRadius.circular(12.w)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Offstage(
                      offstage: _parsing,
                      child: Text(_result.isEmpty ? "未识别到内容" : _result),
                    ),
                    SizedBox(height: 15.h),
                    _buildLoadingView(),
                    const Spacer(),
                    _buildToolBar(),
                  ],
                ),
              ),
            ),
            SizedBox(height: ByScreenUtils.bottomSafeHeight),
          ],
        ),
      ),
    );
  }

  Offstage _buildLoadingView() {
    return Offstage(
      offstage: !_parsing,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFF3753FF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(6.w),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ByWidgetsUtil.commonText(
              text: "正在识别中",
              fontSize: 12.sp,
              textColor: ByColorUtil.TabTextColorSelected,
            ),
            SizedBox(width: 5.w),
            const CupertinoActivityIndicator(
              color: ByColorUtil.TabTextColorSelected,
              radius: 7,
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
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
        text: "字幕配音",
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

              final text = _result;
              if (text.isEmpty) {
                BotToast.showText(text: "未识别到内容");
                return;
              }
              final provider = context.read<T>();
              provider.updateSubtitle(_result);
              provider.changeShowAudioStatus(false);
              ByNavRouterUtils.goBackUntilName(
                  context, Consts.kVoiceoverSubtitlePage);

              // provider.loadSpeakers(
              //   onSuccess: (speakers) {
              //     if (speakers.isEmpty) {
              //       BotToast.showText(text: "当前配音角色不可用");
              //       return;
              //     }

              //     provider.words2Audio(
              //       text,
              //       speaker: speakers.first.speaker,
              //       onSuccess: (taskId) {
              //         EasyLoading.show();
              //         provider.queryWords2AudioStatus(
              //           taskId,
              //           onSuccess: (url) {
              //             EasyLoading.dismiss();
              //             final navigator = Navigator.of(context);
              //             ByFfmpegUtil.downloadAudio(
              //               url,
              //               null,
              //               deleteWhenFinished: false,
              //               saveToAlbum: false,
              //               onSuccess: (filePath, asset) async {
              //                 final exists = await File(filePath).exists();
              //                 if (filePath.isEmpty || !exists) {
              //                   BotToast.showText(text: "配音生成失败!");
              //                   return;
              //                 }
              //                 final video = await widget.assetEntity!.file;
              //                 final result = await ChannelOperate.toVideoEdit(
              //                   true,
              //                   videoLocalFilePathParameter: [video!.path],
              //                   selectMusic: filePath,
              //                   isOriginalSoundtrack: true,
              //                 );
              //                 final String resutlPath =
              //                     result["edit_result"] ?? "";
              //                 if (resutlPath.isNotEmpty) {
              //                   final index = provider.selectedMaterials
              //                       .indexOf(widget.assetEntity);
              //                   final newAsset =
              //                       await ByAssetsUtil.getAssetEntityByPath(
              //                           resutlPath);
              //                   provider.updateSelectedMaterialAtIndex(
              //                       newAsset, index);
              //                   navigator.pop();
              //                   navigator.pop();
              //                 }
              //               },
              //             );
              //           },
              //         );
              //       },
              //     );
              //   },
              // );

              // showDialog(
              //   context: context,
              //   useSafeArea: false,
              //   builder: (ctx) => MultiProvider(
              //     providers: [
              //       ChangeNotifierProvider.value(value: context.read<T>()),
              //     ],
              //     child: VoiceSelectDailog<T>(),
              //   ),
              // );
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

  Widget _buildToolBar() {
    return SizedBox(
      width: ByScreenUtils.screenWidth - 24.w,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () async {
              ClipboardData? data = await Clipboard.getData('text/plain');
              _result = data?.text ?? "";
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 29.h,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: ByWidgetsUtil.commonText(
                text: "粘贴",
                fontSize: 12.sp,
                textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
              ),
            ),
          ),
          Container(
            height: 29.h,
            alignment: Alignment.center,
            child: ByWidgetsUtil.commonText(
              text: "|",
              fontSize: 12.sp,
            ),
          ),
          GestureDetector(
            onTap: () {
              byDebugPrint("清空", tag: "Voice Cover:");
              setState(() {
                _result = "";
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 29.h,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: ByWidgetsUtil.commonText(
                text: "清空",
                fontSize: 12.sp,
                textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
              ),
            ),
          ),
          const Spacer(),
          Container(
            height: 29.h,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: ByWidgetsUtil.commonRichText(
              // text: "${wordsEditingController.text.length}/2000",
              texts: [
                TextSpan(
                  text: "${_result.length}",
                  style: TextStyle(
                      color: wordsEditingController.text.length < 2000
                          ? ByColorUtil.PurchaseDialogTimeBgColor
                          : ByColorUtil.CommonTextColor.withOpacity(0.5)),
                ),
                const TextSpan(text: "/2000"),
              ],
              fontSize: 12.sp,
              textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// 解析语音
  void _parseAudio() {
    EasyLoading.show();

    ByFfmpegUtil.loadUploadInfo(
      type: MediaType.audio,
      onSuccess: (UploadInfoBean infoBean) {
        /// 上传
        ByFfmpegUtil.uploadFile(
          infoBean: infoBean,
          filePath: widget.recordingFilePath,
          onSuccess: (resp) {
            ByFfmpegUtil.textExtractByAudio(
              audioUrl: infoBean.objectUrl,
              onSuccess: (String requestID) {
                /// 轮询状态
                _loadParsingProgress(requestID);
              },
            );
          },
        );
      },
    );
  }

  /// 查询文字解析状态
  void _loadParsingProgress(String requestID) {
    ByFfmpegUtil.queryAudioRecognitionTask(
      requestID: requestID,
      onSuccess: (data) {
        byDebugPrint(data["status"], tag: "解析状态：");
        final status = data["status"];
        if (status != 3 && mounted) {
          Future.delayed(const Duration(seconds: 1), () {
            _loadParsingProgress(requestID);
          });
        } else if (status == 3) {
          EasyLoading.dismiss();
          final List beansData = data["content"] ?? [];
          List<AudioResultBean> beans =
              beansData.map((e) => AudioResultBean.fromJson(e)).toList();
          var res = "";
          for (var e in beans) {
            res += e.text;
          }

          byDebugPrint(res, tag: "识别结果：");
          setState(() {
            _parsing = false;
            _result = res;
          });
        }
      },
    );
  }
}
