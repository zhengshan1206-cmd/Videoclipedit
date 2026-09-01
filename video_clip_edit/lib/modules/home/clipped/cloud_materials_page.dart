import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/recreate/short_show_list_page.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_permission_utils.dart';
import 'package:video_clip_edit/modules/home/beans/cloud_video_bean.dart';
import 'package:video_clip_edit/modules/download/providers/download_provider.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/modules/home/clipped/video_clip_downloading_page.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/cloud_material_cell.dart';

class CloudMaterialsPage<T extends MaterialBaseProvider>
    extends StatefulWidget {
  final ShortShowListPageType type;
  final CloudVideoListBean videoListBean;
  const CloudMaterialsPage({
    required this.type,
    super.key,
    required this.videoListBean,
  });

  @override
  State<CloudMaterialsPage> createState() => _CloudMaterialsPageState<T>();
}

class _CloudMaterialsPageState<T extends MaterialBaseProvider>
    extends State<CloudMaterialsPage<T>> {
  @override
  void initState() {
    super.initState();

    /// 加载云端素材列表
    _loadCloudVideos();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<T>();
    final videoDetailBeans = provider.videoDetailBeans;
    final isCloudMaterial = widget.type == ShortShowListPageType.cloudMaterial;
    final maxCount = 9 - provider.selectedMaterials.length;
    final selectedCount = provider.selectedVideoDetailBeans.length;
    return Scaffold(
      backgroundColor: ByColorUtil.CommonPageBgColor,
      appBar: _buildAppbar(context, isCloudMaterial),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ShortShowListPageType.shortShow == widget.type)
              SizedBox(height: 8.h),
            if (ShortShowListPageType.shortShow == widget.type)
              ByWidgetsUtil.commonTipsBar("仅提供热门短剧素材使用，请到首页获取短剧授权。"),
            SizedBox(height: 10.h),
            Expanded(
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
                    canPreview: true,
                  );
                },
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 50.h,
              child: ByWidgetsUtil.commonBtn(
                title: "确定($selectedCount/$maxCount)",
                onClick: () async {
                  final navigator = Navigator.of(context);
                  // 检查视频权限
                  final status = await ByPermissionUtils.videos();
                  if (!status) return;

                  /// 下载页面
                  final child = MultiProvider(
                    providers: [
                      ChangeNotifierProvider(
                          create: (context) => DownloadProvider()),
                      ChangeNotifierProvider.value(value: provider)
                    ],
                    child: VideoClipDownloadingPage<T>(),
                  );

                  /// push到下载页面
                  navigator.push(MaterialPageRoute(
                    builder: (context) => child,
                  ));
                },
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppbar(BuildContext context, bool isCloudMaterial) {
    final typeName = isCloudMaterial ? "混剪素材" : "热门短剧";
    const maxCount = 9; //isCloudMaterial ? 10 : 5;
    String textInfo = '请选择1-$maxCount个$typeName片段';
    return AppBar(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            (widget.videoListBean.materialName.isNotEmpty)
                ? widget.videoListBean.materialName
                : "云端素材",
            style: const TextStyle(
              color: ByColorUtil.CommonTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 5),
            child: Text(
              textInfo,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            ),
          )
        ],
      ),
    );
  }

  /// 加载云端素材列表
  void _loadCloudVideos() {
    final provider = context.read<T>();
    provider.videoDetailBeans = [];
    provider.loadCloudVideosForName(
      id: widget.videoListBean.id.toString(),
      onSuccess: (List<Detail> beans) {},
    );
  }
}
