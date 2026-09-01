// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_permission_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/ai_draw_management_page.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/widgets/ai_imgs_downoad_dialog.dart';
import 'package:video_clip_edit/v2/minorMode/minor_mode_ui.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_image_preview_page.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/beans/ai_draw_my_work_detail_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_work_management_provider.dart';

import 'ai_draw_page.dart';

class AiDrawWorkDetailsPage extends StatefulWidget {
  const AiDrawWorkDetailsPage({super.key, required this.workId, this.type});

  final int workId;
  final String? type;

  @override
  State<AiDrawWorkDetailsPage> createState() => _AiDrawWorkDetailsPageState();
}

class _AiDrawWorkDetailsPageState extends State<AiDrawWorkDetailsPage> {
  AiMyWorkDetailItemBean? workDetailItemBean;
  @override
  void initState() {
    super.initState();

    _loadWorkDetails();
  }

  ///做同款的点击事件
  void doSameCase() {
    ByNavigatorUtil.checkLogin(
      context: context,
      nextStepEvent: () {
        final provider = AiDrawProvider();
        provider.desc = workDetailItemBean!.prompt;
        provider.selectedStyleId = workDetailItemBean!.modelId;
        if (widget.type == "ai_draw") {
          ByNavRouterUtils.push(
            context,
            ChangeNotifierProvider(
              create: (context) => provider,
              child: const AiDrawPage(),
            ),
          );
          return;
        }
        provider.startSameStyleCreatePreview(
          caseBean: workDetailItemBean!,
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
    return Scaffold(
      body: Stack(
        children: [
          if (workDetailItemBean != null)
            ListView(
              padding: EdgeInsets.only(bottom: 66.h),
              children: [
                Stack(
                  children: [
                    Center(
                      child: CachedNetworkImage(
                        alignment: Alignment.center,
                        imageUrl: workDetailItemBean!.picUrl,
                        fit: BoxFit.cover,
                        height: 460.h,
                        width: 1.sw,
                      ),
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
                              tag: workDetailItemBean!.id,
                              url: workDetailItemBean!.picUrl,
                            ),
                          );
                        },
                        child: Hero(
                          tag: workDetailItemBean!.id,
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
                        text: workDetailItemBean!.model,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(
                      height: 32.h,
                      child: MinorModeUi.hideWhenRestricted(
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            final status = await ByPermissionUtils.storage();
                            if (!status) return;
                            showDialog(
                              context: context,
                              builder: (c) {
                                return AiImgsDownoadDialog(
                                  contents: "",
                                  maxLine: 10,
                                  cancelBtnTitle: "取消",
                                  confirmBtnTitle: "确定",
                                  confirmCallback: () {},
                                  imgUrls: [workDetailItemBean!.picUrl],
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
                    ),
                    SizedBox(width: 12.w),
                  ],
                ),
                SizedBox(height: 5.h),
                Container(
                  height: 0.5,
                  color: const Color(0xFFF3F5F9),
                  width: double.infinity,
                  margin: EdgeInsets.only(
                    left: 12.w,
                    right: 12.w,
                    bottom: 10.h,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Row(
                    children: [
                      ClipOval(
                        child: workDetailItemBean!.activeUserAvatar.isEmpty
                            ? Image.asset(
                                "assets/mine/mine_avarta.png",
                                width: 44.w,
                                height: 44.w,
                                fit: BoxFit.cover,
                              )
                            : CachedNetworkImage(
                                imageUrl: workDetailItemBean!.activeUserAvatar,
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
                            text: workDetailItemBean!.activeUserName.isEmpty
                                ? "未知"
                                : workDetailItemBean!.activeUserName,
                            textColor: const Color(0xFF0E1840),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          SizedBox(height: 5.h),
                          ByWidgetsUtil.commonText(
                            text:
                                "已入驻平台${workDetailItemBean!.activeUserCreateDays}天",
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
                  padding: EdgeInsets.only(
                    left: 12.w,
                    right: 12.w,
                    bottom: 15.h,
                  ),
                  child: ByWidgetsUtil.commonText(
                    text: workDetailItemBean!.prompt,
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
                      Clipboard.setData(
                        ClipboardData(text: workDetailItemBean!.prompt),
                      );
                      BotToast.showText(text: "复制成功");
                    },
                  ),
                ),
              ],
            ),
          MinorModeUi.hideWhenRestricted(
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
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            doSameCase();
                          },
                          child: SizedBox(
                            height: 50.h,
                            child: ByWidgetsUtil.commonContainer(
                              alignment: Alignment.center,
                              bgColor: ByColorUtil.LoginBtnBgColor,
                              borerRadius: 20.h,
                              child: ByWidgetsUtil.commonRichText(
                                texts: [const TextSpan(text: "做同款")],
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

  void _loadWorkDetails() {
    final provider = context.read<AiDrawProvider>();
    provider.loadWorkDetails(
      workId: widget.workId,
      onSuccess: (bean) {
        setState(() {
          workDetailItemBean = bean;
        });
      },
    );
  }
}
