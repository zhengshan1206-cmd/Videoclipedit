import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/beans/cloud_video_bean.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/home/recreate/widgets/short_show_list_cell.dart';

enum ShortShowListPageType {
  /// 云端素材
  cloudMaterial,

  /// 短剧素材
  shortShow,
}

extension ShortShowListPageTypeExt on ShortShowListPageType {
  String get typeValue {
    switch (this) {
      case ShortShowListPageType.cloudMaterial:
        return "1";
      default:
        return "2";
    }
  }

  String get titileValue {
    switch (this) {
      case ShortShowListPageType.cloudMaterial:
        return "云端素材";
      default:
        return "热门短剧";
    }
  }

  String get descValue {
    switch (this) {
      case ShortShowListPageType.cloudMaterial:
        return "云端素材";
      default:
        return "热门短剧素材";
    }
  }
}

class ShortShowListPage<T extends MaterialBaseProvider> extends StatefulWidget {
  const ShortShowListPage({
    super.key,
    required this.type,
  });
  final ShortShowListPageType type;
  @override
  State<ShortShowListPage<T>> createState() => _ShortShowListPageState<T>();
}

class _ShortShowListPageState<T extends MaterialBaseProvider>
    extends State<ShortShowListPage<T>> {
  bool showEmptyView = false;

  @override
  void initState() {
    super.initState();
    _loadCloudVideos();
  }

  @override
  void dispose() {
    EasyLoading.dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<T, List<CloudVideoListBean>>(
      builder: (context, listBeans, child) {
        return Scaffold(
          appBar: ByWidgetsUtil.appBar(
              context: context, title: widget.type.descValue),
          backgroundColor: ByColorUtil.CommonPageBgColor,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              children: [
                if (ShortShowListPageType.shortShow == widget.type)
                  SizedBox(height: 8.h),
                if (ShortShowListPageType.shortShow == widget.type)
                  ByWidgetsUtil.commonTipsBar("仅提供热门短剧素材使用，请到首页获取短剧授权。"),
                SizedBox(height: 8.h),
                Expanded(
                  child: listBeans.isEmpty
                      ? showEmptyView
                          ? ByWidgetsUtil.noDataView()
                          : Container()
                      : GridView.builder(
                          padding: EdgeInsets.symmetric(vertical: 2.w),
                          itemCount: listBeans.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10.w,
                            crossAxisSpacing: 10.w,
                            childAspectRatio: 17 / 20,
                          ),
                          itemBuilder: (context, index) {
                            return ShortShowListCell<T>(
                              index: index,
                              type: widget.type,
                              bean: listBeans[index],
                            );
                          },
                        ),
                ),
                SizedBox(height: 24.h + ByScreenUtils.bottomSafeHeight),
              ],
            ),
          ),
        );
      },
      selector: (BuildContext ctx, T provider) {
        return provider.listBeans;
      },
    );
  }

  void _loadCloudVideos() {
    final provider = context.read<T>();
    provider.listBeans = [];
    provider.cloudPage = 1;
    provider.loadCloudVideos(
      type: widget.type.typeValue,
      onSuccess: (List<CloudVideoListBean> beans) {
        setState(() {
          showEmptyView = true;
        });
      },
    );
  }
}
