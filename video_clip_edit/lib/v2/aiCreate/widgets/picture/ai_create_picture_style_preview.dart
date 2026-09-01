import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:video_clip_edit/data/model/aiCreate/ai_create_picture_style_bean.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

///画面风格预览
class AiCreatePictureStylePreview extends StatefulWidget {
  const AiCreatePictureStylePreview({
    super.key,
    required this.styleBean,
  });

  final AICreatePictureStyleBean styleBean;

  @override
  State<AiCreatePictureStylePreview> createState() => _AiCreatePictureStylePreviewState();
}

class _AiCreatePictureStylePreviewState extends State<AiCreatePictureStylePreview> {

  final SwiperController _controller = SwiperController();

  double ratio = 1;
  int currentIndex = 0;

  final ratiosMap = {
    "1:1": 1 / 1,
    "3:4": 3 / 4,
    "4:3": 4 / 3,
    "16:9": 16 / 9,
    "9:16": 9 / 16,
  };

  @override
  void initState() {
    super.initState();
    ratio = ratiosMap[widget.styleBean.cases![currentIndex].ratio] ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    final cases = widget.styleBean.cases ?? [];
    return Center(
      child: ByWidgetsUtil.commonContainer(
        padding: EdgeInsets.all(10.w),
        margin: EdgeInsets.symmetric(horizontal: 28.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 5.h),
              ByWidgetsUtil.commonText(
                fontSize: 16.sp,
                text: widget.styleBean.title ?? '',
                fontWeight: FontWeight.w500,
                textColor: ByColorUtil.CommonTextColor,
              ),
              SizedBox(height: 15.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(12.w),
                child: AspectRatio(
                  aspectRatio: ratio,
                  child: Swiper(
                    autoplay: false,
                    index: currentIndex,
                    onIndexChanged: (value) {
                      setState(() {
                        currentIndex = value;
                        ratio = ratiosMap[widget.styleBean.cases![value].ratio] ?? 1;
                      });
                    },
                    itemCount: cases.length,
                    controller: _controller,
                    onTap: (index) {},
                    itemBuilder: (context, index) {
                      final currentCase = cases[index];
                      return CachedNetworkImage(
                        imageUrl: currentCase.url ?? '',
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator(),),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        fit: BoxFit.cover,
                      );
                    },
                    pagination: SwiperPagination(
                      margin: const EdgeInsets.all(0.0),
                      builder: SwiperCustomPagination(
                        builder: (BuildContext context, SwiperPluginConfig config) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 10.h),
                            child: Row(
                              children: [
                                const Spacer(),
                                ...List.generate(
                                  cases.length,
                                  (index) {
                                    final isCurrent = index == config.activeIndex;
                                    return Container(
                                      width: 8.w,
                                      height: 8.w,
                                      decoration: BoxDecoration(
                                        color: ByColorUtil.WhiteColor.withOpacity(isCurrent ? 1 : 0.5),
                                        borderRadius: BorderRadius.circular(10.w),
                                      ),
                                      margin: EdgeInsets.only(right: 4.w, left: 4.w),
                                    );
                                  },
                                ),
                                const Spacer(),
                              ],
                            ),
                          );
                        },
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
}
