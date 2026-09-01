// ignore_for_file: use_build_context_synchronously

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_permission_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/main/controllers/main_controller.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/widgets/ai_videos_downoad_dialog.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_video_management_provider.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/widgets/video_player_widget.dart';

// ignore: must_be_immutable
class StoryVideoPreviewPage extends StatefulWidget {
  final String videoUrl;
  final bool backToHme;
  final int id;
  AiOralVideoManagementProvider? provider;

  StoryVideoPreviewPage({
    super.key,
    this.backToHme = false,
    required this.videoUrl,
    this.provider,
    required this.id,
  });

  @override
  State<StoryVideoPreviewPage> createState() => _StoryVideoPreviewPageState();
}

class _StoryVideoPreviewPageState extends State<StoryVideoPreviewPage>
    with RouteAware {
  _StoryVideoPreviewPageState();
  final GlobalKey<VideoPlayerWidgetState> _playerKey =
      GlobalKey<VideoPlayerWidgetState>();
  bool deleteSuccess = false;

  @override
  void dispose() {
    _stopPlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ByWidgetsUtil.appBar(
            context: context,
            title: "视频详情",
            onPop: () {
              if (widget.backToHme) {
                Get.find<MainController>().backToMain();
              } else {
                ByNavRouterUtils.goBack(context);
              }
            },
            actions: []),
        backgroundColor: ByColorUtil.CommonPageBgColor,
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
              child: ByWidgetsUtil.commonTipsBar("内容由AI生成仅供参考，禁止利用功能从事违法活动。"),
            ),
            Expanded(
              child: Center(
                child: VideoPlayerWidget(
                  key: _playerKey,
                  url: widget.videoUrl,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            _bottomSettingWidget()
          ],
        ));
  }

  Widget _bottomSettingWidget() {
    return ByWidgetsUtil.physicalModel(
      child: Container(
        height: 66.h,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                child: ByWidgetsUtil.commonBtn(
              title: "下载视频",
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              onClick: () async {
                if (await ByPermissionUtils.storage() == false) return;
                final videoUrl = widget.videoUrl;
                showDialog(
                  context: context,
                  builder: (c) {
                    return AiVideosDownoadDialog(
                      contents: "",
                      maxLine: 10,
                      cancelBtnTitle: "取消",
                      confirmBtnTitle: "确定",
                      confirmCallback: () {},
                      videoUrls: [videoUrl],
                    );
                  },
                );
              },
            ))
          ],
        ),
      ),
    );
  }

  void _stopPlayer() {
    _playerKey.currentState?.stopPlay();
  }
}
