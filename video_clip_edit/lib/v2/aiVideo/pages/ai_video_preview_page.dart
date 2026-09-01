// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/main/controllers/main_controller.dart';
import 'package:video_clip_edit/modules/main/main_page.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_color_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_permission_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/widgets/ai_videos_downoad_dialog.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/widgets/video_player_widget.dart';
import 'package:video_clip_edit/v2/aiVideo/models/ai_video_generation_model.dart';
import 'package:video_clip_edit/v2/aiVideo/widgets/ai_video_copy_text_dialog.dart';

import '../../../modules/common/widget/common_dialog.dart';
import '../../../modules/profile/providers/mine_videos_single_page_provider.dart';
import '../../../modules/profile/widgets/mine_videos_management_gride_view.dart';
import '../provider/ai_video_management_provider.dart';

class AiVideoPreviewPage extends StatefulWidget {
  final AiVideoGenerationTaskModel videoBean;
  final bool backToHme;
  final AiVideoManagementProvider? provider;
  final MineVideosSinglePageProvider? provider2;
  final MineVideoType? type;
  const AiVideoPreviewPage({
    super.key,
    this.backToHme = false,
    required this.videoBean,
    this.provider,
    this.provider2,
    this.type,
  });

  @override
  State<AiVideoPreviewPage> createState() => _AiVideoPreviewPageState();
}

