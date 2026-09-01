import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/core/base/base_view.dart';
import 'package:video_clip_edit/modules/ai/ai_video/ai_dynamic_video_controller.dart';
import 'package:video_clip_edit/modules/ai/ai_video/new_ai_video_dialog_ex.dart';
import 'package:video_clip_edit/modules/ai/ai_video/new_ai_video_list_view_page_ex.dart';
import 'package:video_clip_edit/modules/guid/providers/guide_pop_providers.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/v2/aiVideo/models/ai_video_generation_model.dart';
import 'package:video_clip_edit/v2/aiVideo/pages/ai_video_management_page.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_video_management_provider.dart';
import 'package:video_clip_edit/v2/aiVideo/widgets/generate_mode_dialog.dart';
import 'package:video_clip_edit/v2/integral/integral_controller.dart';
import 'package:video_clip_edit/widgets/common/right_navigation_bar.dart';
import '../../../controller/user_controller.dart';
import '../../../utils/comon/by_colors.dart';
import '../../../v2/aiVideo/models/ai_video_square_model.dart';
import 'package:video_clip_edit/widgets/common/integral_vip_view.dart';

class AIDynamicVideoPage extends StatefulWidget {
  const AIDynamicVideoPage({
    super.key,
    this.fromHome = false,
    this.initType,
    this.prompt,
    this.uniqueKey,
  });

  ///是否来自首页
  final bool? fromHome;

  final AiVideoGenerationType? initType;

  final String? prompt;

  final String? uniqueKey;

  @override
  State<StatefulWidget> createState() => AIDynamicVideoPageState();
}

