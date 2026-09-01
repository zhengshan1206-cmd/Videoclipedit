import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/base/base_view.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';

import '../../../generated/assets.dart';
import '../../../widgets/common_button.dart';

class AiCartoonImagePreviewPage extends StatefulWidget {
  const AiCartoonImagePreviewPage({
    super.key,
    required this.url,
    required this.tag,
  });
  final String url;
  final int tag;

  @override
  State<AiCartoonImagePreviewPage> createState() =>
      _AiCartoonImagePreviewPageState();
}

class _AiCartoonImagePreviewPageState extends State<AiCartoonImagePreviewPage> {
  @override
  void initState() {
    super.initState();
    // 设置为透明
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.black));
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      backgroundColor: Colors.black.withOpacity(0.8),
      hasAppBar: false,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ByNavRouterUtils.goBack(context);
        },
        child: Stack(
          children: [
            Hero(
              tag: widget.tag,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: widget.url,
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.center,
                ),
              ),
            ),
            Positioned(
                top: 10.w,
                left: 16.w,
                child: CommonButton(
                  padding: EdgeInsets.zero,
                  minSize: 30,
                  onPressed: Get.back,
                  child: Image.asset(
                    color: Colors.white,
                    Assets.homeIconBack,
                    width: 24.w,
                    height: 24.w,
                  ),
                ))
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ByNavRouterUtils.goBack(context);
        },
        child: Hero(
          tag: widget.tag,
          child: Center(
            child: CachedNetworkImage(
              imageUrl: widget.url,
              fit: BoxFit.fitWidth,
              alignment: Alignment.center,
            ),
          ),
        ),
      ),
      appBar: AppBar(),
    );
  }
}
