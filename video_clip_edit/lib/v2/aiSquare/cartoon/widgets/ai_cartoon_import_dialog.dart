import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_novel_write_page.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_novel_create_page.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_import_provider.dart';

class AiCartoonImportDialog extends StatefulWidget {
  const AiCartoonImportDialog({super.key});

  @override
  State<AiCartoonImportDialog> createState() => _AiCartoonImportDialogState();
}

class _AiCartoonImportDialogState extends State<AiCartoonImportDialog> {
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
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).pop();
            },
            child: SizedBox(
              height: 100.h,
              width: double.infinity,
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: ByColorUtil.WhiteColor,
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
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          SizedBox(
            width: 18.w,
            height: 14.h,
          ),
          const Spacer(),
          ByWidgetsUtil.commonText(
            text: "导入文案",
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).pop();
            },
            child: SizedBox(
              width: 18.w,
              height: 14.h,
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
    return Row(
      children: [
        Expanded(
          child: AiCartoonBgmTabView(
            pageController: _controller,
          ),
        ),
        SizedBox(
          height: 24.h,
          child: ByWidgetsUtil.commonBtn(
            title: "去创作",
            fontSize: 12.sp,
            borderRadius: 24,
            fontWeight: FontWeight.normal,
            bgColor: const Color(0xFFEAEEFF),
            textColor: ByColorUtil.TabTextColorSelected,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            onClick: () {
              byDebugPrint("去创作:");
            },
          ),
        ),
        SizedBox(width: 12.w),
      ],
    );
  }

  _buildPages() {
    return Expanded(
      child: AiCartoonBgmPageView(
        pageController: _controller,
      ),
    );
  }
}

class AiCartoonBgmPageView extends StatelessWidget {
  const AiCartoonBgmPageView({
    super.key,
    required this.pageController,
  });
  final PageController pageController;
  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      onPageChanged: (value) {
        final provider = context.read<AiCartoonImportProvider>();
        provider.updateSelectedTab(provider.tabs[value]);
      },
      children: const [
        AiCartoonNovelCreatePage(),
        AiCartoonNovelWritePage(),
      ],
    );
  }
}

class AiCartoonBgmTabView extends StatefulWidget {
  const AiCartoonBgmTabView({
    super.key,
    required this.pageController,
  });

  final PageController pageController;

  @override
  State<AiCartoonBgmTabView> createState() => _AiCartoonBgmTabViewState();
}

class _AiCartoonBgmTabViewState extends State<AiCartoonBgmTabView> {
  @override
  Widget build(BuildContext context) {
    final selectedTab =
        context.select<AiCartoonImportProvider, String>((p) => p.selectedTab);
    final tabs = context.read<AiCartoonImportProvider>().tabs;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: tabs.map(
          (e) {
            final selected = e == selectedTab;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                context.read<AiCartoonImportProvider>().updateSelectedTab(e);
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
    );
  }
}
