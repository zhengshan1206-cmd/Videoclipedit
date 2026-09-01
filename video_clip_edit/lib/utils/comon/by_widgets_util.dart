import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/main.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_dialog_util.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/profile/widgets/no_data_view.dart';
import 'package:video_clip_edit/widgets/common_button.dart';

class ByWidgetsUtil {
  static PreferredSize appBarBottom() {
    return PreferredSize(
      preferredSize: Size.fromHeight(1.h), // 分割线的高度
      child: Container(
        color: ByColorUtil.CommonPageBgColor, // 分割线的颜色
        height: 1.h, // 分割线的高度
      ),
    );
  }

  /// 高斯模糊
  static Widget gaussianBlur({
    required Widget child,
    double? sigmaX,
    double? sigmaY,
  }) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: sigmaX ?? 3,
        sigmaY: sigmaY ?? 3,
      ),
      child: child,
    );
  }

  static closeBtnForGuid({
    BuildContext? context,
    required void Function() onTap,
  }) {
    return Positioned(
      left: 10.w,
      top: ByScreenUtils.topSafeHeight + (56.h - 36.h) * 0.5,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context ?? navigatorKey.currentContext!).unfocus();
          onTap.call();
        },
        child: SizedBox(
          height: 36.h,
          width: 80.w,
          child: ByWidgetsUtil.commonContainer(
            alignment: Alignment.center,
            child: ByWidgetsUtil.commonText(
              text: "关闭提示",
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }

  /// 通用 appbar 组件
  static AppBar customAppBar({
    required BuildContext context,
    required Widget title,
    Widget? leaing,
    void Function()? onPop,
    bool popScop = false,
    bool showBottmLine = true,
    String? contents,
    String? popScopTitle,
    String? popScopConfirmBtnTitle,
    Function? popScopConfirmCallback,
    String? popScopCancelBtnTitle,
    Function? popScopCancelCallback,
    bool popScopeExt = true,
    List<Widget>? actions,
    Color? backgroundColor,
  }) {
    return AppBar(
      bottom: showBottmLine ? appBarBottom() : null,
      leading: leaing ??
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              FocusScope.of(context).unfocus();
              EasyLoading.dismiss();
              if (popScop) {
                final navigator = Navigator.of(context);
                final canPop = await ByDialogUtil.showPopScopeDialog(
                      context: context,
                      contents: contents,
                      title: popScopTitle,
                      confirmBtnTitle: popScopConfirmBtnTitle,
                      confirmCallback: popScopConfirmCallback,
                      cancelBtnTitle: popScopCancelBtnTitle,
                      cancelCallback: popScopCancelCallback,
                    ) ??
                    false;
                if (canPop) {
                  /// 执行返回前的操作
                  onPop?.call();
                  EasyLoading.dismiss();
                  if (popScopeExt) {
                    navigator.pop();
                  }
                }
                return;
              }

              if (onPop != null) {
                onPop();
                return;
              }
              ByNavRouterUtils.goBack(context);
            },
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              child: Image.asset(
                "assets/home/icon_back.png",
                width: 16,
                height: 16,
              ),
            ),
          ),
      title: title,
      backgroundColor: backgroundColor ?? ByColorUtil.WhiteColor,
      actions: actions,
    );
  }

  /// 通用 appbar 组件
  static AppBar appBar({
    required BuildContext context,
    required String title,
    Widget? leaing,
    void Function()? onPop,
    bool popScop = false,
    bool showBottmLine = true,
    String? contents,
    String? popScopTitle,
    String? popScopConfirmBtnTitle,
    Function? popScopConfirmCallback,
    String? popScopCancelBtnTitle,
    Function? popScopCancelCallback,
    bool popScopeExt = true,
    List<Widget>? actions,
    Color? backgroundColor,
  }) {
    return AppBar(
      bottom: showBottmLine ? appBarBottom() : null,
      elevation: 0.1,
      leading: leaing ??
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              FocusScope.of(context).unfocus();
              EasyLoading.dismiss();
              if (popScop) {
                final navigator = Navigator.of(context);
                final canPop = await ByDialogUtil.showPopScopeDialog(
                      context: context,
                      contents: contents,
                      title: popScopTitle,
                      confirmBtnTitle: popScopConfirmBtnTitle,
                      confirmCallback: popScopConfirmCallback,
                      cancelBtnTitle: popScopCancelBtnTitle,
                      cancelCallback: popScopCancelCallback,
                    ) ??
                    false;
                if (canPop) {
                  /// 执行返回前的操作
                  onPop?.call();
                  EasyLoading.dismiss();
                  if (popScopeExt) {
                    navigator.pop();
                  }
                }
                return;
              }

              if (onPop != null) {
                onPop();
                return;
              }
              ByNavRouterUtils.goBack(context);
            },
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              child: Image.asset(
                "assets/home/icon_back.png",
                width: 16,
                height: 16,
              ),
            ),
          ),
      title: Text(
        title,
        style: const TextStyle(
          color: ByColorUtil.CommonTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      backgroundColor: backgroundColor ?? ByColorUtil.WhiteColor,
      actions: actions,
    );
  }

  static Widget activityIndicator({
    double? radius,
    Color? color,
    bool isNormal = true,
  }) {
    if (isNormal) {
      return Center(
        child: CupertinoActivityIndicator(
          radius: radius ?? 12.w,
          color: color ?? ByColorUtil.TabTextColorSelected,
        ),
      );
    }
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Color(0xFF5B4BF7),
        strokeCap: StrokeCap.round,
      ),
      // child: CupertinoActivityIndicator(
      //   radius: radius ?? 12.w,
      //   color: color ?? ByColorUtil.TabTextColorSelected,
      // ),
    );
  }

  static Widget fadedSpin({Color? color, double? size}) {
    return SpinKitFadingCircle(
      color: color ?? ByColorUtil.WhiteColor,
      size: size ?? 30.w,
    );
  }

  static futuerBuilderWidget<T>({
    Widget? errorWidget,
    Widget? waitingWidget,
    required Future<T>? future,
    required Widget Function(BuildContext ctx, T? data) builder,
  }) {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          /// 等待时显示的加载指示器
          return waitingWidget ??
              CircularProgressIndicator(
                color: ByColorUtil.TabTextColorSelected,
                strokeWidth: 15.w,
              );
        } else if (snapshot.hasError) {
          /// 错误时显示的内容
          return errorWidget ?? Text("Error: ${snapshot.error}");
        } else {
          return builder(context, snapshot.data);
        }
      },
      future: future,
    );
  }

  static Positioned positionedFillTextArea(
    BuildContext context,
    TextEditingController controller, {
    EdgeInsetsGeometry? padding,
    String? hintText,
    double? fontSize,
  }) {
    return Positioned.fill(
      child: Padding(
        padding:
            padding ?? EdgeInsets.symmetric(horizontal: 12.w, vertical: 0.h),
        child: TextField(
          maxLines: null,
          expands: false,
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelStyle: TextStyle(
              fontSize: fontSize ?? 14.sp,
              color: ByColorUtil.CommonTextColor,
            ),
            hintText: hintText ?? "请输入文字内容...",
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: ByColorUtil.CommonTextColor.withOpacity(0.5),
            ),
          ),
          cursorColor: ByColorUtil.CommonTextColor,
          // cursorHeight: 15.sp,
        ),
      ),
    );
  }

  /// 通用图片按钮组件
  static GestureDetector imageBtn({
    required String image,
    required double width,
    required double height,
    required double imageWidth,
    required double imageHeight,
    required void Function() onClick,
    Color? bgColor,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onClick(),
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: bgColor ?? ByColorUtil.LoginBtnBgColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(6.w)),
        child: Image.asset(
          image,
          width: imageWidth,
          height: imageHeight,
        ),
      ),
    );
  }

  static Widget commonContainer({
    Color? bgColor,
    double? borerRadius,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    AlignmentGeometry? alignment,
    required Widget child,
    double? width,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        boxShadow: boxShadow,
        color: bgColor ?? ByColorUtil.WhiteColor,
        borderRadius: BorderRadius.circular(borerRadius ?? 12.w),
        border: border,
      ),
      padding: padding,
      margin: margin,
      alignment: alignment,
      child: child,
    );
  }

  /// 通用按钮组件
  static GestureDetector btnWithIcon({
    BuildContext? context,
    required String title,
    required String iconPath,
    required void Function() onClick,
    TextDirection? textDirection,
    double? iconW,
    double? iconH,
    double? height,
    double? fontSize,
    Color? iconColor,
    double? borderRadius,
    double? contentGap,
    FontWeight? fontWeight,
    EdgeInsetsGeometry? padding,
    Color? textColor = ByColorUtil.WhiteColor,
    Color? bgColor = ByColorUtil.LoginBtnBgColor,
    BoxDecoration? boxDecoration,
  }) {
    boxDecoration ??= BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius ?? 8.w),
      color: bgColor,
    );
    final netorkIcon = iconPath.startsWith("http");
    return GestureDetector(
      onTap: () {
        FocusScope.of(context ?? navigatorKey.currentContext!).unfocus();
        onClick();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: height ?? 50.h,
        alignment: Alignment.center,
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
        decoration: boxDecoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: textDirection,
          children: [
            if (iconPath.isNotEmpty)
              netorkIcon
                  ? CachedNetworkImage(
                      imageUrl: iconPath,
                      fit: BoxFit.contain,
                      width: iconW ?? 18.w,
                      height: iconH ?? 18.w,
                    )
                  : Image.asset(
                      iconPath,
                      fit: BoxFit.contain,
                      width: iconW ?? 18.w,
                      height: iconH ?? 18.w,
                      color: iconColor,
                    ),
            if (iconPath.isNotEmpty) SizedBox(width: contentGap ?? 7.w),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize ?? 12.sp,
                fontWeight: fontWeight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 通用按钮组件
  static GestureDetector btnWithSvgIcon({
    BuildContext? context,
    required String title,
    required String iconPath,
    required void Function() onClick,
    TextDirection? textDirection,
    double? iconW,
    double? iconH,
    double? fontSize,
    double? borderRadius,
    double? contentGap,
    FontWeight? fontWeight,
    EdgeInsetsGeometry? padding,
    Color? textColor = ByColorUtil.WhiteColor,
    Color? bgColor = ByColorUtil.LoginBtnBgColor,
    BoxDecoration? boxDecoration,
  }) {
    boxDecoration ??= BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius ?? 8.w),
      color: bgColor,
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context ?? navigatorKey.currentContext!).unfocus();
        onClick();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 50.h,
        alignment: Alignment.center,
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
        decoration: boxDecoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: textDirection,
          children: [
            ByWidgetsUtil.svgAsset(
              filePath: iconPath,
              width: iconW ?? 18.w,
              height: iconH ?? 18.w,
            ),
            SizedBox(width: contentGap ?? 7.w),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize ?? 12.sp,
                fontWeight: fontWeight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget svgAsset({
    required String filePath,
    required double width,
    required double height,
    BoxFit fit = BoxFit.contain,
  }) {
    return SvgPicture.asset(
      filePath,
      width: width,
      height: height,
      fit: fit,
    );
  }

  /// 通用按钮组件
  static GestureDetector commonBtn({
    BuildContext? context,
    required String title,
    required void Function() onClick,
    EdgeInsetsGeometry? padding,
    FontWeight? fontWeight,
    Color? textColor = ByColorUtil.WhiteColor,
    Color? bgColor = ByColorUtil.LoginBtnBgColor,
    double? borderRadius,
    double? fontSize,
    Color? borderColor,
    double? borderWidth,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context ?? navigatorKey.currentContext!).unfocus();
        onClick();
      },
      child: Container(
        alignment: Alignment.center,
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          color: bgColor,
          border: borderColor == null
              ? null
              : Border.all(
                  color: borderColor,
                  width: borderWidth ?? 1,
                ),
        ),
        child: Text(
          title,
          style: TextStyle(
              color: textColor,
              fontSize: fontSize ?? 12.sp,
              fontWeight: fontWeight ?? FontWeight.bold),
        ),
      ),
    );
  }

  /// 通用按钮组件
  static GestureDetector commonBtnWithRichText({
    BuildContext? context,
    required Widget title,
    required void Function() onClick,
    EdgeInsetsGeometry? padding,
    FontWeight? fontWeight,
    Color? bgColor = ByColorUtil.LoginBtnBgColor,
    double? borderRadius,
    Color? borderColor,
    double? borderWidth,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context ?? navigatorKey.currentContext!).unfocus();
        onClick();
      },
      child: Container(
        alignment: Alignment.center,
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          color: bgColor,
          border: borderColor == null
              ? null
              : Border.all(
                  color: borderColor,
                  width: borderWidth ?? 1,
                ),
        ),
        child: title,
      ),
    );
  }

  /// 通用按钮组件
  static GestureDetector gradientBtn({
    BuildContext? context,
    required String title,
    required void Function() onClick,
    EdgeInsetsGeometry? padding,
    Color? textColor = ByColorUtil.WhiteColor,
    Gradient? gradient,
    double? fontSize,
    FontWeight? fontWeight,
    double? borderRadius,
    BorderRadiusGeometry? csutomerBorderRadius,
  }) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context ?? navigatorKey.currentContext!).unfocus();
        onClick();
      },
      child: Container(
        alignment: Alignment.center,
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
        decoration: BoxDecoration(
          borderRadius:
              csutomerBorderRadius ?? BorderRadius.circular(borderRadius ?? 8),
          gradient: gradient,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize ?? 12.sp,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }

  static Widget physicalModel({
    Color color = Colors.black,
    double elevation = 10,
    required Widget child,
  }) {
    return PhysicalModel(
      color: color,
      elevation: elevation,
      child: child,
    );
  }

  /// 通用Text组件
  static Text commonText({
    String? fontFamily,
    required String text,
    double? fontSize,
    FontWeight? fontWeight = FontWeight.normal,
    TextAlign? textAlign,
    Color? textColor,
    int? maxLines,
    TextDecoration? decoration,
    Color? decorationColor,
    double? height,
    double? decorationThickness,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines ?? 1,
      overflow: TextOverflow.ellipsis,
      // textHeightBehavior: const TextHeightBehavior(
      //   applyHeightToFirstAscent: true,
      //   applyHeightToLastDescent: false,
      // ),
      style: TextStyle(
        height: height,
        fontWeight: fontWeight,
        fontFamily: fontFamily,
        fontSize: fontSize ?? 14.sp,
        decoration: decoration ?? TextDecoration.none,
        decorationThickness: decorationThickness,
        color: textColor ?? ByColorUtil.CommonTextColor,
        decorationColor:
            decorationColor ?? ByColorUtil.WhiteColor.withOpacity(0.5),
      ),
    );
  }

  /// 通用Text组件
  static RichText commonRichText({
    String? fontFamily,
    required List<InlineSpan> texts,
    double? height,
    double? fontSize,
    FontWeight? fontWeight = FontWeight.normal,
    Color? textColor,
    TextDecoration? decoration,
  }) {
    return RichText(
      text: TextSpan(
        text: "",
        children: texts,
        style: TextStyle(
          fontWeight: fontWeight,
          fontFamily: fontFamily,
          height: height,
          fontSize: fontSize ?? 14.sp,
          decoration: decoration ?? TextDecoration.none,
          color: textColor ?? ByColorUtil.CommonTextColor,
        ),
      ),
    );
  }

  static Widget outlinedBtn({
    Color? textColor,
    double? fontSize,
    Color? borderColor,
    double? borderRadius,
    BuildContext? context,
    required String title,
    EdgeInsetsGeometry? padding,
    required void Function() onClick,
    Color? bgColor = ByColorUtil.WhiteColor,
    FontWeight? fontWeight = FontWeight.normal,
  }) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context ?? navigatorKey.currentContext!).unfocus();
        onClick();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding:
            padding ?? EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: borderColor ?? textColor ?? ByColorUtil.LoginBtnBgColor,
          ),
          borderRadius: BorderRadius.circular(borderRadius ?? 8.w),
        ),
        child: ByWidgetsUtil.commonText(
          text: title,
          fontSize: fontSize,
          fontWeight: fontWeight,
          textColor: textColor ?? ByColorUtil.LoginBtnBgColor,
        ),
      ),
    );
  }

  /// 通用提示组件
  static Widget commonTipsBar(
    String tips, {
    EdgeInsetsGeometry? padding,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    double? borderRadius,
  }) {
    return Container(
      padding:
          padding ?? EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 8.w),
        color: const Color(0xFF2E54FF).withOpacity(0.1),
      ),
      child: Row(
        mainAxisSize: mainAxisSize,
        children: [
          Image.asset(
            "assets/mine/icon_info.png",
            width: 12.w,
            height: 12.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 5.w),
          Expanded(
            child: ByWidgetsUtil.commonText(
              text: tips,
              maxLines: 100,
              fontSize: 12.sp,
              textColor: const Color(0xFF5A4BF7),
            ),
          ),
        ],
      ),
    );
  }

  static Widget generatingBtn({
    String title = "正在创作中",
  }) {
    return CommonButton(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      minSize: 24.h,
      borderRadius: BorderRadius.circular(6.h),
      spacing: 6.w,
      suffixDirectional: SuffixDirectional.right,
      suffixWidget: ByWidgetsUtil.activityIndicator(radius: 8.w),
      color: ByColorUtil.color3753FF.withOpacity(0.1),
      child: BYText.instance(title, 12.sp, color: ByColorUtil.LoginBtnBgColor),
    );
  }

  /// 通用提示组件
  static Widget commonTipsBar2({
    required String tips,
    required String title,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.w),
        color: const Color(0xFF2E54FF).withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                "assets/mine/icon_info.png",
                width: 12.w,
                height: 12.w,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 5.w),
              Expanded(
                child: ByWidgetsUtil.commonText(
                  text: title,
                  maxLines: 100,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  textColor: const Color(0xFF5A4BF7),
                ),
              ),
            ],
          ),
          ByWidgetsUtil.commonText(
            text: tips,
            maxLines: 100,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            textColor: const Color(0xFF5A4BF7),
          )
        ],
      ),
    );
  }

  /// 通用富文本提示组件
  static Widget commonRichTextTipsBar({
    required List<InlineSpan> textSpans,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.w),
        color: const Color(0xFF2E54FF).withOpacity(0.1),
      ),
      child: Row(
        children: [
          Image.asset(
            "assets/mine/icon_info.png",
            width: 12.w,
            height: 12.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 5.w),
          // ByWidgetsUtil.commonText(
          //   text: tips,
          //   fontSize: 12.sp,
          //   textColor: const Color(0xFF5A4BF7),
          // ),
          RichText(
            text: TextSpan(
              children: textSpans,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF5A4BF7),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// 渐变背景容器
  static Widget gradientBgContainer({
    required Gradient? gradient,
    double? borderRadius,
    AlignmentGeometry? alignment,
    EdgeInsetsGeometry? padding,
    BoxBorder? border,
    required Widget child,
  }) =>
      Container(
        alignment: alignment ?? Alignment.center,
        padding: padding ?? EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 12.w)),
          gradient: gradient ??
              const LinearGradient(
                colors: [Color(0xFF5C4CF7), Color(0xFF7E71FE)],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
          border: border,
        ),
        child: child,
      );

  /// 渐变背景容器

  static richTextThree({
    String? fontFamily,
    FontWeight? fontWeight,
    String partPre = "¥",
    required Color textColorPre,
    double? fontSizePre,
    required String partMiddle,
    required Color textColorMiddle,
    double? fontSizeMiddle,
    required String partTail,
    required Color textColorTail,
    double? fontSizeTail,
  }) {
    return RichText(
      text: TextSpan(
          text: partPre,
          style: TextStyle(
            fontFamily: fontFamily,
            color: textColorPre,
            fontSize: fontSizePre ?? 16.sp,
            fontWeight: fontWeight ?? FontWeight.bold,
          ),
          children: [
            TextSpan(
              text: partMiddle,
              style: TextStyle(
                fontFamily: fontFamily,
                color: textColorMiddle,
                fontSize: fontSizeMiddle ?? 32.sp,
                fontWeight: fontWeight ?? FontWeight.bold,
              ),
            ),
            TextSpan(
              text: partTail,
              style: TextStyle(
                fontFamily: fontFamily,
                color: textColorTail,
                fontSize: fontSizeTail ?? 18.sp,
                fontWeight: fontWeight ?? FontWeight.bold,
              ),
            ),
          ]),
    );
  }

  static richText({
    String? fontFamily,
    FontWeight? fontWeight,
    String? unit,
    required Color textColorUnit,
    double? fontSizeUnit,
    required String partIntegral,
    required Color textColorIntegral,
    double? fontSizeIntegral,
    String? partFractional,
    Color? textColorFractional,
    double? fontSizeFractional,
  }) {
    return RichText(
      text: TextSpan(
          text: unit ?? '¥',
          style: TextStyle(
            fontFamily: fontFamily,
            color: textColorUnit,
            fontSize: fontSizeUnit ?? 16.sp,
            fontWeight: fontWeight ?? FontWeight.bold,
          ),
          children: [
            TextSpan(
              text: partIntegral,
              style: TextStyle(
                fontFamily: fontFamily,
                color: textColorIntegral,
                fontSize: fontSizeIntegral ?? 32.sp,
                fontWeight: fontWeight ?? FontWeight.bold,
              ),
            ),
            TextSpan(
              text: partFractional != null && partFractional.isNotEmpty
                  ? ".$partFractional"
                  : "",
              style: TextStyle(
                fontFamily: fontFamily,
                color: textColorFractional ?? ByColorUtil.CommonTextColor,
                fontSize: fontSizeFractional ?? 18.sp,
                fontWeight: fontWeight ?? FontWeight.bold,
              ),
            ),
          ]),
    );
  }

  static noDataViewNormal({
    Color? color,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? height,
    double? width,
    RichText? desc,
  }) {
    return Container(
        padding: padding,
        margin: margin,
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: color ?? ByColorUtil.WhiteColor,
          borderRadius: BorderRadius.circular(borderRadius ?? 12.w),
        ),
        alignment: Alignment.center,
        child: NoDataView(
            desc: desc ??
                RichText(
                  text: TextSpan(
                    text: "暂无内容",
                    style: TextStyle(
                      color: ByColorUtil.CommonTextColor.withOpacity(0.6),
                      fontSize: 12.sp,
                    ),
                  ),
                )));
  }

  static Widget commonListNoDataView({
    String? prompts,
    Color? promptsColor,
    Widget? bottomWidget,
    EdgeInsetsGeometry? padding,
  }) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ListView(
          padding: padding,
          children: [
            SizedBox(
              width: constraints.biggest.width,
              height: constraints.biggest.height,
              child: ByWidgetsUtil.commonNoData(
                prompts: prompts,
                promptsColor: promptsColor,
                bottomWidget: bottomWidget,
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget commonNoData({
    String? prompts,
    Color? promptsColor,
    Widget? bottomWidget,
  }) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NoDataView(
            gap: 0,
            desc: RichText(
              text: TextSpan(
                text: prompts ?? "暂无数据",
                style: TextStyle(
                  color: promptsColor ??
                      ByColorUtil.CommonTextColor.withOpacity(0.5),
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
          if (bottomWidget != null) bottomWidget,
        ],
      ),
    );
  }

  static noDataView({
    Color? color,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? height,
    double? width,
    RichText? desc,
  }) {
    return Container(
      padding: padding,
      margin: margin,
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color ?? ByColorUtil.WhiteColor,
        borderRadius: BorderRadius.circular(borderRadius ?? 12.w),
      ),
      alignment: Alignment.center,
      child: NoDataView(desc: desc),
    );
  }

  static sliverNoDataView({
    RichText? desc,
  }) {
    return SliverFillRemaining(
      // hasScrollBody: true,
      child: Container(
        width: double.infinity,
        height: 100.h,
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 15.h),
        decoration: const BoxDecoration(
          color: ByColorUtil.WhiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
        ),
        child: Column(
          children: [
            _buildTopbar(),
            SizedBox(height: 15.h),
            NoDataView(
              desc: desc ??
                  RichText(
                    text: TextSpan(
                      text: "暂无内容",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 74, 92, 163),
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  static _buildTopbar() {
    return Row(children: [
      Image.asset(
        "assets/home/icon_records.png",
        width: 15.w,
        height: 15.w,
        fit: BoxFit.contain,
      ),
      SizedBox(width: 5.w),
      ByWidgetsUtil.commonText(
        text: "提取记录",
        fontWeight: FontWeight.bold,
        textColor: const Color(0xFF0E1840),
      ),
      const Spacer(),
      ByWidgetsUtil.commonText(
        text: "更多",
        textColor: const Color(0xFF0E1840).withOpacity(0.5),
        fontSize: 12.sp,
      ),
      const SizedBox(width: 5),
      Image.asset(
        "assets/mine/arrow_right.png",
        width: 8.w,
        height: 13.w,
      )
    ]);
  }
}
