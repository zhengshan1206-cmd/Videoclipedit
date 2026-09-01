import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_settings_mixin.dart';

class AiCartoonBatchReplaceDailog<T extends AiSettingsMixin>
    extends StatefulWidget {
  const AiCartoonBatchReplaceDailog({super.key});

  @override
  State<AiCartoonBatchReplaceDailog> createState() =>
      _AiCartoonBatchReplaceDailogState<T>();
}

class _AiCartoonBatchReplaceDailogState<T extends AiSettingsMixin>
    extends State<AiCartoonBatchReplaceDailog<T>> {
  final TextEditingController wordsEditingController = TextEditingController();
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
                SizedBox(height: 10.h),
                _buildProhibitedWords(context),
                SizedBox(height: 20.h),
                _buildSelectedWord(context),
                SizedBox(height: 7.h),
                Image.asset(
                  "assets/home/icon_clip_replace.png",
                  width: 16.w,
                  height: 16.w,
                ),
                SizedBox(height: 7.h),
                _buildInput(),
                SizedBox(height: 10.h),
                ByWidgetsUtil.commonBtn(
                  title: "替换",
                  fontSize: 16.sp,
                  onClick: () {
                    final provider = context.read<T>();
                    provider.replaceWord(wordsEditingController.text, () {
                      provider.detect(
                        context,
                        provider.desc,
                        onSuccess: () {
                          if (provider.bandedWords.isEmpty) {
                            FocusScope.of(context).unfocus();
                            ByNavRouterUtils.goBack(context);
                          } else {
                            provider.selectedBandedWord =
                                provider.bandedWords.first;
                          }
                        },
                      );
                    });
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
          text: "批量替换",
          textColor: ByColorUtil.CommonTextColor,
          fontSize: 16.sp,
        ),
        const Spacer(),
      ],
    );
  }

  _buildProhibitedWords(BuildContext context) {
    return Consumer<T>(builder: (context, provider, child) {
      final bandedWords = provider.bandedWords;
      byDebugPrint(bandedWords, tag: "prohibiteWords:");
      if (provider.selectedBandedWord.isEmpty) {
        provider.selectedBandedWord = bandedWords[0];
      }

      return Wrap(
        spacing: 5,
        runSpacing: 5,
        children: List.generate(
          bandedWords.length,
          (index) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                provider.updateSelectedBandedWord(bandedWords[index]);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF62B60).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.w),
                  border: Border.all(
                    color: bandedWords[index] == provider.selectedBandedWord
                        ? const Color(0xFFF62B60)
                        : Colors.transparent,
                  ),
                ),
                child: ByWidgetsUtil.commonText(
                  fontSize: 14.sp,
                  text: bandedWords[index],
                  fontWeight: FontWeight.normal,
                  textColor: const Color(0xFFF62B60),
                ),
              ),
            );
          },
        ),
      );
    });
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
        child: Consumer<T>(builder: (context, provider, child) {
          return ByWidgetsUtil.commonText(
            text: provider.selectedBandedWord,
            textColor: ByColorUtil.CommonTextColor,
            fontSize: 16.sp,
          );
        }));
  }

  _buildInput() {
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
        controller: wordsEditingController,
        cursorColor: ByColorUtil.CommonTextColor,
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
