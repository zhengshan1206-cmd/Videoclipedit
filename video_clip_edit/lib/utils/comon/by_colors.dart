// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ByColorUtil {
  static const MainTextColor = Color(0xFF000000);
  static const TabTextColorSelected = Color(0xFF5B4BF7);
  static const TabTextColorMarquee = Color(0xFFEA3B75);
  static const HomeHotAuthTitleBg = Color(0xFFDBE4FF);
  static const HomeHotAuthNumberColor = Color(0xFFFF1034);
  static const HomeHotAuthIncomeColor = Color(0xFFFF8C39);
  static const HomeHotAuthBtnBgColor = Color(0xFFFFCC3B);
  static const HomeHotAuthRankGradientColorStart = Color(0xFFFF3838);
  static const HomeHotAuthRankGradientColorEnd = Color(0xFFFF3EAB);
  static const LoginTextfieldTextColor = Color(0xFF101E48);
  static const LoginBtnBgColor = Color(0xFF5B4BF7);
  static const CommonPageBgColor = Color(0xFFF8FAFB);
  static const CommonTextColor = Color(0xFF0B1843);
  static const BandedWordsColor = Color(0xFFF62B60);

  static const WhiteColor = Color(0xFFFFFFFF);
  static const BlackColor = Color(0xFF000000);
  static const CommonInputBgColor = Color(0xFFF3F3F5);
  static const PurchaseBorderColor = Color(0xFFFFE8B6);
  static const PurchaseTagNewBgColor = Color(0xFFFF3B4F);
  static const PurchaseDialogTimeBgColor = Color(0xFFF4593F);
  static const PurchasePriceTextColor = Color(0xFF805008);
  static const PurchasePriceDescColor = Color(0xFF7A4502);

  static const color121634 = Color(0xff121634);
  static const colorF8FAFB = Color(0xffF8FAFB);

  static const color202026 = Color(0xff202026);

  static const color4E4C4B = Color(0xff4E4C4B);

  static const colorFAE3C8 = Color(0xffFAE3C8);

  static const colorFFCB86 = Color(0xffFFCB86);

  static const colorFFEEDA = Color(0xffFFEEDA);

  static const color131420 = Color(0xff131420);

  static const colorF4F7F8 = Color(0xffF4F7F8);

  static const colorF3F5F9 = Color(0xffF3F5F9);

  static const colorEAEEFF = Color(0xffEAEEFF);

  static const color4A1F00 = Color(0xff4A1F00);

  static const colorFF8902 = Color(0xffFF8902);

  static const color67441E = Color(0xff67441E);

  static const color0B1843 = Color(0xff0B1843);

  static const colorF0F2F9 = Color(0xffF0F2F9);

  static const colorF9FAFF = Color(0xffF9FAFF);

  static const colorF4F6FF = Color(0xffF4F6FF);

  static const color81899F = Color(0xff81899F);

  static const colorF4F8F9 = Color(0xffF4F8F9);

  static const color3753FF = Color(0xff3753FF);

  static const colorFBFCFD = Color(0xffFBFCFD);

  static Color hexToColor(String hex) {
    hex = hex.replaceAll("#", ""); // 去掉 #
    if (hex.length == 6) {
      hex = "FF$hex"; // 如果没有透明度，默认添加 FF 作为透明度
    }
    return Color(int.parse("0x$hex"));
  }

  static Color hexaToColor(String hex) {
    hex = hex.replaceAll("#", ""); // 去掉 #
    if (hex.length == 6) {
      hex = "FF${hex}"; // 如果没有透明度，默认添加 FF 作为透明度
    } else {
      hex = "${hex.substring(6)}${hex.substring(0, 6)}";
    }
    return Color(int.parse("0x$hex"));
  }

  /// 线性渐变装饰器
  static LinearGradient lineareGradient({
    required Color colorStart,
    required Color colorEnd,
    Alignment begin = Alignment.bottomRight,
    Alignment end = Alignment.topLeft,
  }) =>
      LinearGradient(
        colors: [
          colorStart,
          colorEnd,
        ],
        begin: begin,
        end: end,
      );

  /// 线性渐变装饰器
  static LinearGradient lineareGradientMultiple({
    List<Color>? colors,
    List<double>? stops,
    Alignment begin = Alignment.bottomRight,
    Alignment end = Alignment.topLeft,
  }) =>
      LinearGradient(
        colors: colors ??
            [
              const Color(0xFF4BB1FF),
              const Color(0xFFE6F1FC),
              const Color(0xFFFBB1FF),
            ],
        stops: stops ?? [0, 0.5, 1],
        begin: begin,
        end: end,
      );

  /// 线性渐变装饰器
  static LinearGradient lineareGradientMultipleWithColorsString({
    required String colorsString,
    Alignment begin = Alignment.bottomRight,
    Alignment end = Alignment.topLeft,
  }) {
    final colorsStr = colorsString.split(",");
    final colors = colorsStr.map((e) => ByColorUtil.hexToColor(e)).toList();
    final step = 1 / (colors.length - 1);
    final List<double> stops = colors.map((e) {
      return step * (colors.indexOf(e));
    }).toList();
    return LinearGradient(
      colors: colors,
      stops: stops,
      begin: begin,
      end: end,
    );
  }

  /// 线性渐变装饰器
  static LinearGradient lineareGradientMultipleWithHexaColorsString({
    required String colorsString,
    Alignment begin = Alignment.bottomRight,
    Alignment end = Alignment.topLeft,
  }) {
    final colorsStr = colorsString.split(",");
    final colors = colorsStr.map((e) => ByColorUtil.hexaToColor(e)).toList();
    final step = 1 / (colors.length - 1);
    final List<double> stops = colors.map((e) {
      return step * (colors.indexOf(e));
    }).toList();
    return LinearGradient(
      colors: colors,
      stops: stops,
      begin: begin,
      end: end,
    );
  }
}
