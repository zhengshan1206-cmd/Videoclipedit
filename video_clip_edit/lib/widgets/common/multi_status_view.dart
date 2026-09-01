import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/util/common_ui.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/flavors/app_values.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/widgets/common_button.dart';

enum EmptyActionType {
  ///只显示文字
  text,

  ///只显示按钮
  button,

  ///按钮文字都显示
  all,
}

enum MultiStatusType {
  ///内容
  statusContent,

  ///加载中
  statusLoading,

  ///无数据
  statusEmpty,

  ///数据错误
  statusError,

  ///无网络
  statusNoNetWork,

  ///自定义
  statusCustom,
}

class MultiStatusView extends StatefulWidget {
  const MultiStatusView({
    super.key,
    required this.child,
    this.currentStatus = MultiStatusType.statusContent,
    this.loadingWidget,
    this.errorWidget,
    this.noNetWorkWidget,
    this.customWidget,
    this.emptyWidget,
    this.emptyText,
    this.emptyActionType = EmptyActionType.all,
    this.hasAppBar = true,
    this.backgroundColor = ByColorUtil.WhiteColor,
    this.action,
    this.actionText,
    this.scrollController,
  });

  final Widget child;
  final MultiStatusType currentStatus;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? noNetWorkWidget;
  final Widget? customWidget;

  final Widget? emptyWidget;
  final EmptyActionType emptyActionType;
  final String? emptyText;

  final VoidCallback? action;
  final String? actionText;

  final bool hasAppBar;

  final Color backgroundColor;

  final ScrollController? scrollController;

  @override
  State<MultiStatusView> createState() => _MultiStatusViewState();
}

class _MultiStatusViewState extends State<MultiStatusView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    switch (widget.currentStatus) {
      case MultiStatusType.statusContent:
        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              color: widget.backgroundColor,
              height: constraints.maxHeight,
              child: widget.child,
            );
          },
        );
      case MultiStatusType.statusLoading:
        return _buildLoadingWidget();
      case MultiStatusType.statusEmpty:
        return _buildEmptyWidget();
      case MultiStatusType.statusError:
        return _buildErrorWidget();
      case MultiStatusType.statusNoNetWork:
        return _buildNoNetWorkWidget();
      case MultiStatusType.statusCustom:
        return _buildCustomWidgetWidget();
    }
  }

  _buildLoadingWidget() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            color: widget.backgroundColor,
            width: Get.width,
            height: constraints.maxHeight,
            padding: EdgeInsets.only(
                bottom: !widget.hasAppBar
                    ? 0
                    : safeAreaEdgeInsets.top + kToolbarHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.loadingWidget != null
                  ? [widget.loadingWidget!]
                  : [loadingIndicator()],
            ),
          ),
        );
      },
    );
  }

  _buildEmptyWidget() {
    List<Widget> content = widget.emptyWidget != null
        ? [widget.emptyWidget!]
        : [
            Image.asset(Assets.commonIconEmptyBg, width: 180.w, height: 100.w),
            SizedBox(height: 10.h),
            ..._getActions(widget.emptyActionType),
          ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: widget.scrollController,
          child: Container(
            color: widget.backgroundColor,
            width: Get.width,
            height: constraints.maxHeight,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              ...content,
              Flexible(
                child: SizedBox(
                  height: !widget.hasAppBar
                      ? 0
                      : safeAreaEdgeInsets.top + kToolbarHeight,
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  _buildErrorWidget() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            color: widget.backgroundColor,
            width: Get.width,
            height: constraints.maxHeight,
            padding: EdgeInsets.only(
                bottom: !widget.hasAppBar
                    ? 0
                    : safeAreaEdgeInsets.top + kToolbarHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.errorWidget != null
                  ? [widget.errorWidget!]
                  : [
                      BYText.instance("服务错误", 16.sp),
                    ],
            ),
          ),
        );
      },
    );
  }

  _buildNoNetWorkWidget() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            color: widget.backgroundColor,
            width: Get.width,
            height: constraints.maxHeight,
            padding: EdgeInsets.only(
                bottom: !widget.hasAppBar
                    ? 0
                    : safeAreaEdgeInsets.top + kToolbarHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.noNetWorkWidget != null
                  ? [widget.noNetWorkWidget!]
                  : [
                      BYText.instance("网络错误，请先打开网络", 16.sp),
                    ],
            ),
          ),
        );
      },
    );
  }

  _buildCustomWidgetWidget() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            color: widget.backgroundColor,
            width: Get.width,
            height: constraints.maxHeight,
            padding: EdgeInsets.only(
                bottom: !widget.hasAppBar
                    ? 0
                    : safeAreaEdgeInsets.top + kToolbarHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.customWidget != null
                  ? [widget.customWidget!]
                  : [
                      BYText.instance("自定义布局", 16.sp),
                    ],
            ),
          ),
        );
      },
    );
  }

  _getActions(EmptyActionType emptyActionType) {
    switch (emptyActionType) {
      case EmptyActionType.all:
        return [
          BYText.instance(widget.emptyText ?? '暂无内容', 12.sp,
              color: ByColorUtil.CommonTextColor.withOpacity(0.6),
              textAlign: TextAlign.center),
          SizedBox(height: 22.h),
          IntrinsicWidth(
            child: CommonButton(
              padding: EdgeInsets.only(left: 17.w, right: 12.w),
              minSize: 32.h,
              borderRadius: BorderRadius.circular(8),
              color: ByColorUtil.LoginBtnBgColor,
              disabledColor: ByColorUtil.LoginBtnBgColor,
              spacing: 4.w,
              suffixDirectional: SuffixDirectional.right,
              suffixWidget: Image.asset(
                Assets.homeArrowRight,
                width: 12.w,
                height: 12.w,
                color: ByColorUtil.WhiteColor,
              ),
              onPressed: widget.action,
              child: BYText.instance(widget.actionText ?? '', 14.sp,
                  color: ByColorUtil.WhiteColor),
            ),
          ),
        ];
      case EmptyActionType.text:
        return [
          BYText.instance(widget.emptyText ?? '暂无内容', 12.sp,
              color: ByColorUtil.CommonTextColor.withOpacity(0.6),
              textAlign: TextAlign.center)
        ];
      case EmptyActionType.button:
        return [
          IntrinsicWidth(
            child: CommonButton(
              padding: EdgeInsets.only(left: 17.w, right: 12.w),
              minSize: 32.h,
              borderRadius: BorderRadius.circular(8),
              color: ByColorUtil.LoginBtnBgColor,
              disabledColor: ByColorUtil.LoginBtnBgColor,
              spacing: 4.w,
              suffixDirectional: SuffixDirectional.right,
              suffixWidget: Image.asset(
                Assets.homeArrowRight,
                width: 12.w,
                height: 12.w,
                color: ByColorUtil.WhiteColor,
              ),
              onPressed: widget.action,
              child: BYText.instance(widget.actionText ?? '', 14.sp,
                  color: ByColorUtil.WhiteColor),
            ),
          ),
        ];
    }
  }

  @override
  bool get wantKeepAlive => true;
}
