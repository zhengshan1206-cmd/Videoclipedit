// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:video_clip_edit/utils/comon/by_ffmpeg_util.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/download/providers/download_provider.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/modules/home/providers/show_recreate_provider.dart';
import 'package:video_clip_edit/modules/home/recreate/beans/commentary_item_bean.dart';
import 'package:video_clip_edit/modules/home/recreate/recreate_edit_step_four_page.dart';
import 'package:video_clip_edit/modules/home/recreate/provdier/video_recreate_dubbing_provider.dart';

/// 生成视频配音的生成页面
class VideoRecreateDubbingGeneratingPage<T extends MaterialBaseProvider>
    extends StatefulWidget {
  final AssetEntity? assetEntity;

  const VideoRecreateDubbingGeneratingPage({
    super.key,
    this.assetEntity,
  });

  @override
  State<VideoRecreateDubbingGeneratingPage> createState() =>
      _VideoRecreateDubbingGeneratingPageState<T>();
}

class _VideoRecreateDubbingGeneratingPageState<T extends MaterialBaseProvider>
    extends State<VideoRecreateDubbingGeneratingPage<T>> {
  String workID = "";
  AssetEntity? combinedAsset;

  bool dowloading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
      /// 开始循环创建配音任务
      _generateDubbingTasks();
    });
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
              text: dowloading
                  ? "配音下载中(${context.select<DownloadProvider, int>((p) => p.progress.floor())}%)"
                  : "配音生成中(${context.select<VideoRecreateDubbingProvider, int>((p) => p.progress)}%)",
              fontSize: 15.sp,
              textColor: ByColorUtil.CommonTextColor,
            ),
          ],
        ),
      ),
    );
  }

  /// 查询每个配音任务的生成进度
  void querryProgress(String taskId) {
    final provider = context.read<T>();
    provider.queryWords2AudioStatus(
      taskId,
      onSuccess: (url, urlSrt) {
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

            ///...
          },
        );
      },
    );
  }

  /// 创建批量配音任务
  void _generateDubbingTasks() {
    final providerRecreate = context.read<T>() as ShowRecreateProvider;
    final providerDubbing = context.read<VideoRecreateDubbingProvider>();
    final providerDownload = context.read<DownloadProvider>();

    /// 配音角色列表为空，或者未选择配音角色，
    /// 下载配音角色列表，选择第一个角色生成解说配音
    if (providerRecreate.selectedDubbingIdx == -1 ||
        (providerRecreate.dubbingBeans?.isEmpty ?? true)) {
      providerDubbing.loadSpeakers(
        onSuccess: (speakers) {
          if (speakers.isEmpty) {
            BotToast.showText(text: "当前配音角色不可用");
            return;
          }

          /// 解说模型列表
          final List<CommentaryItemBean> commentaryItemBeans =
              providerRecreate.commentaryItemBeans;

          /// 遍历模型创建配音任务
          providerDubbing.startGenerateDubbing(
            commentaryItemBeans,
            speakers.first.speaker,
            onSuccess: (urls) async {
              print("ddddddddddddddddd生成的语音路径列表：$urls");
              setState(() {
                dowloading = true;
              });
              providerRecreate.commentaryItemBeans =
                  providerDubbing.commentaryItemBeans;

              /// 下载完成后需要将下载路径更新到
              await providerDownload.downloadFiles(
                urls,
                commentaryItemBeans: commentaryItemBeans,
                showLoading: false,
              );

              /// 跳转到第四步
              ByNavRouterUtils.pushReplacement(
                context,
                MultiProvider(
                  providers: [
                    ChangeNotifierProvider.value(
                      value: context.read<T>(),
                    ),
                    ChangeNotifierProvider(
                        create: (context) => DownloadProvider()),
                  ],
                  child: RecreateEditStepFourPage<T>(),
                ),
              );
            },
            onFaild: (val) {
              BotToast.showText(
                  text: val.contains("违规") ? val : "配音生成失败，请稍后重试");
              Navigator.of(context).pop();
            },
          );
        },
      );
    } else {
      /// 使用已经选择的配音角色生成解说配音
      final List<CommentaryItemBean> commentaryItemBeans =
          providerRecreate.commentaryItemBeans;

      /// 遍历模型创建配音任务
      providerDubbing.startGenerateDubbing(
        commentaryItemBeans,
        providerRecreate
            .dubbingBeans![providerRecreate.selectedDubbingIdx].speaker,
        onSuccess: (urls) async {
          providerRecreate.commentaryItemBeans =
              providerDubbing.commentaryItemBeans;
          setState(() {
            dowloading = true;
          });

          /// 下载完成后需要将下载路径更新到
          await providerDownload.downloadFiles(
            urls,
            commentaryItemBeans: commentaryItemBeans,
            showLoading: false,
          );

          /// 跳转到第四步
          ByNavRouterUtils.pushReplacement(
            context,
            MultiProvider(
              providers: [
                ChangeNotifierProvider.value(
                  value: context.read<T>(),
                ),
                ChangeNotifierProvider(create: (context) => DownloadProvider()),
              ],
              child: RecreateEditStepFourPage<T>(),
            ),
          );
        },
        onFaild: (val) {
          BotToast.showText(text: val.contains("违规") ? val : "语音生成失败，请稍后重试");
          Navigator.of(context).pop();
        },
      );
    }
  }
}
