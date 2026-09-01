import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_bgm_mixin.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_settings_mixin.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_bgm_local_page.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_bgm_recommented_page.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_item_bean.dart';

import '../../../hotCreate/providers/new_short_play_list_controller.dart';

class AiCartoonBgmDialog<T extends AiSettingsMixin, S extends AiBgmMixin>
    extends StatefulWidget {
  const AiCartoonBgmDialog({
    super.key,
    required this.itemBean,
    this.fromNewShortPlayPage = false,
    this.controller,
  });

  final AiCartoonItemBean itemBean;
  final bool fromNewShortPlayPage;
  final NewShortPlayListController? controller;

  @override
  State<AiCartoonBgmDialog<T, S>> createState() =>
      _AiCartoonBgmDialogState<T, S>();
}

class _AiCartoonBgmDialogState<T extends AiSettingsMixin, S extends AiBgmMixin>
    extends State<AiCartoonBgmDialog<T, S>> {
  final PageController _controller = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          SizedBox(height: 100.h),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: ByColorUtil.CommonPageBgColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.w),
                    topRight: Radius.circular(18.w),
                  )),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  _buildTitle(),
                  SizedBox(height: 20.h),
                  _buildTab(context),
                  SizedBox(height: 8.h),
                  _buildPages(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  _buildTitle() {
    return Padding(
      padding: EdgeInsets.only(left: 12.w),
      child: Row(
        children: [
          SizedBox(
            width: 18.w,
            height: 14.h,
          ),
          const Spacer(),
          ByWidgetsUtil.commonText(
            text: "选择配乐",
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // Navigator.of(context).pop();
              Get.back();
            },
            child: Container(
              width: 33.w,
              height: 33.h,
              // color: Colors.blue,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 12.w),
              child: Image.asset(
                "assets/home/icon_close_dark.png",
                width: 14.w,
                height: 14.h,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
    );
  }

  _buildTab(BuildContext context) {
    return AiCartoonBgmTabView<T, S>(
      pageController: _controller,
      itemBean: widget.itemBean,
      fromNewShortPlayPage: widget.fromNewShortPlayPage,
      controller: widget.controller,
    );
  }

  _buildPages() {
    return Expanded(
      child: AiCartoonBgmPageView<T, S>(
        pageController: _controller,
        itemBean: widget.itemBean,
        fromNewShortPlayPage: widget.fromNewShortPlayPage,
        controller: widget.controller,
      ),
    );
  }
}

class AiCartoonBgmPageView<T extends AiSettingsMixin, S extends AiBgmMixin>
    extends StatelessWidget {
  const AiCartoonBgmPageView({
    super.key,
    required this.pageController,
    required this.itemBean,
    this.fromNewShortPlayPage = false,
    this.controller,
  });
  final PageController pageController;
  final AiCartoonItemBean itemBean;
  final bool fromNewShortPlayPage;
  final NewShortPlayListController? controller;

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      onPageChanged: (value) {
        final provider = context.read<S>();
        provider.updateSelectedTab(provider.tabs[value]);
      },
      children: [
        AiBgmRecommentedPage<T, S>(
          itemBean: itemBean,
          fromNewShortPlayPage: fromNewShortPlayPage,
          controller: controller,
        ),
        AiBgmLocalPage<T, S>(
          itemBean: itemBean,
          controller: controller,
        ),
      ],
    );
  }
}

class AiCartoonBgmTabView<T extends AiSettingsMixin, S extends AiBgmMixin>
    extends StatefulWidget {
  const AiCartoonBgmTabView({
    super.key,
    required this.pageController,
    required this.itemBean,
    this.fromNewShortPlayPage = false,
    this.controller,
  });

  final PageController pageController;
  final AiCartoonItemBean itemBean;

  final bool fromNewShortPlayPage;
  final NewShortPlayListController? controller;

  @override
  State<AiCartoonBgmTabView<T, S>> createState() =>
      _AiCartoonBgmTabViewState<T, S>();
}

class _AiCartoonBgmTabViewState<T extends AiSettingsMixin, S extends AiBgmMixin>
    extends State<AiCartoonBgmTabView<T, S>> {
  @override
  void dispose() {
    ByAudioPlayer.sharedInstance.stop();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = context.select<S, String>((p) => p.selectedTab);
    final tabs = context.read<S>().tabs;
    final selectedBgmUrl =
        context.select<T, String>((value) => value.selectedBgmUrl);
    final selected = selectedBgmUrl.isEmpty;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: tabs.map(
                (e) {
                  final selected = e == selectedTab;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      context.read<S>().updateSelectedTab(e);
                      widget.pageController.jumpToPage(tabs.indexOf(e));
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 20.w),
                      child: Column(
                        children: [
                          ByWidgetsUtil.commonText(
                            text: e,
                            fontSize: 16.sp,
                            textColor: selected
                                ? ByColorUtil.TabTextColorSelected
                                : ByColorUtil.CommonTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                          SizedBox(height: 5.h),
                          Container(
                            width: 15.w,
                            height: 3.h,
                            decoration: BoxDecoration(
                              color: selected
                                  ? ByColorUtil.TabTextColorSelected
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(3.h),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
          SizedBox(
            height: 28.h,
            child: ByWidgetsUtil.commonBtn(
              fontSize: 12.sp,
              borderWidth: 0.5,
              borderRadius: 28,
              title: "不需要背景音乐",
              fontWeight: FontWeight.normal,
              bgColor: selected
                  ? ByColorUtil.TabTextColorSelected
                  : ByColorUtil.WhiteColor,
              textColor: selected
                  ? ByColorUtil.WhiteColor
                  : ByColorUtil.TabTextColorSelected,
              borderColor: ByColorUtil.TabTextColorSelected,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              onClick: () {
                final providerBgm = context.read<S>();
                providerBgm.updateSelectedBgmId(-1);
                providerBgm.updateSelectedLocalBgmId(-1);
                final proider = context.read<T>();
                proider.selectedBgmUrl = "";
                proider.updateSectionConfigBeansFrom(
                  widget.itemBean,
                  "不需要背景音乐",
                );
                if (widget.controller != null) {
                  if (widget.fromNewShortPlayPage) {
                    widget.controller!.selectedBgmUrl = "";
                    widget.controller!.updateSectionConfigBeansFrom(
                      widget.itemBean,
                      "不需要背景音乐",
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
