import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/guid/add_material_guid_page.dart';
import 'package:video_clip_edit/modules/home/clipped/cloud_materials_page.dart';
import 'package:video_clip_edit/modules/home/providers/show_recreate_provider.dart';
import 'package:video_clip_edit/modules/home/recreate/short_show_list_page.dart';
import 'package:video_clip_edit/modules/home/widgets/hot_auth_view.dart';
import 'package:video_clip_edit/modules/home/widgets/hot_rank_view.dart';
import 'package:video_clip_edit/providers/home_provider.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_datetime_ext.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';

class HomeHotListCell extends StatelessWidget {
  const HomeHotListCell({
    super.key,
    required this.auth,
    required this.colors,
    required this.index,
  });

  final HotAuthBean auth;
  final List<List<Color>> colors;
  final int index;
  @override
  Widget build(BuildContext context) {
    final providerHome = context.read<HomePageProvider>();
    return Container(
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.only(
        bottom: 8.h,
        left: 12.w,
        right: 12.w,
      ),
      decoration: BoxDecoration(
        // boxShadow: [
        //   BoxShadow(
        //     color: ColorUtil.MainTextColor.withOpacity(0.05),
        //     spreadRadius: 2,
        //     blurRadius: 7,
        //   )
        // ],
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(
          color: ByColorUtil.MainTextColor.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.w),
                child: SizedBox(
                  width: 100.w,
                  height: 130.h,
                  child: CachedNetworkImage(
                    imageUrl: auth.coverUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: index > 2
                    ? Container()
                    : HotRankView(
                        rank: 'Top${index + 1}',
                        gradientColorStart: colors[index][0],
                        gradientColorEnd: colors[index][1],
                      ),
              )
            ],
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  auth.dramaName,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: ByColorUtil.MainTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      "${auth.joinPeopleNum}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: ByColorUtil.HomeHotAuthNumberColor,
                      ),
                    ),
                    Text(
                      "人已推广   |   粉丝要求",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: ByColorUtil.MainTextColor,
                      ),
                    ),
                    Text(
                      "≥${auth.fansNum}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: ByColorUtil.HomeHotAuthNumberColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      "历史最高收益：",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: ByColorUtil.MainTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Image.asset(
                      "assets/home/home_auth_income.png",
                      width: 18.w,
                      height: 18.w,
                    ),
                    SizedBox(width: 6.5.w),
                    Text(
                      // ByFinanceUtils.amountConversion(auth.maxIncome),
                      auth.maxIncome.amountConversion(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: ByColorUtil.HomeHotAuthIncomeColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    // if (auth.url.isNotEmpty) {
                    //    _openUrl(auth.url);
                    //
                    // }
                    providerHome.loadCloudVideos(onSuccess: (data) {
                      for (int i = 0; i < data.length; i++) {
                        if (data[i].id == auth.id) {
                          LaunchProvider provider =
                              context.read<LaunchProvider>();
                          final bool showCreateGuid =
                              provider.shouldShowCreateGuid();
                          ByNavRouterUtils.push(
                              context,
                              showCreateGuid == false
                                  ? ChangeNotifierProvider<
                                      ShowRecreateProvider>(
                                      create: (context) =>
                                          ShowRecreateProvider(),
                                      child: CloudMaterialsPage<
                                          ShowRecreateProvider>(
                                        videoListBean: data[i],
                                        type: ShortShowListPageType.shortShow,
                                      ),
                                    )
                                  : const AddMaterialGuidPage());

                          if (showCreateGuid) {
                            provider.checkCreateGuid();
                          }
                        }
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: ByColorUtil.LoginBtnBgColor,
                      borderRadius: BorderRadius.circular(10.w),
                    ),
                    child: Text(
                      "推广授权",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: ByColorUtil.WhiteColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
