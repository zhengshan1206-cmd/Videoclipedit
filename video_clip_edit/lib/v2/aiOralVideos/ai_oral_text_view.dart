import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_dubbing_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/widgets/ai_create_text_dialog.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_input_mixin.dart';

import '../../modules/home/providers/by_audio_player.dart';
import '../../providers/launch_provider.dart';

///AI数字人 口播文案
class AiOralTextView<T extends AiInputMixin> extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final int maxWords;
  final FocusNode focusNode;
  final bool needAiHintText;
  const AiOralTextView({
    super.key,
    this.padding,
    required this.maxWords,
    required this.focusNode,
    this.needAiHintText = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WordsCounter(),
      child: AiCommonInputViewInner<T>(
        padding: padding,
        maxWords: maxWords,
        focusNode: focusNode,
        needAiHintText: needAiHintText,
      ),
    );
  }
}

class AiCommonInputViewInner<T extends AiInputMixin> extends StatefulWidget {
  const AiCommonInputViewInner({
    super.key,
    this.padding,
    this.extractCallback,
    this.hideExtractBtn = false,
    required this.maxWords,
    required this.focusNode,
    this.needAiHintText = true,
  });

  final EdgeInsetsGeometry? padding;
  final void Function()? extractCallback;
  final bool hideExtractBtn;
  final int maxWords;
  final FocusNode focusNode;
  final bool needAiHintText;

  @override
  State<AiCommonInputViewInner> createState() =>
      _AiCommonInputViewInnerState<T>();
}

