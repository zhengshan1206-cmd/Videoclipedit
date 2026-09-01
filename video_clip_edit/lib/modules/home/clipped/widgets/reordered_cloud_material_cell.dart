import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_color_utils.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_download_util.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class ReorderedCloudMaterialCell<T extends MaterialBaseProvider>
    extends StatelessWidget {
  final int index;
  const ReorderedCloudMaterialCell({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<T>();
    final material = provider.selectedMaterials[index];
    bool isFile = material is File;
    bool isLocal = material is AssetEntity || isFile;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.w),
      child: Stack(
        children: [
          if (!isLocal)
            Positioned.fill(
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: "",
              ),
            ),
          if (isLocal)
            isFile
                ? Positioned.fill(
                    child: ByDownloadUtil.videoCover(material.path))
                : Positioned.fill(
                    child: Image(
                      image: AssetEntityImageProvider(
                        (material as AssetEntity),
                        isOriginal: false,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
          Positioned(
            right: 0.w,
            top: 0.w,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                provider.removeMaterial(material);
              },
              child: Container(
                width: 34.w,
                height: 34.h,
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/home/icon_close.png",
                  width: 20.w,
                  height: 20.w,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0.h,
            child: Container(
              padding: const EdgeInsets.only(
                left: 10,
                right: 5,
                top: 5,
                bottom: 6,
              ),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      //渐变开始于上面的中间开始
                      begin: Alignment.topCenter,
                      //渐变结束于下面的中间
                      end: Alignment.bottomCenter,
                      colors: [
                    ByColorUtils.hexColor("#03000000"),
                    ByColorUtils.hexColor("#CC000000")
                  ])),
              width: ByScreenUtils.screenWidth,
              child: ByWidgetsUtil.commonText(
                text: "${index + 1}".padLeft(2, "0"),
                fontSize: 14.sp,
                textColor: ByColorUtil.WhiteColor,
              ),
            ),
          )
        ],
      ),
    );
  }
}
