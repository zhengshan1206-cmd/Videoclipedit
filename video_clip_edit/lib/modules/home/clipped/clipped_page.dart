import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/consts/const.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/widgets/common/right_navigation_bar.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/widgets/banner_view.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/modules/home/clipped/add_material_page.dart';
import 'package:video_clip_edit/modules/home/providers/clipped_provider.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/guide_page.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/common_function_list_cell.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/providers/video_extraction_provider.dart';

class ClippedPage<T extends MaterialBaseProvider> extends StatelessWidget {
  const ClippedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: Stack(
        children: [
          _buildBanner(context),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: 189.h)),

              /// 热门授权
              _buildFunctiionList(context),
            ],
          ),
          Positioned(child: _buildAppBar(context)),
        ],
      ),
    );
  }

  SliverList _buildFunctiionList(BuildContext context) {
    return SliverList.builder(
      itemCount: context.read<T>().functionList.length,
      itemBuilder: (ctx, index) {
        final provider = context.read<T>();
        final function = provider.functionList[index];
        return CommonFunctionListCell<T>(
          function: function,
          assetSelecctedCallback: (List<AssetEntity> assets) {
            /// 未选择则不处理
            if (assets.isEmpty) return;

            /// 将选中的素材添加到素材列表
            provider.addNewMaterials(assets);
            ByNavRouterUtils.push(
              context,
              name: Consts.kAddMaterialPage,
              ChangeNotifierProvider.value(
                value: provider,
                child: AddMaterialPage<T>(),
              ),
            ).then((_) {
              provider.clearSelectedMaterials();
            });
            // provider
          },
        );
      },
    );
  }

  _buildBanner(BuildContext context) {
    final bannerBeans = context.select<ClippedProvider, List<SubFunction>>(
      (value) => value.bannerBeans,
    );
    return Positioned(
      top: 0,
      left: 0,
      width: MediaQuery.of(context).size.width,
      height: 200.h,
      child: BannerView(
        urls: bannerBeans.isEmpty
            ? const ["assets/home/banner_cipped.png"]
            : bannerBeans.map((e) => e.imgUrl).toList(),
        onTap: (index) {
          if (bannerBeans.isNotEmpty) {
            ByCommonUtils.subFunctionCase(context, bannerBeans[index]);
          }
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      height: statusBarHeight + 44,
      padding: EdgeInsets.only(left: 12.w, right: 12.w, top: statusBarHeight),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ByNavRouterUtils.goBack(context);
            },
            child: Container(
              width: 44.w,
              height: 44,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 5.w),
              child: Image.asset(
                "assets/home/icon_back.png",
                width: 16,
                height: 16,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
