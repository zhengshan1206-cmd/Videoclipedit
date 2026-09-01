import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/home/clipped/cloud_materials_from_mine_page.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/recreate/short_show_list_page.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class AddMaterialDialog<T extends MaterialBaseProvider>
    extends StatelessWidget {
  const AddMaterialDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Stack(
          children: [
            Consumer<T>(builder: (context, provider, child) {
              return Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    bottom: 14.h + ByScreenUtils.bottomSafeHeight,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffF4F7F8),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18.w),
                      topRight: Radius.circular(18.w),
                    ),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.functionList.length,
                    itemBuilder: (context, index) {
                      final function = provider.functionList[index];
                      return GestureDetector(
                        onTap: () {
                          switch (function.title) {
                            case "云端素材":
                              ByNavRouterUtils.pushReplacement(
                                  context,
                                  ChangeNotifierProvider<T>.value(
                                    value: provider,
                                    child: ShortShowListPage<T>(
                                        type: ShortShowListPageType
                                            .cloudMaterial),
                                  ));
                              break;
                            case "热门短剧":
                              ByNavRouterUtils.pushReplacement(
                                  context,
                                  ChangeNotifierProvider<T>.value(
                                    value: provider,
                                    child: ShortShowListPage<T>(
                                        type: ShortShowListPageType.shortShow),
                                  ));
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.w, vertical: 28.h),
                          margin: EdgeInsets.only(
                            bottom: 8.h,
                            left: 12.w,
                            right: 12.w,
                          ),
                          decoration: BoxDecoration(
                            color: ByColorUtil.WhiteColor,
                            borderRadius: BorderRadius.circular(16.w),
                            border: Border.all(
                              color:
                                  ByColorUtil.MainTextColor.withOpacity(0.05),
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16.w),
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
                    },
                  ));
            }),
            Positioned(
              right: 12.w,
              top: 11,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  ByNavRouterUtils.goBack(context);
                },
                child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  child: Image.asset(
                    "assets/login/login_dialog_close.png",
                    width: 11,
                    height: 11,
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  void _openAlbum(BuildContext context) async {
    ByCommonUtils.pickAssets(
      context,
      type: RequestType.video,
      // durationLimit: 600,
      maxCount: 9 - context.read<T>().selectedMaterials.length,
      onSelectedCallback: (assets) {
        /// 未选择则不处理
        if (assets.isEmpty) return;
        final provider = context.read<T>();

        /// 将选中的素材添加到素材列表
        provider.addNewMaterials(assets);
        ByNavRouterUtils.goBack(context);
      },
    );
  }
}
