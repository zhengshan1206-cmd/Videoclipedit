import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class ByLoadingWidget extends StatelessWidget {
  const ByLoadingWidget({
    super.key,
    this.message = "加载中...",
    this.size = 50,
    this.strokeWidth = 6,
    this.messageColor,
    this.messageSize = 11,
    this.messageFontWeight = FontWeight.normal,
    this.progressColor = const Color(0xFF5B4BF7),
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.isLoading = true,
  });

  /// 加载提示文字
  final String message;

  /// loading大小
  final double size;

  /// loading线条宽度
  final double strokeWidth;

  /// 提示文字颜色
  final Color? messageColor;

  /// 提示文字大小
  final double messageSize;

  /// 提示文字字重
  final FontWeight messageFontWeight;

  /// loading颜色
  final Color progressColor;

  /// 背景颜色
  final Color? backgroundColor;

  /// 圆角大小
  final double? borderRadius;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 是否显示loading
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: !isLoading,
      child: Container(
        padding: padding ?? EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFFF4F6FA),
          borderRadius: BorderRadius.circular(borderRadius ?? 12.w),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size.w,
              height: size.w,
              child: CircularProgressIndicator(
                strokeWidth: strokeWidth,
                color: progressColor,
                strokeCap: StrokeCap.round,
              ),
            ),
            if (message.isNotEmpty) ...[
              SizedBox(height: 18.h),
              ByWidgetsUtil.commonText(
                text: message,
                maxLines: 10,
                fontSize: messageSize.sp,
                textAlign: TextAlign.center,
                textColor: messageColor ??
                    ByColorUtil.CommonTextColor.withOpacity(0.5),
                fontWeight: messageFontWeight,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 可控制显示/隐藏的Loading组件
class ByLoadingController extends StatefulWidget {
  const ByLoadingController({
    super.key,
    this.message = "加载中...",
    this.size = 50,
    this.strokeWidth = 6,
    this.messageColor,
    this.messageSize = 11,
    this.messageFontWeight = FontWeight.normal,
    this.progressColor = const Color(0xFF5B4BF7),
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.isLoading = false,
    this.onLoadingChanged,
  });

  /// 加载提示文字
  final String message;

  /// loading大小
  final double size;

  /// loading线条宽度
  final double strokeWidth;

  /// 提示文字颜色
  final Color? messageColor;

  /// 提示文字大小
  final double messageSize;

  /// 提示文字字重
  final FontWeight messageFontWeight;

  /// loading颜色
  final Color progressColor;

  /// 背景颜色
  final Color? backgroundColor;

  /// 圆角大小
  final double? borderRadius;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 是否显示loading
  final bool isLoading;

  /// loading状态改变回调
  final void Function(bool)? onLoadingChanged;

  @override
  State<ByLoadingController> createState() => _ByLoadingControllerState();
}

class _ByLoadingControllerState extends State<ByLoadingController> {
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _isLoading = widget.isLoading;
  }

  @override
  void didUpdateWidget(ByLoadingController oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading != widget.isLoading) {
      setState(() {
        _isLoading = widget.isLoading;
      });
    }
  }

  /// 显示loading
  void show() {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
      widget.onLoadingChanged?.call(true);
    }
  }

  /// 隐藏loading
  void hide() {
    if (_isLoading) {
      setState(() {
        _isLoading = false;
      });
      widget.onLoadingChanged?.call(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ByLoadingWidget(
      message: widget.message,
      size: widget.size,
      strokeWidth: widget.strokeWidth,
      messageColor: widget.messageColor,
      messageSize: widget.messageSize,
      messageFontWeight: widget.messageFontWeight,
      progressColor: widget.progressColor,
      backgroundColor: widget.backgroundColor,
      borderRadius: widget.borderRadius,
      padding: widget.padding,
      isLoading: _isLoading,
    );
  }
}
