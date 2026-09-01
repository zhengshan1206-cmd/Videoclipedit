import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_cases_view.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_videos_management_provider.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_video_materials_management_provider.dart';

class MineVideoMaterialsSliverTypeListView extends StatelessWidget {
  const MineVideoMaterialsSliverTypeListView({
    super.key,
    required this.categoryScrollController,
    required this.pageController,
    required this.onSize,
  });
  final ScrollController categoryScrollController;
  final PageController pageController;
  final void Function(Size size, int index) onSize;

  @override
  Widget build(BuildContext context) {
    final selectedIndex =
        context.select<MineVideoMaterialsManagementProvider, int>(
            (val) => val.selectedCategory);
    final List<MineVideosCategoryBean> categoryBeans = context.select<
        MineVideoMaterialsManagementProvider,
        List<MineVideosCategoryBean>>((val) => val.mineVideos);

    return SliverPersistentHeader(
      pinned: true,
      delegate: StickyHeaderDelegate(
        minHeight: 58.h,
        maxHeight: 58.h,
        child: Stack(
          children: [
            Container(
              color: const Color(0xFFFFFFFF),
              height: 58.h,
              padding: EdgeInsets.only(
                bottom: 12.h,
                top: 10.h,
              ),
              child: ListView.builder(
                controller: categoryScrollController,
                padding: EdgeInsets.only(
                  left: 12.w,
                  right: 12.w,
                ),
                itemCount: categoryBeans.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final selected = selectedIndex == index;
                  final category = categoryBeans[index];
                  return LayoutBuilder(builder: (context, constraits) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final renderBox =
                          context.findRenderObject() as RenderBox?;
                      if (renderBox != null) {
                        onSize(renderBox.size, index);
                      }
                    });
                    return Container(
                      padding: EdgeInsets.only(
                          right: index == categoryBeans.length - 1 ? 0 : 10.0),
                      child: ByWidgetsUtil.commonBtn(
                        title: category.title,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        textColor: const Color(0xFFF8FAFB),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        bgColor: selected
                            ? ByColorUtil.TabTextColorSelected
                            : const Color(0xFFB5B9C6),
                        borderColor: selected
                            ? ByColorUtil.TabTextColorSelected
                            : const Color(0xFFB5B9C6),
                        borderRadius: 10.w,
                        onClick: () {
                          if (selectedIndex == index) return;
                          context
                              .read<MineVideoMaterialsManagementProvider>()
                              .updateSelectedCategory(index);
                          pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.decelerate,
                          );
                        },
                      ),
                    );
                  });
                },
              ),
            ),
            Positioned.fill(
              child: Offstage(
                offstage:
                    context.select<MineVideoMaterialsManagementProvider, bool>(
                        (val) => val.videosEditing == false),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
