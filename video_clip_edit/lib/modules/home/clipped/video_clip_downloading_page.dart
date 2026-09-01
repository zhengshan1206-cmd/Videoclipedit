// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/beans/cloud_video_bean.dart';
import 'package:video_clip_edit/modules/common/widget/common_dialog.dart';
import 'package:video_clip_edit/modules/home/clipped/add_material_page.dart';
import 'package:video_clip_edit/modules/download/providers/download_provider.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';

class VideoClipDownloadingPage<T extends MaterialBaseProvider>
    extends StatefulWidget {
  const VideoClipDownloadingPage({super.key});

  @override
  State<VideoClipDownloadingPage<T>> createState() =>
      _VideoClipDownloadingPageState<T>();
}

class _VideoClipDownloadingPageState<T extends MaterialBaseProvider>
    extends State<VideoClipDownloadingPage<T>> {
  @override
  void initState() {
    super.initState();

    _downloadVideos();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.select<DownloadProvider, double>(
      (provider) => provider.progress,
    );

    final canPop = progress >= 100;
    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
        _onPopInvoked(didPop, progress, context);
      },
      child: Scaffold(
        backgroundColor: ByColorUtil.WhiteColor,
        appBar: ByWidgetsUtil.appBar(
          context: context,
          title: "视频下载",
          onPop: () {
            _onPopInvoked(
              canPop,
              progress,
              context,
              fromAppbBar: true,
            );
          },
        ),
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
              SizedBox(height: 45.h),
              ByWidgetsUtil.commonRichText(
                texts: [
                  TextSpan(text: "视频下载中${progress.toStringAsFixed(0)}%"),
                ],
                fontSize: 15.sp,
              ),
              SizedBox(height: 45.h),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _downloadVideos() async {
    final provider = context.read<T>();
    final downloadProvider = context.read<DownloadProvider>();

    final List<Detail> beans = provider.selectedVideoDetailBeans
        .where((e) => e.videoUrl.startsWith("http"))
        .toList();

    final assetsPaths = await downloadProvider.downloadVidoes(
      beans,
      showLoading: false,
    );

    /// 添加素材
    provider.addNewMaterials(
      assetsPaths.where((e) => e != null).map((path) => File(path!)).toList(),
    );

    provider.selectedVideoDetailBeans.clear();

    /// 跳转到素材编辑界面
    ByNavRouterUtils.pushReplacement(
      context,
      ChangeNotifierProvider.value(
        value: provider,
        child: AddMaterialPage<T>(),
      ),
    );
  }

  void _onPopInvoked(
    bool didPop,
    double progress,
    BuildContext context, {
    bool fromAppbBar = false,
  }) async {
    final navigator = Navigator.of(context);
    if (didPop) {
      if (fromAppbBar) navigator.pop();
      return;
    }

    if (progress < 100) {
      final result = await showDialog(
        context: context,
        builder: (c) {
          return CommonDialog(
            contents: "素材正在下载中，离开将会中断，确定要返回吗？",
            maxLine: 10,
            cancelBtnTitle: "取消",
            confirmBtnTitle: "确定",
            confirmCallback: () {
              context.read<DownloadProvider>().cancelAllDownloads();
            },
          );
        },
      );
      if (result) {
        navigator.pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }
}
