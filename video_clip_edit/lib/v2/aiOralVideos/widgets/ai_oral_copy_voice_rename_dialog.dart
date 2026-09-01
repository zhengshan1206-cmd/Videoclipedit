import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class AiOralCopyVoiceRenameDialog extends StatefulWidget {
  const AiOralCopyVoiceRenameDialog({
    super.key,
    this.onFinish,
  });

  final void Function(String name)? onFinish;

  @override
  State<AiOralCopyVoiceRenameDialog> createState() =>
      _AiOralCopyVoiceRenameDialogState();
}

class _AiOralCopyVoiceRenameDialogState
    extends State<AiOralCopyVoiceRenameDialog> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20.h, width: double.infinity),
            ByWidgetsUtil.commonText(
              text: "重命名",
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 42.h),
            SizedBox(
              height: 50.h,
              child: ByWidgetsUtil.commonContainer(
                borerRadius: 12.w,
                bgColor: const Color(0xFFECF1F3),
                child: TextField(
                  maxLines: null,
                  expands: true,
                  cursorColor: ByColorUtil.CommonTextColor,
                  // cursorHeight: 16.sp,
                  controller: _textEditingController,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 20 - 8.sp),
                    border: InputBorder.none,
                    labelStyle: TextStyle(
                      fontSize: 16.sp,
                      color: ByColorUtil.CommonTextColor,
                    ),
                    hintStyle: TextStyle(
                      fontSize: 16.sp,
                      color: ByColorUtil.CommonTextColor.withOpacity(0.3),
                    ),
                    hintText: "请输入内容",
                  ),
                ),
              ),
            ),
            SizedBox(height: 25.h),
            SizedBox(
              height: 50.h,
              child: ByWidgetsUtil.commonBtn(
                title: "确定",
                fontSize: 16.sp,
                borderRadius: 12.w,
                fontWeight: FontWeight.w500,
                onClick: () {
                  if (_textEditingController.text.isEmpty) {
                    BotToast.showText(text: "请输入内容");
                    return;
                  }
                  ByNavRouterUtils.goBack(context);
                  widget.onFinish?.call(_textEditingController.text);
                },
              ),
            ),
            SizedBox(
              height: 12.h +
                  ByScreenUtils.bottomSafeHeight +
                  MediaQuery.of(context).viewInsets.bottom,
            ),
          ],
        ),
      ),
    );
  }
}
