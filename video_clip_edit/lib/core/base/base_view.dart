import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/util/common_ui.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/flavors/app_values.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/widgets/common_button.dart';

enum NavLeadingType {
  none,
  back,
  close,
  custom,
}

class BaseView extends StatefulWidget {
  const BaseView({
    super.key,
    this.scaffoldKey,
    this.hasAppBar = true,
    this.isTransparentAppBar = false,
    this.leadingType = NavLeadingType.back,
    this.leadingAction,
    this.leading,
    this.leadingWidth,
    this.titleView,
    this.title,
    this.rear,
    this.hasFlexibleSpace = false,
    this.bottom,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset,
    this.drawer,
    this.onDrawerChanged,
    this.bottomNavigationBar,
    required this.child,
  });

  final Key? scaffoldKey;

  final bool hasAppBar;

  final bool isTransparentAppBar;

  final Widget? titleView;

  final String? title;

  final Color? backgroundColor;

  final bool extendBodyBehindAppBar;

  final bool? resizeToAvoidBottomInset;

  final Widget child;

  final double? leadingWidth;

  final NavLeadingType leadingType;

  final VoidCallback? leadingAction;

  final Widget? leading;

  final Widget? rear;

  final bool hasFlexibleSpace;

  final PreferredSize? bottom;

  final Widget? drawer;

  final Widget? bottomNavigationBar;

  final void Function(bool)? onDrawerChanged;

  @override
  State<BaseView> createState() => _BaseViewState();
}

class _BaseViewState extends State<BaseView> {
  late StreamSubscription<bool> keyboardSubscription;
  var keyboardVisibilityController = KeyboardVisibilityController();

  @override
  void initState() {
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      if (visible == false) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      onDrawerChanged: (isOpen) {
        if (widget.onDrawerChanged != null) {
          widget.onDrawerChanged!(isOpen);
        }
      },
      key: widget.scaffoldKey,
      drawer: widget.drawer,
      backgroundColor: widget.backgroundColor,
      extendBodyBehindAppBar: widget.hasAppBar && !widget.isTransparentAppBar
          ? widget.extendBodyBehindAppBar
          : true,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      bottomNavigationBar: widget.bottomNavigationBar,
      appBar: widget.hasAppBar
          ? AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: widget.isTransparentAppBar
                  ? Colors.transparent
                  : ByColorUtil.WhiteColor,
              leadingWidth: widget.leadingWidth,
              leading: _leading(),
              actions: _rear(),
              title: _titleView(),
              centerTitle: true,
              bottom: widget.bottom,
              flexibleSpace: widget.hasFlexibleSpace
                  ? Container(
                      height: safeAreaTopDistance(kToolbarHeight),
                      alignment: Alignment.bottomCenter,
                      decoration: const BoxDecoration(
                        color: ByColorUtil.colorF4F7F8,
                        image: DecorationImage(
                          fit: BoxFit.fitWidth,
                          image: AssetImage(
                            Assets.homeHomePageBgTop,
                          ),
                        ),
                      ),
                      child: getDivider(height: 1.h, color: ByColorUtil.CommonPageBgColor),
                    )
                  : null,
            )
          : AppBar(
              toolbarHeight: 0,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: Colors.transparent,
            ),
      body: widget.child,
    );
  }

  Widget? _leading() {
    switch (widget.leadingType) {
      case NavLeadingType.none:
        return const SizedBox();
      case NavLeadingType.back:
        return CommonButton(
          padding: EdgeInsets.zero,
          minSize: 30,
          onPressed: widget.leadingAction ?? Get.back,
          child: Image.asset(
            Assets.homeIconBack,
            width: 16.w,
            height: 16.w,
          ),
        );
      case NavLeadingType.close:
        return CommonButton(
          padding: EdgeInsets.zero,
          minSize: 24,
          onPressed: widget.leadingAction ?? Get.back,
          child: Image.asset(
            Assets.homeIconCloseDark,
            width: 16.w,
            height: 16.w,
          ),
        );
      case NavLeadingType.custom:
        return widget.leading;
    }
  }

  Widget? _titleView() {
    return widget.titleView ??
        (widget.title == null
            ? null
            : BYText.instance(
                widget.title!,
                16,
                isTitle: true,
                fontWeight: BYFontWeight.bold,
              ));
  }

  List<Widget> _rear() {
    return widget.rear == null
        ? []
        : [
            Center(child: widget.rear!),
            SizedBox(width: 12.w),
          ];
  }
}
