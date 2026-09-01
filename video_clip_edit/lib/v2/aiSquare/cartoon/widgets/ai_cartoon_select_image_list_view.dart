import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_image_preview_page.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_image_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_select_image_provider.dart';

class AiCartoonSelectImageListView extends StatefulWidget {
  const AiCartoonSelectImageListView({
    super.key,
    required this.ratio,
    required this.pid,
    required this.imageBean,
    required this.controller,
  });

  final String ratio;
  final String pid;
  final AiCartoonImageBean imageBean;
  final EasyRefreshController controller;

  @override
  State<AiCartoonSelectImageListView> createState() =>
      _AiCartoonSelectImageListViewState();
}

class _AiCartoonSelectImageListViewState
    extends State<AiCartoonSelectImageListView> {
  final Map<String, double> ratioMap = {
    "16:9": 16 / 9,
    "9:9": 9 / 6,
    "4:3": 4 / 3,
    "3:4": 3 / 4,
    "1:1": 1 / 1,
  };

  @override
  Widget build(BuildContext context) {
    getRatio(String ra) {
      return ratioMap[ra] ?? 1;
    }

    final images = context.select<AiCartoonSelectImageProvider, List<String>>(
      (p) => p.images,
    );
    return EasyRefresh(
      refreshOnStart: true,
      onRefresh: () {
        _loadImages(reset: true);
      },
      onLoad: _loadImages,
      canRefreshAfterNoMore: true,
      canLoadAfterNoMore: false,
      controller: widget.controller,
      child: GridView.builder(
        padding: EdgeInsets.only(bottom: 66.h),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return AiCartoonSelectImageListViewCell(index: index);
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10.h,
          crossAxisSpacing: 10.w,
          childAspectRatio: getRatio(widget.ratio),
        ),
      ),
    );
  }

  FutureOr _loadImages({
    bool reset = false,
  }) {
    final provider = context.read<AiCartoonSelectImageProvider>();
    String keywords = widget.imageBean.text;

    if (reset) {
      provider.resetPages();
    }

    if (provider.keywords.isNotEmpty) {
      keywords = provider.keywords;
    }
    provider.loadImages(
      pid: widget.pid,
      imgId: widget.imageBean.id,
      keyword: keywords,
    );
  }
}

class AiCartoonSelectImageListViewCell extends StatelessWidget {
  const AiCartoonSelectImageListViewCell({
    super.key,
    required this.index,
  });

  final int index;

  @override
  Widget build(BuildContext context) {
    final selectedImageIndex = context
        .select<AiCartoonSelectImageProvider, int>((p) => p.selectedImageIndex);
    final selected = selectedImageIndex == index;
    final provider = context.read<AiCartoonSelectImageProvider>();
    final images = provider.images;
    return GestureDetector(
      onTap: () {
        provider.updateSelectedImageIndex(index);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.w),
        child: Stack(
          children: [
            Container(),
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl:
                    context.read<AiCartoonSelectImageProvider>().images[index],
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Offstage(
                offstage: !selected,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.w),
                    border: Border.all(
                      color: ByColorUtil.TabTextColorSelected,
                      width: 3.w,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Offstage(
                offstage: !selected,
                child: Image.asset(
                  "assets/ai/ai_cartton_selected.png",
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              bottom: 10.h,
              right: 10.w,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AiCartoonImagePreviewPage(
                      tag: index,
                      url: images[index],
                    ),
                  );
                },
                child: Hero(
                  tag: index,
                  child: SizedBox(
                    width: 21.w,
                    height: 21.h,
                    child: Image.asset(
                      "assets/ai/ai_cartoon_picture_preview.png",
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
