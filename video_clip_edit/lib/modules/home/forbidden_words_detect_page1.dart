import 'package:bot_toast/bot_toast.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/beans/text_risk_bean.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/any_replace_dailog.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/batch_replace_dailog.dart';
import 'package:video_clip_edit/modules/home/providers/forbidden_words_provider.dart';
import 'package:video_clip_edit/modules/profile/widgets/by_special_text_builder.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class ForbiddenWordsDetectPage1 extends StatefulWidget {
  const ForbiddenWordsDetectPage1({
    super.key,
  });

  @override
  State<ForbiddenWordsDetectPage1> createState() =>
      _ForbiddenWordsDetectPage1State();
}

class _ForbiddenWordsDetectPage1State extends State<ForbiddenWordsDetectPage1> {
  TextEditingController wordsEditingController = TextEditingController();

  final FocusNode focusNode = FocusNode();

  int pos = 0;

  String showText = "";

  List<String> prohibitList = [];

  bool isCheck = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(context: context, title: "违禁词检测"),
      backgroundColor: ByColorUtil.WhiteColor,
      body:  Column(
        children: [
          Container(
            height: 13.h,
            color: ByColorUtil.CommonPageBgColor,
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                bottom: 14.h + ByScreenUtils.bottomSafeHeight,
                left: 11.w,
                right: 11.w,
              ),
              color: ByColorUtil.WhiteColor,
              child: Stack(
                children: [
                  /// 背景色
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F8F9),
                      borderRadius: BorderRadius.circular(
                        12.w,
                      ),
                    ),
                  ),

                  /// 输入框
                  _buildTextArea(context),

                  /// 工具条
                  _buildToolBar(),
                ],
              ),
            ),
          ),
          _buildActions(context),
          _buildConfirmBtn(context),
        ],
      )
    );
  }

  Container _buildConfirmBtn(BuildContext context) {
    return Container(
      color: ByColorUtil.WhiteColor,
      padding: EdgeInsets.only(
          left: 12.w,
          right: 12.w,
          top: 10.h,
          bottom: ByScreenUtils.bottomSafeHeight + 10.h),
      child: Consumer<ForbiddenWordsProvider>(
        builder: (c, p, w) {
          p;
          return Column(
            children: [
              if (isCheck)
                ByWidgetsUtil.commonBtn(
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    title: "立即检测", //forbidden ? "检测成功" : "立即检测",
                    onClick: () {
                      FocusScope.of(context).unfocus();
                      if (isCheck) {
                        detect(context, wordsEditingController.text);
                      }
                    }),
              const SizedBox(height: 10),
              ByWidgetsUtil.commonBtn(
                padding: EdgeInsets.symmetric(vertical: 13.h),
                fontWeight: FontWeight.bold,
                bgColor: Colors.amber,
                textColor: Colors.black,
                fontSize: 16.sp,
                title: "复制",
                onClick: () => _copy(),
              )
            ],
          );
        },
      ),
    );
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: wordsEditingController.text));
    BotToast.showText(text: "复制成功");
  }

  Container _buildActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            child: ByWidgetsUtil.commonBtn(
              title: "首字母替换",
              fontSize: 14.sp,
              textColor: ByColorUtil.LoginBtnBgColor,
              bgColor: const Color(0xFF2E54FF).withOpacity(0.1),
              onClick: () {
                showDialog(
                  context: context,
                  useSafeArea: false,
                  builder: (ctx) => ChangeNotifierProvider.value(
                    value: context.read<ForbiddenWordsProvider>(),
                    child: const AnyReplaceDailog<ForbiddenWordsProvider>(),
                  ),
                );
              },
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: ByWidgetsUtil.commonBtn(
              title: "批量替换",
              fontSize: 14.sp,
              textColor: ByColorUtil.LoginBtnBgColor,
              bgColor: const Color(0xFF2E54FF).withOpacity(0.1),
              onClick: () {
                showDialog(
                  context: context,
                  useSafeArea: false,
                  builder: (ctx) => ChangeNotifierProvider.value(
                    value: context.read<ForbiddenWordsProvider>(),
                    child: const BatchReplaceDialog<ForbiddenWordsProvider>(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Positioned _buildTextArea(BuildContext context) {
    return Positioned.fill(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        child: ExtendedTextField(
          maxLines: 10,
          minLines: 1,
          // expands: false,
          controller: wordsEditingController,
          autofocus: false,
          specialTextSpanBuilder: BySpecialTextBuilder(),
          decoration: InputDecoration(
            border: InputBorder.none,
            labelStyle: TextStyle(
              fontSize: 14.sp,
              color: ByColorUtil.CommonTextColor,
            ),
            hintText: "请输入文字内容...",
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: ByColorUtil.CommonTextColor.withOpacity(0.5),
            ),
          ),
          cursorColor: ByColorUtil.CommonTextColor,
        ),
      ),
    );
  }

  Positioned _buildToolBar() {
    return Positioned(
      bottom: 6.h,
      child: SizedBox(
        width: ByScreenUtils.screenWidth - 24.w,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                byDebugPrint("粘贴", tag: "Voice Cover:");
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 29.h,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: ByWidgetsUtil.commonText(
                  text: "粘贴",
                  fontSize: 12.sp,
                  textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                ),
              ),
            ),
            Container(
              height: 29.h,
              alignment: Alignment.center,
              child: ByWidgetsUtil.commonText(
                text: "|",
                fontSize: 12.sp,
              ),
            ),
            GestureDetector(
              onTap: () {
                wordsEditingController.text = "123123123";
                byDebugPrint("清空", tag: "Voice Cover:");
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 29.h,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: ByWidgetsUtil.commonText(
                  text: "清空",
                  fontSize: 12.sp,
                  textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                ),
              ),
            ),
            const Spacer(),
            Container(
              height: 29.h,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: ByWidgetsUtil.commonText(
                text: "${wordsEditingController.text.length}/2000",
                fontSize: 12.sp,
                textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  foo(String content, List<String> words) {
    for (var e in words) {
      content = content.replaceAll(e, "\$$e\$");
    }
    return content;
  }

  bool forbidden = false;

  void detect(BuildContext context, String content) {
    if (content.isEmpty) {
      BotToast.showText(text: "请输入检测内容");
      return;
    }
    showText = content;

    var provider = context.read<ForbiddenWordsProvider>();
    provider.textRisk(
      content: showText,
      onSuccess: (data) {
        byDebugPrint(data, tag: "违禁词信息:");
        final status = data["status"] ?? 0;
        if (status == -1 || status == 200) {
          final TextRiskBean riskBean = TextRiskBean.fromJson(data["data"]);
          final riskWords = riskBean.labelName;
          updateProhibiteWords(riskWords);
          if (mounted) {
            setState(() {
              forbidden = status == 200;
              isCheck = prohibitList.isEmpty;
            });
          }

          wordsEditingController.text = foo(showText, prohibitList);
          byDebugPrint(forbidden, tag: "forbidden:");
          byDebugPrint(isCheck, tag: "isCheck:");
          byDebugPrint(riskWords, tag: "违禁词列表:");
        }
      },
    );
  }

  String selectText = "";
  updateProhibiteWords(List<String> words) {
    prohibitList = [];
    prohibitList = words;
    if (prohibitList.isNotEmpty) {
      selectText = prohibitList.first;
    } else {
      selectText = "";
    }
  }
}
