import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/v2/toolBox/beans/new_tool_box_list_bean.dart';
import 'package:video_clip_edit/v2/toolBox/providers/home_gride_view_provider.dart';

enum ToolBoxGrideViewCellType {
  /// 故事创作
  textImageS2("text_image_s2"),

  /// 小图（2列）
  minImage("min_image"),

  /// 大图（1列）
  maxImage("max_image"),

  /// 首页广场
  textImage("text_image");

  final String rawValue;

  const ToolBoxGrideViewCellType(this.rawValue);
  static ToolBoxGrideViewCellType fromRawValue(String rawValue) {
    for (final value in ToolBoxGrideViewCellType.values) {
      if (value.rawValue == rawValue) {
        return value;
      }
    }
    return ToolBoxGrideViewCellType.minImage;
  }

  double get aspectRatio {
    switch (this) {
      case ToolBoxGrideViewCellType.minImage:
        return 17 / 22;
      case ToolBoxGrideViewCellType.maxImage:
        return 351 / 460;
      case ToolBoxGrideViewCellType.textImage:
        return 1.0;
      case ToolBoxGrideViewCellType.textImageS2:
        return 17 / 9;
    }
  }

  @override
  String toString() => 'ToolBoxGrideViewCellType($rawValue)';
}

class ToolBoxGrideView extends StatelessWidget {
  const ToolBoxGrideView({
    super.key,
    required this.isLarge,
    required this.index,
    /// 为 false 时不再叠加 [ByScreenUtils.bottomInsetForScrollable]（由外层如 [SafeArea] 已处理底部手势区）
    this.includeBottomSafeInset = true,
  });
  final bool isLarge;
  final int index;
  final bool includeBottomSafeInset;

  @override
  Widget build(BuildContext context) {
    List<NewToolBoxListBean> listBeans =
        context.select<HomeGrideViewProvider, List<NewToolBoxListBean>>(
      (value) => value.listBeans,
    );
    final loadTimes = context.select<HomeGrideViewProvider, int>(
      (value) => value.loadTimes,
    );
    final showEmptyView = loadTimes > 0 && listBeans.isEmpty;

    return showEmptyView
        ? ByWidgetsUtil.commonListNoDataView()
        : WaterfallFlow.builder(
            padding: EdgeInsets.only(
              left: 12.w,
              right: 12.w,
              bottom: 12.h +
                  (includeBottomSafeInset
                      ? ByScreenUtils.bottomInsetForScrollable(context)
                      : 0),
            ),
            // physics: const NeverScrollableScrollPhysics(),
            // shrinkWrap: true,
            gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
              crossAxisCount: isLarge ? 1 : 2,
              crossAxisSpacing: 11.w,
              mainAxisSpacing: 10.h,
            ),
            itemCount: listBeans.length,
            itemBuilder: (context, index) {
              if (index > listBeans.length - 1) {
                return const SizedBox();
              }
              final bean = listBeans[index];
              final style = bean.style;
              final type = ToolBoxGrideViewCellType.fromRawValue(style);
              switch (type) {
                case ToolBoxGrideViewCellType.minImage:
                case ToolBoxGrideViewCellType.maxImage:
                  return ToolBoxCommonCell(
                    bean: bean,
                    type: type,
                    isLarge: isLarge,
                  );
                case ToolBoxGrideViewCellType.textImageS2:
                  return ToolBoxStoryCell(index: index, type: type, bean: bean);
                case ToolBoxGrideViewCellType.textImage:
                  return HomePageTypeCell(index: index, type: type, bean: bean);
              }
            },
          );
  }
}