class _AiVideoPreviewPageState extends State<AiVideoPreviewPage>
    with RouteAware {
  _AiVideoPreviewPageState();
  final GlobalKey<VideoPlayerWidgetState> _playerKey =
      GlobalKey<VideoPlayerWidgetState>();

  bool deleteSuccess = false;

  @override
  void dispose() {
    _stopPlayer();
    super.dispose();
  }

  ///删除视频点击事件
  void deleteVideo() {
    if (deleteSuccess) {
      return;
    }
    _stopPlayer();
    showDialog(
      context: context,
      builder: (ctx) {
        return CommonDialog(
          reverse: false,
          maxLine: 10,
          contents: "请确认是否删除，删除后将不可回恢复，请谨慎操作",
          confirmBtnTitle: "删除",
          confirmCallback: () {},
        );
      },
    ).then((value) {
      if (value == true) {
        AiVideoManagementProvider? provider = widget.provider;
        MineVideosSinglePageProvider? provider2 = widget.provider2;
        if (provider != null) {
          EasyLoading.show(
              status: "删除中",
              maskType: EasyLoadingMaskType.black,
              dismissOnTap: false);
          provider.deleteVideos([widget.videoBean.id], onSuccess: () {
            provider.resetPages();
            provider.updateSelectAllStatus(false);
            provider.loadVideoList();
            EasyLoading.dismiss();
            setState(() {
              deleteSuccess = true;
            });
            Navigator.pop(context);
          });
        }
        if (provider2 != null && widget.type != null) {
          EasyLoading.show(
              status: "删除中",
              maskType: EasyLoadingMaskType.black,
              dismissOnTap: false);
          provider2.deleteVideos([widget.videoBean.id], type: widget.type!,
              onSuccess: () {
            provider2.updateSelectAllStatus(false);
            provider2.loadVideoList(type: widget.type!, isRefresh: true);
            EasyLoading.dismiss();
            setState(() {
              deleteSuccess = true;
            });
            Navigator.pop(context);
          });
        }
      }
    });
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
        actions: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  deleteVideo();
                },
                child: Text(
                  "删除",
                  style: TextStyle(
                      color: const Color(0XFF0B1843),
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp),
                ),
              ),
              SizedBox(
                width: 12.w,
              )
            ],
          )
        ],
      ),
      // backgroundColor: ByColorUtil.CommonPageBgColor,
      // body: Column(
      //   children: [
      //     Padding(
      //       padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      //       child: ByWidgetsUtil.commonTipsBar("内容由AI生成仅供参考，禁止利用功能从事违法活动。"),
      //     ),
      //     Expanded(
      //       child: Center(
      //         child: VideoPlayerWidget(
      //           key: _playerKey,
      //           url: widget.videoBean.videoUrl!,
      //         ),
      //       ),
      //     ),
      //     SizedBox(height: 8.h),
      //     _bottomSettingWidget()
      //   ],
      // ),
      body: _bodyWidget()
    );
  }

  Widget _bottomSettingWidget() {
    return  Container(
      height:Platform.isAndroid?66.h:86.h,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical:  Platform.isAndroid?8.h:16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (widget.videoBean.prompt != null)
            Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: ByWidgetsUtil.commonBtn(
                    title: "复制文案",
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    bgColor: ByColorUtils.hexColor('#CED1D9'),
                    onClick: () {
                      showDialog(
                        context: context,
                        builder: (context) => AiVideoCopyTextDialog(
                          videoBean: widget.videoBean,
                        ),
                      );
                    },
                  ),
                )),
          // Expanded(
          //     child: ByWidgetsUtil.commonBtn(
          //   title: "优化视频",
          //   fontSize: 16.sp,
          //   fontWeight: FontWeight.w500,
          //   bgColor: ByColorUtils.hexColor('#1CCB71'),
          //   onClick: () async {
          //     _stopPlayer();
          //     final videoUrl = widget.videoBean.videoUrl;
          //     if (await ByPermissionUtils.storage() == false) return;
          //     final String path = await showDialog(
          //       context: context,
          //       builder: (c) {
          //         return AiVideosDownoadDialog(
          //           contents: "",
          //           maxLine: 10,
          //           cancelBtnTitle: "取消",
          //           confirmBtnTitle: "确定",
          //           confirmCallback: () {},
          //           videoUrls: [videoUrl!],
          //           save: false,
          //         );
          //       },
          //     );
          //     if (path.isEmpty) return;
          //     final file = File(path);
          //     if (file.existsSync() == false) {
          //       BotToast.showText(text: "视频解析失败，请稍后再试");
          //       return;
          //     }
          //     await ChannelOperate.toVideoEdit(false,
          //         videoLocalFilePathParameter: [path]).then((data) {
          //       if (data != null) {
          //         final String pathResult = data["edit_result"] ?? "";
          //         if (pathResult.isNotEmpty) {
          //           ByNavRouterUtils.push(
          //               context, VideoClipHyberPrevicew(pathResult));
          //         } else {
          //           BotToast.showText(text: "视频剪辑失败");
          //         }
          //       }
          //     });
          //   },
          // )),
          // SizedBox(width: 12.w),
          Expanded(
              child: ByWidgetsUtil.commonBtn(
                title: "下载视频",
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                onClick: () async {
                  if (await ByPermissionUtils.storage() == false) return;
                  final videoUrl = widget.videoBean.videoUrl;
                  showDialog(
                    context: context,
                    builder: (c) {
                      return AiVideosDownoadDialog(
                        contents: "",
                        maxLine: 10,
                        cancelBtnTitle: "取消",
                        confirmBtnTitle: "确定",
                        confirmCallback: () {},
                        videoUrls: [videoUrl!],
                      );
                    },
                  );
                },
              ))
        ],
      ),
    );
  }

  void _stopPlayer() {
    _playerKey.currentState?.stopPlay();
  }

  Widget _bodyWidget() {
    if (deleteSuccess == true) {
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            child: ByWidgetsUtil.commonTipsBar("内容由AI生成仅供参考，禁止利用功能从事违法活动。"),
          ),
          SizedBox(
            height: 85.h,
            width: double.infinity,
          ),
          Image.asset(
            "assets/mine/mine_no_data.png",
            width: 180.w,
            height: 100.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 30.h),
          ByWidgetsUtil.commonText(
            fontSize: 14.sp,
            text: "暂无数据",
            fontWeight: FontWeight.normal,
            textColor: ByColorUtil.CommonTextColor.withOpacity(0.3),
          ),
        ],
      );
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
          child: ByWidgetsUtil.commonTipsBar("内容由AI生成仅供参考，禁止利用功能从事违法活动。"),
        ),
        Expanded(
          child: Center(
            child: VideoPlayerWidget(
              key: _playerKey,
              url: widget.videoBean.videoUrl!,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        _bottomSettingWidget()
      ],
    );
  }
}
