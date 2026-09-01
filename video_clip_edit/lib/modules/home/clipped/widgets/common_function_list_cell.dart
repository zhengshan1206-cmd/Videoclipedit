import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/home/clipped/cloud_materials_from_mine_page.dart';
import 'package:video_clip_edit/modules/home/recreate/short_show_list_page.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/beans/function_item_bean.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

typedef AssetSelecctedCallback = void Function(List<AssetEntity> assets);

class CommonFunctionListCell<T extends MaterialBaseProvider>
    extends StatelessWidget {
  const CommonFunctionListCell({
    super.key,
    required this.function,
    this.assetSelecctedCallback,
  });

  final FunctionItemBean function;
  final AssetSelecctedCallback? assetSelecctedCallback;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<T>();
    // if(cloudVideoListBean!=null){
    //   ByNavRouterUtils.push(
    //     context,
    //     ChangeNotifierProvider.value(
    //       value: context.read<T>(),
    //       child: CloudMaterialsPage<T>(videoListBean: ),
    //     ),
    //   );
    // }
    return GestureDetector(
      onTap: () async {
        switch (function.title) {
          /// 选取云端素材
          case "云端素材":
            ByNavRouterUtils.push(
              context,
              ChangeNotifierProvider.value(
                value: provider,
                child: ShortShowListPage<T>(
                    type: ShortShowListPageType.cloudMaterial),
              ),
            );
            break;

          /// 选取云端素材
          case "热门短剧":
            ByNavRouterUtils.push(
              context,
              ChangeNotifierProvider.value(
                value: provider,
                child:
                    ShortShowListPage<T>(type: ShortShowListPageType.shortShow),
              ),
            );
            break;

          /// 选取我的作品
          case "我的作品":
            ByNavRouterUtils.push(
              context,
              ChangeNotifierProvider.value(
                value: provider,
                child: CloudMaterialsFromMinePage<T>(),
              ),
            );
            break;

          /// 打开相册
          case "本地上传":
            _openAlbum(context);
            break;
          default:
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
        margin: EdgeInsets.only(
          bottom: 8.h,
          left: 12.w,
          right: 12.w,
        ),
        decoration: BoxDecoration(
          color: ByColorUtil.WhiteColor,
          borderRadius: BorderRadius.circular(16.w),
          border: Border.all(
            color: ByColorUtil.MainTextColor.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              // borderRadius: BorderRadius.circular(16.w),
              child: SizedBox(
                width: 44.w,
                height: 44.w,
                child: Image.asset(
                  function.icon,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 27.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    function.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: const Color(0xFF0E1840),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 9.h),
                  Text(
                    function.desc,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF0E1840),
                    ),
                  ),
                ],
              ),
            ),
            Image.asset(
              "assets/home/arrow_right_bold.png",
              width: 16.w,
              height: 16.w,
            )
          ],
        ),
      ),
    );
  }

  void _openAlbum(BuildContext context) async {
    ByCommonUtils.pickAssets(
      context,
      type: RequestType.video,
      // durationLimit: 600,
      onSelectedCallback: (asstes) => assetSelecctedCallback?.call(asstes),
    );
  }
}
