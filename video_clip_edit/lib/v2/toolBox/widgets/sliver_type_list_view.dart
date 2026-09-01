import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/providers/ai_chat_providers.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_cases_view.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/v2/toolBox/beans/new_tool_box_list_bean.dart';
import 'package:video_clip_edit/v2/toolBox/widgets/tool_box_banner_view.dart';
import 'package:video_clip_edit/v2/toolBox/providers/new_tool_box_provider.dart';
import 'package:video_clip_edit/v2/toolBox/beans/new_tool_box_category_bean.dart';

class SliverTypeListView extends StatelessWidget {
  const SliverTypeListView({
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
    double offset = context.select<NewToolBoxProvider, double>(
      (value) => value.currentOffset,
    );
    if (offset >= 210.h) {
      offset = 210.h;
    }
    final double opacity = offset >= 170.h ? offset / 210.h : 0;

    final selectedIndex = context.select<NewToolBoxProvider, int>(
      (val) => val.selectedIndex,
    );
    final List<NewToolBoxCategoryBean> categoryBeans =
        context.select<NewToolBoxProvider, List<NewToolBoxCategoryBean>>(
      (val) => val.categoryBeans,
    );

    return SliverPersistentHeader(
      pinned: true,
      delegate: StickyHeaderDelegate(
        minHeight: 44.h + ByScreenUtils.topSafeHeight,
        maxHeight: 244.h,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 200.h,
              child: const ToolBoxBannerView(),
            ),
            Column(
              children: [
                const Spacer(),
                Container(
                  color: Colors.white.withOpacity(opacity),
                  height: 44.h + ByScreenUtils.topSafeHeight,
                  padding: EdgeInsets.only(
                    bottom: 12.h,
                    top: ByScreenUtils.topSafeHeight,
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
                      final hasIcon = selected && category.icon.isNotEmpty;
                      return LayoutBuilder(builder: (context, constraits) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final renderBox =
                              context.findRenderObject() as RenderBox?;
                          if (renderBox != null) {
                            onSize(renderBox.size, index);
                          }
                        });
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                  right: index == categoryBeans.length - 1
                                      ? 0
                                      : 8.0),
                              child: ByWidgetsUtil.btnWithIcon(
                                title: category.title,
                                iconPath: category.icon,
                                iconW: hasIcon ? 16.w : 0,
                                iconH: 16.h,
                                contentGap: hasIcon ? 3 : 0,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                textColor: selected
                                    ? Colors.white
                                    : ByColorUtil.CommonTextColor.withOpacity(
                                        0.8),
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                bgColor: selected
                                    ? ByColorUtil.TabTextColorSelected
                                    : const Color(0xFFEAEEFF),
                                boxDecoration: BoxDecoration(
                                  border: Border.all(
                                    color: selected
                                        ? ByColorUtil.TabTextColorSelected
                                        : const Color(0xFFD9DDEB),
                                    width: 0.5,
                                  ),
                                  color: selected
                                      ? ByColorUtil.TabTextColorSelected
                                      : const Color(0xFFEAEEFF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                onClick: () {
                                  if (selectedIndex == index) return;
                                  context
                                      .read<NewToolBoxProvider>()
                                      .updateSelectedIndex(index);
                                  // pageController.jumpToPage(index);
                                  pageController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.decelerate,
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              right:
                                  index == categoryBeans.length - 1 ? 0 : 8.0,
                              top: -8.h,
                              child: Offstage(
                                offstage: category.mark.isEmpty,
                                child: CachedNetworkImage(
                                  imageUrl: category.mark,
                                  width: 23.w,
                                  height: 15.h,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                          ],
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AiChatTypeListView extends StatelessWidget {
  const AiChatTypeListView({
    super.key,
    required this.categoryScrollController,
    required this.onSize,
  });
  final ScrollController categoryScrollController;
  final void Function(Size size, int index) onSize;

  @override
  Widget build(BuildContext context) {
    final List<NewToolBoxListBean> categoryBeans =
        context.select<AiChatProviders, List<NewToolBoxListBean>>(
      (val) => val.listBeans,
    );

    return Container(
      clipBehavior: Clip.none,
      color: Colors.transparent,
      height: 38.h,
      padding: EdgeInsets.only(
        top: 10.h,
        // bottom: 12.h,
        left: 12.w,
        right: 12.w,
      ),
      child: ListView.builder(
        clipBehavior: Clip.none,
        controller: categoryScrollController,
        padding: EdgeInsets.only(left: 0.w, right: 0.w),
        itemCount: categoryBeans.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final category = categoryBeans[index];
          final hasIcon = category.icon.isNotEmpty;
          return LayoutBuilder(builder: (context, constraits) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final renderBox = context.findRenderObject() as RenderBox?;
              if (renderBox != null) {
                onSize(renderBox.size, index);
              }
            });
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.only(
                      right: index == categoryBeans.length - 1 ? 0 : 8.0),
                  child: ByWidgetsUtil.btnWithIcon(
                    title: category.title,
                    iconPath: category.icon,
                    iconW: hasIcon ? 16.w : 0,
                    iconH: 16.h,
                    contentGap: hasIcon ? 3 : 0,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    textColor: ByColorUtil.CommonTextColor.withOpacity(0.8),
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    bgColor: const Color(0xFFEAEEFF),
                    boxDecoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFD9DDEB),
                        width: 0.5,
                      ),
                      color: const Color(0xFFf3f5f9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onClick: () {
                      ///针对华为用户是否需要绑定手机号码
                      ByNavigatorUtil.checkLogin(
                          context: context,
                          nextStepEvent: () {
                            final bean = categoryBeans[index];
                            final data = SubFunction.fromJson({
                              "id": bean.id,
                              "title": bean.title,
                              "img_url": bean.icon,
                              "jump_url": bean.jumpUrl,
                              "jump_param": bean.jumpParam,
                              "type": bean.type,
                              "des": bean.des,
                              "isNew": false,
                              "fromChat": true,
                            });
                            ByCommonUtils.subFunctionCase(context, data);
                          });
                    },
                  ),
                ),
              ],
            );
          });
        },
      ),
    );
  }
}
