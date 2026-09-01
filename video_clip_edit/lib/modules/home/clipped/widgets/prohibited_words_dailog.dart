import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/batch_replace_dailog.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/modules/home/widgets/prohibited_words_input_view.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/widgets/pan_to_unfocus.dart';

// ignore: must_be_immutable
class ProhibitedWordsDailog<T extends MaterialBaseProvider>
    extends StatefulWidget {
  String? content;
  int? contentLeng;
  Function(String content)? onSure;
  ProhibitedWordsDailog(
      {super.key,
      this.content,
      this.contentLeng,
      this.onSure}); // final String contents;

  @override
  State<ProhibitedWordsDailog> createState() =>
      _ProhibitedWordsDailogState<T>();
}

class _ProhibitedWordsDailogState<T extends MaterialBaseProvider>
    extends State<ProhibitedWordsDailog<T>> {
  late TextEditingController wordsEditingController;

  String lastDetectedContent = "";

  @override
  void initState() {
    super.initState();
    final provider = context.read<T>();
    wordsEditingController = TextEditingController(
      text: provider.subtitlesBean
          .wordsDisplay(prohitiedWods: provider.prohibiteWords),
    );
    String wordsOrigin = "";
    if (widget.content != null) {
      provider.subtitlesBean.wordsOrigin = widget.content!;
      //   provider.subtitlesBean.wordsOrigin=widget.content!;
      //    // wordsOrigin = widget.content!;
    } else {
      //   wordsOrigin = provider.subtitlesBean.wordsOrigin;
    }
    wordsOrigin = provider.subtitlesBean.wordsOrigin;
    lastDetectedContent = wordsOrigin;
    provider.detect(
      context,
      wordsOrigin,
      onSuccess: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<T>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                    child: _buildInputWidget(context),
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
                        final provider = context.read<T>();
                        if (lastDetectedContent ==
                            provider.subtitlesBean.wordsOrigin) {
                          BotToast.showText(text: "已经检测过该内容");
                          return;
                        }
                        Future.delayed(const Duration(milliseconds: 200), () {
                          provider.detect(
                            context,
                            provider.subtitlesBean.wordsOrigin,
                            onSuccess: () {
                              if (!provider.hasProhibiteWords()) {
                                BotToast.showText(text: "当前已没有任何违禁词");
                                // Navigator.of(context).pop();
                              }
                            },
                          );
                        });
                      },
                    ),
                  ),
                  if (provider.forbidden) const SizedBox(height: 10),
                  if (provider.forbidden)
                    ByWidgetsUtil.commonBtn(
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      fontWeight: FontWeight.bold,
                      bgColor: Colors.amber,
                      textColor: Colors.white,
                      fontSize: 16.sp,
                      title: widget.content != null ? "确定" : "复制",
                      onClick: () {
                        if (widget.content != null) {
                          widget.onSure?.call(
                              context.read<T>().subtitlesBean.wordsOrigin);
                          ByNavRouterUtils.goBack(context);
                        } else {
                          _copyContent(context);
                        }
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

  void _copyContent(BuildContext context) {
    Clipboard.setData(
      ClipboardData(
        text: context.read<T>().subtitlesBean.wordsOrigin,
      ),
    );
    BotToast.showText(text: "复制成功");
  }

  /// 输入框组件
  _buildInputWidget(BuildContext context) {
    return ProhibitedInputView<T>(
      hideExtractBtn: true,
      contentLength: widget.contentLeng,
      inputAutofocus: widget.content != null ? false : true,
      padding: EdgeInsets.only(left: 0.w, right: 0.w, top: 5.h, bottom: 10.h),
    );
  }

  _buildActions(BuildContext context) {
    return Offstage(
      offstage: !context.watch<T>().hasProhibiteWords(),
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
                  final provider = context.read<T>();
                  provider.updateSubtitle(
                    provider.replaceWithInitialLetterOfPinyin(),
                    onsSuccess: () {
                      provider.detect(
                          context, provider.subtitlesBean.wordsOrigin);
                    },
                  );
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
                  final provider = context.read<T>();
                  if (!provider.hasProhibiteWords()) {
                    BotToast.showText(text: "暂无违禁词，请重新检测");
                    return;
                  }
                  // ByNavRouterUtils.goBack(context);
                  showDialog(
                    context: context,
                    useSafeArea: false,
                    builder: (ctx) => ChangeNotifierProvider.value(
                      value: context.read<T>(),
                      child: BatchReplaceDialog<T>(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
    return Consumer<T>(builder: (context, provider, child) {
      final prohibiteWords = provider.prohibiteWords;
      if (prohibiteWords.isEmpty) return Container();

      return SizedBox(
        height: 30.h,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          scrollDirection: Axis.horizontal,
          itemCount: prohibiteWords.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                context
                    .read<T>()
                    .updateSelectedProhibiteWord(prohibiteWords[index]);
                // ByNavRouterUtils.goBack(context);
                showDialog(
                  context: context,
                  useSafeArea: false,
                  builder: (ctx) => ChangeNotifierProvider.value(
                    value: context.read<T>(),
                    child: BatchReplaceDialog<T>(),
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
}
