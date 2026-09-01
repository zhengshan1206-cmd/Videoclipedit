import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/core/util/manager/auth.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/guide_page.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/providers/video_extraction_provider.dart';
import 'package:video_clip_edit/v2/aiPhotoFix/models/ai_photo_fix_task_model.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';
import 'package:video_clip_edit/widgets/common/integral_vip_view.dart';
import 'package:video_clip_edit/widgets/common/right_navigation_bar.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../../modules/home/providers/words_extract_provider.dart';
import '../../../modules/home/words/beans/upload_info_bean.dart';
import '../../../utils/comon/by_ffmpeg_util.dart';
import '../../aiSquare/song/beans/rights_by_type.dart';
import '../provider/ai_photo_fix_management_provider.dart';
import '../provider/ai_photo_fix_provider.dart';
import '../widgets/before_after/src/before_after.dart';
import 'ai_photo_fix_management_page.dart';

class NewHdPhotoFixPage extends StatefulWidget {
  const NewHdPhotoFixPage({super.key});

  @override
  State<NewHdPhotoFixPage> createState() => _NewHdPhotoFixPageState();
}

class _NewHdPhotoFixPageState extends State<NewHdPhotoFixPage>
    with SingleTickerProviderStateMixin {
  late AiPhotoFixProvider provider;
  @override
  void initState() {
    super.initState();
    provider = context.read<AiPhotoFixProvider>();
    updateRights();
  }

  RightsByType? _rights;
  void updateRights() {
    provider.loadRights(
        type: 'refix_image_hd',
        onSuccess: (rights) {
          if (mounted) {
            setState(() {
              _rights = rights;
            });
          }
        });
  }

  void upload() async {
    FocusManager.instance.primaryFocus?.unfocus();
    // final isVip = context.read<LaunchProvider>().launchInfo?.isVip ?? 0;
    // if (isVip != 1) {
    //   ByNavRouterUtils.push(
    //     context,
    //     ChangeNotifierProvider(
    //       create: (BuildContext context) =>
    //           AiVipGuidProvider(),
    //       child: const AiVipGuidPage(),
    //     ),
    //   );
    //   return;
    // }

    final integralVipController = IntegralVipController.getOrPut();

    ///不是会员并且无试用-付费弹窗
    if (!chekVip() && integralVipController.isTest <= 0) {
      final provider = context.read<AiSquareProvider>();
      String mark = 'hd_photo_fix';
      provider.showModelPayDialog(context, mark);
      return;
    }

    // 检查积分是否足够
    if (!integralVipController.canContinueUse()) {
      integralVipController.showIntegralPayDialog();
      return;
    }
    AuthManager.materialAuth(
      onSuccess: () {
        ByCommonUtils.pickAssetsByType(
          context,
          maxCount: 1,
          type: RequestType.image,
          onSelectedCallback: (asstes) async {
            if (asstes.isEmpty) return;
            File? file = await asstes.first.file;
            if (file == null) return;
            ByFfmpegUtil.loadUploadInfo(
                type: MediaType.picture,
                onSuccess: (UploadInfoBean infoBean) {
                  ByFfmpegUtil.uploadFile(
                      infoBean: infoBean,
                      filePath: file.path,
                      onSuccess: (resp) {
                        ///增加鉴黄逻辑
                        ByFfmpegUtil.contentsRisk(
                            url: infoBean.objectUrl,
                            onSuccess: () {
                              if (mounted) {
                                final imageUrl = infoBean.objectUrl;
                                provider.generate(
                                  refImageUrl: imageUrl,
                                  type: kAiHdPhotoFixTaskType,
                                  onSuccess: () {
                                    updateRights();
                                    ByNavRouterUtils.pushReplacement(
                                        context,
                                        MultiProvider(
                                          providers: [
                                            ChangeNotifierProvider(
                                                create: (context) =>
                                                    AiPhotoFixManagementProvider()),
                                          ],
                                          child: const AiPhotoFixManagementPage(
                                              type: kAiHdPhotoFixTaskType),
                                        ));
                                  },
                                );
                              }
                            });
                      });
                });
          },
        );
      },
    );
    
  }

  void showRecords() {
    ByNavRouterUtils.push(
        context,
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
                create: (context) => AiPhotoFixManagementProvider()),
          ],
          child: AiPhotoFixManagementPage(type: kAiHdPhotoFixTaskType),
        ));
  }

  // 积分-vip-次数-消耗模块-老照片高清修复
  Widget _buildIntegralVipView() {
    return const IntegralVipView(
      requiredPoints: 0,
      type: "refix_image_hd", // 通过这个type请求权益接口获取实际积分
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            ByNavRouterUtils.goBack(context);
          },
          child: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            child: Image.asset(
              "assets/home/icon_back.png",
              color: Colors.black,
              width: 16,
              height: 16,
            ),
          ),
        ),
        actions: const [
          Center(
            //高清修复 /hd_photo_fix
            // child: RightNavigationBar(entranceType: 1),
            child: SizedBox(),
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/ai/aiPhotoFix/hd_bg@2x.png",
              fit: BoxFit.fitWidth,
            ),
          ),
          _buildBody(context),
        ],
      ),
    );
  }

  var _compareValue = 0.5;
  Widget _buildBody(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 228.5.h),
      child: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
            child: Center(
              child: Container(
                padding: EdgeInsets.all(1),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(18),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF4BB1FF),
                      Color(0xFFE7F1FB),
                      Color(0xFFFAB1FF),
                    ],
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.all(15.h),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(18),
                    ),
                  ),
                  child: Stack(
                    children: [
                      BeforeAfter(
                        value: _compareValue,
                        after: Image.asset(
                            'assets/ai/aiPhotoFix/hd_after@2x.png',
                            scale: 2),
                        before: Image.asset(
                            'assets/ai/aiPhotoFix/hd_before@2x.png',
                            scale: 2),
                        trackColor: Colors.white,
                        trackWidth: 2,
                        onValueChanged: (value) {
                          setState(() => _compareValue = value);
                        },
                      ),
                      Positioned(
                          left: 10.w,
                          top: 10.h,
                          child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 9.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF000000),
                                borderRadius: BorderRadius.circular(12.w),
                                border: Border.all(
                                    color: const Color(0xFFB0B1A3),
                                    width: 0.5.w),
                              ),
                              child: Text(
                                "修复前",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    height: 1.0),
                              ))),
                      Positioned(
                          right: 10.w,
                          top: 10.h,
                          child: Container(
                              padding:
                                  EdgeInsets.fromLTRB(5.5.w, 6.h, 9.w, 6.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF000000),
                                borderRadius: BorderRadius.circular(12.w),
                                border: Border.all(
                                    color: const Color(0xFFB0B1A3),
                                    width: 0.5.w),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                      "assets/ai/aiPhotoFix/fix_star@2x.png",
                                      scale: 2),
                                  SizedBox(width: 2.w),
                                  Text(
                                    "修复后",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        height: 1.0),
                                  ),
                                ],
                              )))
                    ],
                  ),
                ),
              ),
            ),
          )),
          buildBottomBar(),
        ],
      ),
    );
  }

  bool chekVip() {
    final isVip = context.read<LaunchProvider>().launchInfo?.isVip ?? 0;
    return isVip == 1;
    // if (isVip != 1) {
    //   context.read<PurchaseProvider>().loadVIPItems(
    //     onSuccess: () {
    //       showDialog(
    //         context: context,
    //         builder: (context) {
    //           return const DailogBonusLowestPrice();
    //         },
    //       );
    //     },
    //   );
    // }
  }

  Widget buildBottomBar() {
    final showFreeCount = _rights != null &&
        ((_rights!.currentIntegral == 0) || ((_rights!.freeCount > 0)));
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      color: Colors.white,
      child: SafeArea(
          top: false,
          child: Column(
            children: [
              _buildIntegralVipView(),
              Row(
                children: [
                  if (chekVip())
                    SizedBox(
                      height: 50,
                      child: FilledButton(
                        onPressed: showRecords,
                        style: FilledButton.styleFrom(
                          foregroundColor: const Color(0xFF5B4BF7),
                          backgroundColor: const Color(0xFFEAEEFF),
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "创作记录",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (chekVip()) SizedBox(width: 9.sp),
                  Expanded(
                      child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: upload,
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF5B4BF7),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "立即体验",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // if (showFreeCount)
                      //   Positioned(
                      //       top: -12,
                      //       right: 0,
                      //       child: Container(
                      //         padding: EdgeInsets.symmetric(
                      //             horizontal: 11.w, vertical: 3.h),
                      //         decoration: BoxDecoration(
                      //           color: const Color(0xFFFF2A70),
                      //           borderRadius: BorderRadius.circular(12),
                      //         ),
                      //         child: Text(
                      //           "限免x${_rights!.freeCount}",
                      //           style: TextStyle(
                      //             fontSize: 12.sp,
                      //             color: Colors.white,
                      //           ),
                      //         ),
                      //       )),
                    ],
                  ))
                ],
              ),
              if (_rights != null && !showFreeCount)
                Builder(builder: (context) {
                  var costIntegral = _rights!.currentIntegral.toDouble();
                  return Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/ai/aiVideo/coin@2x.png", scale: 2),
                        SizedBox(width: 4.w),
                        Text(
                          _rights!.userIntegral.toString(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Flexible(
                          child: Text(
                            "本次消耗${costIntegral.floor()}积分",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF0B1843).withOpacity(0.5),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                })
            ],
          )),
    );
  }
}
