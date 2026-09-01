import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/base/base_view.dart';
import 'package:video_clip_edit/modules/ai/ai_video/image_edit_controller.dart';

///图片裁剪页面
class ImageEditPage extends StatefulWidget {
  const ImageEditPage({super.key});

  @override
  State<StatefulWidget> createState() => ImageEditPageState();
}

class ImageEditPageState extends State<ImageEditPage> {
  /// 裁剪百分比，以9/16的形式传递
  String? ratio;

  ImageEditController? _imageEditorController;

  @override
  void initState() {
    _imageEditorController =
        Get.put<ImageEditController>(ImageEditController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
        hasAppBar: false,
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: true,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              SizedBox(
                height: 56.h,
              ),
              Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16.w,
                        ),
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
                      ],
                    ),
                  ),
                  Positioned(
                      child: Text(
                    "图片裁切",
                    style: TextStyle(color: Colors.white, fontSize: 18.sp),
                  )),
                ],
              ),
              SizedBox(
                height: 24.h,
              ),
              Obx(() {
                String initRatio =
                    Get.find<ImageEditController>().initRatio.value;
                return initRatio.isNotEmpty == true
                    ? Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.w),
                            color: Colors.white.withOpacity(.2)),
                        padding: EdgeInsetsDirectional.only(
                            start: 12.w, end: 12.w, top: 10.h, bottom: 10.h),
                        margin:
                            EdgeInsetsDirectional.only(start: 12.w, end: 12.w),
                        child: Row(
                          children: [
                            Text(
                              "根据第一张图的选择，后续图片仅支持${initRatio.replaceAll("\\", ":")}",
                              style: TextStyle(
                                  fontSize: 12.sp, color: Colors.white),
                            )
                          ],
                        ),
                      )
                    : Obx(() {
                        var currentRatioLabel =
                            Get.find<ImageEditController>().currentRatio.value;
                        return Row(
                          children: [
                            SizedBox(
                              width: 30.w,
                            ),
                            _buildCropRatio(
                                ImageAspectRatio.ratio9_16, currentRatioLabel),
                            const Expanded(child: SizedBox()),
                            _buildCropRatio(
                                ImageAspectRatio.ratio16_9, currentRatioLabel),
                            const Expanded(child: SizedBox()),
                            _buildCropRatio(
                                ImageAspectRatio.ratio3_4, currentRatioLabel),
                            const Expanded(child: SizedBox()),
                            _buildCropRatio(
                                ImageAspectRatio.ratio4_3, currentRatioLabel),
                            const Expanded(child: SizedBox()),
                            _buildCropRatio(
                                ImageAspectRatio.ratio1_1, currentRatioLabel),
                            SizedBox(
                              width: 30.w,
                            ),
                          ],
                        );
                      });
              }),
              SizedBox(
                height: 14.h,
              ),
              Expanded(
                  child: Container(
                margin: EdgeInsetsDirectional.only(start: 12.w, end: 12.w),
                width: double.infinity,
                child: ExtendedImage(
                  image: ExtendedFileImageProvider(
                    File(_imageEditorController?.path ?? ""),
                    cacheRawData: true,
                  ),
                  mode: ExtendedImageMode.editor,
                  fit: BoxFit.contain,
                  initEditorConfigHandler: (_) => EditorConfig(
                      maxScale: 8.0,
                      cropRectPadding: const EdgeInsets.all(0.0),
                      hitTestSize: 20.0,
                      initialCropAspectRatio:
                          _imageEditorController?.imageRatio ?? 9 / 16,
                      cropAspectRatio:
                          _imageEditorController?.imageRatio ?? 9 / 16,
                      cornerSize: const Size(25.0, 2.0),
                      lineHeight: 2,
                      cornerColor: Colors.white,
                      controller: _imageEditorController?.editorController,
                      editorMaskColorHandler:
                          (BuildContext context, bool pointerDown) {
                        return Colors.transparent;
                      }),
                ),
              )),
              SizedBox(
                height: 30.h,
              ),
              GestureDetector(
                child: Container(
                  margin: EdgeInsetsDirectional.only(start: 12.w, end: 12.w),
                  height: 48.h,
                  alignment: AlignmentDirectional.center,
                  decoration: BoxDecoration(
                      color: const Color(0xFF5B4BF7),
                      borderRadius: BorderRadius.all(Radius.circular(12.w))),
                  child: Text(
                    "确定",
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                ),
                onTap: () {
                  Get.find<ImageEditController>().crop().then((path) {
                    ///
                    Get.back(result: [
                      path,
                      Get.find<ImageEditController>().currentRatio.value
                    ]);
                  }).catchError((e) {
                    BotToast.showText(text: "剪切失败，请重试");
                  });
                },
              ),
              SizedBox(
                height: 14.h,
              ),
            ],
          ),
        ));
  }

  Widget _buildCropRatio(
      ImageAspectRatio imageAspectRatio, String currentLabel) {
    return GestureDetector(
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: Center(
                child: AspectRatio(
                  aspectRatio: imageAspectRatio.value,
                  child: Container(
                    height: 24.w,
                    width: 24.h,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        border: Border.all(
                            color: imageAspectRatio.label == currentLabel
                                ? Colors.white
                                : const Color(0xFF808080),
                            width: 2.w)),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 4.h,
            ),
            Text(
              imageAspectRatio.label.replaceAll("/", ":"),
              style: TextStyle(
                  color: imageAspectRatio.label == currentLabel
                      ? Colors.white
                      : const Color(0xFF808080)),
            )
          ],
        ),
      ),
      onTap: () {
        Get.find<ImageEditController>().changeRatio(imageAspectRatio.label);
      },
    );
  }
}
