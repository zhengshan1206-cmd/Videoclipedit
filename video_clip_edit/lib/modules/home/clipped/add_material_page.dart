import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/download/providers/download_provider.dart';
import 'package:video_clip_edit/modules/home/recreate/provdier/video_recreate_dubbing_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:flutter_reorderable_grid_view/widgets/custom_draggable.dart';
import 'package:video_clip_edit/modules/home/clipped/video_material_edit.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:video_clip_edit/modules/home/clipped/video_clip_parsing_page.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/add_material_dailog.dart';
import 'package:video_clip_edit/modules/home/recreate/recreate_video_parsing_page.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/reordered_cloud_material_cell.dart';

class AddMaterialPage<T extends MaterialBaseProvider> extends StatefulWidget {
  const AddMaterialPage({super.key});

  @override
  State<AddMaterialPage> createState() => _AddMaterialPageState<T>();
}

class _AddMaterialPageState<T extends MaterialBaseProvider>
    extends State<AddMaterialPage<T>> {
  final _scrollController = ScrollController();
  final _gridViewKey = GlobalKey();

  // @override
  // void dispose() {
  //   if(mounted){
  //     // context.read<T>().clearSelectedMaterials();
  //     context.read<T>().selectedMaterials.clear();
  //   }
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(context: context, title: "添加素材"),
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            child: ByWidgetsUtil.commonTipsBar("长按可拖动调整视频顺序，最多可添加9个视频。"),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8.h,
                horizontal: 12.w,
              ),
              child: _buildGrideView(context),
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  /// 底部工具条
  _buildBottomBar(BuildContext context) {
    T provider = context.watch<T>();
    return Container(
      color: ByColorUtil.WhiteColor,
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 8.h,
        bottom: 8.h + ByScreenUtils.bottomSafeHeight,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ByWidgetsUtil.btnWithIcon(
              title: "精细模式",
              fontSize: 16.sp,
              onClick: () {
                provider.changeGeneratingMode(
                    MaterialProviderGeneratingMode.delicate);
                provider.addNewWork(
                  provider.selectedMaterials,
                  onSuccess: (data) {
                    if (data != null) {
                      final workID = (data["data"]["id"] ?? "").toString();
                      provider.workId = workID;
                    }

                    MaterialProviderTypeExt.handleType(
                        type: T,
                        callback: (MaterialProviderType t) {
                          switch (t) {
                            case MaterialProviderType.clip:
                              ByNavRouterUtils.push(
                                context,
                                ChangeNotifierProvider.value(
                                  value: provider,
                                  child: VideoMaterialEdit<T>(),
                                ),
                              );
                              break;
                            case MaterialProviderType.recreate:
                              ByNavRouterUtils.push(
                                context,
                                ChangeNotifierProvider.value(
                                  value: provider,
                                  child: RecreateVideoParsingPage<T>(
                                      mergeOnly: true),
                                ),
                              );
                              break;
                            default:
                          }
                        });
                  },
                );
              },
              iconPath: 'assets/home/icon_mode_delicate.png',
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: ByWidgetsUtil.btnWithIcon(
              title: "极速模式",
              fontSize: 16.sp,
              onClick: () {
                provider.changeGeneratingMode(
                  MaterialProviderGeneratingMode.speedy,
                );

                provider.addNewWork(
                  provider.selectedMaterials,
                  onSuccess: (data) {
                    if (data != null) {
                      final workID = (data["data"]["id"] ?? "").toString();
                      provider.workId = workID;
                    }
                    MaterialProviderTypeExt.handleType(
                      type: T,
                      callback: (type) {
                        switch (type) {
                          case MaterialProviderType.clip:
                            ByNavRouterUtils.push(
                              context,
                              ChangeNotifierProvider.value(
                                value: provider,
                                child: VideoClipParsingPage<T>(
                                    compositionOnly: true),
                              ),
                            );
                            break;
                          case MaterialProviderType.recreate:
                            ByNavRouterUtils.push(
                              context,
                              MultiProvider(
                                providers: [
                                  ChangeNotifierProvider.value(
                                      value: context.read<T>()),
                                  ChangeNotifierProvider(
                                      create: (context) =>
                                          VideoRecreateDubbingProvider()),
                                  ChangeNotifierProvider(
                                      create: (context) => DownloadProvider()),
                                ],
                                child: RecreateVideoParsingPage<T>(),
                              ),
                            );
                            break;
                          default:
                        }
                      },
                    );
                  },
                );
              },
              bgColor: const Color(0xFF1CCB71),
              iconPath: 'assets/home/icon_mode_speed.png',
            ),
          )
        ],
      ),
    );
  }

  /// 推动排序的GrideView
  _buildGrideView(BuildContext context) {
    final provider = context.watch<T>();
    final materials = provider.selectedMaterials;
    return ReorderableBuilder<dynamic>.builder(
      onReorder: (reorder) {
        _handleReorder(reorder, provider);
      },
      onDragEnd: _handleDragEnd,
      lockedIndices: [materials.length],
      onDragStarted: _handleDragStarted,
      key: Key(_gridViewKey.toString()),
      scrollController: _scrollController,
      nonDraggableIndices: [materials.length],
      positionDuration: const Duration(milliseconds: 300),
      onUpdatedDraggedChild: _handleUpdatedDraggedChild,
      childBuilder: (itemBuilder) {
        return GridView.builder(
          key: _gridViewKey,
          controller: _scrollController,
          itemCount: materials.length + 1,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10.w,
            crossAxisSpacing: 10.w,
          ),
          itemBuilder: (ctx, index) {
            return itemBuilder(
              _buildGrideItem(
                index: index,
                context: context,
                provider: provider,
              ),
              index,
            );
          },
        );
      },
    );
  }

  Widget _buildGrideItem({
    required BuildContext context,
    required int index,
    required T provider,
  }) {
    final materials = provider.selectedMaterials;
    if (index == materials.length) {
      return CustomDraggable(
        key: const Key("Add"),
        data: index,
        child: GestureDetector(
          onTap: () {
            if (materials.length >= 9) {
              BotToast.showText(text: "最多添加9个视频");
              return;
            }
            showDialog(
              context: context,
              useSafeArea: false,
              builder: (ctx) {
                return ChangeNotifierProvider<T>.value(
                  value: context.read<T>(),
                  child: AddMaterialDialog<T>(),
                );
              },
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: ByColorUtil.WhiteColor,
              borderRadius: BorderRadius.circular(12.w),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10.h),
                Image.asset(
                  "assets/home/icon_add_material.png",
                  width: 75.w,
                  height: 75.w,
                ),
                SizedBox(height: 19.h),
                ByWidgetsUtil.commonText(
                  text: "添加素材",
                  fontSize: 14.sp,
                  textColor: const Color(0xFF5A4BF7),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return CustomDraggable(
      key: Key(materials[index].toString()),
      data: index,
      child: ChangeNotifierProvider.value(
        value: provider,
        child: ReorderedCloudMaterialCell<T>(index: index),
      ),
    );
  }

  /// 位置改变后回调
  void _handleUpdatedDraggedChild(int index) {}

  /// 拖动结束，重新排序完毕后回调
  void _handleReorder(
    ReorderedListFunction reorderedListFunction,
    T provider,
  ) {
    provider.updateSelectedMaterials(
        reorderedListFunction(provider.selectedMaterials));
  }

  /// 开始拖动时回调
  void _handleDragStarted(int index) {}

  /// 拖动结束时回调
  void _handleDragEnd(int index) {}
}
