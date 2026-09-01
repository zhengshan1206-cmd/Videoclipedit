// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:video_clip_edit/utils/consts/const.dart';
import 'package:video_clip_edit/routes/route_utils.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/providers/mine_page_provider.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_permission_utils.dart';
import 'package:video_clip_edit/modules/profile/widgets/no_data_view.dart';
import 'package:video_clip_edit/modules/home/beans/cloud_video_bean.dart';
import 'package:video_clip_edit/modules/home/clipped/add_material_page.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/cloud_material_cell.dart';

class CloudMaterialsFromMinePage<T extends MaterialBaseProvider>
    extends StatefulWidget {
  const CloudMaterialsFromMinePage({
    super.key,
  });

  @override
  State<CloudMaterialsFromMinePage> createState() =>
      _CloudMaterialsFromMinePageState<T>();
}

class _CloudMaterialsFromMinePageState<T extends MaterialBaseProvider>
    extends State<CloudMaterialsFromMinePage<T>> {
  late EasyRefreshController _controller = _controller = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );
  @override
  void initState() {
    super.initState();

    _loadRecords();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColorUtil.CommonPageBgColor,
      appBar: ByWidgetsUtil.appBar(context: context, title: "我的创作"),
      body:  Padding(
        padding: EdgeInsets.only(
            top: 8.w,
            left: 12.w,
            right: 12.w,
            bottom: context.byBottomSafeHeight),
        child: Column(
          children: [
            // _buildTipsbar(),
            // SizedBox(height: 10.h),
            _buildWorkList(context),
          ],
        ),
      )
    );
  }

  // _buildTipsbar() {
  //   return ByWidgetsUtil.commonTipsBar("文件在云端存储7天，过期无法恢复，请及时保存。");
  // }

  _buildWorkList(BuildContext context) {
    final provider = context.watch<MinePageProvider>();
    final clipProvider = context.read<T>();
    final List<Detail> videoDetailBeans = provider.cloudVideoDetailBeans;
    final providerMaterail = context.read<T>();
    final selectedCount = providerMaterail.selectedMaterials.length;
    final maxCount = 9 - selectedCount;
    final currentCount = providerMaterail.selectedVideoDetailBeans.length;

    return Expanded(
      child: videoDetailBeans.isEmpty
          ? _buildNoContents()
          : Column(
              children: [
                Expanded(
                  child: EasyRefresh(
                    onRefresh: () {
                      provider.resetPages();
                      provider.loadWorkList(status: "2");
                    },
                    onLoad: () {
                      provider.loadWorkList(status: "2");
                    },
                    child: GridView.builder(
                      itemCount: videoDetailBeans.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10.w,
                        crossAxisSpacing: 10.w,
                      ),
                      itemBuilder: (context, index) {
                        return CloudMaterialCell<T>(
                          index: index,
                          videoBean: videoDetailBeans[index],
                          maxCount: maxCount,
                          fromMyWorks: true,
                        );
                      },
                    ),
                  ),
                ),
                ByWidgetsUtil.commonBtn(
                  title: "确定($currentCount/$maxCount)",
                  onClick: () async {
                    final status = await ByPermissionUtils.videos();
                    if (!status) return;

                    // 将选中的作品添加到选中的素材中
                    final provider = context.read<T>();
                    List<dynamic> videos = [];
                    for (var video in provider.selectedVideoDetailBeans) {
                      final asset = File(video.videoUrl);
                      if (asset.existsSync()) {
                        videos.add(asset);
                      }
                    }
                    if (videos.isNotEmpty) {
                      provider.addNewMaterials(videos);
                      provider.selectedVideoDetailBeans.clear();
                    }
                    ByNavRouterUtils.push(
                      context,
                      name: Consts.kAddMaterialPage,
                      MultiProvider(
                        providers: [
                          ChangeNotifierProvider.value(value: provider),
                          ChangeNotifierProvider.value(value: clipProvider)
                        ],
                        child: AddMaterialPage<T>(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 8.h),
              ],
            ),
    );
  }

  _buildNoContents() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.w),
      child: Container(
        margin: EdgeInsets.only(bottom: ByScreenUtils.bottomSafeHeight + 12.h),
        color: ByColorUtil.WhiteColor,
        alignment: Alignment.center,
        height: 300.h,
        child: NoDataView(
          onTap: () {
            RouteUtils.gotoPage(context, "/voideCreate");
          },
        ),
      ),
    );
  }

  void _loadRecords() {
    final provider = context.read<MinePageProvider>();
    provider.resetPages();
    provider.loadWorkList(status: "2");
  }
}
