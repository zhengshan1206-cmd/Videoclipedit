import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/home/providers/forbidden_words_provider.dart';
import 'package:video_clip_edit/modules/home/widgets/prohibited_words_input_view.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/batch_replace_dailog.dart';
import 'package:video_clip_edit/widgets/pan_to_unfocus.dart';

class ForbiddenWordsDetectPage extends StatefulWidget {
  const ForbiddenWordsDetectPage({
    super.key,
  });

  @override
  State<ForbiddenWordsDetectPage> createState() =>
      _ForbiddenWordsDetectPageState();
}

class _ForbiddenWordsDetectPageState extends State<ForbiddenWordsDetectPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ByWidgetsUtil.appBar(context: context, title: "违禁词检测"),
        backgroundColor: ByColorUtil.WhiteColor,
        body: PanToUnfocus(
          child: Column(
            children: [
              Expanded(
                child: _buildInputWidget(context),
              ),
              _buildProhibitedWords(context),
              SizedBox(height: 10.h),
              _buildActions(context),
              _buildConfirmBtn(context),
              SizedBox(height: 10.h),
            ],
          ),
        ));
  }

  /// 违禁词列表
  _buildProhibitedWords(BuildContext context) {
    return Consumer<ForbiddenWordsProvider>(
        builder: (context, provider, child) {
      final prohibiteWords = provider.prohibiteWords;
      if (prohibiteWords.isEmpty) return Container();

      return SizedBox(
        height: 30.h,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          scrollDirection: Axis.horizontal,
          itemCount: prohibiteWords.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                context
                    .read<ForbiddenWordsProvider>()
                    .updateSelectedProhibiteWord(prohibiteWords[index]);
                // ByNavRouterUtils.goBack(context);
                showDialog(
                  context: context,
                  useSafeArea: false,
                  builder: (ctx) => ChangeNotifierProvider.value(
                    value: context.read<ForbiddenWordsProvider>(),
                    child: const BatchReplaceDialog<ForbiddenWordsProvider>(),
                  ),
                );
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                margin: EdgeInsets.only(
                    right: (index == prohibiteWords.length - 1) ? 0 : 10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF62B60).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.w),
                  border: Border.all(
                    color:
                        prohibiteWords[index] == provider.selectedProhibiteWord
                            ? const Color(0xFFF62B60)
                            : Colors.transparent,
                  ),
                ),
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
    });
  }

  /// 输入框组件
  _buildInputWidget(BuildContext context) {
    return ProhibitedInputView<ForbiddenWordsProvider>(
      padding: EdgeInsets.only(
        top: 15.h,
        left: 11.w,
        right: 11.w,
        bottom: 12.h,
      ),
    );
  }

  /// 确认按钮
  Container _buildConfirmBtn(BuildContext context) {
    return Container(
      color: ByColorUtil.WhiteColor,
      padding: EdgeInsets.only(
          left: 12.w,
          right: 12.w,
          bottom: ByScreenUtils.bottomSafeHeight + 10.h),
      child: Consumer<ForbiddenWordsProvider>(
        builder: (c, p, w) {
          p;
          return Column(
            children: [
              ByWidgetsUtil.commonBtn(
                padding: EdgeInsets.symmetric(vertical: 13.h),
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                title: "立即检测", //p.forbidden ? "检测成功" :
                onClick: () {
                  final purchaseProvider = context.read<PurchaseProvider>();
                  if (purchaseProvider.preLoginCheck(context) == false) return;
                  FocusScope.of(context).unfocus();
                  Future.delayed(const Duration(milliseconds: 200), () {
                    if (p.forbidden) {
                      p.detect(
                        context,
                        p.subtitlesBean.wordsOrigin,
                        onSuccess: () {
                          // updateTextDisplay(p, controller.text);
                        },
                      );
                    } else {
                      p.detect(
                        context,
                        p.subtitlesBean.wordsOrigin,
                        onSuccess: () {
                          // updateTextDisplay(p, controller.text);
                        },
                      );
                    }
                  });
                },
              ),
              if (p.forbidden) const SizedBox(height: 10),
              if (p.forbidden)
                ByWidgetsUtil.commonBtn(
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                  fontWeight: FontWeight.bold,
                  bgColor: Colors.amber,
                  textColor: Colors.white,
                  fontSize: 16.sp,
                  title: "复制",
                  onClick: () => _copyContent(context),
                )
            ],
          );
        },
      ),
    );
  }

  void _copyContent(BuildContext context) {
    Clipboard.setData(
      ClipboardData(
        text: context.read<ForbiddenWordsProvider>().subtitlesBean.wordsOrigin,
      ),
    );
    BotToast.showText(text: "复制成功");
  }

  /// 替换按钮列表
  _buildActions(BuildContext context) {
    final provider = context.watch<ForbiddenWordsProvider>();
    return Offstage(
      offstage: !provider.hasProhibiteWords(),
      child: Container(
        padding: EdgeInsets.only(left: 11.w, right: 11.w, bottom: 10.h),
        child: SizedBox(
          height: 44.h,
          child: Row(
            children: [
              Expanded(
                child: ByWidgetsUtil.commonBtn(
                  title: "首字母替换",
                  fontSize: 14.sp,
                  textColor: ByColorUtil.LoginBtnBgColor,
                  bgColor: const Color(0xFF2E54FF).withOpacity(0.1),
                  onClick: () {
                    final provider = context.read<ForbiddenWordsProvider>();
                    final res = provider.replaceWithInitialLetterOfPinyin();

                    provider.updateForbiddenState(true);
                    provider.updateSubtitle(res);
                    provider.detect(context, res);
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
                    final provider = context.read<ForbiddenWordsProvider>();
                    if (!provider.hasProhibiteWords()) {
                      BotToast.showText(text: "暂无违禁词，请重新检测");
                      return;
                    }
                    showDialog(
                      context: context,
                      useSafeArea: false,
                      builder: (ctx) => ChangeNotifierProvider.value(
                        value: provider,
                        child:
                            const BatchReplaceDialog<ForbiddenWordsProvider>(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
