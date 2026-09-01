import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/song/beans/rights_by_type.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_material_provider.dart';
import 'package:video_clip_edit/v2/hotReplica/repica_video_management_page.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_opening_provider.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/guide_page.dart';
import 'package:video_clip_edit/v2/hotReplica/providers/hot_case_replica_provider.dart';
import 'package:video_clip_edit/v2/hotReplica/providers/replica_video_management_provider.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/providers/video_extraction_provider.dart';
import 'package:video_clip_edit/widgets/common/right_navigation_bar.dart';

class ReplicaAppBar extends StatelessWidget {
  const ReplicaAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // double offset = context.select<HotCaseReplicaProvider, double>(
    //   (value) => value.offset,
    // );
    // double opacity = 0;
    // final navBarH = ByScreenUtils.navigationBarHeight;
    // if (offset >= navBarH) {
    //   opacity = 1;
    // } else {
    //   opacity = offset / navBarH;
    // }
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: Container(
        height: ByScreenUtils.navigationBarHeight,
        padding: EdgeInsets.only(
          top: ByScreenUtils.topSafeHeight,
          left: 12.w,
          right: 12.w,
        ),
        color: Colors.transparent,
        child: SizedBox(
            height: kToolbarHeight,
            child: Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.pop(context),
                  child: Image.asset(
                    "assets/home/icon_back.png",
                    width: 20.w,
                    height: 16.h,
                    fit: BoxFit.fitHeight,
                  ),
                ),
                const Spacer(),
                // SizedBox(
                //   width: 70.w,
                // ),
                // Expanded(
                //   child: ByWidgetsUtil.commonText(
                //     text: "爆款复刻",
                //     textAlign: TextAlign.center,
                //     textColor: ByColorUtil.CommonTextColor.withOpacity(
                //         opacity < 0.7 ? opacity / 2 : opacity),
                //     fontSize: 16,
                //     fontWeight: FontWeight.w700,
                //   ),
                // ),

              ],
            )),
      ),
    );
  }
}

