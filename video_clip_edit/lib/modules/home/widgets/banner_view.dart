import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/modules/home/beans/home_banner_bean.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/modules/home/widgets/svga_player.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';

class BannerView extends StatefulWidget {
  final BoxFit fit;
  final List<String> urls;
  final List<HomeBannerBean> list;
  final void Function()? onError;
  final int autoplayDelay;
  final SwiperPlugin? pagination;
  final void Function(int index)? onTap;
  final void Function(int index)? onIndexChanged;

  const BannerView({
    super.key,
    required this.urls,
    this.list = const [],
    this.onTap,
    this.autoplayDelay = 6000,
    this.fit = BoxFit.cover,
    this.onError,
    this.pagination,
    this.onIndexChanged,
  });
  @override
  State<BannerView> createState() => _BannerViewState();
}

class _BannerViewState extends State<BannerView> {
  @override
  Widget build(BuildContext context) {
    return Swiper(
      autoplay: true,
      autoplayDelay: widget.autoplayDelay,
      onIndexChanged: widget.onIndexChanged,
      onTap: (index) {
        if (widget.list.isNotEmpty &&
            widget.list.length == widget.urls.length) {
          HomeBannerBean bean = widget.list[index];
          SubFunction subFunction = SubFunction.fromJson(bean.toJson());
          ByCommonUtils.subFunctionCase(context, subFunction);
        }
        widget.onTap?.call(index);
      },
      pagination: widget.pagination,
      itemBuilder: (context, index) {
        final url = widget.urls[index];
        if (url.endsWith(".svga")) {
          return SvgaPlayer(url: url);
        }
        if (url.startsWith("http")) {
          return CachedNetworkImage(
            imageUrl: url,
            placeholder: (context, url) => const Center(
              child: SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) {
              widget.onError?.call();
              return const Icon(Icons.error);
            },
            fit: widget.fit,
          );
        }
        return Image.asset(
          url,
          fit: widget.fit,
        );
      },
      itemCount: widget.urls.length,
    );
  }
}
