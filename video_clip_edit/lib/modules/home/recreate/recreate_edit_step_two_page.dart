import 'dart:io';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:video_clip_edit/utils/comon/by_ffmpeg_util.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/recreate/widgets/step_view.dart';
import 'package:video_clip_edit/modules/home/words/beans/upload_info_bean.dart';
import 'package:video_clip_edit/modules/home/words/beans/audio_result_bean.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/modules/home/providers/show_recreate_provider.dart';
import 'package:video_clip_edit/modules/home/providers/words_extract_provider.dart';
import 'package:video_clip_edit/modules/home/recreate/widgets/role_words_cell.dart';
import 'package:video_clip_edit/modules/home/recreate/recreate_edit_step_three_page.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/widgets/video_player_widget.dart';

class RecreateEditStepTwoPage<T extends MaterialBaseProvider>
    extends StatefulWidget {
  const RecreateEditStepTwoPage({super.key});

  @override
  State<RecreateEditStepTwoPage<T>> createState() =>
      _RecreateEditStepTwoPageState<T>();
}

class _RecreateEditStepTwoPageState<T extends MaterialBaseProvider>
    extends State<RecreateEditStepTwoPage<T>> {
  @override
  void initState() {
    super.initState();

    /// 解析视频文件
    _parseVideo();
  }

  @override
  void dispose() {
    EasyLoading.dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          /// 视频预览
          _buildVideoPreview(context),

          /// 进度
          _buildStepView(context),

          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: ByWidgetsUtil.commonText(
                fontSize: 12.sp,
                text: "可修改角色名或纠正台词",
                textColor: ByColorUtil.TabTextColorSelected),
          ),

          /// 文案列表
          _buildWordsList(context),
        ],
      ),
    );
  }

  /// App Bar
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: ByWidgetsUtil.commonText(
        text: "解说文案",
        fontWeight: FontWeight.w600,
        fontSize: 16.sp,
      ),
      actions: [
        SizedBox(
          height: 30.h,
          child: ByWidgetsUtil.commonBtn(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            title: "下一步",
            onClick: () {
              final provider = context.read<ShowRecreateProvider>();
              provider.commentaryItemBeans.clear();
              provider.resetSelectedRoleName();

              ByNavRouterUtils.push(
                context,
                ChangeNotifierProvider.value(
                  value: provider,
                  child: RecreateEditStepThreePage<T>(),
                ),
              );
            },
          ),
        ),
        SizedBox(width: 12.w),
      ],
    );
  }

  /// 视频预览
  _buildVideoPreview(BuildContext context) {
    final dynamic asset = context.read<T>().assetSpeedy!;
    final videoOffset =
        context.select<ShowRecreateProvider, int>((p) => p.videoOffset);
    return SizedBox(
      height: 210.h,
      child: ByWidgetsUtil.futuerBuilderWidget(
        future: _parseVideoUrl(asset),
        builder: (ctx, data) {
          if (data == null) {
            return Container();
          }
          return VideoPlayerWidget(
            url: data.path,
            offset: videoOffset,
          );
        },
      ),
    );
  }

  Future<File?> _parseVideoUrl(dynamic asset) async {
    if (asset is AssetEntity) {
      return asset.file;
    }
    return asset as File;
  }

  /// 进度
  _buildStepView(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: StepView<T>(step: 1),
    );
  }

  /// 文案列表
  _buildWordsList(BuildContext context) {
    final provider = context.watch<T>() as ShowRecreateProvider;
    final beans = provider.speakerQuotesBeans;
    return Expanded(
        child: ListView.builder(
      itemCount: beans.length,
      itemBuilder: (ctx, index) {
        final AudioResultBean bean = beans[index];
        return RoleWordsCell<T>(bean: bean);
      },
    ));
  }

  /// 解析视频文件
  void _parseVideo() async {
    final provider = context.read<T>() as ShowRecreateProvider;

    /// 现将视频合并成一个完整的视频
    final dynamic video = provider.assetSpeedy!;
    provider.speakerQuotesBeans.clear();
    File? file;
    if (video is AssetEntity) {
      file = await video.file;
    } else if (video is File) {
      file = video;
    }
    if (file == null) {
      BotToast.showText(text: "视频解析失败");
      return;
    }
    EasyLoading.show(status: "视频解析中...");

    /// 提取音频
    ByFfmpegUtil.splitAudioFileFromVideo(file, onSuccess: (resTuple) {
      EasyLoading.dismiss();
      _uploadFile(provider, resTuple.item2);
    }, onErro: (c) {
      EasyLoading.dismiss();
      ByNavRouterUtils.goBack(context);
    });
  }

  void _uploadFile(
    ShowRecreateProvider provider,
    String filePath,
  ) {
    EasyLoading.show(status: "声音解析中...");
    ByFfmpegUtil.loadUploadInfo(
      type: MediaType.audio,
      onSuccess: (UploadInfoBean infoBean) {
        byDebugPrint(filePath, tag: "音频路径：");
        
        /// 上传
        ByFfmpegUtil.uploadFile(
          infoBean: infoBean,
          filePath: filePath,
          loadingText: "内容提取中",
          dismiss: false,
          onSuccess: (resp) {
            EasyLoading.show(status: "台词提取中...");

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
    ShowRecreateProvider provider,
    String requestID,
  ) {
    ByFfmpegUtil.queryAudioRecognitionTask(
      requestID: requestID,
      onSuccess: (data) {
        final status = data["status"];
        if (status == 2) {
          byDebugPrint("2s后重新查询", tag: "解析状态：");
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              qurreyParingProgress(provider, requestID);
            }
          });
        } else if (status == 3) {
          EasyLoading.dismiss();
          final List beansData = data["content"] ?? [];
          List<AudioResultBean> speakerQuotesBeans =
              beansData.map((e) => AudioResultBean.fromJson(e)).toList();
          provider.updateSpeakerQuotesBeans(speakerQuotesBeans);
        }
      },
    );
  }
}
