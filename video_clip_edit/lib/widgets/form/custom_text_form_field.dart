import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/widgets/common_button.dart';

enum CustomTextFieldType {
  edit,
  choose,
}

class CustomTextField extends StatefulWidget {
  CustomTextField({
    super.key,
    this.title,
    this.titleStyle,
    this.subTitle,
    this.subTitleStyle,
    this.hintText,
    this.hintTextStyle,
    this.controller,
    this.spacing,
    this.padding,
    this.subTitleMaxLines = 1,
    this.enabled = true,
    this.prefixWidget,
    this.suffixWidget,
    this.arrowWidget,
    this.onChanged,
    this.onTap,
    this.keyboardType,
    this.inputFormatters,
    this.showCleanButton = false,
    this.subTitleTextAlign = TextAlign.right,
    this.type = CustomTextFieldType.edit,
    this.direction = Axis.horizontal,
  });

  final TextEditingController? controller;

  /// 标题文字，左或上
  final String? title;
  final TextStyle? titleStyle;

  /// 子标题文字（内容），右或下
  String? subTitle;
  final TextStyle? subTitleStyle;

  ///提示文字
  final String? hintText;
  final TextStyle? hintTextStyle;

  /// title和subTitle间距，默认水平24，垂直4
  final double? spacing;

  final EdgeInsetsGeometry? padding;

  /// 显示类型
  final CustomTextFieldType type;
  final int? subTitleMaxLines;

  /// type == XCTextFormFieldType.choose，输入框始终不能输入，enabled无效
  final bool? enabled;
  final bool showCleanButton;

  final Axis direction;
  final TextAlign subTitleTextAlign;

  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  final Widget? prefixWidget;
  final Widget? suffixWidget;

  final Widget? arrowWidget;

  final ValueChanged<String>? onChanged;
  final GestureTapCallback? onTap;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _showCleanButton = false;
  late final TextEditingController _controller = TextEditingController();

  TextEditingController get _getController => widget.controller ?? _controller;

  @override
  void initState() {
    super.initState();
    _getController.text = widget.subTitle ?? "";
    _getController.addListener(
      () {
        String newValue = _getController.text;
        if (newValue.isNotEmpty && _showCleanButton == false) {
          setState(() {
            _showCleanButton = true;
          });
        } else if (newValue.isEmpty && _showCleanButton == true) {
          setState(() {
            _showCleanButton = false;
          });
        }
        widget.subTitle = newValue;
        if (widget.onChanged != null) {
          widget.onChanged!(newValue);
        }
      },
    );
  }

  @override
  void dispose() {
    _getController.dispose();
    super.dispose();
  }

  double _spacing() =>
      widget.spacing ?? (widget.direction == Axis.horizontal ? 8.w : 4.w);
  final double _fontSize = 14.sp;
  final double _cleanButtonSize = 20.w;
  final double _cleanButtonSpacing = 4.w;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        if ((widget.type == CustomTextFieldType.choose ||
                (widget.type == CustomTextFieldType.edit &&
                    !(widget.enabled ?? false))) &&
            widget.onTap != null) {
          widget.onTap!();
        }
      },
      child: Container(
        padding: widget.padding,
        child: widget.direction == Axis.horizontal
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  widget.prefixWidget ?? Container(),
                  _getTitleWidget(),
                  SizedBox(
                    width: _spacing(),
                  ),
                  Expanded(
                    child: _getSubTitleWidget(),
                  ),
                  widget.suffixWidget ?? Container(),
                  _getSelectArrow(),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  widget.prefixWidget ?? Container(),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _getTitleWidget(),
                        SizedBox(
                          height: _spacing(),
                        ),
                        _getSubTitleWidget(),
                      ],
                    ),
                  ),
                  widget.suffixWidget ?? Container(),
                  _getSelectArrow(),
                ],
              ),
      ),
    );
  }

  _getTitleWidget() {
    return Text(widget.title ?? '', style: _getTitleTextStyle());
  }

  _getSelectArrow() {
    return widget.type == CustomTextFieldType.choose
        ? Container(
            margin: EdgeInsets.only(
              left: _cleanButtonSpacing,
            ),
            child: widget.arrowWidget ??
                Image.asset(Assets.commonArrowRight,
                    width: 15.w,
                    height: 15.h,
                    color: widget.enabled == true
                        ? ByColorUtil.CommonTextColor.withOpacity(0.5)
                        : ByColorUtil.BlackColor),
          )
        : Container();
  }

  _getSubTitleWidget() {
    return widget.type == CustomTextFieldType.choose || widget.enabled == false
        ? Text(
            (widget.subTitle ?? widget.hintText) ?? "",
            overflow: TextOverflow.ellipsis,
            maxLines: widget.subTitleMaxLines,
            textAlign: widget.subTitleTextAlign,
            style: widget.subTitle != null
                ? _getSubTitleTextStyle()
                : _getHintTextStyle(),
          )
        : _getTextField();
  }

  _getTextField() {
    bool enabled =
        widget.enabled == true && widget.type == CustomTextFieldType.edit;
    _showCleanButton = _getController.text.isNotEmpty && enabled == true;

    return TextField(
      controller: _getController,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      selectionControls: MaterialTextSelectionControls(),
      maxLines: widget.subTitleMaxLines,
      enabled: enabled,
      textAlign: widget.subTitleTextAlign,
      style: _getSubTitleTextStyle(),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          isCollapsed: true,
          border: InputBorder.none,
          hintText: widget.hintText,
          hintStyle: _getHintTextStyle(),
          hintMaxLines: 1,
          suffixIconConstraints: BoxConstraints(
              maxWidth: _cleanButtonSize + _cleanButtonSpacing * 2,
              maxHeight: _cleanButtonSize),
          suffixIcon: _showCleanButton & widget.showCleanButton == false
              ? null
              : CommonButton(
                  padding: EdgeInsets.zero,
                  minSize: 20,
                  child: Image.asset(Assets.commonInputDelete),
                  onPressed: () {
                    setState(() {
                      _getController.clear();
                      _showCleanButton = false;
                    });
                  },
                )),
    );
  }

  _getTitleTextStyle() {
    return widget.titleStyle ??
        BYTextStyle.instance(_fontSize,
            color: widget.enabled == true
                ? ByColorUtil.CommonTextColor
                : ByColorUtil.CommonTextColor.withOpacity(0.5));
  }

  _getSubTitleTextStyle() {
    return widget.subTitleStyle ??
        BYTextStyle.instance(_fontSize,
            color: widget.enabled == true
                ? ByColorUtil.CommonTextColor.withOpacity(0.5)
                : ByColorUtil.CommonTextColor.withOpacity(0.5));
  }

  _getHintTextStyle() {
    return widget.hintTextStyle ??
        BYTextStyle.instance(_fontSize,
            color: ByColorUtil.CommonTextColor.withOpacity(0.5));
  }
}