class _AiCommonInputViewInnerState<T extends AiInputMixin>
    extends State<AiCommonInputViewInner<T>> {
  late TextEditingController controller;
  late final FocusNode focusNode;
  // final int maxWords = 2000;

  @override
  void dispose() {
    controller.removeListener(_textChanged);
    focusNode.removeListener(_focusNodeStatusChanged);
    super.dispose();
  }

  @override
  void initState() {
    focusNode = widget.focusNode;

    controller = TextEditingController(text: context.read<T>().inputValue)
      ..addListener(_textChanged);

    Future.microtask(() {
      focusNode.addListener(_focusNodeStatusChanged);
      focusNode.unfocus();
    });

    super.initState();
  }

  /// 失去焦点时更新provider的描述信息
  _focusNodeStatusChanged() {
    final provider = context.read<T>();

    if (!focusNode.hasFocus) {
      provider.updateInputValue(controller.text);
    }
  }

  /// 更新字数，并同步到 provider（避免键盘未收起时点击生成视频读到的是旧值）
  _textChanged() {
    final wordsCount = controller.text.length;
    if (wordsCount > widget.maxWords) {
      controller.text = controller.text.substring(0, widget.maxWords);
    }
    context.read<T>().updateInputValue(controller.text);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WordsCounter>().changeWordsCount(controller.text.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: widget.padding ??
          EdgeInsets.only(
            top: 0.h,
            left: 11.w,
            right: 11.w,
            bottom: 14.h + ByScreenUtils.bottomSafeHeight,
          ),
      color: ByColorUtil.WhiteColor,
      child: Stack(
        children: [
          /// 背景色
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8F9),
              // color: Colors.red,
              borderRadius: BorderRadius.circular(12.w),
            ),
          ),

          /// 输入框
          buildTextArea(context),

          /// 工具条
          buildToolBar(context),

          ///AI改写
          // _aiHintTextView(),

          AiWriteTextView(
            textEditingController: controller,
          ),
        ],
      ),
    );
  }

  /// 输入框
  Positioned buildTextArea(BuildContext context) {
    final desc = context.select<T, String>((p) => p.inputValue);
    byDebugPrint("---", tag: "buildTextArea:");
    // 仅当 provider 与 controller 不一致时同步（如清空、粘贴、AI 写入），避免每次 rebuild 覆盖导致光标跳到末尾
    if (controller.text != desc) {
      controller.text = desc;
    }
    return Positioned.fill(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0.h),
        child: Container(
          margin: EdgeInsets.only(bottom: 25.h),
          child: ExtendedTextField(
            maxLines: 5,
            expands: false,
            controller: controller,
            focusNode: focusNode,
            autofocus: false,
            onChanged: (String value) {},
            decoration: InputDecoration(
              border: InputBorder.none,
              labelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.normal,
                color: ByColorUtil.CommonTextColor,
              ),
              hintText: widget.needAiHintText ? "请输入您需要的配音的文案，至少15个字。" : "",
              hintStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.normal,
                color: ByColorUtil.CommonTextColor.withOpacity(0.3),
              ),
            ),
            cursorColor: ByColorUtil.CommonTextColor,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              color: Colors.black
            ),
          ),
        ),
      ),
    );
  }

  /// 输入框内的底部工具条
  Positioned buildToolBar(BuildContext context) {
    return Positioned(
      bottom: 5.h,
      child: SizedBox(
        width: ByScreenUtils.screenWidth - 24.w,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 10.w),
            _pasteBtnView(),
            // _buildIconBtn(
            //   title: '粘贴内容',
            //   icon: 'assets/ai/ai_cartoon_input_paste.png',
            //   onClick: () async {
            //     ClipboardData? data = await Clipboard.getData('text/plain');
            //     final text = data?.text;
            //     if (data == null || text == null || text.isEmpty) {
            //       BotToast.showText(text: "当前没有复制任何内容");
            //       return;
            //     }
            //
            //     final value = controller.value;
            //     // 获取当前光标位置
            //     final selection = value.selection;
            //     final cursorPosition = selection.start;
            //     // 如果光标有效，则在光标处插入文本
            //     if (cursorPosition != -1) {
            //       final newText = value.text.replaceRange(
            //         cursorPosition,
            //         cursorPosition,
            //         text,
            //       );
            //
            //       // 更新文本并设置新的光标位置
            //       controller.value = value.copyWith(
            //         text: newText,
            //         selection: TextSelection.collapsed(
            //           // 设置光标到粘贴内容末尾
            //           offset: cursorPosition + text.length,
            //         ),
            //       );
            //       // controller.
            //     } else {
            //       controller.text = text;
            //     }
            //     final provider = context.read<T>();
            //     provider.updateInputValue(controller.text);
            //   },
            // ),
            const Spacer(),
            WordsCounterView(maxWords: widget.maxWords),
            GestureDetector(
              onTap: () {
                if (ByAudioPlayer.sharedInstance.isPlaying) {
                  ByAudioPlayer.sharedInstance.pause();
                }
                controller.text = "";context.read<T>().updateInputValue("");
              },
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  SizedBox(
                    width: 5.w,
                  ),
                  ByWidgetsUtil.commonText(
                    text: "清空",
                    fontSize: 12.sp,
                    fontWeight: FontWeight.normal,
                    textColor: const Color(0XFF0B1843).withOpacity(0.5),
                  )
                ],
              ),
            ),
            SizedBox(width: 5.w),
            SizedBox(width: 5.w),
          ],
        ),
      ),
    );
  }

  SizedBox _buildIconBtn({
    required String title,
    required String icon,
    required void Function() onClick,
  }) {
    return SizedBox(
      height: 24.h,
      child: ByWidgetsUtil.btnWithIcon(
        title: title,
        iconPath: icon,
        iconW: 12.w,
        iconH: 12.h,
        onClick: onClick,
        fontSize: 12.sp,
        contentGap: 4.w,
        borderRadius: 20.w,
        fontWeight: FontWeight.normal,
        bgColor: ByColorUtil.WhiteColor,
        textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
      ),
    );
  }

  ///粘贴按钮
  Widget _pasteBtnView() {
    return GestureDetector(
      onTap: () async {
        if (ByAudioPlayer.sharedInstance.isPlaying) {
          ByAudioPlayer.sharedInstance.pause();
        }
        ClipboardData? data = await Clipboard.getData('text/plain');
        final text = data?.text;
        if (data == null || text == null || text.isEmpty) {
          BotToast.showText(text: "当前没有复制任何内容");
          return;
        }

        final value = controller.value;
        // 获取当前光标位置
        final selection = value.selection;
        final cursorPosition = selection.start;
        // 如果光标有效，则在光标处插入文本
        if (cursorPosition != -1) {
          final newText = value.text.replaceRange(
            cursorPosition,
            cursorPosition,
            text,
          );

          // 更新文本并设置新的光标位置
          controller.value = value.copyWith(
            text: newText,
            selection: TextSelection.collapsed(
              // 设置光标到粘贴内容末尾
              offset: cursorPosition + text.length,
            ),
          );
          // controller.
        } else {
          controller.text = text;
        }
        final provider = context.read<T>();
        provider.updateInputValue(controller.text);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0XFFF0F2F9),
          borderRadius: BorderRadius.circular(12.w),
        ),
        padding: EdgeInsets.only(left: 8.w, right: 8.w, top: 3.w, bottom: 3.w),
        child: Text(
          "粘贴",
          style: TextStyle(
              color: const Color(0XFF0B1843).withOpacity(0.5),
              fontWeight: FontWeight.w400,
              fontSize: 12.sp),
        ),
      ),
    );
  }
}

