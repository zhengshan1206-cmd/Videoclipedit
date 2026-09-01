import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/widgets/form/custom_text_form_field.dart';

LinearGradient generalGradient({isReverse = false}) {
  return LinearGradient(
    begin: isReverse ? Alignment.bottomCenter : Alignment.topCenter,
    end: isReverse ? Alignment.topCenter : Alignment.bottomCenter,
    colors: [
      ByColorUtil.BlackColor.withOpacity(0.8),
      ByColorUtil.BlackColor.withOpacity(0),
    ],
    stops: const [0, 1],
  );
}

Widget loadingIndicator(
    {Color color = ByColorUtil.LoginBtnBgColor, double size = 60}) {
  return Container(
    width: size,
    height: size,
    padding: const EdgeInsets.all(1),
    child: Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
        strokeWidth: 2,
      ),
    ),
  );
}

getDivider({
  bool visible = true,
  double? height = 0.5,
  double? thickness,
  Color? color,
}) {
  return Visibility(
    visible: visible,
    child: Divider(
      height: height,
      thickness: thickness,
      color: color ?? ByColorUtil.CommonTextColor.withOpacity(0.05),
    ),
  );
}

Widget radiusView(
    {required Widget child,
    Color? backgroundColor,
    double? minHeight,
    BoxBorder? border,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    GestureTapCallback? onTap}) {
  return Container(
    constraints: minHeight == null
        ? null
        : BoxConstraints(
            minHeight: minHeight,
          ),
    margin: margin ??
        EdgeInsets.only(left: 12.w, top: 15.h, right: 12.w, bottom: 15.h),
    padding: padding ??
        EdgeInsets.only(left: 12.w, top: 8.h, right: 12.w, bottom: 8.h),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: backgroundColor ?? Colors.white,
      border: border,
    ),
    child: GestureDetector(
      onTap: onTap,
      child: child,
    ),
  );
}

buildTextFormView(String title, CustomTextFieldType type,
    {bool enable = true,
    bool showDivider = false,
    EdgeInsetsGeometry? padding,
    Function()? onTap,
    ValueChanged<String>? onChange,
    String? hintText,
    String? subTitle,
    TextStyle? titleStyle,
    TextStyle? subTitleStyle,
    TextStyle? hintTitleStyle,
    Widget? suffixWidget,
    Widget? arrowWidget,
    double? spacing,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool showCleanButton = false,
    TextAlign subTitleTextAlign = TextAlign.right}) {
  return Column(
    children: [
      CustomTextField(
        key: UniqueKey(),
        hintText: hintText,
        title: title,
        titleStyle: titleStyle,
        enabled: enable,
        subTitle: subTitle,
        subTitleStyle: subTitleStyle,
        hintTextStyle: hintTitleStyle,
        spacing: spacing,
        padding: padding ?? EdgeInsets.symmetric(vertical: 16.h),
        onTap: onTap,
        subTitleTextAlign: subTitleTextAlign,
        inputFormatters: inputFormatters,
        onChanged: onChange,
        showCleanButton: showCleanButton,
        type: type,
        suffixWidget: suffixWidget,
        arrowWidget: arrowWidget,
      ),
      Visibility(
        visible: showDivider,
        child: getDivider(),
      ),
    ],
  );
}
