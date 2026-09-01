import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_image_preview_page.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/ai_draw_management_page.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/beans/ai_draw_style_case_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_work_management_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/widgets/ai_imgs_downoad_dialog.dart';

class AiSameCasePage extends StatelessWidget {
  const AiSameCasePage({
    super.key,
    required this.caseBean,
    required this.preview,
  });
  final AiDrawStyleCaseBean caseBean;
  final bool preview;

  void doSameCase({required BuildContext context}) {
    ByNavigatorUtil.checkLogin(
      context: context,
      nextStepEvent: () {
        final provider = AiDrawProvider();
        provider.startSameStyleCreate(
          caseBean: caseBean,
          onSuccess: (taskID) {
            /// 进入到进度查询页面
            ByNavRouterUtils.push(
              context,
              ChangeNotifierProvider(
                create: (context) => AiDrawWorkManagementProvider(),
                child: const AiDrawManagementPage(),
              ),
            );
          },
          onFailed: () {
            BotToast.showText(text: "创作失败，请稍后再试");
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPreview = preview == true;
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(bottom: 66.h),
            children: [
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: caseBean.picUrl,
                    fit: BoxFit.cover,
                    height: 420.h,
                    width: double.infinity,
                  ),
                  Positioned(
                    bottom: 10.h,
                    right: 12.w,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AiCartoonImagePreviewPage(
                            tag: caseBean.id,
                            url: caseBean.picUrl,
                          ),
                        );
                      },
                      child: Hero(
                        tag: caseBean.id,
                        child: SizedBox(
                          width: 21.w,
                          height: 21.h,
                          child: Image.asset(
                            "assets/ai/ai_same_case_preview.png",
                            width: 32.w,
                            height: 32.h,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    // child: GestureDetector(
                    //   behavior: HitTestBehavior.opaque,
                    //   onTap: () {},
                    //   child: Image.asset(
                    //     "assets/ai/ai_same_case_preview.png",
                    //     width: 32.w,
                    //     height: 32.h,
                    //     fit: BoxFit.contain,
                    //   ),
                    // ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ByWidgetsUtil.commonText(
                      text: caseBean.model,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(
                    height: 32.h,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        LaunchProvider provider =
                            context.read<LaunchProvider>();
                        if (provider.launchInfo?.isVip != 1) {
                          provider.gotoPay(
                            context,
                            closePay: true,
                            replace: false,
                          );
                          return;
                        }
                        showDialog(
                          context: context,
                          builder: (c) {
                            return AiImgsDownoadDialog(
                              contents: "",
                              maxLine: 10,
                              cancelBtnTitle: "取消",
                              confirmBtnTitle: "确定",
                              confirmCallback: () {},
                              imgUrls: [caseBean.picUrl],
                            );
                          },
                        );
                      },
                      child: ByWidgetsUtil.commonContainer(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        bgColor: const Color(0xFFEBEEFD),
                        borerRadius: 9.w,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 13,
                              height: 12,
                              child: Image.asset(
                                "assets/ai/ai_same_case_download.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            ByWidgetsUtil.commonText(
                              text: "保存",
                              textColor: const Color(0xFF584CEE),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                ],
              ),
              SizedBox(height: 5.h),
              Offstage(
                offstage: isPreview,
                child: Row(
                  children: [
                    SizedBox(width: 12.w),
                    ByWidgetsUtil.commonText(
                      text: "${caseBean.useTime}浏览",
                      fontSize: 12.sp,
                      fontWeight: FontWeight.normal,
                      textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                    ),
                    SizedBox(width: 10.w),
                    ..._buildLabels(),
                    SizedBox(width: 5.w),
                    SizedBox(
                      height: 18.h,
                      child: ByWidgetsUtil.btnWithIcon(
                        borderRadius: 9.h,
                        fontSize: 12.sp,
                        padding: const EdgeInsets.only(left: 4, right: 6),
                        bgColor: const Color(0xFFF64556),
                        title: "HOT",
                        contentGap: 2,
                        iconW: 12,
                        iconH: 12,
                        fontWeight: FontWeight.bold,
                        iconPath: "assets/ai/ai_same_case_hot.png",
                        onClick: () {},
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15.h),
              Container(
                height: 0.5,
                color: const Color(0xFFF3F5F9),
                width: double.infinity,
                margin: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 10.h),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Row(
                  children: [
                    ClipOval(
                      child: caseBean.activeUserAvatar.isEmpty
                          ? Image.asset(
                              "assets/mine/mine_avarta.png",
                              width: 44.w,
                              height: 44.w,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: caseBean.activeUserAvatar,
                              width: 44.w,
                              height: 44.w,
                              fit: BoxFit.cover,
                            ),
                    ),
                    SizedBox(width: 10.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ByWidgetsUtil.commonText(
                          text: caseBean.activeUserName.isEmpty
                              ? "未知"
                              : caseBean.activeUserName,
                          textColor: const Color(0xFF0E1840),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(height: 5.h),
                        ByWidgetsUtil.commonText(
                          text: "已入驻平台${caseBean.activeUserCreateDays}天",
                          textColor: const Color(0xFF0E1840).withOpacity(0.5),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.normal,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: 0.5,
                color: const Color(0xFFF3F5F9),
                width: double.infinity,
                margin: EdgeInsets.only(
                  left: 12.w,
                  right: 12.w,
                  bottom: 15.h,
                  top: 10.h,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 12.w, bottom: 12.h),
                child: ByWidgetsUtil.commonText(
                  text: "提示词",
                  textColor: const Color(0xFF0E1840),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 15.h),
                child: ByWidgetsUtil.commonText(
                  text: caseBean.prompt,
                  textColor: const Color(0xFF0E1840).withOpacity(0.5),
                  fontSize: 14.sp,
                  maxLines: 100,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Container(
                height: 44.h,
                margin: EdgeInsets.symmetric(horizontal: 12.w),
                child: ByWidgetsUtil.btnWithIcon(
                  borderRadius: 9.h,
                  fontSize: 12.sp,
                  padding: const EdgeInsets.only(left: 4, right: 6),
                  bgColor: const Color(0xFFF8FAFB),
                  title: "复制",
                  textColor: const Color(0xFF0E1840).withOpacity(0.5),
                  contentGap: 5.w,
                  iconW: 12,
                  iconH: 14,
                  fontWeight: FontWeight.bold,
                  iconPath: "assets/ai/ai_same_case_copy.png",
                  onClick: () {
                    Clipboard.setData(ClipboardData(text: caseBean.prompt));
                    BotToast.showText(text: "复制成功");
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: PhysicalModel(
              color: Colors.white,
              child: Container(
                height: Platform.isAndroid ? 66.h : 86.h,
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Row(
                  children: [
                    Offstage(
                      offstage: isPreview,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {},
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            SizedBox(
                              height: 50.h,
                              child: ByWidgetsUtil.commonContainer(
                                alignment: Alignment.center,
                                bgColor: const Color(0xFFF3F5F9),
                                borerRadius: 50.h,
                                padding: EdgeInsets.symmetric(horizontal: 19.w),
                                child: ByWidgetsUtil.commonText(
                                  text: caseBean.withdrawMoney,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  textColor: ByColorUtil.CommonTextColor,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: -9.h,
                              child: ByWidgetsUtil.commonContainer(
                                bgColor: const Color(0xFFF49A2F),
                                padding: EdgeInsets.symmetric(
                                  vertical: 2.h,
                                  horizontal: 4.w,
                                ),
                                child: ByWidgetsUtil.commonText(
                                  text: caseBean.withdrawMoneyTip,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.normal,
                                  textColor: const Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          doSameCase(context: context);
                        },
                        child: SizedBox(
                          height: 50.h,
                          child: ByWidgetsUtil.commonContainer(
                            alignment: Alignment.center,
                            bgColor: ByColorUtil.LoginBtnBgColor,
                            borerRadius: 50.h,
                            child: ByWidgetsUtil.commonRichText(
                              texts: isPreview
                                  ? [const TextSpan(text: "做同款")]
                                  : [
                                      const TextSpan(text: "做同款"),
                                      TextSpan(
                                        text: "  ${caseBean.useTime}",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.normal,
                                          color: ByColorUtil.WhiteColor
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              textColor: ByColorUtil.WhiteColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 11,
            top: ByScreenUtils.topSafeHeight + kToolbarHeight * 0.5 - 16,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                ByNavRouterUtils.goBack(context);
              },
              child: Image.asset(
                "assets/ai/ai_same_case_back.png",
                width: 32,
                height: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildLabels() {
    final List widgets = [];
    final labels = caseBean.labels;
    for (var element in labels) {
      widgets.add(SizedBox(width: 5.w));
      widgets.add(
        SizedBox(
          height: 18.sp,
          child: ByWidgetsUtil.commonBtn(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            borderColor: const Color(0xFF040A22),
            borderWidth: 0.5,
            bgColor: ByColorUtil.WhiteColor,
            title: element,
            fontSize: 12.sp,
            fontWeight: FontWeight.normal,
            textColor: const Color(0xFF0E1840),
            onClick: () {},
          ),
        ),
      );
    }
    return widgets;
  }
}
