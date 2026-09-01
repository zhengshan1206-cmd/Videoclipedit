import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';

extension BYFontWeight on FontWeight {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;
}

extension BYTextStyle on TextStyle {
  static TextStyle instance(
    double fontSize, {
    Color color = ByColorUtil.CommonTextColor,
    FontStyle? fontStyle,
    FontWeight fontWeight = BYFontWeight.regular,
    TextDecoration? decoration,
    double? height,
    double? letterSpacing,
    List<Shadow>? shadows,
  }) {
    return TextStyle(
      fontSize: fontSize,
      color: color,
      fontStyle: fontStyle,
      fontWeight: fontWeight,
      decoration: decoration,
      height: height,
      letterSpacing: letterSpacing,
      shadows: shadows,
    );
  }
}

extension BYText on Text {
  static Text instance(
    String text,
    double fontSize, {
    Color color = ByColorUtil.CommonTextColor,
    bool isTitle = false,
    FontStyle? fontStyle,
    FontWeight fontWeight = BYFontWeight.regular,
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
    double? height,
    double? letterSpacing,
    List<Shadow>? shadows,
    StrutStyle? strutStyle,
  }) {
    return Text(
      text,
      maxLines: maxLines,
      strutStyle: strutStyle,
      style: BYTextStyle.instance(
        fontSize,
        color: color,
        fontStyle: fontStyle,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        shadows: shadows,
      ),
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