/// AI动态视频
class AIDynamicVideoPageState extends State<AIDynamicVideoPage>
    with SingleTickerProviderStateMixin {
  ///用户user
  UserController get userController => Get.find<UserController>();

  /// 我的积分（使用安全获取，避免未注册报错）
  IntegralController get controller => IntegralController.getOrPut();

  ///热门同款
  Widget _hotProductView({required BuildContext context, index = 0}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 12.w, right: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Column(
        children: [
          ///热门同款
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/ai/aiVideo/ai_dynamic_video_hot.png",
                    width: 16.w,
                    height: 16.w,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    "热门同款",
                    style: TextStyle(
                      color: const Color(0XFF0B1843),
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 5.w),
              Padding(
                padding: EdgeInsets.only(top: 5.w),
                child: Text(
                  "可用下列素材直接生成",
                  style: TextStyle(
                    color: Color(0XFF0B1843).withOpacity(0.5),
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  // _checkLogin(() {
                  Get.to(
                    () => NewAiVideoListViewPageEx(
                      currentIndex: index,
                      type:
                          Get.find<AiDynamicVideoController>(
                                tag: _uniqueKey,
                              ).type ==
                              0
                          ? Get.find<AiDynamicVideoController>(
                                      tag: _uniqueKey,
                                    ).currentMode.value ==
                                    2
                                ? AiVideoGenerationType.multipleImages
                                : Get.find<AiDynamicVideoController>(
                                        tag: _uniqueKey,
                                      ).currentMode.value ==
                                      1
                                ? AiVideoGenerationType.firstAndEndFrame
                                : AiVideoGenerationType.imageToVideo
                          : AiVideoGenerationType.textToVideo,
                    ),
                  )?.then((value) {
                    if (value is AiVideoSquareModel) {
                      Get.find<AiDynamicVideoController>(
                        tag: _uniqueKey,
                      ).useSame(models: value);
                    }
                    // });
                  });
                },
                child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsetsDirectional.only(start: 40.w),
                  child: Row(
                    children: [
                      Text(
                        "更多",
                        style: TextStyle(
                          color: Color(0XFF0B1843).withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                          fontSize: 14.sp,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 15.w,
                        color: Color(0XFF0B1843).withOpacity(0.7),
                      ),
                      SizedBox(width: 5.w),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 110.h,
            child: GetBuilder<AiDynamicVideoController>(
              id: index == 0 ? "hotVideosForImage" : "hotVideosForText",
              tag: _uniqueKey,
              builder: (controller) {
                return ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...(index == 0
                            ? controller.currentMode.value == 2
                                  ? controller.hotVideosForMultiple
                                  : controller.currentMode.value == 1
                                  ? controller.hotVideosForTwo
                                  : controller.hotVideosForOne
                            : controller.hotVideos2)
                        .map(
                          (e) => GestureDetector(
                            onTap: () {
                              // _checkLogin(() {
                              showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: (context) {
                                  return NewAiVideoDialogEx(
                                    model: e,
                                    type: index,
                                  );
                                },
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                              ).then((value) {
                                if (value != null) {
                                  controller.useSame(models: value);
                                  controller.initIntegralVipController();
                                }
                              });
                              // });
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 90.w,
                                  height: 110.h,
                                  margin: EdgeInsets.only(right: 10.w),
                                  decoration: BoxDecoration(
                                    // color: Colors.blue,
                                    borderRadius: BorderRadius.circular(10.w),
                                    image: DecorationImage(
                                      image: NetworkImage(e.coverUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    "assets/ai/aiVideo/new_ai_video_play_icon.png",
                                    width: 23.w,
                                    height: 23.w,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double _getWidth(BuildContext context, {int num = 2}) {
    return (MediaQuery.of(context).size.width - 12.w * 2 - 10.w * (num - 1)) /
        num;
  }

  double _getLeft(BuildContext context, {int num = 2, int startIndex = 0}) {
    return _getWidth(context, num: min(num, 3)) * (startIndex + 1) +
        startIndex * 10.w -
        16.w;
  }

  List<Widget> _buildImageList(
    List<Pair<String, String>> pairs,
    List<int> list,
  ) {
    List<Widget> widgets = [];
    if (list.length < 2) {
      widgets.add(
        _buildImageWidget(
          pairs[0].key,
          "上传首帧图片",
          imgIndex: 0,
          width: _getWidth(context),
        ),
      );
      widgets.add(SizedBox(width: 10.w));
      widgets.add(
        _buildImageWidget(
          pairs[1].key,
          "上传尾帧图片",
          imgIndex: 1,
          width: _getWidth(context),
        ),
      );
      widgets.add(SizedBox(width: 10.w));
    } else {
      for (int index in list) {
        widgets.add(
          _buildImageWidget(
            pairs[list[index]].key,
            "",
            imgIndex: list[index],
            width: _getWidth(context, num: min(list.length, 3)),
          ),
        );
        widgets.add(SizedBox(width: 10.w));
      }
    }
    return widgets.sublist(0, widgets.length - 1);
  }

  ///模式选择
  Widget _chooseModeWidget({required BuildContext context}) {
    return Container(
      width: 1.sw,
      margin: EdgeInsets.only(left: 12.w, right: 12.w, top: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Column(
        children: [
          ///模式选择（暂时注释）
          // Row(
          //   children: [
          //     Image.asset(
          //       "assets/ai/aiVideo/ai_dynamic_video_mode_selection.png",
          //       width: 16.w,
          //       height: 16.w,
          //     ),
          //     SizedBox(
          //       width: 2.w,
          //     ),
          //     Text(
          //       "模式选择",
          //       style: TextStyle(
          //           color: const Color(0XFF0B1843),
          //           fontWeight: FontWeight.bold,
          //           fontSize: 16.sp),
          //     ),
          //     const Spacer(),
          //     Obx(() {
          //       var currentMode =
          //           Get.find<AiDynamicVideoController>(tag: _uniqueKey)
          //               .currentMode;
          //       return Row(
          //         children: [
          //           GestureDetector(
          //             child: Container(
          //               height: 24.h,
          //               alignment: AlignmentDirectional.center,
          //               padding: EdgeInsetsDirectional.only(
          //                 start: 8.w,
          //                 end: 8.w,
          //               ),
          //               decoration: BoxDecoration(
          //                   color: 0 == currentMode.value
          //                       ? const Color(0xFF5A4BF7)
          //                       : const Color(0xFFEAEEFF),
          //                   borderRadius: BorderRadius.only(
          //                       topLeft: Radius.circular(6.w),
          //                       bottomLeft: Radius.circular(6.w))),
          //               child: Text(
          //                 "普通模式",
          //                 style: TextStyle(
          //                     color: 0 == currentMode.value
          //                         ? Colors.white
          //                         : const Color(0xFF0B1843).withOpacity(.8),
          //                     fontSize: 12.sp),
          //               ),
          //             ),
          //             onTap: () {
          //               Get.find<AiDynamicVideoController>(tag: _uniqueKey)
          //                   .switchMode(0);
          //             },
          //           ),
          //           Container(
          //             height: 24.h,
          //             width: 1.w,
          //             color: Color(0xFF5A4BF7).withOpacity(.1),
          //           ),
          //           GestureDetector(
          //             child: Container(
          //               height: 24.h,
          //               alignment: AlignmentDirectional.center,
          //               padding: EdgeInsetsDirectional.only(
          //                 start: 8.w,
          //                 end: 8.w,
          //               ),
          //               color: 1 == currentMode.value
          //                   ? const Color(0xFF5A4BF7)
          //                   : const Color(0xFFEAEEFF),
          //               child: Text(
          //                 "首尾帧",
          //                 style: TextStyle(
          //                     color: 1 == currentMode.value
          //                         ? Colors.white
          //                         : Color(0xFF0B1843).withOpacity(.8),
          //                     fontSize: 12.sp),
          //               ),
          //             ),
          //             onTap: () {
          //               Get.find<AiDynamicVideoController>(tag: _uniqueKey)
          //                   .switchMode(1);
          //             },
          //           ),
          //           Container(
          //             height: 24.h,
          //             width: 1.w,
          //             color: Color(0xFF5A4BF7).withOpacity(.1),
          //           ),
          //           GestureDetector(
          //             child: Container(
          //               height: 24.h,
          //               alignment: AlignmentDirectional.center,
          //               padding:
          //                   EdgeInsetsDirectional.only(start: 8.w, end: 8.w),
          //               decoration: BoxDecoration(
          //                   color: currentMode.value == 2
          //                       ? const Color(0xFF5A4BF7)
          //                       : const Color(0xFFEAEEFF),
          //                   borderRadius: BorderRadius.only(
          //                       topRight: Radius.circular(6.w),
          //                       bottomRight: Radius.circular(6.w))),
          //               child: Text(
          //                 "多图参考",
          //                 style: TextStyle(
          //                     color: currentMode.value == 2
          //                         ? Colors.white
          //                         : const Color(0xFF0B1843).withOpacity(.8),
          //                     fontSize: 12.sp),
          //               ),
          //             ),
          //             onTap: () {
          //               Get.find<AiDynamicVideoController>(tag: _uniqueKey)
          //                   .switchMode(2);
          //             },
          //           )
          //         ],
          //       );
          //     })
          //   ],
          // ),

          ///上传图片
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/ai/aiVideo/ai_dynamic_video_upload_image.png",
                width: 16.w,
                height: 16.w,
              ),
              SizedBox(width: 5.w),
              Text(
                "上传图片",
                style: TextStyle(
                  color: const Color(0XFF0B1843),
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.w),
          Obx(() {
            int currentMode = Get.find<AiDynamicVideoController>(
              tag: _uniqueKey,
            ).currentMode.value;
            if (currentMode == 2) {
              return Column(
                children: [
                  GetBuilder<AiDynamicVideoController>(
                    id: "updateImage2",
                    tag: _uniqueKey,
                    builder: (controller) {
                      List<Pair<String, String>> pairs =
                          controller.selectedImg2;
                      List<int> list = controller.validIndex();
                      return Column(
                        children: [
                          Stack(
                            alignment: AlignmentDirectional.centerStart,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 100.h,
                                child: SingleChildScrollView(
                                  controller: controller.imageScrollController,
                                  scrollDirection: Axis.horizontal,
                                  child: Stack(
                                    alignment: AlignmentDirectional.centerStart,
                                    children: [
                                      Row(
                                        children: _buildImageList(pairs, list),
                                      ),
                                      if (list.length >= 2)
                                        Positioned(
                                          left: _getLeft(
                                            context,
                                            num: list.length,
                                            startIndex: 0,
                                          ),
                                          child: GestureDetector(
                                            child: Image.asset(
                                              "assets/ai/aiVideo/img_swap_icon.png",
                                              width: 32.w,
                                              height: 32.w,
                                            ),
                                            onTap: () {
                                              controller.swapImage(start: 0);
                                            },
                                          ),
                                        ),
                                      if (list.length >= 3)
                                        Positioned(
                                          left: _getLeft(
                                            context,
                                            num: list.length,
                                            startIndex: 1,
                                          ),
                                          child: GestureDetector(
                                            child: Image.asset(
                                              "assets/ai/aiVideo/img_swap_icon.png",
                                              width: 32.w,
                                              height: 32.w,
                                            ),
                                            onTap: () {
                                              controller.swapImage(start: 1);
                                            },
                                          ),
                                        ),
                                      if (list.length >= 4)
                                        Positioned(
                                          left: _getLeft(
                                            context,
                                            num: list.length,
                                            startIndex: 2,
                                          ),
                                          child: GestureDetector(
                                            child: Image.asset(
                                              "assets/ai/aiVideo/img_swap_icon.png",
                                              width: 32.w,
                                              height: 32.w,
                                            ),
                                            onTap: () {
                                              controller.swapImage(start: 2);
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      SizedBox(width: 4.w),
                      Text(
                        "最多支持4张，推荐上传两张合成效果更好哦。",
                        style: TextStyle(
                          color: Color(0xFF0B1843).withOpacity(.5),
                          fontSize: 12.sp,
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Obx(() {
                        bool showUpload = Get.find<AiDynamicVideoController>(
                          tag: _uniqueKey,
                        ).showUpload.value;
                        if (showUpload != true) {
                          return const SizedBox();
                        }
                        return GestureDetector(
                          child: Row(
                            children: [
                              Text(
                                "继续上传",
                                style: TextStyle(
                                  color: Color(0xFF5A4BF7),
                                  fontSize: 12.sp,
                                ),
                              ),
                              SizedBox(width: 4.w),
                            ],
                          ),
                          onTap: () {
                            /// 点击选择图片
                            Get.find<AiDynamicVideoController>(
                              tag: _uniqueKey,
                            ).updateImageUrl(
                              index:
                                  Get.find<AiDynamicVideoController>(
                                        tag: _uniqueKey,
                                      ).validIndex().length ==
                                      2
                                  ? 2
                                  : 3,
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ],
              );
            } else if (currentMode == 1) {
              return GetBuilder<AiDynamicVideoController>(
                id: "updateImage1",
                tag: _uniqueKey,
                builder: (AiDynamicVideoController controller) {
                  List<Pair<String, String>> paths = controller.selectedImg1;
                  return Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildImageWidget(
                              paths[0].key,
                              "上传首帧图片",
                              imgIndex: 0,
                              width: _getWidth(context),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _buildImageWidget(
                              paths[1].key,
                              "上传尾帧图片",
                              imgIndex: 1,
                              width: _getWidth(context),
                            ),
                          ),
                        ],
                      ),
                      if (paths.every((ele) => ele.key.isNotEmpty == true) ==
                          true)
                        Positioned(
                          child: GestureDetector(
                            child: Image.asset(
                              "assets/ai/aiVideo/img_swap_icon.png",
                              width: 32.w,
                              height: 32.w,
                            ),
                            onTap: () {
                              controller.swapImage(start: 0);
                            },
                          ),
                        ),
                    ],
                  );
                },
              );
            } else {
              return GetBuilder<AiDynamicVideoController>(
                id: "updateImage0",
                tag: _uniqueKey,
                builder: (AiDynamicVideoController controller) {
                  String path = controller.selectedImg0[0].key;
                  return _buildImageWidget(path, "上传图片");
                },
              );
            }
          }),
        ],
      ),
    );
  }

  ///图片展示与新增
  Widget _buildImageWidget(
    String path,
    String text, {
    int imgIndex = 0,
    double? width,
  }) {
    if (path.isNotEmpty == true) {
      return GestureDetector(
        child: Stack(
          children: [
            SizedBox(
              width: width ?? double.infinity,
              height: 100.h,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.w),
                    child:
                        (path.startsWith("http") == true
                                ? CachedNetworkImage(
                                    height: 100.h,
                                    width: width ?? double.infinity,
                                    imageUrl: path,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(path),
                                    width: width ?? double.infinity,
                                    height: 100.h,
                                    fit: BoxFit.cover,
                                  ))
                            .blurred(
                              blurColor: Colors.white.withOpacity(0),
                              colorOpacity: 0,
                              blur: 5,
                            ),
                  ),
                  if (path.startsWith("http") == true)
                    CachedNetworkImage(
                      height: 100.h,
                      imageUrl: path,
                      fit: BoxFit.fitHeight,
                    ),
                  if (path.startsWith("http") != true)
                    Image.file(
                      File(path),
                      height: 100.h,
                      fit: BoxFit.fitHeight,
                    ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                height: 36.h,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.7),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12.w),
                    bottomRight: Radius.circular(12.w),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        child: Container(
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/ai/aiVideo/img_replace_icon.png",
                                width: 12.w,
                                height: 12.w,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                "替换",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(.8),
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          /// 点击选择图片
                          Get.find<AiDynamicVideoController>(
                            tag: _uniqueKey,
                          ).updateImageUrl(index: imgIndex);
                        },
                      ),
                    ),
                    Container(
                      color: Colors.white.withOpacity(.5),
                      width: 1.w,
                      height: 10.h,
                    ),
                    Expanded(
                      child: GestureDetector(
                        child: Container(
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/ai/aiVideo/img_delete_icon.png",
                                width: 12.w,
                                height: 12.w,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                "删除",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(.8),
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Get.find<AiDynamicVideoController>(
                            tag: _uniqueKey,
                          ).deleteImage(index: imgIndex);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          ///开启图片预览
          void openDialog(BuildContext context) => showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                child: GestureDetector(
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // PhotoView(
                        //   tightMode: true,
                        //   backgroundDecoration: const BoxDecoration(
                        //       color: Colors.transparent, boxShadow: []),
                        //   onTapUp: (
                        //     BuildContext context,
                        //     TapUpDetails details,
                        //     PhotoViewControllerValue controllerValue,
                        //   ) {
                        //     Navigator.pop(context);
                        //   },
                        //   imageProvider: path.startsWith("http") == true
                        //       ? CachedNetworkImageProvider(path)
                        //       : FileImage(File(path)),
                        //   heroAttributes:
                        //       const PhotoViewHeroAttributes(tag: "someTag"),
                        // ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: (path.startsWith("http") == true)
                              ? CachedNetworkImage(
                                  imageUrl: path,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                )
                              : Image.file(
                                  File(path),
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                        ),
                        SizedBox(height: 16.h),
                        Image.asset(
                          "assets/ai/ai_cartoon_picture_preview_close.png",
                          width: 32.w,
                          height: 32.w,
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              );
            },
          );

          openDialog(context);
        },
      );
    } else {
      return GestureDetector(
        child: Container(
          width: width ?? double.infinity,
          height: 100.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFF),
            borderRadius: BorderRadius.all(Radius.circular(12.w)),
            border: Border.all(color: const Color(0xFFEAEEFF), width: 1.w),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/ai/aiVideo/upload_image_tip.png",
                width: 28.w,
                height: 28.w,
              ),
              SizedBox(height: 6.h),
              Text(
                text,
                style: TextStyle(
                  color: Color(0xFF8289A1),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                "（支持JPG、PNG，大小不超过5M）",
                style: TextStyle(color: Color(0xFF8289A1), fontSize: 10.sp),
              ),
            ],
          ),
        ),
        onTap: () {
          _checkLogin(() {
            /// 点击选择图片
            Get.find<AiDynamicVideoController>(
              tag: _uniqueKey,
            ).updateImageUrl(index: imgIndex);
          });
        },
      );
    }
  }

  ///创意描述
  Widget _creativeDescriptionWidget({
    required BuildContext context,
    int? index,
  }) {
    return Container(
      width: 1.sw,
      margin: EdgeInsets.only(left: 12.w, right: 12.w, top: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Column(
        children: [
          ///创意描述
          Row(
            children: [
              Image.asset(
                "assets/ai/aiVideo/ai_dynamic_video_creative_desc.png",
                width: 16.w,
                height: 16.w,
              ),
              SizedBox(width: 5.w),
              Text(
                "创意描述",
                style: TextStyle(
                  color: const Color(0XFF0B1843),
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.w),

          GetBuilder<AiDynamicVideoController>(
            id: "updateTab",
            tag: _uniqueKey,
            builder: (AiDynamicVideoController controller) {
              return GestureDetector(
                child: Container(
                  width: double.infinity,
                  height: controller.type == 1 ? 180.h : 120.h,
                  padding: EdgeInsetsDirectional.only(start: 12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFF),
                    borderRadius: BorderRadius.all(Radius.circular(12.w)),
                    border: Border.all(
                      color: const Color(0xFFEAEEFF),
                      width: 1.w,
                    ),
                  ),
                  child: _imagineHintTextView(index: index),
                ),
                onTap: () {
                  Get.find<AiDynamicVideoController>(
                    tag: _uniqueKey,
                  ).requestFocus();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  ///不希望呈现的内容
  Widget _hiddenContentWidget({required BuildContext context}) {
    return Container(
      width: 1.sw,
      margin: EdgeInsets.only(left: 12.w, right: 12.w),
      padding: EdgeInsets.only(top: 15.w, left: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Column(
        children: [
          ///不希望呈现内容
          Row(
            children: [
              Text(
                "不希望呈现的内容",
                style: TextStyle(
                  color: const Color(0XFF0B1843),
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              Text(
                "（可选填）",
                style: TextStyle(
                  color: const Color(0XFF111E48),
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.w),

          Container(
            width: double.infinity,
            height: 120.h,
            padding: const EdgeInsetsDirectional.only(
              start: 12,
              end: 12,
              bottom: 0,
              top: 0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFF),
              borderRadius: BorderRadius.all(Radius.circular(12.w)),
              border: Border.all(color: const Color(0xFFEAEEFF), width: 1.w),
            ),
            child: _imagineHintTextView(onlyInput: true),
          ),
        ],
      ),
    );
  }

  ///构建视频设置item
  Widget _buildVideoSettingItem(Widget child, {int index = 0, double? width}) {
    if (index == 1) {
      return SizedBox(width: width, child: child);
    }
    return Expanded(child: child);
  }

  ///视频设置
  Widget _videoSettingWidget({
    required BuildContext context,
    int? index = 0,
    bool imageToView = true,
  }) {
    return Container(
      width: 1.sw,
      margin: EdgeInsets.only(left: 12.w, right: 12.w, top: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Column(
        children: [
          ///视频设置
          Row(
            children: [
              Image.asset(
                "assets/ai/aiVideo/ai_dynamic_video_setting.png",
                width: 16.w,
                height: 16.w,
              ),
              SizedBox(width: 5.w),
              Text(
                "视频设置",
                style: TextStyle(
                  color: const Color(0XFF0B1843),
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.w),
          _buildScrollWidget(
            Row(
              children: [
                _buildVideoSettingItem(
                  GestureDetector(
                    child: Container(
                      width: double.infinity,
                      height: 64.h,
                      padding: index == 1
                          ? EdgeInsetsDirectional.only(start: 12.w)
                          : EdgeInsetsDirectional.only(start: 16.w, end: 16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFF),
                        borderRadius: BorderRadius.all(Radius.circular(10.w)),
                        border: Border.all(
                          color: const Color(0xFFEAEEFF),
                          width: 1.w,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Obx(() {
                            int generateMode =
                                Get.find<AiDynamicVideoController>(
                                  tag: _uniqueKey,
                                ).generateMode;
                            VideoQuality videoQuality =
                                VideoQuality.fromString(generateMode) ??
                                VideoQuality.standard;
                            return Text(
                              videoQuality.label,
                              style: TextStyle(
                                color: Color(0xFF0B1843),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Text(
                                "生成模式",
                                style: TextStyle(
                                  color: const Color(
                                    0xFF0B1843,
                                  ).withOpacity(.8),
                                  fontSize: 12.sp,
                                ),
                              ),
                              index == 1
                                  ? SizedBox(width: 4.w)
                                  : const Expanded(child: SizedBox()),
                              Image.asset(
                                "assets/ai/aiVideo/img_next1_icon.png",
                                width: 12.w,
                                height: 12.w,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Get.find<AiDynamicVideoController>(
                        tag: _uniqueKey,
                      ).showGenerateModeDialog();
                    },
                  ),
                  index: index ?? 0,
                  width: 95.w,
                ),
                Obx(() {
                  var controller = Get.find<AiDynamicVideoController>(
                    tag: _uniqueKey,
                  );
                  int currentMode = controller.currentMode.value;
                  return ((controller.type == 0 && currentMode == 0) ||
                          controller.type == 1)
                      ? _buildVideoSettingItem(
                          Row(
                            children: [
                              SizedBox(width: 10.w),
                              Expanded(
                                child: GestureDetector(
                                  child: Container(
                                    width: double.infinity,
                                    height: 64.h,
                                    padding: index == 1
                                        ? EdgeInsetsDirectional.only(
                                            start: 12.w,
                                          )
                                        : EdgeInsetsDirectional.only(
                                            start: 16.w,
                                            end: 16.w,
                                          ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FAFF),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.w),
                                      ),
                                      border: Border.all(
                                        color: const Color(0xFFEAEEFF),
                                        width: 1.w,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Obx(() {
                                          int duration =
                                              Get.find<
                                                    AiDynamicVideoController
                                                  >(tag: _uniqueKey)
                                                  .videoDuration
                                                  .value;
                                          return Text(
                                            "${duration}S",
                                            style: TextStyle(
                                              color: const Color(0xFF0B1843),
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        }),
                                        SizedBox(height: 6.h),
                                        Row(
                                          children: [
                                            Text(
                                              "视频时长",
                                              style: TextStyle(
                                                color: const Color(
                                                  0xFF0B1843,
                                                ).withOpacity(.8),
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                            index == 1
                                                ? SizedBox(width: 4.w)
                                                : const Expanded(
                                                    child: SizedBox(),
                                                  ),
                                            Image.asset(
                                              "assets/ai/aiVideo/img_next1_icon.png",
                                              width: 12.w,
                                              height: 12.w,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    controller.showVideoDurationDialog();
                                  },
                                ),
                              ),
                            ],
                          ),
                          index: index ?? 0,
                          width: 95.w,
                        )
                      : const SizedBox();
                }),
                if (imageToView != true) SizedBox(width: 10.w),
                if (imageToView != true)
                  _buildVideoSettingItem(
                    GestureDetector(
                      child: Container(
                        width: double.infinity,
                        height: 64.h,
                        padding: index == 1
                            ? EdgeInsetsDirectional.only(start: 12.w)
                            : EdgeInsetsDirectional.only(
                                start: 16.w,
                                end: 16.w,
                              ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFF),
                          borderRadius: BorderRadius.all(Radius.circular(10.w)),
                          border: Border.all(
                            color: const Color(0xFFEAEEFF),
                            width: 1.w,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Obx(() {
                              String label = Get.find<AiDynamicVideoController>(
                                tag: _uniqueKey,
                              ).videoRatio.value;
                              return Text(
                                label.replaceAll("/", ":"),
                                style: TextStyle(
                                  color: const Color(0xFF0B1843),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                Text(
                                  "视频比例",
                                  style: TextStyle(
                                    color: Color(0xFF0B1843).withOpacity(.8),
                                    fontSize: 12.sp,
                                  ),
                                ),
                                index == 1
                                    ? SizedBox(width: 4.w)
                                    : const Expanded(child: SizedBox()),
                                Image.asset(
                                  "assets/ai/aiVideo/img_next1_icon.png",
                                  width: 12.w,
                                  height: 12.w,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Get.find<AiDynamicVideoController>(
                          tag: _uniqueKey,
                        ).showVideoRatioDialog();
                      },
                    ),
                    index: index ?? 0,
                    width: 95.h,
                  ),
                SizedBox(width: 10.w),
                _buildVideoSettingItem(
                  GetBuilder<AiDynamicVideoController>(
                    id: "updateBgm",
                    tag: _uniqueKey,
                    builder: (AiDynamicVideoController controller) {
                      return GestureDetector(
                        onTap: () {
                          controller.showBgmDialog();
                        },
                        child: Container(
                          width: double.infinity,
                          height: 64.h,
                          padding: index == 1
                              ? EdgeInsetsDirectional.only(start: 12.w)
                              : EdgeInsetsDirectional.only(
                                  start: 16.w,
                                  end: 16.w,
                                ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFF),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.w),
                            ),
                            border: Border.all(
                              color: const Color(0xFFEAEEFF),
                              width: 1.w,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                controller.type == 0 &&
                                        controller.bgmTitle1.isNotEmpty == true
                                    ? controller.bgmTitle1
                                    : controller.type == 1 &&
                                          controller.bgmTitle2.isNotEmpty ==
                                              true
                                    ? controller.bgmTitle2
                                    : "音乐名称",
                                style: TextStyle(
                                  color: Color(0xFF0B1843),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Row(
                                children: [
                                  Text(
                                    "背景音乐",
                                    style: TextStyle(
                                      color: Color(0xFF0B1843).withOpacity(.8),
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  index == 1
                                      ? SizedBox(width: 4.w)
                                      : const Expanded(child: SizedBox()),
                                  Image.asset(
                                    "assets/ai/aiVideo/img_next1_icon.png",
                                    width: 12.w,
                                    height: 12.w,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  index: index ?? 0,
                  width: 95.w,
                ),
              ],
            ),
            index: index,
          ),
        ],
      ),
    );
  }

  Widget _buildScrollWidget(Widget child, {int? index}) {
    if (index == 1) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: child,
      );
    }
    return child;
  }

  /// 灵感输入
  Widget _imagineHintTextView({bool onlyInput = false, int? index}) {
    return GetBuilder<AiDynamicVideoController>(
      tag: _uniqueKey,
      builder: (controller) {
        late TextEditingController editingController;
        late FocusNode focusNode;
        if (controller.type == 0) {
          editingController = onlyInput == false
              ? controller.editingController1ForImageToVideo
              : controller.editingController2ForImageToVideo;
          focusNode = onlyInput == false
              ? controller.focusNode1ForImageToVideo
              : controller.focusNode2ForImageToVideo;
        } else {
          editingController = onlyInput == false
              ? controller.editingController1ForTextToVideo
              : controller.editingController2ForTextToVideo;
          focusNode = onlyInput == false
              ? controller.focusNode1ForTextToVideo
              : controller.focusNode2ForTextToVideo;
        }
        return Column(
          children: [
            SizedBox(height: 4.w),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(end: 12.w),
                      child: TextField(
                        textAlignVertical: TextAlignVertical.top,
                        maxLength: 200,
                        minLines: 1,
                        maxLines: null,
                        expands: false,
                        controller: editingController,
                        focusNode: focusNode,
                        autofocus: false,
                        scrollPadding: EdgeInsets.zero,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          isDense: true,
                          labelStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.normal,
                            color: ByColorUtil.CommonTextColor,
                          ),
                          hintText: "请描述想要生成的画面和动作。例如：一只海龟在海里游动。",
                          counterText: "",
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.normal,
                            overflow: TextOverflow.visible,
                            color: ByColorUtil.CommonTextColor.withOpacity(0.3),
                          ),
                        ),
                        cursorColor: ByColorUtil.CommonTextColor,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color(0XFF0B1843),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // if (Get.find<AiDynamicVideoController>(tag: _uniqueKey)
                  //         .type ==
                  //     1)
                  //   Obx(() {
                  //     bool show =
                  //         Get.find<AiDynamicVideoController>(tag: _uniqueKey)
                  //             .showDeepSeekNotice
                  //             .value;
                  //     return show == true
                  //         ? Row(
                  //             children: [
                  //               Text(
                  //                 "没有灵感？",
                  //                 style: TextStyle(
                  //                     color: const Color(0xFF0B1843)
                  //                         .withOpacity(.8)),
                  //               ),
                  //               GestureDetector(
                  //                 child: const Text(
                  //                   "【DeepSeek帮我写】",
                  //                   style: TextStyle(color: Color(0xFF5B4BF7)),
                  //                 ),
                  //                 onTap: () {
                  //                   controller.randomPrompt();
                  //                 },
                  //               ),
                  //             ],
                  //           )
                  //         : const SizedBox();
                  //   }),
                ],
              ),
            ),
            if (onlyInput != true)
              Row(
                children: [
                  _textNumberView(),
                  GestureDetector(
                    onTap: () {
                      controller.deletePrompts();
                    },
                    child: Container(
                      color: Colors.transparent,
                      padding: EdgeInsetsDirectional.only(
                        start: 7.w,
                        end: 10.w,
                      ),
                      child: Text(
                        "清空",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: ByColorUtil.CommonTextColor.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 26.w),
                  Obx(() {
                    bool showPrompts = Get.find<AiDynamicVideoController>(
                      tag: _uniqueKey,
                    ).showTextToVideoPrompts.value;
                    return Expanded(
                      child: Opacity(
                        opacity:
                            (Get.find<AiDynamicVideoController>(
                                      tag: _uniqueKey,
                                    ).type ==
                                    1 &&
                                showPrompts)
                            ? 1
                            : 0,
                        child: Row(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  GetBuilder<AiDynamicVideoController>(
                                    id: index == 1
                                        ? "promptsForText"
                                        : "promptsForImage",
                                    tag: _uniqueKey,
                                    builder: (AiDynamicVideoController controller) {
                                      return SizedBox(
                                        height: 24.h,
                                        child: NotificationListener<ScrollNotification>(
                                          onNotification:
                                              (
                                                ScrollNotification notification,
                                              ) {
                                                if (notification
                                                    is ScrollEndNotification) {
                                                  controller
                                                          .scrollingForTextToVideo
                                                          .value =
                                                      false;
                                                } else if (notification
                                                    is ScrollUpdateNotification) {
                                                  controller
                                                          .scrollingForTextToVideo
                                                          .value =
                                                      true;
                                                }
                                                return false;
                                              },
                                          child: ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, index) {
                                              Map<dynamic, dynamic> data = {};
                                              if (controller.type == 0) {
                                                if (controller
                                                        .currentMode
                                                        .value ==
                                                    0) {
                                                  data = controller
                                                      .prompts1[index];
                                                } else if (controller
                                                        .currentMode
                                                        .value ==
                                                    1) {
                                                  data = controller
                                                      .prompts3[index];
                                                } else if (controller
                                                        .currentMode
                                                        .value ==
                                                    2) {
                                                  data = controller
                                                      .prompts4[index];
                                                }
                                              } else {
                                                data =
                                                    controller.prompts2[index];
                                              }
                                              return GestureDetector(
                                                child: Container(
                                                  height: 24.h,
                                                  padding:
                                                      EdgeInsetsDirectional.only(
                                                        start: 10.w,
                                                        end: 10.w,
                                                      ),
                                                  alignment:
                                                      AlignmentDirectional
                                                          .center,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadiusDirectional.all(
                                                          Radius.circular(12.h),
                                                        ),
                                                    border: Border.all(
                                                      color: Color(0xFFEAEEFF),
                                                      width: 1.w,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    data['tag'],
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: const Color(
                                                        0xFF0B1843,
                                                      ).withOpacity(.8),
                                                      fontSize: 12.sp,
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  if ((Get.find<
                                                                AiDynamicVideoController
                                                              >(tag: _uniqueKey)
                                                              .type ==
                                                          1 &&
                                                      showPrompts)) {
                                                    _checkLogin(() {
                                                      Get.find<
                                                            AiDynamicVideoController
                                                          >(tag: _uniqueKey)
                                                          .addPrompts(
                                                            data['prompt'],
                                                          );
                                                    });
                                                  }
                                                },
                                              );
                                            },
                                            separatorBuilder:
                                                (
                                                  BuildContext context,
                                                  int index,
                                                ) {
                                                  return SizedBox(width: 4.w);
                                                },
                                            itemCount: controller.type == 0
                                                ? controller
                                                              .currentMode
                                                              .value ==
                                                          0
                                                      ? controller
                                                            .prompts1
                                                            .length
                                                      : controller
                                                                .currentMode
                                                                .value ==
                                                            1
                                                      ? controller
                                                            .prompts3
                                                            .length
                                                      : controller
                                                            .prompts4
                                                            .length
                                                : controller.prompts2.length,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  // 左侧渐变
                                  Positioned(
                                    left: 0,
                                    child: Obx(() {
                                      bool show =
                                          Get.find<AiDynamicVideoController>(
                                            tag: _uniqueKey,
                                          ).scrollingForTextToVideo.value;
                                      return show == true
                                          ? Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                width: 20.w,
                                                height: 24.h,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                    colors: [
                                                      const Color(
                                                        0xFFF9FAFF,
                                                      ).withOpacity(1),
                                                      const Color(
                                                        0xFFF9FAFF,
                                                      ).withOpacity(0),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const SizedBox();
                                    }),
                                  ),
                                  // 右侧渐变
                                  Positioned(
                                    right: 0,
                                    child: Obx(() {
                                      bool show =
                                          Get.find<AiDynamicVideoController>(
                                            tag: _uniqueKey,
                                          ).scrollingForTextToVideo.value;
                                      return show == true
                                          ? Align(
                                              alignment: Alignment.centerRight,
                                              child: Container(
                                                width: 20.w,
                                                height: 24.h,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin:
                                                        Alignment.centerRight,
                                                    end: Alignment.centerLeft,
                                                    colors: [
                                                      const Color(
                                                        0xFFF9FAFF,
                                                      ).withOpacity(1),
                                                      const Color(
                                                        0xFFF9FAFF,
                                                      ).withOpacity(0),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const SizedBox();
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            RefreshButtonWidget(
                              onTap: () {
                                if (controller.type == 0) {
                                  if (controller.currentMode.value == 2) {
                                    controller.loadPrompts(loadType: 4);
                                  } else if (controller.currentMode.value ==
                                      1) {
                                    controller.loadPrompts(loadType: 3);
                                  } else {
                                    controller.loadPrompts(loadType: 1);
                                  }
                                } else {
                                  controller.refreshPrompts(loadType: 2);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            SizedBox(height: 4.w),
          ],
        );
      },
    );
  }

  ///字数显示
  Widget _textNumberView() {
    return GetBuilder<AiDynamicVideoController>(
      id: 'promptsTextNumber',
      tag: _uniqueKey,
      builder: (controller) {
        int number = 0;
        if (controller.type == 0) {
          number = controller.promptsTextForImageToVideo.length;
        } else {
          number = controller.promptsTextForTextToVideo.length;
        }
        return Text(
          "${number}/200",
          style: TextStyle(
            fontSize: 12.sp,
            color: ByColorUtil.CommonTextColor.withOpacity(0.3),
          ),
        );
      },
    );
  }

  ///立即生成
  Widget _oneKeyBtn() {
    return Obx(() {
      bool isEnabled = Get.find<AiDynamicVideoController>(
        tag: _uniqueKey,
      ).allowRequest.value;
      return SizedBox(
        height: 50,
        child: FilledButton(
          onPressed: () {
            if (isEnabled == true) {
              _checkLogin(() {
                if (userController.user.value?.isVip == 1) {
                  Get.find<AiDynamicVideoController>(
                    tag: _uniqueKey,
                  ).generateVideo();
                } else {
                  // launchProvider.gotoPay(context, closePay: true);
                  launchProvider.showPayHalfDialog(
                    context,
                    "ai_text_to_video_v2",
                  );
                }
              });
            } else {
              ///主要是为了触发错误提示
              Get.find<AiDynamicVideoController>(
                tag: _uniqueKey,
              ).generateVideo();
            }
          },
          style: TextButton.styleFrom(
            backgroundColor: isEnabled
                ? const Color(0xFF5B4BF7)
                : const Color(0xFFB5B9C6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            "立即生成",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _getChildren1({required BuildContext context}) {
    return <Widget>[
      _buildTabView(context: context),
      _buildTabView(context: context, index: 1),
    ];
  }

  final ScrollController _scrollControllerForImage = ScrollController();

  final ScrollController _scrollControllerForText = ScrollController();

  bool calculateSuccessForText = false;

  bool calculateSuccessForImage = false;

  ///计算底部滑动距离
  void calculateBottomHeight(int index) {
    if (index == 1 && calculateSuccessForText == true) return;
    if (index == 0 && calculateSuccessForImage == true) return;
    double height = 0;
    try {
      ScrollController scrollController = index == 1
          ? _scrollControllerForText
          : _scrollControllerForImage;
      double maxScrollExtent = scrollController.position.maxScrollExtent;
      if (maxScrollExtent > 0) {
        if (maxScrollExtent >= 400.h) {
          height = max(0, (16.w + 10.h + 110.h) - (maxScrollExtent - (400.h)));
          if (widget.fromHome == true) {
            if (index == 0) {
              height -= 10.h;
            } else if (index == 1) {
              height += 10.h;
            }
          }
        } else {
          height =
              max((400.h - maxScrollExtent), 0) + (16.w + 10.h + 110.h) + 10.h;
        }
      }
    } catch (e) {
      ///异常了
      debugPrint("异常了");
    }
    debugPrint("height===>${height}");
    if (index == 1) {
      Get.find<AiDynamicVideoController>(
        tag: _uniqueKey,
      ).bottomHeightForText.value = height;
      calculateSuccessForText = true;
    } else {
      Get.find<AiDynamicVideoController>(
        tag: _uniqueKey,
      ).bottomHeightForImage.value = height;
      calculateSuccessForImage = true;
    }
  }

  Widget _buildTabView({required BuildContext context, int index = 0}) {
    return ListView(
      padding: EdgeInsets.zero,
      controller: index == 1
          ? _scrollControllerForText
          : _scrollControllerForImage,
      children: [
        _hotProductView(context: context, index: index),

        if (index == 0) _chooseModeWidget(context: context),
        _creativeDescriptionWidget(context: context, index: index),
        _videoSettingWidget(
          context: context,
          imageToView: index == 0,
          index: index,
        ),
        // _hiddenContentWidget(context: context),
        SizedBox(height: 10.h),
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(child: SizedBox()),
              Image.asset(
                "assets/ai/aiVideo/img_notices.png",
                width: 12.w,
                height: 12.w,
              ),
              SizedBox(width: 4.w),
              Text(
                "内容由AI生成，禁止利用功能从事违法活动。",
                style: TextStyle(
                  color: Color(0xFF111E48).withOpacity(.5),
                  fontSize: 12.sp,
                  height: 1,
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
        if (index == 0)
          Obx(() {
            AiDynamicVideoController controller =
                Get.find<AiDynamicVideoController>(tag: _uniqueKey);
            return SizedBox(height: controller.bottomHeightForImage.value);
          }),
        if (index == 1)
          Obx(() {
            AiDynamicVideoController controller =
                Get.find<AiDynamicVideoController>(tag: _uniqueKey);
            return SizedBox(height: controller.bottomHeightForText.value);
          }),
      ],
    );
  }

  LaunchProvider get launchProvider => Get.context!.read<LaunchProvider>();

  String? _uniqueKey;

  String getBase64RandomString(int length) {
    var random = Random.secure();
    var values = List.generate(length, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  @override
  void initState() {
    _uniqueKey = widget.uniqueKey ?? getBase64RandomString(20);
    AiDynamicVideoController controller = Get.put<AiDynamicVideoController>(
      AiDynamicVideoController(),
      tag: _uniqueKey,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initType == AiVideoGenerationType.textToVideo) {
        controller.switchType(1);
      }
      if (widget.prompt?.isNotEmpty == true) {
        controller.addPrompts(widget.prompt!);
      }
      if (controller.type == 0) {
        calculateBottomHeight(0);
      } else {
        calculateBottomHeight(0);
        Future.delayed(const Duration(milliseconds: 500), () {
          calculateBottomHeight(1);
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      hasAppBar: false,
      backgroundColor: const Color(0XFFF8FAFB),
      resizeToAvoidBottomInset: true,
      child: GestureDetector(
        onTap: () {
          Get.find<AiDynamicVideoController>(tag: _uniqueKey).cancelFocusNode();
        },
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 160.w,
                    child: Image.asset(
                      userController.isShowSpringStyle.value
                          ? "assets/springFestival/springFestival-3.png"
                          : "assets/ai/aiVideo/img_bg.png",
                      height: 160.w,
                      fit: BoxFit.fill,
                    ),
                  )),
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Column(
                      children: [
                        SizedBox(height: 52.h),
                        Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                children: [
                                  if (widget.fromHome == true)
                                    SizedBox(width: 12.w),
                                  if (widget.fromHome != true)
                                    SizedBox(width: 16.w),
                                  if (widget.fromHome != true)
                                    GestureDetector(
                                      child: const Icon(
                                        Icons.arrow_back_ios_new,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onTap: () {
                                        Get.back();
                                      },
                                    ),
                                  if (widget.fromHome == true &&
                                      userController.isShowSpringStyle.value == false)
                                    Image.asset(
                                      "assets/ai/aiVideo/img_ai_dynamic_video_icon.png",
                                      height: 28.h,
                                    ),
                                  const Expanded(child: SizedBox()),
                                  GetBuilder<AiDynamicVideoController>(
                                    id: "updateType",
                                    tag: _uniqueKey,
                                    builder: (controller) {
                                      int type = controller.type;
                                      return Stack(
                                        children: [
                                          Offstage(
                                            offstage: type == 1 ? true : false,
                                            child: const RightNavigationBar(
                                              entranceType: GuideEntranceType
                                                  .aiImageToVideo,
                                              hasMultipilePage: true,
                                            ),
                                          ),
                                          Offstage(
                                            offstage: type == 0 ? true : false,
                                            child: const RightNavigationBar(
                                              entranceType: GuideEntranceType
                                                  .aiTextToVideo,
                                              hasMultipilePage: true,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            if (widget.fromHome != true)
                              Positioned(
                                child: Text(
                                  "AI动态视频",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 18.h),
                        GetBuilder<AiDynamicVideoController>(
                          id: "updateTab",
                          tag: _uniqueKey,
                          builder: (AiDynamicVideoController controller) {
                            return SizedBox(
                              width: double.infinity,
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  Opacity(
                                    opacity: controller.type == 0 ? 1 : 0,
                                    child: Image.asset(
                                      "assets/ai/aiVideo/img_tab_left.png",
                                      fit: BoxFit.fitWidth,
                                      width: double.infinity,
                                    ),
                                  ),
                                  Opacity(
                                    opacity: controller.type == 1 ? 1 : 0,
                                    child: Image.asset(
                                      "assets/ai/aiVideo/img_tab_right.png",
                                      fit: BoxFit.fitWidth,
                                      width: double.infinity,
                                    ),
                                  ),
                                  Positioned(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            child: Container(
                                              color: Colors.transparent,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "图生视频",
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      color:
                                                          controller.type == 0
                                                          ? const Color(
                                                              0xFF5A4BF7,
                                                            )
                                                          : Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Opacity(
                                                    opacity:
                                                        controller.type == 0
                                                        ? 1
                                                        : 0,
                                                    child: SizedBox(
                                                      height: 8.h,
                                                    ),
                                                  ),
                                                  Opacity(
                                                    opacity:
                                                        controller.type == 0
                                                        ? 1
                                                        : 0,
                                                    child: Container(
                                                      width: 30.w,
                                                      height: 3.h,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xFF5A4BF7,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              1.5.h,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 8.h),
                                                ],
                                              ),
                                            ),
                                            onTap: () {
                                              controller.switchType(0);
                                              Future.delayed(
                                                const Duration(
                                                  milliseconds: 500,
                                                ),
                                                () {
                                                  calculateBottomHeight(0);
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            child: Container(
                                              color: Colors.transparent,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "文生视频",
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      color:
                                                          controller.type == 1
                                                          ? const Color(
                                                              0xFF5A4BF7,
                                                            )
                                                          : Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Opacity(
                                                    opacity:
                                                        controller.type == 1
                                                        ? 1
                                                        : 0,
                                                    child: SizedBox(
                                                      height: 8.h,
                                                    ),
                                                  ),
                                                  Opacity(
                                                    opacity:
                                                        controller.type == 1
                                                        ? 1
                                                        : 0,
                                                    child: Container(
                                                      width: 30.w,
                                                      height: 3.h,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xFF5A4BF7,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              1.5.h,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 8.h),
                                                ],
                                              ),
                                            ),
                                            onTap: () {
                                              controller.switchType(1);
                                              Future.delayed(
                                                const Duration(
                                                  milliseconds: 500,
                                                ),
                                                () {
                                                  calculateBottomHeight(1);
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.white,
                            child: PageView(
                              physics: const NeverScrollableScrollPhysics(),
                              controller: Get.find<AiDynamicVideoController>(
                                tag: _uniqueKey,
                              ).pageController,
                              children: _getChildren1(context: context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.15),
                    // color:Colors.red,
                    offset: Offset(0, 2.w),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: GetBuilder<AiDynamicVideoController>(
                id: "updateIntegralVipInfo",
                tag: _uniqueKey,
                builder: (AiDynamicVideoController controller) {
                  return Column(
                    children: [
                      SizedBox(height: 4.h),
                      IntegralVipView(
                        padding: EdgeInsetsDirectional.only(
                          start: 12.w,
                          end: 12.w,
                        ),
                        type: controller.equityType, // 通过这个type请求权益接口获取实际积分
                      ),
                    ],
                  );
                },
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 8.w),
              child: Row(
                children: [
                  if (userController.user.value?.isVip == 1)
                    SizedBox(
                      height: 50,
                      child: FilledButton(
                        onPressed: showRecords,
                        style: FilledButton.styleFrom(
                          foregroundColor: const Color(0xFF5B4BF7),
                          backgroundColor: const Color(0xFFEAEEFF),
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "创作记录",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (userController.user.value?.isVip == 1)
                    SizedBox(width: 12.w),
                  Expanded(child: _oneKeyBtn()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkLogin(VoidCallback voidCallback) {
    ByNavigatorUtil.checkLogin(
      context: context,
      nextStepEvent: () {
        voidCallback.call();
      },
    );
  }

  void showRecords() {
    ByNavRouterUtils.push(
      context,
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => AiVideoManagementProvider(),
          ),
        ],
        child: const AiVideoManagementPage(finishPage: true),
      ),
    ).then((value) {
      if (value is AiVideoGenerationTaskModel) {
        Get.find<AiDynamicVideoController>(tag: _uniqueKey).initData(value);
      }
    });
  }
}

///旋转360度动画
class RefreshButtonWidget extends StatefulWidget {
  final VoidCallback? onTap;

  const RefreshButtonWidget({super.key, this.onTap});

  @override
  State<StatefulWidget> createState() => RefreshButtonWidgetState();
}

class RefreshButtonWidgetState extends State<RefreshButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    if (_controller.isAnimating) return;
    _controller.forward(from: 0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        padding: EdgeInsetsDirectional.only(start: 4.w, end: 16.w),
        height: 24.h,
        color: Colors.transparent,
        child: Center(
          child: RotationTransition(
            turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
            child: Image.asset(
              "assets/ai/aiVideo/img_refresh_icon.png",
              width: 13.w,
              height: 13.w,
            ),
          ),
        ),
      ),
    );
  }
}
