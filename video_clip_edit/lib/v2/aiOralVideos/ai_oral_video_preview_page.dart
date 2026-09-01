// ignore_for_file: use_build_context_synchronously
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/modules/main/controllers/main_controller.dart';
import 'package:video_clip_edit/modules/main/main_page.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_permission_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_video_management_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/widgets/ai_videos_downoad_dialog.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/widgets/video_player_widget.dart';

import '../../modules/common/widget/common_dialog.dart';
import '../../modules/profile/providers/mine_video_materials_single_page_provider.dart';
import '../../modules/profile/providers/mine_videos_single_page_provider.dart';
import '../../modules/profile/widgets/mine_video_materials_managment_page_view.dart';
import '../../modules/profile/widgets/mine_videos_management_gride_view.dart';
import '../aiVideo/provider/ai_video_management_provider.dart';

class AiOralVideoPreviewPage extends StatefulWidget {
  final String videoUrl;
  final bool backToHme;
  final int id;
  AiOralVideoManagementProvider? provider;
  MineVideoMaterialsSinglePageProvider? provider2;
  MineVideosSinglePageProvider? provider3;
   MineVideoType? type;
   MineVideoMaterialsPageType? type2;
  AiOralVideoPreviewPage({
    super.key,
    this.backToHme = false,
    required this.videoUrl,
    this.provider,
    required this.id,
    this.provider2,
    this.provider3,
    this.type,
    this.type2,
  });

  @override
  State<AiOralVideoPreviewPage> createState() => _AiOralVideoPreviewPageState();
}

class _AiOralVideoPreviewPageState extends State<AiOralVideoPreviewPage>
    with RouteAware {
  _AiOralVideoPreviewPageState();
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
    if(deleteSuccess){
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
          confirmCallback: () {

          },
        );
      },
    ).then((value){
      // log("同意删除==== ");
      if(value==true){
        AiOralVideoManagementProvider? provider = widget.provider;
        MineVideoMaterialsSinglePageProvider? provider2 = widget.provider2;
        MineVideosSinglePageProvider? provider3 = widget.provider3;
        if(provider!=null){
          EasyLoading.show(status: "删除中",maskType: EasyLoadingMaskType.black,dismissOnTap: false);
          provider.deleteVideos([widget.id],onSuccess: (){
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

        if(provider2!=null&&widget.type2!=null){
          EasyLoading.show(status: "删除中",maskType: EasyLoadingMaskType.black,dismissOnTap: false);
          provider2.deleteVideos([widget.id],onSuccess: (){
            provider2.updateSelectAllStatus(false);
            provider2.loadVideoList(type: widget.type2!,isRefresh: true);
            EasyLoading.dismiss();
            setState(() {
              deleteSuccess = true;
            });
            Navigator.pop(context);
          });
        }

        if(provider3!=null&&widget.type!=null){
          EasyLoading.show(status: "删除中",maskType: EasyLoadingMaskType.black,dismissOnTap: false);
          provider3.deleteVideos([widget.id],onSuccess: (){
            provider3.updateSelectAllStatus(false);
            provider3.loadVideoList(type: widget.type!);
            EasyLoading.dismiss();
            setState(() {
              deleteSuccess = true;
            });
            Navigator.pop(context);
          }, type: widget.type!);
        }
      }
    });
  }

  ///快手推广教程 常见问题view
  Widget helpView() {
    return Row(
      children: [
        SizedBox(
          width: 12.w,
        ),
        Expanded(
          child: helpItemView(
              iconPath: "assets/ai/clip/help_course.png",
              text: "快手推广授权教程",
              onTapEvent: () {}),
        ),
        SizedBox(
          width: 11.w,
        ),
        Expanded(
          child: helpItemView(
              iconPath: "assets/ai/clip/some_question.png",
              text: "常见问题",
              onTapEvent: () {}),
        ),
        SizedBox(
          width: 12.w,
        ),
      ],
    );
  }

  ///帮助的item view
  Widget helpItemView({
    required String iconPath,
    required String text,
    required VoidCallback onTapEvent,
  }) {
    return GestureDetector(
      onTap: () {
        onTapEvent();
        log("===点击事件===");
      },
      child: Container(
        padding:
        EdgeInsets.only(left: 12.w, right: 12.w, top: 13.w, bottom: 13.w),
        decoration: BoxDecoration(
          color: const Color(0XFFF1F4FD),
          borderRadius: BorderRadius.circular(10.w),
        ),
        alignment: Alignment.center,
        child: Row(
          children: [
            Image.asset(
              iconPath,
              width: 18.w,
              height: 18.w,
            ),
            SizedBox(
              width: 10.w,
            ),
            Text(
              text,
              style: TextStyle(
                  color: const Color(0XFF5A4BF7),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
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
          ]
        ),
        backgroundColor: ByColorUtil.CommonPageBgColor,
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
              child: ByWidgetsUtil.commonTipsBar("内容由AI生成仅供参考，禁止利用功能从事违法活动。"),
            ),
            // helpView(),
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
            // Expanded(
            //     child: ByWidgetsUtil.commonBtn(
            //   title: "优化视频",
            //   fontSize: 16.sp,
            //   fontWeight: FontWeight.w500,
            //   bgColor: ByColorUtils.hexColor('#1CCB71'),
            //   onClick: () async {
            //     _stopPlayer();
            //     final videoUrl = widget.videoUrl;
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
            //           videoUrls: [videoUrl],
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
