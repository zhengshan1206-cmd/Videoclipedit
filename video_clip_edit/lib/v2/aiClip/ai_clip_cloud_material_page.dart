import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiClip/ai_sample_play_page.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_provider.dart';
import 'package:video_clip_edit/v2/aiClip/beans/ai_oepning_video_item_bean.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_opening_provider.dart';

class AiClipCloudMaterialPage extends StatefulWidget {
  const AiClipCloudMaterialPage({super.key});

  @override
  State<AiClipCloudMaterialPage> createState() =>
      _AiClipCloudMaterialPageState();
}

class _AiClipCloudMaterialPageState extends State<AiClipCloudMaterialPage> {
  @override
  void initState() {
    super.initState();

    _loadData();
  }

  void _loadData() {
    context.read<AiClipOpeningProvider>().loadAiMaterialOpeningList(
          videoRatio: context.read<AiClipProvider>().selectedRatioId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final bottomBarH = 66.h + ByScreenUtils.bottomSafeHeight;
    final openingBeans =
        context.select<AiClipOpeningProvider, List<AiOpeningVideoItemBean>>(
      (value) => value.openingBeans,
    );
    return Scaffold(
      body: Stack(
        children: [
          ListView.builder(
            padding: EdgeInsets.only(bottom: bottomBarH),
            itemCount: openingBeans.length,
            itemBuilder: (context, index) {
              return AiClipCloudMaterialCell(
                index: index,
                bean: openingBeans[index],
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: bottomBarH,
            child: PhysicalModel(
              color: ByColorUtil.BlackColor,
              child: Container(
                color: ByColorUtil.WhiteColor,
                child: Container(
                  height: 50.h,
                  margin: EdgeInsets.only(
                    left: 12.w,
                    right: 12.w,
                    top: 8.h,
                    bottom: 8.h + ByScreenUtils.bottomSafeHeight,
                  ),
                  child: ByWidgetsUtil.commonBtn(
                    padding: EdgeInsets.zero,
                    borderRadius: 12.w,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    title: "确定选择",
                    onClick: () {
                      ByNavRouterUtils.goBack(context);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AiClipCloudMaterialCell extends StatelessWidget {
  const AiClipCloudMaterialCell({
    super.key,
    required this.index,
    required this.bean,
  });
  final int index;
  final AiOpeningVideoItemBean bean;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            children: [
              SizedBox(
                width: 3.w,
                height: 14.h,
                child: ByWidgetsUtil.commonContainer(
                    bgColor: ByColorUtil.LoginBtnBgColor,
                    borerRadius: 2.w,
                    child: Container()),
              ),
              SizedBox(width: 4.w),
              ByWidgetsUtil.commonText(
                text: bean.materialName,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(width: 5.w),
              Offstage(
                offstage: bean.vipLimit != 1,
                child: SizedBox(
                  height: 16.h,
                  child: ByWidgetsUtil.gradientBgContainer(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    borderRadius: 4.w,
                    gradient: ByColorUtil.lineareGradient(
                      colorStart: const Color(0xFFFF8D05),
                      colorEnd: const Color(0xFFFFC763),
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    child: ByWidgetsUtil.commonText(
                      text: "会员专享",
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      textColor: ByColorUtil.WhiteColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: SizedBox(
            height: 248.h,
            child: GridView.builder(
              scrollDirection:
                  bean.details.length > 2 ? Axis.horizontal : Axis.vertical,
              itemCount: bean.details.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.h,
                mainAxisSpacing: 8.w,
              ),
              itemBuilder: (context, index) {
                return AiMaterialOpeningGridCell(
                  index: index,
                  detail: bean.details[index],
                );
              },
            ),
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}

class AiMaterialOpeningGridCell extends StatelessWidget {
  const AiMaterialOpeningGridCell({
    super.key,
    required this.index,
    required this.detail,
  });

  final int index;
  final Detail detail;

  @override
  Widget build(BuildContext context) {
    final selectedOpeningBean = context.select<AiClipOpeningProvider, Detail?>(
      (value) => value.selectedOpeningBean,
    );
    final selected = selectedOpeningBean?.id == detail.id;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.w),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          context
              .read<AiClipOpeningProvider>()
              .updateSelectedOpeningBean(detail);
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: detail.coverUrl,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 40.h,
              child: ByWidgetsUtil.gradientBgContainer(
                gradient: ByColorUtil.lineareGradient(
                  colorStart: const Color(0xFF000000).withOpacity(0),
                  colorEnd: const Color(0xFF000000).withOpacity(0.7),
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                alignment: Alignment.bottomLeft,
                borderRadius: 0,
                padding: EdgeInsets.only(left: 5.w, bottom: 10.h),
                child: Container(),
              ),
            ),
            // Positioned.fill(
            //   child: ByWidgetsUtil.commonContainer(
            //     border: Border.all(
            //       color: selected
            //           ? ByColorUtil.TabTextColorSelected
            //           : Colors.transparent,
            //       width: 2,
            //     ),
            //     bgColor: Colors.transparent,
            //     child: Container(),
            //   ),
            // ),
            // Positioned(
            //   right: 0,
            //   top: 0,
            //   child: Offstage(
            //     offstage: !selected,
            //     child: ByWidgetsUtil.svgAsset(
            //       filePath: "assets/ai/clip/ai_clip_icon_ratio_selected.svg",
            //       width: 24,
            //       height: 24,
            //     ),
            //   ),
            // ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 50.h,
              child: ByWidgetsUtil.gradientBgContainer(
                gradient: ByColorUtil.lineareGradient(
                  colorStart: const Color(0xFF000000).withOpacity(0),
                  colorEnd: const Color(0xFF000000).withOpacity(0),
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                alignment: Alignment.topRight,
                borderRadius: 0,
                padding: EdgeInsets.only(right: 10.w, top: 10.h),
                child: ByWidgetsUtil.svgAsset(
                  filePath: selected
                      ? "assets/ai/clip/ai_clip_icon_selected.svg"
                      : "assets/ai/clip/ai_clip_icon_unselected.svg",
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            Positioned(
              left: 10.w,
              bottom: 10.h,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (ctx) => AiSamplePlayPage(
                      videoUrl: detail.videoUrl,
                    ),
                  );
                },
                child: Image.asset(
                  "assets/ai/clip/ai_clip_icon_sample_play.png",
                  width: 24.w,
                  height: 24.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
