/*
 * @Author: cold-x
 * @Date: 2025-05-08 20:05:05
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-05-08 20:05:50
 * @FilePath: /video_clip_edit/lib/utils/comon/by_color_utils.dart
 * @Description: 
 */
import 'dart:math';
import 'package:flutter/material.dart';

class ByColorUtils {
  /// 十六进制颜色设置
  /// hex, 十六进制值，例如：0xffffff,
  /// alpha, 透明度 [0.0,1.0]
  /// 用法：ByColorUtils.hexAColor(0x3caafa); | ByColorUtils.hexAColor(0x3caafa,alpha: 0.5);
  static Color hexAColor(int hex, {double alpha = 1}) {
    if (alpha < 0) {
      alpha = 0;
    } else if (alpha > 1) {
      alpha = 1;
    }
    return Color.fromRGBO((hex & 0xFF0000) >> 16, (hex & 0x00FF00) >> 8,
        (hex & 0x0000FF) >> 0, alpha);
  }

  /// hex颜色设置
  static Color hexColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static Color hexAlphaColor(String hex, String alpha) {
    hex = hex.replaceAll("#", ""); // 去掉 #
    if (hex.length == 6) {
      hex = "$alpha$hex";
    }
    return Color(int.parse("0x$hex"));
  }

  /// 创建Material风格的color
  static MaterialColor materialColor(Color color) {
    List strengths = <double>[.05];
    Map swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch as Map<int, Color>);
  }

  /// 取随机颜色
  static Color randomColor() {
    var red = Random.secure().nextInt(255);
    var greed = Random.secure().nextInt(255);
    var blue = Random.secure().nextInt(255);
    return Color.fromARGB(255, red, greed, blue);
  }

  /// 设置动态颜色
  static Color dynamicColor(BuildContext context, Color lightColor,
      [Color? darkColor]) {
    var isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkColor ?? lightColor : lightColor;
  }
}
