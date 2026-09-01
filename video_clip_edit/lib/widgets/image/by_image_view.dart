import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/widgets/common_button.dart';

class BYImageView extends StatelessWidget {
  BYImageView({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.alignment,
    this.needFadeIn = true,
    this.placeholderName = Assets.commonPlaceholder,
    this.onPress,
  });

  BYImageView.avatar({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.alignment,
    this.needFadeIn = true,
    this.onPress,
  }) {
    placeholderName = Assets.commonDefaultAvatar;
  }

  BYImageView.normal(
      {super.key,
      required this.imageUrl,
      required this.width,
      required this.height,
      this.fit = BoxFit.cover,
      this.alignment,
      this.needFadeIn = true,
      this.onPress,
      String? placeholderName})
      : placeholderName = placeholderName ?? Assets.commonPlaceholder;

  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final Alignment? alignment;
  late String placeholderName;

  final bool needFadeIn;

  final void Function(String? imageUrl)? onPress;

  /// 验证URL是否有效（必须包含协议和主机名）
  static bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
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

  @override
  Widget build(BuildContext context) {
    final placeholder = Image.asset(
      placeholderName,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
    final isValidUrl = _isValidUrl(imageUrl);
    final content = isValidUrl
        ? CachedNetworkImage(
            fadeInDuration:
                needFadeIn ? const Duration(milliseconds: 100) : Duration.zero,
            alignment: alignment ?? Alignment.center,
            width: width,
            height: height,
            fit: fit,
            imageUrl: imageUrl!,
            placeholder: (context, url) => placeholder,
            errorWidget: (context, url, error) => placeholder,
          )
        : placeholder;

    if (onPress != null) {
      final button = CommonButton(
        borderRadius: BorderRadius.zero,
        padding: EdgeInsets.zero,
        minSize: min(width, height),
        child: content,
        onPressed: () => onPress!(imageUrl),
      );

      if (isValidUrl) {
        return Hero(
          tag: imageUrl!,
          child: button,
        );
      } else {
        return button;
      }
    } else {
      return content;
    }
  }
}
