import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/v2/aiOralVideos/widgets/ai_common_input_view.dart';

class ReplicaInputFiled extends StatelessWidget {
  const ReplicaInputFiled({
    super.key,
    required this.maxWords,
    required this.initText,
    this.onFoucusChanged,
    this.onTextChanged,
  });
  final int maxWords;
  final String initText;
  final void Function(bool, String)? onFoucusChanged;
  final void Function(String)? onTextChanged;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => WordsCounter(),
        child: ReplicaInputFiledInner(
          maxWords: maxWords,
          initText: initText,
          onFoucusChanged: onFoucusChanged,
          onTextChanged: onTextChanged,
        ));
  }
}

class ReplicaInputFiledInner extends StatefulWidget {
  const ReplicaInputFiledInner({
    super.key,
    required this.maxWords,
    required this.initText,
    this.onFoucusChanged,
    this.onTextChanged,
  });
  final int maxWords;
  final String initText;
  final void Function(bool, String)? onFoucusChanged;
  final void Function(String)? onTextChanged;
  @override
  State<ReplicaInputFiledInner> createState() => _ReplicaInputFiledInnerState();
}

class _ReplicaInputFiledInnerState extends State<ReplicaInputFiledInner> {
  late TextEditingController controller;
  late final FocusNode focusNode = FocusNode();
  @override
  void dispose() {
    controller.removeListener(_textChanged);

    focusNode.removeListener(_focusNodeStatusChanged);
    super.dispose();
  }

  /// 失去焦点时更新provider的描述信息
  _focusNodeStatusChanged() {
    widget.onFoucusChanged?.call(focusNode.hasFocus, controller.text);
  }

  /// 更新字数
  _textChanged() {
    final wordsCount = controller.text.length;
    if (wordsCount > widget.maxWords) {
      controller.text = controller.text.substring(0, widget.maxWords);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WordsCounter>().changeWordsCount(controller.text.length);
    });
  }

  @override
  void initState() {
    controller = TextEditingController(text: widget.initText)
      ..addListener(_textChanged);

    Future.microtask(() {
      focusNode.unfocus();
      focusNode.addListener(_focusNodeStatusChanged);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      // padding: EdgeInsets.symmetric(horizontal: 10.w),
      padding: EdgeInsets.only(left: 10.w,right: 10.w,),
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(
          color: const Color(0xFFEDEFF4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ExtendedTextField(
              maxLines: null,
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
                hintText: "请输入视频标题",
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.normal,
                  color: ByColorUtil.CommonTextColor.withOpacity(0.3),
                ),
              ),
              cursorColor: ByColorUtil.CommonTextColor,
            ),
          ),
          SizedBox(width: 5.w),
          Padding(padding: EdgeInsets.only(top: 5.w,),child:   WordsCounterView(maxWords: widget.maxWords),)
        ],
      ),
    );
  }
}
