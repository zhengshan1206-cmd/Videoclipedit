import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/prohited/input_view_ex.dart';
import 'package:video_clip_edit/widgets/pan_to_unfocus.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/prohited/batch_replace_dailog.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/prohited/prohited_words_controller.dart';

class ProhibitedWordsDailog extends StatefulWidget {
  const ProhibitedWordsDailog({
    super.key,
    required this.originalContents,
    required this.onTextChanged,
  });

  final String originalContents;
  final void Function(String)? onTextChanged;

  @override
  State<ProhibitedWordsDailog> createState() => _ProhibitedWordsDailogState();
}

class _ProhibitedWordsDailogState extends State<ProhibitedWordsDailog> {
  late final ProhitedWordsController controller = Get.put(
    ProhitedWordsController(initialValue: widget.originalContents),
  );

  String lastDetectedContent = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    Get.delete<ProhitedWordsController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PanToUnfocus(
        child: Column(
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
                  SizedBox(
                    height: 400.h,
                    child: _buildInputWidget(context, 350.h),
                  ),
                  _buildProhibitedWords(context),
                  SizedBox(height: 10.h),
                  _buildActions(context),
                  SizedBox(
                    height: 50.h,
                    child: ByWidgetsUtil.commonBtn(
                      title: "立即检测",
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      onClick: () {
                        FocusScope.of(context).unfocus();

                        if (lastDetectedContent ==
                            controller.inputValue.value) {
                          BotToast.showText(text: "已经检测过该内容");
                          return;
                        }
                        Future.delayed(const Duration(milliseconds: 200), () {
                          controller.detect(
                            context,
                            controller.inputValue.value,
                            onSuccess: () {
                              if (controller.bandedWords.isEmpty) {
                                BotToast.showText(text: "当前已没有任何违禁词");
                                // Navigator.of(context).pop();
                              }
                            },
                          );
                        });
                      },
                    ),
                  ),
                  if (controller.bandedWords.isEmpty)
                    const SizedBox(height: 10),
                  if (controller.bandedWords.isEmpty)
                    ByWidgetsUtil.commonBtn(
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      fontWeight: FontWeight.bold,
                      textColor: Colors.white,
                      fontSize: 16.sp,
                      title: "确定",
                      onClick: () {
                        Navigator.of(context).pop();
                      },
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 输入框组件
  _buildInputWidget(BuildContext context, double? height) {
    return InputViewEx(
      editAreaHeight: 350.h,
      padding: EdgeInsets.only(left: 0.w, right: 0.w, top: 5.h, bottom: 10.h),
      onChanged: widget.onTextChanged,
    );
  }

  _buildActions(BuildContext context) {
    return Obx(() => Offstage(
          offstage: controller.bandedWords.isEmpty,
          child: Container(
            margin: EdgeInsets.only(bottom: 10.h),
            height: 44.h,
            child: Row(
              children: [
                Expanded(
                  child: ByWidgetsUtil.commonBtn(
                    title: "首字母替换",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.normal,
                    textColor: ByColorUtil.LoginBtnBgColor,
                    bgColor: const Color(0xFF2E54FF).withOpacity(0.1),
                    onClick: () {
                      controller.inputValue.value =
                          controller.replaceWithInitialLetterOfPinyin();
                      controller.detect(context, controller.inputValue.value);
                    },
                  ),
                ),
                SizedBox(width: 11.w),
                Expanded(
                  child: ByWidgetsUtil.commonBtn(
                    title: "批量替换",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.normal,
                    textColor: ByColorUtil.LoginBtnBgColor,
                    bgColor: const Color(0xFF2E54FF).withOpacity(0.1),
                    onClick: () {
                      if (controller.bandedWords.isEmpty) {
                        BotToast.showText(text: "暂无违禁词，请重新检测");
                        return;
                      }

                      showDialog(
                        context: context,
                        useSafeArea: false,
                        builder: (ctx) => const BatchReplaceDailog(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Row _buildTitle(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 30.w),
        const Spacer(),
        ByWidgetsUtil.commonText(
          text: "违禁词检测",
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
              "assets/login/login_dialog_close.png",
              width: 12,
              height: 12,
            ),
          ),
        ),
        // SizedBox(width: 11.w),
      ],
    );
  }

  /// 违禁词列表
  _buildProhibitedWords(BuildContext context) {
    return Obx(() {
      final bandedWords = controller.bandedWords;
      if (bandedWords.isEmpty) return Container();
      return SizedBox(
        height: 30.h,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          scrollDirection: Axis.horizontal,
          itemCount: bandedWords.length,
          itemBuilder: (context, index) {
            return Obx(() {
              final selected =
                  bandedWords[index] == controller.selectedBandedWord.value;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  controller.selectedBandedWord.value = bandedWords[index];
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  margin: EdgeInsets.only(
                      right: (index == bandedWords.length - 1) ? 0 : 10.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF62B60).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.w),
                    border: Border.all(
                      color: selected
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
            });
          },
        ),
      );
    });
  }
}
