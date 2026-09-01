import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/beans/ai_draw_img_details_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_work_management_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/widgets/ai_draw_management_list_view.dart';

import '../../../utils/comon/by_common_utils.dart';
import '../../../utils/comon/by_nav_router_utils.dart';
import 'ai_draw_page.dart';

Future<AiDrawImgDetailsBean?> showAiDrawPicker(
  BuildContext context, {
  AiDrawWorkManagementProvider? provider,
}) async {
  return await showModalBottomSheet<AiDrawImgDetailsBean>(
    context: context,
    scrollControlDisabledMaxHeightRatio: 0.7,
    clipBehavior: Clip.antiAlias,
    enableDrag: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
    builder: (context) => ChangeNotifierProvider<AiDrawWorkManagementProvider>(
        create: (_) => provider ?? AiDrawWorkManagementProvider(),
        child: const AiDrawPicker()),
  );
}

class AiDrawPicker extends StatefulWidget {
  const AiDrawPicker({super.key});

  @override
  State<AiDrawPicker> createState() => _AiDrawPickerState();
}

class _AiDrawPickerState extends State<AiDrawPicker> {
  @override
  Widget build(BuildContext context) {
    final List<AiDrawImgDetailsBean> videoRecordBeans = context
        .select<AiDrawWorkManagementProvider, List<AiDrawImgDetailsBean>>(
      (p) => p.workRecordBeans,
    );
    final times =
        context.select<AiDrawWorkManagementProvider, int>((p) => p.times);
    Widget contentView;
    if (videoRecordBeans.isEmpty && times > 0) {
      contentView = ByWidgetsUtil.commonNoData(
        prompts: "",
        bottomWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "暂无绘画记录，",
              style: TextStyle(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.24),
                fontSize: 14.sp,
              ),
            ),
            GestureDetector(
              onTap: () => ByNavRouterUtils.pushReplacement(
                context,
                ChangeNotifierProvider(
                  create: (_) => AiDrawProvider(),
                  child: const AiDrawPage(),
                ),
              ),
              child: Text(
                "去绘画",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF5B4BF7),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      contentView = EasyRefresh(
        refreshOnStart: true,
        onRefresh: () {
          _loadImages(reset: true);
        },
        onLoad: _loadImages,
        canRefreshAfterNoMore: true,
        canLoadAfterNoMore: false,
        child: GridView.builder(
          itemCount: videoRecordBeans.length,
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
            childAspectRatio: 17 / 25,
          ),
          itemBuilder: (context, index) => AiDrawPickerListViewCell(
            index: index,
            bean: videoRecordBeans[index],
          ),
        ),
      );
    }

    return Container(
      color: ByColorUtil.CommonPageBgColor,
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: 32,
            child: Container(
              height: 4.h,
              width: 48.w,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: contentView,
          ),
        ],
      ),
    );
  }

  FutureOr _loadImages({
    bool reset = false,
  }) {
    final provider = context.read<AiDrawWorkManagementProvider>();
    if (reset) {
      provider.resetPages();
    }
    provider.loadPictureList();
  }
}

class AiDrawManagementListView extends StatefulWidget {
  const AiDrawManagementListView({
    super.key,
  });

  @override
  State<AiDrawManagementListView> createState() =>
      _AiDrawManagementListViewState();
}

class _AiDrawManagementListViewState extends State<AiDrawManagementListView> {
  @override
  Widget build(BuildContext context) {
    byDebugPrint("AiDrawManagementListView:----");
    final List<AiDrawImgDetailsBean> videoRecordBeans = context
        .select<AiDrawWorkManagementProvider, List<AiDrawImgDetailsBean>>(
      (p) => p.workRecordBeans,
    );
    return GridView.builder(
      itemCount: videoRecordBeans.length,
      padding: EdgeInsets.only(bottom: 66.h + ByScreenUtils.bottomSafeHeight),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 17 / 25,
      ),
      itemBuilder: (context, index) => AiDrawPickerListViewCell(
        index: index,
        bean: videoRecordBeans[index],
      ),
    );
  }
}

class AiDrawPickerListViewCell extends StatelessWidget {
  const AiDrawPickerListViewCell({
    super.key,
    required this.index,
    required this.bean,
  });

  final int index;
  final AiDrawImgDetailsBean bean;
  @override
  Widget build(BuildContext context) {
    byDebugPrint("---AiDrawPickerListViewCell");
    final status = AiCartoonPictureStatusExt.fromRawValue(bean.status);

    bool showCommonBg = [
      AiCartoonPictureStatus.pictureCreate,
      AiCartoonPictureStatus.picturePredictPrice,
      AiCartoonPictureStatus.pictureGenerating
    ].contains(status);

    bool showFaildBg = [AiCartoonPictureStatus.failed].contains(status);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (status == AiCartoonPictureStatus.complete) {
          Navigator.pop(context, bean);
        } else if (status == AiCartoonPictureStatus.failed) {
          BotToast.showText(text: "无法选择生成失败的图片");
        } else if (status == AiCartoonPictureStatus.pictureGenerating) {
          BotToast.showText(text: "无法选择生成中的图片");
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (showCommonBg)
              Positioned.fill(
                  child: Image.asset(
                "assets/ai/ai_cartoon_video_bg.png",
                fit: BoxFit.cover,
              )),
            if (showFaildBg)
              Positioned.fill(
                  child: Image.asset(
                "assets/ai/ai_cartoon_video_bg_faild.png",
                fit: BoxFit.cover,
              )),
            if (status == AiCartoonPictureStatus.complete)
              Positioned.fill(
                  child: CachedNetworkImage(
                imageUrl: bean.picUrl,
                fit: BoxFit.cover,
              )),
            if (showCommonBg)
              Positioned.fill(
                  child: Column(
                children: [
                  SizedBox(height: 75.h),
                  ByWidgetsUtil.activityIndicator(),
                  SizedBox(height: 50.h),
                  ByWidgetsUtil.commonText(
                    text: "生成中...",
                    textColor: Colors.white,
                    fontSize: 14.sp,
                  )
                ],
              )),
            // Positioned(
            //   left: 0,
            //   right: 0,
            //   bottom: 0,
            //   height: 60.h,
            //   child: ByWidgetsUtil.gradientBgContainer(
            //     borderRadius: 0,
            //     padding: EdgeInsets.zero,
            //     gradient: ByColorUtil.lineareGradient(
            //       colorStart: const Color(0xFF000000),
            //       colorEnd: const Color(0xFF000000).withOpacity(0.01),
            //       begin: Alignment.bottomCenter,
            //       end: Alignment.topCenter,
            //     ),
            //     child: const SizedBox.expand(),
            //   ),
            // ),
            if (status == AiCartoonPictureStatus.failed)
              Positioned.fill(
                  child: Center(
                child: Image.asset(
                  "assets/ai/ai_cartoon_video_faild.png",
                  width: 32.w,
                  height: 32.h,
                  fit: BoxFit.contain,
                ),
              )),
          ],
        ),
      ),
    );
  }
}
