import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/providers/show_recreate_provider.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/widgets/video_player_widget.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/home/recreate/widgets/step_view.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/hyber_clip_content_view.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class RecreateEditStepFourPage<T extends MaterialBaseProvider>
    extends StatefulWidget {
  const RecreateEditStepFourPage({super.key});

  @override
  State<RecreateEditStepFourPage<T>> createState() =>
      _RecreateEditStepFourPageState<T>();
}

class _RecreateEditStepFourPageState<T extends MaterialBaseProvider>
    extends State<RecreateEditStepFourPage<T>> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Column(
        children: [
          /// 视频预览
          _buildVideoPreview(context),

          /// 进度
          _buildStepView(context),

          Expanded(
            child: HyberClipContentView<T>(),
          )
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      color: ByColorUtil.WhiteColor,
      child: StepView<T>(step: 3),
    );
  }
}
