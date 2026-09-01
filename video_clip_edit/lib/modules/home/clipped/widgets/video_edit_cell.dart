import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/utils/consts/const.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/clipped/voiceover_subtitle_page.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_download_util.dart';

class VideoEditCell<T extends MaterialBaseProvider> extends StatelessWidget {
  final int index;
  final Key? captureKey;
  const VideoEditCell({
    super.key,
    required this.index,
    this.captureKey,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<T>();
    final selectedMaterials = provider.selectedMaterials;
    final material = selectedMaterials[index];
    final isFile = material is File;
    bool isLocal = material is AssetEntity || isFile;
    // AssetEntity asset = material;
    return Stack(
      children: [
        Padding(
          padding:
              EdgeInsets.only(top: 12.h, right: 12.w, left: 43.w, bottom: 5.h),
          child: RepaintBoundary(
            key: captureKey,
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: ByColorUtil.WhiteColor,
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 170.w,
                    height: 100.h,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.w),
                      child: isLocal
                          ? isFile
                              ? ByDownloadUtil.videoCover(material.path)
                              : Image(
                                  image: AssetEntityImageProvider(
                                      material as AssetEntity,
                                      isOriginal: false),
                                  fit: BoxFit.cover,
                                )
                          : CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: "",
                            ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ByWidgetsUtil.btnWithIcon(
                          iconW: 16.w,
                          iconH: 16.h,
                          title: "编辑视频",
                          fontSize: 14.sp,
                          bgColor: const Color(0xFFECF1F3),
                          textColor: const Color(0xFF0B1843),
                          onClick: () async {
                            // final file = material is File
                            //     ? material
                            //     : await material.file;
                            // String? filePath = file?.path;
                            // if (filePath != null) {
                            //   // await ChannelOperate.myEdit([filePath]);
                            //   await ChannelOperate.toVideoEdit(true,
                            //           hindMenu: true,
                            //           exportTitle: "正在编辑",
                            //           exportTxt: "确定",
                            //           isSelectEditModel: true,
                            //           videoLocalFilePathParameter: [filePath])
                            //       .then((data) async {
                            //     if (data != null) {
                            //       final String path = data["edit_result"] ?? "";
                            //       if (path.isEmpty) {
                            //         BotToast.showText(text: "视频编辑失败，请稍后再试");
                            //         return;
                            //       }
                            //       EasyLoading.show(status: "素材更新中...");
                            //       final asset =
                            //           await ByAssetsUtil.getAssetEntityByPath(
                            //               path);
                            //       EasyLoading.dismiss();
                            //       if (asset != null) {
                            //         provider.updateSelectedMaterialAtIndex(
                            //           asset,
                            //           index,
                            //         );
                            //       }
                            //     }
                            //   });
                            // }

                            // await ChannelOperate.text1(true,videoLocalFilePathParameter: [filePath!!],isSelectEditModel: true);
                          },
                          iconPath: "assets/purchase/icon_clip_edit_video.png",
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                        ),
                        SizedBox(height: 11.h),
                        ByWidgetsUtil.btnWithIcon(
                          iconW: 16.w,
                          iconH: 16.h,
                          title: "字幕配音",
                          fontSize: 14.sp,
                          bgColor: const Color(0xFFECF1F3),
                          textColor: const Color(0xFF0B1843),
                          onClick: () {
                            final T provider = Provider.of<T>(
                              context,
                              listen: false,
                            );
                            ByNavRouterUtils.push(
                              context,
                              name: Consts.kVoiceoverSubtitlePage,
                              ChangeNotifierProvider.value(
                                value: provider,
                                child: VoiceoverSubtitlePage<T>(
                                    contents: '',
                                    workID: '',
                                    assetEntity: material),
                              ),
                            );
                          },
                          iconPath: "assets/purchase/icon_clip_audio.png",
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () {
              provider.removeMaterial(material);
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 29.w,
              height: 15.w + 14.h,
              alignment: Alignment.center,
              child: Image.asset(
                "assets/home/clip_close.png",
                width: 15.w,
                height: 15.w,
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          width: 43.w,
          height: 142.h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  if (index == 0) return;
                  final res = selectedMaterials.swap(
                      selectedMaterials, index, index - 1);
                  provider.updateSelectedMaterials(res);
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 25.w,
                  height: 25.h,
                  alignment: Alignment.center,
                  child: Image.asset(
                    index == 0
                        ? "assets/home/clip_arrow_up_disable.png"
                        : "assets/home/clip_arrow_up.png",
                    width: 16.w,
                    height: 16.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () {
                  if (index == selectedMaterials.length - 1) return;
                  final res = selectedMaterials.swap(
                      selectedMaterials, index, index + 1);
                  provider.updateSelectedMaterials(res);
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 25.w,
                  height: 25.h,
                  alignment: Alignment.center,
                  child: Image.asset(
                    index == selectedMaterials.length - 1
                        ? "assets/home/clip_arrow_down_disable.png"
                        : "assets/home/clip_arrow_down.png",
                    width: 16.w,
                    height: 16.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