class ToolBoxCommonCell extends StatelessWidget {
  const ToolBoxCommonCell({
    super.key,
    required this.bean,
    required this.type,
    required this.isLarge,
  });
  final ToolBoxGrideViewCellType type;
  final NewToolBoxListBean bean;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final doubleBtns = bean.similarType != 0;
    return GestureDetector(
      onTap: () {
        print("bean.id:====> ${bean.id}");
        print("bean.icon:====> ${bean.icon}");
        ByNavigatorUtil.reportDataPoint(
          pageTag: "home_video_square_video",
          operateType: "click",
          funcDetailTag: bean.id.toString(),
          funcDetailImg: bean.bgimg,
        );
        final data = SubFunction.fromJson({
          "id": bean.id,
          "title": bean.title,
          "img_url": bean.icon,
          "jump_url": bean.jumpUrl,
          "jump_param": bean.jumpParam,
          "type": bean.type,
          "des": bean.des,
          "isNew": false,
        });
        ByCommonUtils.subFunctionCase(context, data);
      },
      child: AspectRatio(
        aspectRatio: type.aspectRatio,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2F5FF),
            borderRadius: BorderRadius.circular(isLarge ? 18.w : 12.w),
            border: const Border(
              top: BorderSide(color: Color(0xFFE8EBF5), width: 0.5),
            ),
          ),
          padding: EdgeInsets.all(5.w),
          child: Stack(
            children: [
              Container(),
              Positioned.fill(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 50.0.h),
                  child: CachedNetworkImage(
                    imageUrl: bean.bgimg,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                left: 3.w,
                right: 3.w,
                top: 3.h,
                height: 80.h,
                child: Offstage(
                  offstage: !isLarge,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18.w),
                    child: Stack(
                      children: [
                        ByWidgetsUtil.gaussianBlur(
                          sigmaX: 6,
                          sigmaY: 6,
                          child: Container(
                            color: const Color(0xFF000000).withOpacity(0.3),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: bean.icon,
                                    width: isLarge ? 24 : 18,
                                    height: isLarge ? 24 : 18,
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(width: 4.w),
                                  ByWidgetsUtil.commonText(
                                    fontSize: isLarge ? 20.sp : 16.sp,
                                    text: bean.title,
                                    textColor: const Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ],
                              ),
                              ByWidgetsUtil.commonText(
                                textAlign: TextAlign.start,
                                fontSize: isLarge ? 14.sp : 11.sp,
                                text: bean.des,
                                fontWeight: FontWeight.normal,
                                textColor: const Color(0xFFFFFFFF),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // child: Image.asset(
                //   isLarge
                //       ? "assets/newToolBox/cell_top_bg_large.png"
                //       : "assets/newToolBox/cell_top_bg.png",
                //   fit: BoxFit.fitWidth,
                // ),
              ),
              // Positioned(
              //   left: 0,
              //   right: 0,
              //   bottom: 0,
              //   height: 100.h,
              //   child: ByWidgetsUtil.gradientBgContainer(
              //     borderRadius: 0,
              //     gradient: ByColorUtil.lineareGradient(
              //       colorStart: const Color(0xFFFFFFFF).withOpacity(0),
              //       colorEnd: const Color(0xFFFFFFFF).withOpacity(0.5),
              //       end: Alignment.bottomCenter,
              //       begin: Alignment.topCenter,
              //     ),
              //     child: Container(),
              //   ),
              // ),
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Offstage(
                    offstage: !isLarge,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        if (!doubleBtns)
                          Container(
                            height: isLarge ? 48.h : 36.h,
                            margin: EdgeInsets.symmetric(horizontal: 10.w),
                            child: _buildButton(
                              title: bean.typeName,
                              bgColor: bean.typeBgcolor,
                              textColor: Colors.white,
                              fonSize: isLarge ? 16.sp : 14.sp,
                              onTap: () {
                                final data = SubFunction.fromJson({
                                  "id": bean.id,
                                  "title": bean.title,
                                  "img_url": bean.icon,
                                  "jump_url": bean.jumpUrl,
                                  "jump_param": bean.jumpParam,
                                  "type": bean.type,
                                  "des": bean.des,
                                  "isNew": false,
                                });
                                ByCommonUtils.subFunctionCase(context, data);
                              },
                              fontWeight: FontWeight.bold,
                              borderRadius: 12.h,
                            ),
                          ),
                        if (doubleBtns)
                          SizedBox(
                            height: isLarge ? 48.h : 36.h,
                            child: Row(
                              children: [
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: _buildButton(
                                    title: bean.similarTypeName,
                                    bgColor: bean.similarTypeBgcolor,
                                    textColor: ByColorUtil.WhiteColor,
                                    blur: true,
                                    fonSize: 16.sp,
                                    onTap: () {
                                      final data = SubFunction.fromJson({
                                        "id": bean.id,
                                        "title": bean.title,
                                        "img_url": bean.icon,
                                        "jump_url": bean.similarJumpUrl,
                                        "jump_param": bean.similarJumpParam,
                                        "type": bean.similarType,
                                        "des": bean.des,
                                        "isNew": false,
                                      });
                                      ByCommonUtils.subFunctionCase(
                                        context,
                                        data,
                                      );
                                    },
                                    fontWeight: FontWeight.bold,
                                    borderRadius: 12.h,
                                  ),
                                ),
                                SizedBox(width: 11.w),
                                Expanded(
                                  child: _buildButton(
                                    title: bean.typeName,
                                    bgColor: bean.typeBgcolor,
                                    textColor: Colors.white,
                                    fonSize: 16.sp,
                                    onTap: () {
                                      final data = SubFunction.fromJson({
                                        "id": bean.id,
                                        "title": bean.title,
                                        "img_url": bean.icon,
                                        "jump_url": bean.jumpUrl,
                                        "jump_param": bean.jumpParam,
                                        "type": bean.type,
                                        "des": bean.des,
                                        "isNew": false,
                                      });
                                      ByCommonUtils.subFunctionCase(
                                        context,
                                        data,
                                      );
                                    },
                                    fontWeight: FontWeight.bold,
                                    borderRadius: 12.h,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                              ],
                            ),
                          ),
                        SizedBox(height: isLarge ? 15.h : 2.h),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 2.w,
                right: 2.w,
                bottom: 2.h,
                height: 56.h,
                child: Offstage(
                  offstage: isLarge,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      final data = SubFunction.fromJson({
                        "id": bean.id,
                        "title": bean.title,
                        "img_url": bean.icon,
                        "jump_url": bean.jumpUrl,
                        "jump_param": bean.jumpParam,
                        "type": bean.type,
                        "des": bean.des,
                        "isNew": false,
                      });
                      ByCommonUtils.subFunctionCase(context, data);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.w),
                      child: Stack(
                        children: [
                          ByWidgetsUtil.gaussianBlur(
                            sigmaX: 3,
                            sigmaY: 3,
                            child: Container(
                              color: const Color(0xFF000000).withOpacity(0.5),
                            ),
                          ),
                          Positioned.fill(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: bean.icon,
                                        width: isLarge ? 24 : 18,
                                        height: isLarge ? 24 : 18,
                                        fit: BoxFit.contain,
                                      ),
                                      SizedBox(width: 4.w),
                                      Expanded(
                                        child: ByWidgetsUtil.commonText(
                                          fontSize: isLarge ? 20.sp : 14.sp,
                                          text: bean.title,
                                          textColor: const Color(0xFFFFFFFF),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Image.asset(
                                        "assets/newToolBox/cell_top_bg_action.png",
                                        width: 15.w,
                                        height: 12.h,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2.h),
                                  ByWidgetsUtil.commonText(
                                    textAlign: TextAlign.start,
                                    fontSize: isLarge ? 14.sp : 10.sp,
                                    text: bean.des,
                                    fontWeight: FontWeight.normal,
                                    textColor: const Color(0xFFFFFFFF),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildButton({
    required String title,
    required String bgColor,
    required double fonSize,
    required Color textColor,
    required VoidCallback onTap,
    required FontWeight fontWeight,
    required double borderRadius,
    bool blur = false,
  }) {
    if (blur) {
      return LayoutBuilder(
        builder: (context, constraints) {
          byDebugPrint(
            "constraints: ${constraints.maxWidth} - ${constraints.maxHeight}",
          );
          return Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: ByWidgetsUtil.gaussianBlur(
                    child: Container(
                      color: const Color(0xFF000000).withOpacity(0.3),
                    ),
                  ),
                ),
              ),
              ByWidgetsUtil.commonBtn(
                fontSize: fonSize,
                borderRadius: borderRadius,
                title: title,
                bgColor: Colors.transparent,
                textColor: textColor,
                padding: EdgeInsets.zero,
                fontWeight: fontWeight,
                onClick: onTap,
              ),
            ],
          );
        },
      );
    }

    /// 渐变背景色
    if (bgColor.contains(",")) {
      return ByWidgetsUtil.gradientBtn(
        fontSize: fonSize,
        borderRadius: borderRadius,
        title: title,
        gradient: ByColorUtil.lineareGradientMultipleWithHexaColorsString(
          colorsString: bgColor,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        textColor: textColor,
        padding: EdgeInsets.zero,
        fontWeight: fontWeight,
        onClick: onTap,
      );
    }

    /// 纯色背景色
    return ByWidgetsUtil.commonBtn(
      fontSize: fonSize,
      borderRadius: borderRadius,
      title: title,
      bgColor:
          bgColor.isNotEmpty ? ByColorUtil.hexaToColor(bgColor) : Colors.white,
      textColor: textColor,
      padding: EdgeInsets.zero,
      fontWeight: fontWeight,
      onClick: onTap,
    );
  }
}

class ToolBoxStoryCell extends StatelessWidget {
  const ToolBoxStoryCell({
    super.key,
    required this.index,
    required this.type,
    required this.bean,
  });

  final int index;
  final ToolBoxGrideViewCellType type;
  final NewToolBoxListBean bean;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        log("点击了====> ${bean.typeBgcolor}");
        ByNavigatorUtil.reportDataPoint(
          pageTag: "home_video_square_video",
          operateType: "click",
          funcDetailTag: bean.id.toString(),
          funcDetailImg: bean.bgimg,
        );

        final data = SubFunction.fromJson({
          "id": bean.id,
          "title": bean.title,
          "img_url": bean.icon,
          "jump_url": bean.jumpUrl,
          "jump_param": bean.jumpParam,
          "type": bean.type,
          "des": bean.des,
          "isNew": false,
        });
        ByCommonUtils.subFunctionCase(context, data);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.w),
        child: AspectRatio(
          aspectRatio: type.aspectRatio,
          child: Stack(
            children: [
              Positioned.fill(
                child: ByWidgetsUtil.gradientBgContainer(
                  gradient:
                      ByColorUtil.lineareGradientMultipleWithHexaColorsString(
                    // colorsString: bean.typeBgcolor.isNotEmpty
                    //     ? bean.typeBgcolor
                    //     : "#FFFFFFFF",
                    colorsString: bean.typeBgcolor,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(left: 12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 13.h),
                      ByWidgetsUtil.commonText(
                        text: bean.title,
                        fontSize: 16.sp,
                        textColor: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 5.h),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ByWidgetsUtil.commonText(
                                    text: "热度值：${bean.useTime}",
                                    textColor: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12.sp,
                                  ),
                                  const Spacer(),
                                  CachedNetworkImage(
                                    imageUrl: bean.icon,
                                    fit: BoxFit.contain,
                                    width: 20.w,
                                    height: 20.h,
                                  ),
                                  SizedBox(height: 8.h),
                                ],
                              ),
                            ),
                            CachedNetworkImage(
                              imageUrl: bean.bgimg,
                              fit: BoxFit.fitHeight,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePageTypeCell extends StatelessWidget {
  const HomePageTypeCell({
    super.key,
    required this.index,
    required this.type,
    required this.bean,
  });
  final int index;
  final ToolBoxGrideViewCellType type;
  final NewToolBoxListBean bean;

  _onTap(BuildContext context) {
    log("===首页item点击===   ${bean.toJson()}");
    ByNavigatorUtil.reportDataPoint(
      pageTag: "home_video_square_video",
      operateType: "click",
      funcDetailTag: bean.id.toString(),
      funcDetailImg: bean.bgimg,
    );
    final data = SubFunction.fromJson({
      "id": bean.id,
      "title": bean.title,
      "img_url": bean.icon,
      "jump_url": bean.jumpUrl,
      "jump_param": bean.jumpParam,
      "type": bean.type,
      "des": bean.des,
      "isNew": false,
    });
    // 传递完整的列表数据，用于后续页面使用
    ByCommonUtils.subFunctionCase(context, data, extraData: bean.toJson());
  }

  @override
  Widget build(BuildContext context) {
    final coverRatio = bean.coverRatio;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _onTap(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.only(bottom: 15.h),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.w),
                  child: coverRatio == 0
                      ? ConstrainedBox(
                          constraints: BoxConstraints(minHeight: 50.0.h),
                          child: CachedNetworkImage(
                            imageUrl: bean.bgimg,
                            fit: BoxFit.fitWidth,
                          ),
                        )
                      : AspectRatio(
                          aspectRatio: coverRatio,
                          child: CachedNetworkImage(
                            imageUrl: bean.bgimg,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.only(left: 5.w, right: 0, bottom: 10.h),
                  child: ByWidgetsUtil.commonText(
                    text: bean.title,
                    maxLines: 2,
                    fontSize: 12.sp,
                    textColor: ByColorUtil.CommonTextColor,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _onTap(context);
                        },
                        child: SizedBox(
                          height: 32.h,
                          child: ByWidgetsUtil.commonContainer(
                            alignment: Alignment.center,
                            bgColor: const Color(0xFFEAEEFF),
                            borerRadius: 20.h,
                            child: ByWidgetsUtil.commonRichText(
                              texts: [
                                const TextSpan(text: "创作同款"),
                                TextSpan(
                                  text: "  ${bean.useTime}",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.normal,
                                    color: ByColorUtil.TabTextColorSelected
                                        .withOpacity(0.8),
                                  ),
                                ),
                              ],
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              textColor: ByColorUtil.TabTextColorSelected,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 5.w),
                    // Stack(
                    //   clipBehavior: Clip.none,
                    //   children: [
                    //     SizedBox(
                    //       width: 65.w,
                    //       height: 32.h,
                    //       child: ByWidgetsUtil.commonContainer(
                    //         alignment: Alignment.center,
                    //         bgColor: const Color(0xFFF3F5F9),
                    //         borerRadius: 20.h,
                    //         child: ByWidgetsUtil.commonText(
                    //           text: bean.withdrawMoney,
                    //           fontSize: 14.sp,
                    //           fontWeight: FontWeight.w600,
                    //           textColor: ByColorUtil.CommonTextColor,
                    //         ),
                    //       ),
                    //     ),
                    //     Positioned(
                    //       right: 0,
                    //       top: -9.h,
                    //       child: ByWidgetsUtil.commonContainer(
                    //         bgColor: const Color(0xFFF49A2F),
                    //         padding: EdgeInsets.symmetric(
                    //             vertical: 2.h, horizontal: 4.w),
                    //         child: ByWidgetsUtil.commonText(
                    //             text: bean.withdrawMoneyTip,
                    //             fontSize: 10.sp,
                    //             fontWeight: FontWeight.normal,
                    //             textColor: const Color(0xFFFFFFFF)),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ],
            ),
            if (bean.icon.isNotEmpty)
              Positioned(
                right: 8.w,
                top: 10.h,
                width: 24.w,
                height: 24.h,
                child: CachedNetworkImage(
                  imageUrl: bean.icon,
                  fit: BoxFit.contain,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
