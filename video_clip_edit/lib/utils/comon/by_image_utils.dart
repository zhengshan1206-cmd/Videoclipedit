// ignore: dangling_library_doc_comments
///  description:  图片加载工具类
// ignore_for_file: unused_import
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

enum ImageFormat { png, jpg, jpeg, gif, webp }

/// 使用：_methodValues[ImageFormat.png]
const _methodValues = {
  ImageFormat.png: 'png',
  ImageFormat.jpg: 'jpg',
  ImageFormat.jpeg: 'jpeg',
  ImageFormat.gif: 'gif',
  ImageFormat.webp: 'webp',
};

class ByImageUtils {
  /// 加载本地图片
  /// image: ByImageUtils.getAssetImage('set')
  ///
  /// image: AssetImage('assets/images/set.png')
  /// widget: Image.asset('assets/images/set.png', fit: BoxFit.cover, width: 50, height: 50.0),
  static ImageProvider getAssetImage(String name,
      {ImageFormat format = ImageFormat.png}) {
    //    print('路径-- '+ getImgPath(name, format: format));
    return AssetImage(getImgPath(name, format: format));
  }

  /// 获取图片路径
  static String getImgPath(String name,
      {ImageFormat format = ImageFormat.png}) {
    return 'assets/images/$name.${_methodValues[format]}';
//    return 'images/$name.$format';
  }

  /// 验证URL是否有效（必须包含协议和主机名）
  static bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      // 确保URL包含协议（http/https）和主机名
      return uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.hasAuthority &&
          uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 加载本地或者URL图片
  static ImageProvider loadImage(String imageUrl,
      {String placeholder = 'ic_placeholder'}) {
    if (imageUrl.isEmpty || !_isValidUrl(imageUrl)) {
      return AssetImage(getImgPath(placeholder));
    }
    return CachedNetworkImageProvider(imageUrl,
        errorListener: (error) => print('图片加载失败！$error'));
  }
}

/// 加载本地图片
/// ByAssetImage('account/${_bankLogoList[index]}',width: 24.0)
class ByAssetImage extends StatelessWidget {
  const ByAssetImage(
    this.image, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.format = ImageFormat.png,
    this.color,
    this.cacheWidth,
    this.cacheHeight,
  });

  final String image; // 本地图片路径（assets/images/ 路径下的图片路径，不带后缀）
  final double? width;
  final double? height;
  final BoxFit? fit;
  final ImageFormat format;
  final Color? color;
  final int? cacheWidth;
  final int? cacheHeight;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      ByImageUtils.getImgPath(image, format: format),
      height: height,
      width: width,
      fit: fit,
      color: color,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      // 忽略图片语义
      excludeFromSemantics: true,
    );
  }
}
