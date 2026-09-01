import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_string_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiClip/ai_material_select_page.dart';
import 'package:video_clip_edit/v2/aiClip/beans/ai_material_item_bean.dart';
import 'package:video_clip_edit/v2/aiClip/beans/ai_show_list_item_bean.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_provider.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_material_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_bgm_local_bean.dart';
import 'package:video_clip_edit/v2/hotReplica/providers/hot_case_replica_provider.dart';

class ReplicaClipMaterialSelectView extends StatelessWidget {
  const ReplicaClipMaterialSelectView({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final moreSettingsOn = context.select<HotCaseReplicaProvider, bool>(
      (value) => value.moreSettingsOn,
    );
    if (!moreSettingsOn) return const SliverToBoxAdapter(child: SizedBox());

    bool selected = false;
    final currentType = context.select<AiMaterialProvider, AiMaterialType>(
      (value) => value.currentType,
    );

    /// 混剪素材
    final selectedClipMaterials =
        context.select<AiMaterialProvider, List<MaterialPack>>(
      (value) => value.selectedClipMaterials,
    );

    /// 短剧素材
    final selectedShowListBeans =
        context.select<AiMaterialProvider, List<AiShowListItemBean>>(
      (value) => value.selectedShowListBeans,
    );
    final selectedShowId = context.select<AiMaterialProvider, int>(
      (value) => value.selectedShowId,
    );

    /// 我的素材
    final selectedMineMaterialItemBeans =
        context.select<AiMaterialProvider, List<AiCartoonBgmLocalBean>>(
      (value) => value.selectedMineMaterialItemBeans,
    );

    switch (currentType) {
      case AiMaterialType.clip:
        selected = selectedClipMaterials.isNotEmpty;
        break;
      case AiMaterialType.show:
        selected = selectedShowListBeans.isNotEmpty || selectedShowId != -1;
        break;
      case AiMaterialType.mine:
        selected = selectedMineMaterialItemBeans.isNotEmpty;
        break;
      default:
    }
    return SliverPadding(
      padding: EdgeInsets.only(top: 10.h, left: 12.w, right: 12.w),
      sliver: SliverToBoxAdapter(
        child: SizedBox(
          height: selected ? 80.h : 60.h,
          child: ByWidgetsUtil.commonContainer(
            bgColor: const Color(0xFFF8FAFB),
            border: Border.all(
              color: const Color(0xFFF3F5F9),
              width: 0.5,
            ),
            borerRadius: 10.w,
            child: selected
                ? _buildSelectedView(context)
                : _buildUnselectedView(context),
          ),
        ),
      ),
    );
  }

  /// 未选择
  _buildUnselectedView(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
        final provider = context.read<HotCaseReplicaProvider>();
        final url = provider.inputValue;
        if (url.isEmpty) {
          BotToast.showText(text: "请输入或粘贴视频链接");
          return;
        }
        ByNavRouterUtils.push(
          context,
          MultiProvider(providers: [
            ChangeNotifierProvider.value(
              value: context.read<AiMaterialProvider>(),
            ),
            ChangeNotifierProvider.value(
              value: context.read<AiClipProvider>(),
            ),
          ], child: AiMaterialSelectPage(isHotReplica: true, shareUrl: url)),
        );
      },
      child: Row(
        children: [
          SizedBox(width: 10.w),
          Image.asset(
            "assets/ai/clip/ai_clip_material_add.png",
            width: 24.w,
            height: 24.h,
          ),
          SizedBox(width: 6.w),
          ByWidgetsUtil.commonText(
            text: "请选择混剪素材",
            fontWeight: FontWeight.w500,
          ),
          const Spacer(),
          SizedBox(
            height: 32.h,
            child: ByWidgetsUtil.commonContainer(
              bgColor: const Color(0xFFEAEEFF),
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              alignment: Alignment.center,
              borerRadius: 8.w,
              child: ByWidgetsUtil.commonText(
                text: "去选择",
                fontSize: 12.sp,
                textColor: ByColorUtil.TabTextColorSelected,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
    );
  }

  /// 已选择
  Widget _buildSelectedView(BuildContext context) {
    int count = 0;
    final paddingTop = 6.h;
    final currentType = context.select<AiMaterialProvider, AiMaterialType>(
      (value) => value.currentType,
    );
    final selectedClipMaterials =
        context.select<AiMaterialProvider, List<MaterialPack>>(
      (value) => value.selectedClipMaterials,
    );
    final selectedShowListBeans =
        context.select<AiMaterialProvider, List<AiShowListItemBean>>(
      (value) => value.selectedShowListBeans,
    );

    /// 我的素材
    final selectedMineMaterialItemBeans =
        context.select<AiMaterialProvider, List<AiCartoonBgmLocalBean>>(
      (value) => value.selectedMineMaterialItemBeans,
    );

    String names = "";
    List<String> imgs = [];
    const seporator = "、";
    switch (currentType) {
      case AiMaterialType.clip:
        count = selectedClipMaterials.length;
        imgs = selectedClipMaterials.map((e) => e.coverUrl).toList();
        names = selectedClipMaterials
            .map((e) => e.materialName.replaceAll(" ", ""))
            .join(seporator);
        names = ByStringUtils.subStringWithMaxLength(names, 15, seporator);
        break;
      case AiMaterialType.show:
        final provider = context.read<AiMaterialProvider>();
        final showMaterialItemBeans = provider.showMaterialItemBeans;
        final selectedShowId = provider.selectedShowId;
        // ignore: avoid_function_literals_in_foreach_calls
        MaterialPack? selectedShow;
        for (var show in showMaterialItemBeans) {
          for (var e in show.materialPack) {
            if (e.id == selectedShowId) {
              selectedShow = e;
              break;
            }
            if (selectedShow != null) {
              break;
            }
          }
        }
        count =
            selectedShowListBeans.isNotEmpty ? selectedShowListBeans.length : 1;
        imgs = selectedShowListBeans.isEmpty
            ? [selectedShow!.coverUrl]
            : selectedShowListBeans.map((e) => e.coverUrl).toList();
        names = selectedShowListBeans.isEmpty
            ? selectedShow!.materialName
            : selectedShowListBeans
                .map((e) => e.videoTitle.replaceAll(" ", ""))
                .join(seporator);

        names = ByStringUtils.subStringWithMaxLength(names, 15, seporator);
        break;
      case AiMaterialType.mine:
        count = selectedMineMaterialItemBeans.length;
        imgs = selectedMineMaterialItemBeans.map((e) => e.cover).toList();
        names = selectedMineMaterialItemBeans
            .map((e) => e.name.replaceAll(" ", ""))
            .join(seporator);

        names = ByStringUtils.subStringWithMaxLength(names, 15, seporator);
        break;
      default:
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 2.h),
        SizedBox(
          height: 50.h,
          child: Row(
            children: [
              SizedBox(width: 8.w),
              Expanded(
                child: Stack(
                  children: [
                    ListView.builder(
                      padding: EdgeInsets.only(right: 59.w),
                      scrollDirection: Axis.horizontal,
                      itemCount: count,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              width: 50.h,
                              height: 50.h,
                              padding: EdgeInsets.only(
                                  top: paddingTop, right: paddingTop),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.w),
                                child: CachedNetworkImage(
                                  imageUrl: imgs[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  _deleteMaterialAtIndex(
                                    index,
                                    context: context,
                                  );
                                },
                                child: Image.asset(
                                  "assets/ai/ai_cartoon_config_close.png",
                                  width: 12.h,
                                  height: 12.h,
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: 59.w,
                      child: ByWidgetsUtil.gradientBgContainer(
                        borderRadius: 0,
                        gradient: ByColorUtil.lineareGradient(
                          colorStart: const Color(0xFFF8FAFB).withOpacity(0),
                          colorEnd: const Color(0xFFF8FAFB),
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        child: Container(),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  final provider = context.read<HotCaseReplicaProvider>();
                  final url = provider.inputValue;
                  ByNavRouterUtils.push(
                    context,
                    MultiProvider(
                        providers: [
                          ChangeNotifierProvider.value(
                            value: context.read<AiMaterialProvider>(),
                          ),
                          ChangeNotifierProvider.value(
                            value: context.read<AiClipProvider>(),
                          ),
                        ],
                        child: AiMaterialSelectPage(
                            isHotReplica: true, shareUrl: url)),
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.only(top: paddingTop * 0.5),
                  child: SizedBox(
                    height: 32.h,
                    child: ByWidgetsUtil.commonContainer(
                      bgColor: const Color(0xFFEAEEFF),
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      alignment: Alignment.center,
                      borerRadius: 8.w,
                      child: ByWidgetsUtil.commonText(
                        text: "重新选择",
                        fontSize: 12.sp,
                        textColor: ByColorUtil.TabTextColorSelected,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
            ],
          ),
        ),
        SizedBox(height: 5.h),
        Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: ByWidgetsUtil.commonRichText(
            texts: [
              TextSpan(text: "已选择$names等"),
              TextSpan(
                text: "$count",
                style: const TextStyle(
                  color: ByColorUtil.TabTextColorSelected,
                ),
              ),
              const TextSpan(text: "个素材"),
              // const TextSpan(
              //   text: "$mins",
              //   style: TextStyle(
              //     color: ByColorUtil.TabTextColorSelected,
              //   ),
              // ),
              // const TextSpan(text: "分钟。"),
            ],
            textColor: const Color(0xFFA0A3AE),
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  void _deleteMaterialAtIndex(
    int index, {
    required BuildContext context,
  }) {
    final provider = context.read<AiMaterialProvider>();
    switch (provider.currentType) {
      case AiMaterialType.clip:
        provider.updateSelectedClipMaterialsWithMaterialBean(
            provider.selectedClipMaterials[index]);
        break;
      case AiMaterialType.show:
        provider.updateSelectedShowListItemBeansWithBean(
            provider.selectedShowListBeans[index]);
        break;
      case AiMaterialType.mine:
        provider.updateSelectedMineMaterialItemBeansWithBean(
            provider.selectedMineMaterialItemBeans[index]);
        break;
      default:
    }
  }
}
