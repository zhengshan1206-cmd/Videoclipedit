import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/modules/home/providers/show_recreate_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class SelectNarratorDailog<T extends MaterialBaseProvider>
    extends StatefulWidget {
  const SelectNarratorDailog({
    super.key,
    required this.callback,
  });
  final void Function(bool changed) callback;
  @override
  State<SelectNarratorDailog<T>> createState() =>
      _SelectNarratorDailogState<T>();
}

class _SelectNarratorDailogState<T extends MaterialBaseProvider>
    extends State<SelectNarratorDailog<T>> {
  final TextEditingController wordsEditingController = TextEditingController();
  int selectedIndex = 0;
  String selectedName = "";

  @override
  void initState() {
    super.initState();

    final provider = context.read<ShowRecreateProvider>();
    final List<String> titles =
        provider.speakerQuotesBeans.map((e) => e.speaker).toSet().toList();
    titles.insert(0, "第三视角");

    setState(() {
      selectedName = provider.selectedRoleName;
      selectedIndex = titles.indexOf(selectedName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const Spacer(),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              bottom: 14.h + ByScreenUtils.bottomSafeHeight,
              left: 11.w,
              right: 11.w,
            ),
            decoration: BoxDecoration(
              color: ByColorUtil.WhiteColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.w),
                topRight: Radius.circular(18.w),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 13.h),
                _buildTitle(context),
                SizedBox(height: 15.h),
                _buildNarratorList(context),
                SizedBox(height: 10.h),
                ByWidgetsUtil.commonBtn(
                  title: "确定",
                  fontSize: 16.sp,
                  onClick: () {
                    final provider = context.read<ShowRecreateProvider>();
                    final originName = provider.selectedRoleName;
                    final bool changed = originName != selectedName;
                    byDebugPrint("$originName --- $selectedName --- $changed");
                    provider.updateSelectedRoleName(selectedName);
                    widget.callback(changed);
                    ByNavRouterUtils.goBack(context);
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Row _buildTitle(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 30.w),
        const Spacer(),
        ByWidgetsUtil.commonText(
          text: "选择解说人",
          textColor: ByColorUtil.CommonTextColor,
          fontSize: 16.sp,
        ),
        const Spacer(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            ByNavRouterUtils.goBack(context);
          },
          child: Container(
            width: 30.w,
            height: 30.w,
            alignment: Alignment.center,
            child: Image.asset(
              "assets/home/icon_close_dark.png",
              width: 12,
              height: 12,
            ),
          ),
        ),
      ],
    );
  }

  _buildNarratorList(BuildContext context) {
    final provider = context.read<ShowRecreateProvider>();
    final List<String> titles =
        provider.speakerQuotesBeans.map((e) => e.speaker).toSet().toList();
    titles.insert(0, "第三视角");
    return ListView.builder(
      itemCount: titles.length,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final selected = index == selectedIndex;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              selectedIndex = index;
              selectedName = titles[index];
            });
          },
          child: ByWidgetsUtil.commonContainer(
            borerRadius: 10.w,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 10.h,
            ),
            margin: EdgeInsets.symmetric(vertical: 5.h),
            bgColor: selected
                ? const Color(0xFF3753FF).withOpacity(0.1)
                : const Color(0xFFECF1F3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ByWidgetsUtil.commonText(
                  text: titles[index],
                  fontSize: 16.sp,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  textColor: selected
                      ? ByColorUtil.TabTextColorSelected
                      : ByColorUtil.CommonTextColor,
                ),
                if (index == 0)
                  ByWidgetsUtil.commonText(
                    text: "(完全独立剧情外的路人视角)",
                    fontSize: 12.sp,
                    fontWeight: FontWeight.normal,
                    textColor: selected
                        ? ByColorUtil.TabTextColorSelected.withOpacity(0.8)
                        : ByColorUtil.CommonTextColor.withOpacity(0.8),
                  )
              ],
            ),
          ),
        );
      },
    );
  }
}
