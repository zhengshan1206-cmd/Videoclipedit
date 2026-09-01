import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:image_editor/image_editor.dart';
import 'package:path_provider/path_provider.dart';

enum ImageAspectRatio {
  ratio9_16("9/16", 9 / 16),
  ratio16_9("16/9", 16 / 9),
  ratio3_4("3/4", 3 / 4),
  ratio4_3("4/3", 4 / 3),
  ratio1_1("1/1", 1.0);

  final String label;
  final double value;

  const ImageAspectRatio(this.label, this.value);

  static ImageAspectRatio? fromString(String input) {
    return ImageAspectRatio.values.firstWhere(
      (e) => e.label == input,
      orElse: () => throw ArgumentError("Invalid aspect ratio: $input"),
    );
  }

  @override
  String toString() => label;
}

class ImageEditController extends GetxController {
  ///图片路径
  String? _path;

  String get path => _path ?? "";

  ///当前剪切比例（字符串，当key用）
  RxString currentRatio = ImageAspectRatio.ratio9_16.label.obs;

  ///当前剪切比例（具体数值）
  double _imageRatio = 9 / 16;

  double get imageRatio => _imageRatio;

  final ImageEditorController _editorController = ImageEditorController();

  ///图片编辑Controller
  ImageEditorController get editorController => _editorController;

  void changeRatio(String label) {
    try {
      ImageAspectRatio? aspectRatio0 = ImageAspectRatio.fromString(label);
      if (aspectRatio0 != null) {
        currentRatio.value = aspectRatio0.label;
        _imageRatio = aspectRatio0.value;
        editorController.updateCropAspectRatio(imageRatio);
      }
    } catch (e) {
      ///
    }
  }

  ///图片剪切
  Future<String?> crop() async {
    // final EditActionDetails action = editorController.editActionDetails!;

    // final Uint8List img = editorController.state!.rawImageData;

    // final ImageEditorOption option = ImageEditorOption();

    // if (action.hasRotateDegrees) {
    //   final int rotateDegrees = action.rotateDegrees.toInt();
    //   option.addOption(RotateOption(rotateDegrees));
    // }
    // if (action.flipY) {
    //   option.addOption(const FlipOption(horizontal: true, vertical: false));
    // }

    // if (action.needCrop) {
    //   Rect cropRect = editorController.getCropRect()!;
    //   if (editorController.state!.widget.extendedImageState.imageProvider
    //       is ExtendedResizeImage) {
    //     final ImmutableBuffer buffer = await ImmutableBuffer.fromUint8List(img);
    //     final ImageDescriptor descriptor =
    //         await ImageDescriptor.encoded(buffer);

    //     final double widthRatio =
    //         descriptor.width / editorController.state!.image!.width;
    //     final double heightRatio =
    //         descriptor.height / editorController.state!.image!.height;
    //     cropRect = Rect.fromLTRB(
    //       cropRect.left * widthRatio,
    //       cropRect.top * heightRatio,
    //       cropRect.right * widthRatio,
    //       cropRect.bottom * heightRatio,
    //     );
    //   }
    //   option.addOption(ClipOption.fromRect(cropRect));
    // }

    // final DateTime start = DateTime.now();
    // final Uint8List? result = await ImageEditor.editImage(
    //   image: img,
    //   imageEditorOption: option,
    // );

    // // print('${DateTime.now().difference(start)} ：total time');
    // if (result != null) {
    //   String path = await saveImage(result);
    //   debugPrint("文件名称===>${path}");
    //   return path;
    // }
    return null;
  }

  ///保存图片到本地
  Future<String> saveImage(Uint8List imageBytes) async {
    try {
      // 获取应用的文档目录路径
      final directory = await getApplicationDocumentsDirectory();

      // 生成随机文件名
      final fileName = _generateRandomFileName(); // 生成唯一的文件名
      final filePath = '${directory.path}/$fileName';

      // 写入文件
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      debugPrint("图片保存成功: $filePath");
      return filePath;
    } catch (e) {
      debugPrint("图片保存失败: $e");
      return '';
    }
  }

  ///拼接文件名
  String _generateRandomFileName({String extension = 'png'}) {
    // 当前时间戳
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    // 生成6位随机字符串
    String randomString = List.generate(6, (index) {
      const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
      final random = Random();
      return chars[random.nextInt(chars.length)];
    }).join();

    // 拼接文件名
    return '${timestamp}_$randomString.$extension';
  }

  RxString initRatio = "".obs;

  @override
  void onInit() {
    super.onInit();
    Map<dynamic, dynamic> arguments = Get.arguments;
    try {
      _path = arguments['path'];
      String? aspectRatio = arguments['aspectRatio'];
      if (aspectRatio?.isNotEmpty == true) {
        ImageAspectRatio aspectRatio0 =
            ImageAspectRatio.fromString(aspectRatio!) ??
                ImageAspectRatio.ratio9_16;
        currentRatio.value = aspectRatio0.label;
        _imageRatio = aspectRatio0.value;
        editorController.updateCropAspectRatio(imageRatio);
        initRatio.value = aspectRatio0.label;
      } else {
        currentRatio.value = ImageAspectRatio.ratio9_16.label;
        _imageRatio = ImageAspectRatio.ratio9_16.value;
        editorController.updateCropAspectRatio(imageRatio);
      }
    } catch (e) {
      ///
      debugPrint("e===>${e}");
    }
  }
}
