import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';

EdgeInsets get safeAreaEdgeInsets => Get.mediaQuery.viewPadding;

double safeAreaTopDistance(double distance) =>
    safeAreaEdgeInsets.top + distance;

double safeAreaBottomDistance(double distance) =>
    safeAreaEdgeInsets.bottom + distance;

final theme = ThemeData(
  useMaterial3: false,
  primaryColor: ByColorUtil.WhiteColor,
  scaffoldBackgroundColor: ByColorUtil.WhiteColor,
  colorScheme: const ColorScheme.light(),
  appBarTheme: AppBarTheme(
    centerTitle: true,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness:
          (GetPlatform.isAndroid || (Platform.operatingSystem == 'ohos'))
              ? Brightness.dark
              : Brightness.light,
    ), // 设置状态栏颜
  ),
);
