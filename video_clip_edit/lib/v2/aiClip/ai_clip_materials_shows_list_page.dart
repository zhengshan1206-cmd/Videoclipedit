import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_time_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiClip/ai_sample_play_page.dart';
import 'package:video_clip_edit/v2/aiClip/beans/ai_material_item_bean.dart';
import 'package:video_clip_edit/v2/aiClip/beans/ai_show_list_item_bean.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_material_provider.dart';

class AiClipMaterialsShowsListPage extends StatefulWidget {
  const AiClipMaterialsShowsListPage({
    super.key,
    required this.itemBean,
  });

  final MaterialPack itemBean;

  @override
  State<AiClipMaterialsShowsListPage> createState() =>
      _AiClipMaterialsShowsListPageState();
}

class _AiClipMaterialsShowsListPageState
    extends State<AiClipMaterialsShowsListPage> {
  final EasyRefreshController _controller = EasyRefreshController(
      controlFinishRefresh: true, controlFinishLoad: true);

  @override
  void dispose() {
    byDebugPrint("-----dispose");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(
        context: context,
        title: "选择混剪素材",
        onPop: () {
          final provider = context.read<AiMaterialProvider>();
          provider.showListBeans.clear();
          provider.showListPage = 1;
          ByNavRouterUtils.goBack(context);
        },
      ),
      body: Stack(
        children: [
          _buildContents(context),
          _buidBottomBar(context),
        ],
      ),
    );
  }

  _buidBottomBar(BuildContext context) {
    final count = context
        .select<AiMaterialProvider, List<AiShowListItemBean>>(
          (value) => value.selectedShowListBeans,
        )
        .length;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: PhysicalModel(
        color: Colors.black,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            ByNavRouterUtils.goBack(context);
          },
          child: ByWidgetsUtil.commonContainer(
            borerRadius: 0,
            padding: EdgeInsets.only(
              left: 12.w,
              right: 12.w,
              top: 8.h,
              bottom: 8.h + ByScreenUtils.bottomSafeHeight,
            ),
            child: SizedBox(
              height: 50.h,
              child: ByWidgetsUtil.commonContainer(
                  alignment: Alignment.center,
                  bgColor: ByColorUtil.LoginBtnBgColor,
                  borerRadius: 12.w,
                  child: ByWidgetsUtil.commonRichText(
                    texts: [
                      const TextSpan(text: "确定"),
                      TextSpan(
                        text: "(已选$count)",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.normal,
                        ),
                      )
                    ],
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    textColor: ByColorUtil.WhiteColor,
                  )),
            ),
          ),
        ),
      ),
    );
  }

  _buildContents(BuildContext context) {
    final showListBeans =
        context.select<AiMaterialProvider, List<AiShowListItemBean>>(
      (value) => value.showListBeans,
    );
    return Positioned.fill(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            margin: EdgeInsets.symmetric(vertical: 8.h),
            height: 30.h,
            child: ByWidgetsUtil.commonTipsBar("请选择1-5个素材片段，如不选择将随机使用素材。",
                padding: EdgeInsets.symmetric(horizontal: 10.w)),
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: EasyRefresh(
              refreshOnStart: true,
              controller: _controller,
              onRefresh: () {
                _loadMaterials(context, reset: true, controller: _controller);
              },
              onLoad: () {
                _loadMaterials(context, reset: false, controller: _controller);
              },
              child: GridView.builder(
                padding: EdgeInsets.only(
                  bottom: 76.h + ByScreenUtils.bottomSafeHeight,
                  left: 12.w,
                  right: 12.w,
                ),
                itemCount: showListBeans.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 11.w,
                  mainAxisSpacing: 10.h,
                ),
                itemBuilder: (context, index) {
                  final AiShowListItemBean bean = showListBeans[index];
                  return AiClipShowListCell(index: index, bean: bean);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  void _loadMaterials(
    BuildContext context, {
    bool reset = false,
    required EasyRefreshController controller,
  }) {
    final provider = context.read<AiMaterialProvider>();
    provider.aiLoadShowList(
      reset: reset,
      pid: widget.itemBean.id,
      controller: controller,
    );
  }
}

class AiClipShowListCell extends StatelessWidget {
  const AiClipShowListCell({
    super.key,
    required this.index,
    required this.bean,
  });

  final int index;
  final AiShowListItemBean bean;
  @override
  Widget build(BuildContext context) {
    final provider = context.read<AiMaterialProvider>();
    final maxCount = provider.maxSelectedShowCount;
    final selectedShowListBeans =
        context.select<AiMaterialProvider, List<AiShowListItemBean>>(
      (value) => value.selectedShowListBeans,
    );
    final selected = selectedShowListBeans.map((e) => e.id).contains(bean.id);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final selectedCount = selectedShowListBeans.length;
        if (selectedCount >= maxCount && selected == false) {
          BotToast.showText(text: "短剧素材最多选择${maxCount}条!");
          return;
        }

        /// 修改选中状态
        provider.updateSelectedShowListItemBeansWithBean(bean);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.w),
        child: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                  imageUrl: bean.coverUrl, fit: BoxFit.cover),
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (ctx) => AiSamplePlayPage(videoUrl: bean.videoUrl),
                  );
                },
                child: Image.asset(
                  "assets/ai/clip/ai_clip_icon_sample_play.png",
                  width: 40.w,
                  height: 40.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 50.h,
              child: ByWidgetsUtil.gradientBgContainer(
                gradient: ByColorUtil.lineareGradient(
                  colorStart: const Color(0xFF000000).withOpacity(0),
                  colorEnd: const Color(0xFF000000).withOpacity(0.7),
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                alignment: Alignment.bottomLeft,
                borderRadius: 0,
                padding: EdgeInsets.only(
                  left: 6.w,
                  bottom: 8.h,
                  right: 5.w,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ByWidgetsUtil.commonText(
                        text: bean.videoTitle,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        textColor: const Color(0xFFFFFFFF),
                      ),
                    ),
                    ByWidgetsUtil.commonText(
                      text: "约${ByTimeUtils.formatWithSeconds(bean.duration)}",
                      fontSize: 12.sp,
                      fontWeight: FontWeight.normal,
                      textColor: const Color(0xFFFFFFFF),
                    ),
                  ],
                ),
              ),
            ),
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
          ],
        ),
      ),
    );
  }
}
