import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';

class AnyReplaceDailog<T extends MaterialBaseProvider> extends StatefulWidget {
  const AnyReplaceDailog({super.key});

  @override
  State<AnyReplaceDailog<T>> createState() => _AnyReplaceDailogState<T>();
}

class _AnyReplaceDailogState<T extends MaterialBaseProvider>
    extends State<AnyReplaceDailog<T>> {
  final TextEditingController replacedController = TextEditingController();
  final TextEditingController sourceController = TextEditingController();
  @override
  void initState() {
    super.initState();
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
                SizedBox(height: 20.h),
                _buildInput(sourceController),
                SizedBox(height: 7.h),
                Image.asset(
                  "assets/home/icon_clip_replace.png",
                  width: 16.w,
                  height: 16.w,
                ),
                SizedBox(height: 7.h),
                _buildInput(replacedController),
                SizedBox(height: 10.h),
                ByWidgetsUtil.commonBtn(
                  title: "替换",
                  fontSize: 16.sp,
                  onClick: () {
                    ByNavRouterUtils.goBack(context);
                    byDebugPrint(replacedController.text);
                    context.read<T>().replaceAnyWord(
                          sourceController.text,
                          replacedController.text,
                        );
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
        // SizedBox(width: 30.w),
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
              "assets/home/icon_back.png",
              width: 12,
              height: 12,
            ),
          ),
        ),
        const Spacer(),
        ByWidgetsUtil.commonText(
          text: "首字母替换",
          textColor: ByColorUtil.CommonTextColor,
          fontSize: 16.sp,
        ),
        const Spacer(),
      ],
    );
  }

  _buildProhibitedWords(BuildContext context) {
    final provider = context.watch<T>();
    final prohibiteWords = provider.prohibiteWords;
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: List.generate(
        prohibiteWords.length,
        (index) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              provider.updateSelectedProhibiteWord(prohibiteWords[index]);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF62B60).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.w),
                border: Border.all(
                  color: prohibiteWords[index] == provider.selectedProhibiteWord
                      ? const Color(0xFFF62B60)
                      : Colors.transparent,
                ),
              ),
              // alignment: Alignment.center,
              child: ByWidgetsUtil.commonText(
                fontSize: 14.sp,
                text: prohibiteWords[index],
                fontWeight: FontWeight.normal,
                textColor: const Color(0xFFF62B60),
              ),
            ),
          );
        },
      ),
    );
  }

  _buildSelectedWord(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFECF1F3),
        borderRadius: BorderRadius.circular(10.w),
      ),
      child: ByWidgetsUtil.commonText(
        text: context.select<T, String>((p) => p.selectedProhibiteWord),
        textColor: ByColorUtil.CommonTextColor,
        fontSize: 16.sp,
      ),
    );
  }

  _buildInput(TextEditingController controller) {
    return Container(
      height: 50,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFECF1F3),
        borderRadius: BorderRadius.circular(10.w),
      ),
      child: TextField(
        maxLines: null,
        expands: true,
        controller: controller,
        cursorColor: ByColorUtil.CommonTextColor,
        // cursorHeight: 16.sp,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 10.w, vertical: 20 - 8.sp),
          border: InputBorder.none,
          labelStyle: TextStyle(
            fontSize: 16.sp,
            color: ByColorUtil.CommonTextColor,
          ),
          hintStyle: TextStyle(
            fontSize: 16.sp,
            color: ByColorUtil.CommonTextColor.withOpacity(0.3),
          ),
          hintText: "请输入替换词",
        ),
      ),
    );
  }
}
