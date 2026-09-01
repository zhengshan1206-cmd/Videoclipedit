import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/home/recreate/short_show_list_page.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/beans/cloud_video_bean.dart';
import 'package:video_clip_edit/modules/home/clipped/cloud_materials_page.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';

class ShortShowListCell<T extends MaterialBaseProvider>
    extends StatelessWidget {
  final ShortShowListPageType type;

  const ShortShowListCell({
    super.key,
    required this.type,
    required this.index,
    required this.bean,
  });

  final int index;
  final CloudVideoListBean bean;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ByNavRouterUtils.push(
          context,
          ChangeNotifierProvider.value(
            value: context.read<T>(),
            child: CloudMaterialsPage<T>(
              videoListBean: bean,
              type: type,
            ),
          ),
        );
      },
      child: ByWidgetsUtil.commonContainer(
        padding: EdgeInsets.all(6.w),
        margin: EdgeInsets.only(
          left: index.isEven ? 2.w : 0,
          right: index.isOdd ? 2.w : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: ByColorUtil.BlackColor.withOpacity(0.1),
            blurRadius: 2.w,
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ByWidgetsUtil.commonText(
              text: bean.materialName,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 6.h),
            Expanded(
              child: GridView.builder(
                itemCount: 4,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8.w),

                    /// len:4 - [0, 3]
                    child: (bean.details.isEmpty ||
                            bean.details.length - 1 < index)
                        ? Container()
                        : CachedNetworkImage(
                            imageUrl: bean.details[index].coverUrl,
                            fit: BoxFit.cover,
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
