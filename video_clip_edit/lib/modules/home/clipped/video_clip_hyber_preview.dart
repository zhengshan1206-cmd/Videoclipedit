import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/modules/main/controllers/main_controller.dart';
import 'package:video_clip_edit/modules/main/main_page.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_assets_util.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_download_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/widgets/video_player_widget.dart';

// ignore: must_be_immutable
class VideoClipHyberPrevicew extends StatefulWidget {
  String videoFilePath;
  String? title;
  final bool backToHme;

  VideoClipHyberPrevicew(
    this.videoFilePath, {
    super.key,
    this.title,
    this.backToHme = false,
  });

  @override
  State<VideoClipHyberPrevicew> createState() => _VideoClipHyberPrevicewState();
}

class _VideoClipHyberPrevicewState extends State<VideoClipHyberPrevicew> {
  _VideoClipHyberPrevicewState();
  bool exists = false;

  @override
  void initState() {
    _checkExists();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return PopScope(
    //   canPop: false,
    //   onPopInvoked: (didPop) {
    //     if (didPop) return;
    //     ByNavRouterUtils.goBackUntilName(context, Consts.kAddMaterialPage);
    //   },
    //   child: Scaffold(
    //       appBar: ByWidgetsUtil.appBar(
    //           context: context,
    //           title: "我的预览",
    //           popScop: false,
    //           onPop: () {
    //             ByNavRouterUtils.goBackUntilName(
    //                 context, Consts.kAddMaterialPage);
    //           }),
    //       backgroundColor: ByColorUtil.CommonPageBgColor,
    //       body: Column(
    //         children: [
    //           Expanded(
    //               key: UniqueKey(),
    //               child: Center(
    //                   child: VideoPlayerWidget(url: widget.videoFilePath))),
    //           _bottomSettingWidget()
    //         ],
    //       )),
    // );
    return Scaffold(
        appBar: ByWidgetsUtil.appBar(
          context: context,
          title: widget.title ?? "我的预览",
          onPop: () {
            if (widget.backToHme) {
              Get.find<MainController>().backToMain();
            } else {
              ByNavRouterUtils.goBack(context);
            }
          },
        ),
        backgroundColor: ByColorUtil.CommonPageBgColor,
        body: Column(
          children: [
            Expanded(
                key: UniqueKey(),
                child: Center(
                    child: VideoPlayerWidget(url: widget.videoFilePath))),
            SizedBox(height: 10.h),
            _bottomSettingWidget()
          ],
        ));
  }

  Widget _bottomSettingWidget() {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // if (widget.title == null)
          //   Expanded(
          //       child: ByWidgetsUtil.commonBtn(
          //     title: "优化视频",
          //     fontSize: 14.sp,
          //     bgColor: ByColorUtils.hexColor('#1CCB71'),
          //     onClick: () async {
          //       await ChannelOperate.toVideoEdit(true,
          //               videoLocalFilePathParameter: [widget.videoFilePath])
          //           .then((data) {
          //         if (data != null) {
          //           setState(() {
          //             widget.videoFilePath = data[ChannelApi.editResult];
          //           });
          //         }
          //       });
          //     },
          //   )),
          // if (widget.title != null)
          //   Expanded(
          //       child: ByWidgetsUtil.commonBtn(
          //     title: "视频二创",
          //     fontSize: 14.sp,
          //     bgColor: ByColorUtils.hexColor('#1CCB71'),
          //     onClick: () async {
          //       final provider = ShowRecreateProvider();
          //       provider.addNewMaterials([File(widget.videoFilePath)]);
          //       Future.delayed(const Duration(milliseconds: 100), () {
          //         Future.microtask(() {
          //           ByNavRouterUtils.push(
          //             context,
          //             ChangeNotifierProvider<ShowRecreateProvider>.value(
          //               value: provider,
          //               child: const AddMaterialPage<ShowRecreateProvider>(),
          //             ),
          //           );
          //         });
          //       });
          //     },
          //   )),
          // const SizedBox(width: 10),
          Expanded(
              child: ByWidgetsUtil.commonBtn(
            title: "保存本地",
            fontSize: 14.sp,
            onClick: () async {
              if (exists) {
                BotToast.showText(text: "视频已保存到相册中");
                return;
              }
              final res = await ByDownloadUtil.saveVideoToAlbum(
                widget.videoFilePath,
                isToast: true,
              );
              if (res != null) {
                exists = true;
              }
            },
          ))
        ],
      ),
    );
  }

  void _checkExists() async {
    final assetSearch =
        await ByAssetsUtil.getAssetEntityByPath(widget.videoFilePath);
    if (assetSearch != null) {
      exists = true;
      return null;
    }
  }
}
