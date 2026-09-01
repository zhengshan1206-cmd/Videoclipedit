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
import 'package:video_clip_edit/v2/aiSquare/draw/ai_draw_page.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/beans/ai_draw_img_details_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_work_management_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/widgets/ai_draw_management_list_view.dart';

import '../../../utils/comon/by_common_utils.dart';
import '../../../utils/comon/by_nav_router_utils.dart';

Future<AiDrawImgDetailsBean?> showMyPicturePicker(
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
        child: const MyPicturePicker()),
  );
}

class MyPicturePicker extends StatefulWidget {
  const MyPicturePicker({super.key});

  @override
  State<MyPicturePicker> createState() => _MyPicturePickerState();
}

class _MyPicturePickerState extends State<MyPicturePicker> {
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
      padding: EdgeInsets.only(
        left: 15.w,
        right: 15.w,
        top: 10.h,
        bottom: 15.h + ByScreenUtils.bottomSafeHeight,
      ),
      decoration: BoxDecoration(
        color: ByColorUtil.WhiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.w),
          topRight: Radius.circular(18.w),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Row(
                children: [
                  const Spacer(),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      ByNavRouterUtils.goBack(context);
                    },
                    child: Container(
                      width: 22.w,
                      height: 32.h,
                      alignment: Alignment.center,
                      child: Image.asset(
                        "assets/home/icon_close_dark.png",
                        width: 14.w,
                        height: 14.w,
                      ),
                    ),
                  )
                ],
              ),
              Text(
                "我的图片",
                style: TextStyle(
                    color: Color(0xFF0B1843),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold),
              ),
            ],
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