class ReplicaBottomBar extends StatelessWidget {
  const ReplicaBottomBar({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final vipRights = context.select<HotCaseReplicaProvider, RightsByType?>(
      (value) => value.rightsByType,
    );
    final times = vipRights?.freeCount ?? 0;
    final integral = vipRights?.userIntegral ?? 0;
    final price = vipRights?.currentIntegral ?? 0;
    return PhysicalModel(
      color: const Color(0xFF000000).withOpacity(0.5),
      elevation: 1,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          top: 8.h,
          bottom: 8.h + ByScreenUtils.bottomSafeHeight,
          left: 12.w,
          right: 12.w,
        ),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 91.w,
                  height: 50.h,
                  child: ByWidgetsUtil.commonBtn(
                    title: '创作记录',
                    onClick: () {
                      ByNavRouterUtils.push(
                          context,
                          MultiProvider(providers: [
                            ChangeNotifierProvider(
                              create: (context) =>
                                  ReplicaVideoManagementProvider(),
                            ),
                          ], child: const RepicaVideoManagementPage()));
                    },
                    fontSize: 16.sp,
                    borderRadius: 12.w,
                    fontWeight: FontWeight.normal,
                    bgColor: const Color(0xFFEAEEFF),
                    textColor: ByColorUtil.TabTextColorSelected,
                  ),
                ),
                SizedBox(width: 9.w),
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          Future.delayed(const Duration(milliseconds: 300), () {
                            final provdier =
                                context.read<HotCaseReplicaProvider>();
                            final String shareUrl = provdier.inputValue;
                            if (shareUrl.isEmpty) {
                              BotToast.showText(text: "请输入或粘贴视频链接");
                              return;
                            }

                            final title = provdier.title;
                            // if (title.isEmpty) {
                            //   BotToast.showText(text: "请输入标题");
                            //   return;
                            // }

                            final providerClip = context.read<AiClipProvider>();
                            final materialProvider =
                                context.read<AiMaterialProvider>();
                            final openingProvider =
                                context.read<AiClipOpeningProvider>();
                            final selectedFontId = providerClip.selectedFontId;
                            final type = materialProvider.currentType;
                            final isClip = type == AiMaterialType.clip;
                            final packId = isClip
                                ? materialProvider.selectedClipMaterials
                                    .map((e) => e.id.toString())
                                    .join(",")
                                : materialProvider.selectedShowListBeans.isEmpty
                                    ? materialProvider.selectedShowId.toString()
                                    : "";
                            final videoSource = isClip
                                ? "1"
                                : materialProvider.selectedShowListBeans.isEmpty
                                    ? "1"
                                    : "2";

                            final selectedMineMaterialItemBeans =
                                materialProvider.selectedMineMaterialItemBeans;
                            final videoUrls = isClip
                                ? ""
                                : materialProvider
                                        .selectedShowListBeans.isNotEmpty
                                    ? materialProvider.selectedShowListBeans
                                        .map((e) => e.videoUrl)
                                        .join(",")
                                    : selectedMineMaterialItemBeans
                                        .map((e) => e.url)
                                        .join(",");
                            final headUrls =
                                openingProvider.selectedOpeningBean?.videoUrl ??
                                    materialProvider
                                        .selectedOpeningMaterialItemBeans
                                        .map((e) => e.url)
                                        .join(",");

                            final ratio = providerClip.selectedRatioId;

                            provdier.createHotCaseReplicaVideo(
                              shareUrl: shareUrl,
                              videoHeadUrls: headUrls,
                              videoUrls: videoUrls,
                              ratio: ratio.toString(),
                              materialPackId: packId,
                              videoSource: videoSource,
                              title: title,
                              fontStyle:
                                  selectedFontId == -1 ? 0 : selectedFontId,
                              onSuccess: () {
                                provdier.getVipRights();
                                ByNavRouterUtils.pushReplacement(
                                    context,
                                    MultiProvider(
                                        providers: [
                                          ChangeNotifierProvider(
                                            create: (context) =>
                                                ReplicaVideoManagementProvider(),
                                          ),
                                        ],
                                        child:
                                            const RepicaVideoManagementPage()));
                              },
                              onFaild: () {},
                            );
                          });
                        },
                        child: SizedBox(
                          height: 50.h,
                          child: ByWidgetsUtil.commonContainer(
                            borerRadius: 12.w,
                            alignment: Alignment.center,
                            bgColor: ByColorUtil.LoginBtnBgColor,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ByWidgetsUtil.commonText(
                                  text: "生成视频",
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  textColor: ByColorUtil.WhiteColor,
                                ),
                                // const SizedBox(height: 0),
                                // ByWidgetsUtil.commonText(
                                //   text:
                                //       "（消耗${context.select<AiDrawProvider, int>((value) => value.priceWithPoints)}积分）",
                                //   fontSize: 10.sp,
                                //   fontWeight: FontWeight.normal,
                                //   textColor: ByColorUtil.WhiteColor,
                                // )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0.w,
                        top: -12.h,
                        child: Offstage(
                          offstage: times == 0,
                          child: SizedBox(
                            height: 24.h,
                            child: ByWidgetsUtil.commonContainer(
                              borerRadius: 20.h,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 11.w),
                              child: ByWidgetsUtil.commonText(
                                text: "限免x${times}",
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                textColor: ByColorUtil.WhiteColor,
                              ),
                              bgColor: const Color(0xFFFF2A70),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Offstage(offstage: times > 0, child: SizedBox(height: 7.h)),
            Offstage(
              offstage: times > 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/mine/mine_score_coin.png",
                    width: 18,
                    height: 18,
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(width: 4),
                  ByWidgetsUtil.commonText(
                    text: "${integral}",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    textColor: ByColorUtil.CommonTextColor,
                  ),
                  const SizedBox(width: 10),
                  ByWidgetsUtil.commonText(
                    text: "本次消耗$price积分",
                    textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.normal,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReplicaMoreSettingsHeader extends StatelessWidget {
  const ReplicaMoreSettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 12.w),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ByWidgetsUtil.svgAsset(
                filePath: "assets/replica/replica_header_settings.svg",
                width: 16,
                height: 16,
              ),
              SizedBox(width: 4.w),
              ByWidgetsUtil.commonText(
                text: "更多设置",
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            height: 30.h,
            child: CupertinoSwitch(
              value: context.select<HotCaseReplicaProvider, bool>(
                (value) => value.moreSettingsOn,
              ),
              activeColor: ByColorUtil.LoginBtnBgColor,
              trackColor: const Color(0xFFB5B9C6),
              thumbColor: const Color(0xFFF8F8F8),
              // inactiveTrackColor: ByColorUtil.CommonTextColor.withOpacity(0.2),
              // trackOutlineColor:
              //     const WidgetStatePropertyAll(Colors.transparent),
              onChanged: (value) {
                FocusScope.of(context).requestFocus(FocusNode());
                context
                    .read<HotCaseReplicaProvider>()
                    .changeMoreSettingsOn(value);
              },
            ),
          ),
          SizedBox(width: 12.w),
        ],
      ),
    );
  }
}
