import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/modules/home/beans/home_banner_bean.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/modules/home/widgets/svga_player.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';

// ignore: must_be_immutable
class BannerViewDark extends StatefulWidget {
  final List<String> urls;
  final void Function(int)? onIndexChanged;
  List<HomeBannerBean>? list = [];
  BannerViewDark({
    super.key,
    required this.urls,
    this.list,
    this.controller,
    this.onIndexChanged,
  });

  final SwiperController? controller;

  @override
  State<BannerViewDark> createState() => _BannerViewDarkState();
}

class _BannerViewDarkState extends State<BannerViewDark> {
  @override
  Widget build(BuildContext context) {
    return Swiper(
      autoplay: true,
      autoplayDelay: 6000,
      onIndexChanged: widget.onIndexChanged,
      itemCount: widget.urls.length,
      controller: widget.controller,
      onTap: (index) {
        if (widget.list != null &&
            widget.list!.isNotEmpty &&
            widget.list!.length == widget.urls.length) {
          HomeBannerBean bean = widget.list![index];
          SubFunction subFunction = SubFunction.fromJson(bean.toJson());
          ByCommonUtils.subFunctionCase(context, subFunction);
        }
      },
      itemBuilder: (context, index) {
        final url = widget.urls[index];
        if (url.endsWith(".svga")) {
          return SvgaPlayer(url: url);
        }
        if (url.startsWith("http")) {
          return CachedNetworkImage(
            imageUrl: url,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.cover,
          );
        }
        return Image.asset(
          url,
          fit: BoxFit.cover,
        );
      },
      pagination: SwiperPagination(
        margin: const EdgeInsets.all(0.0),
        builder: SwiperCustomPagination(
          builder: (BuildContext context, SwiperPluginConfig config) {
            return Container(
              color: Colors.transparent,
              margin: EdgeInsets.only(left: 12.w, bottom: 86.h),
              child: Row(
                children: List.generate(widget.urls.length, (index) {
                  final isCurrent = index == config.activeIndex;
                  return Container(
                    width: isCurrent ? 18.w : 8.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: ByColorUtil.WhiteColor.withOpacity(
                          isCurrent ? 1 : 0.5),
                      borderRadius: BorderRadius.circular(10.w),
                    ),
                    margin: EdgeInsets.only(right: 3.w),
                  );
                }),
              ),
            );
          },
        ),
      ),
    );
  }
}