class WordsCounterView extends StatelessWidget {
  const WordsCounterView({
    super.key,
    required this.maxWords,
  });

  final int maxWords;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 29.h,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 0.w),
      child: ByWidgetsUtil.commonText(
        text: "${context.watch<WordsCounter>().count}/$maxWords",
        fontSize: 12.sp,
        textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
      ),
    );
  }
}

class WordsCounter extends BaseProvider {
  int count = 0;
  changeWordsCount(int c) {
    count = c;
    notifyListeners();
  }
}

///AI改写文案 在这里管理了AI创作文案弹窗
class AiWriteTextView extends StatefulWidget {
  final TextEditingController textEditingController;
  const AiWriteTextView({
    super.key,
    required this.textEditingController,
  });

  @override
  State<AiWriteTextView> createState() => _AiWriteTextViewState();
}

class _AiWriteTextViewState extends State<AiWriteTextView> {
  ///弹出AI创作文案弹窗
  void clickShowAiCreateTextDialog() {
    showModalBottomSheet(
      isDismissible: false,
      isScrollControlled: true, // 允许高度自适应
      context: context,
      builder: (context) {
        return const AiCreateTextDialog();
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(18),
        ),
      ),
    ).then((value) {
      if (value != null) {
        if (value["ai_result"] != null) {
          widget.textEditingController.text = value["ai_result"];
          context.read<AiOralDubbingProvider>().inputValue = value["ai_result"];
          Get.log("使用的文案~~==> ${value["ai_result"]} ");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int count = context.watch<WordsCounter>().count;
    if (count > 0) {
      return const SizedBox();
    }
    UserController userController = Get.find<UserController>();
    return Positioned(
      top: 10.w,
      left: 11.w,
      child: GestureDetector(
          onTap: () async {
            await ByAudioPlayer.sharedInstance.stop();
            UserController userController = Get.find<UserController>();
            final provider = context.read<LaunchProvider>();
            if (userController.user.value?.isVip != 1) {
              provider.gotoPay(
                context,
                closePay: true,
                replace: false,
              );
              return;
            }
            clickShowAiCreateTextDialog();
          },
          child: Row(
            children: [
              Text(
                "没有想法吗？",
                style: TextStyle(
                    color: const Color(0XFF0B1843).withOpacity(0.5),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500),
              ),
              Text(
                "【AI帮你写】",
                style: TextStyle(
                    color: const Color(0XFF5B4BF7),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600),
              ),
              if (userController.user.value?.isVip != 1)
                Image.asset(
                "assets/ai/oralVideos/new_ai_write_vip_icon.png",
                width: 30.w,
                height: 30.w,
              ),
            ],
          )
          // child: ByWidgetsUtil.commonRichText(
          //   texts: [
          //     TextSpan(
          //       text: "没有想法吗？",
          //       style: TextStyle(
          //           color: const Color(0XFF0B1843).withOpacity(0.5),
          //           fontSize: 14.sp,
          //           fontWeight: FontWeight.w300),
          //     ),
          //     TextSpan(
          //       text: "【AI帮你写】",
          //       style: TextStyle(
          //           color: const Color(0XFF5B4BF7),
          //           fontSize: 14.sp,
          //           fontWeight: FontWeight.w600),
          //     ),
          //   ],
          //   fontSize: 12.sp,
          //   textColor: ByColorUtil.LoginTextfieldTextColor.withOpacity(0.6),
          // ),
          ),
    );
  }
}
