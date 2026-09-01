import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_image_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/widgets/ai_cartoon_regenerate_input_view.dart';

class AiCartoonVideoRegenerateDialog extends StatefulWidget {
  const AiCartoonVideoRegenerateDialog({
    super.key,
    required this.bean,
  });

  final AiCartoonImageBean bean;

  @override
  State<AiCartoonVideoRegenerateDialog> createState() =>
      _AiCartoonVideoRegenerateDialogState();
}

class _AiCartoonVideoRegenerateDialogState
    extends State<AiCartoonVideoRegenerateDialog> {
  String contents = "";

  @override
  Widget build(BuildContext context) {
    byDebugPrint("AiCartoonVideoRegenerateDialog_build");
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: ByColorUtil.WhiteColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.w),
                topRight: Radius.circular(18.w),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20.h),
                _buildTitle(context),
                SizedBox(height: 15.h),
                ByWidgetsUtil.commonTipsBar("仅对想要替换的图片进行画面描述，不会修改小说文案。"),
                SizedBox(height: 8.h),
                SizedBox(
                  height: 150.h,
                  child: AiCartoonRegenerateInputView(
                    padding: EdgeInsets.zero,
                    useProvider: false,
                    onChanged: (String val) {
                      contents = val;
                    },
                  ),
                ),
                SizedBox(height: 15.h),
                Container(
                  padding: EdgeInsets.only(
                    bottom: 8.h,
                  ),
                  height: 50.h,
                  child: ByWidgetsUtil.commonBtn(
                    title: "一键AI重绘",
                    fontSize: 16.sp,
                    borderRadius: 12.w,
                    padding: EdgeInsets.zero,
                    fontWeight: FontWeight.w500,
                    textColor: ByColorUtil.WhiteColor,
                    onClick: () {
                      if (contents.isEmpty) {
                        BotToast.showText(text: "请输入提示词");
                        return;
                      }
                      final provider = context.read<AiCartoonProvider>();
                      context.read<AiCartoonProvider>().regernateImage(
                            imgId: widget.bean.id,
                            isAi: 2,
                            imgUrl: widget.bean.url,
                            prompt: contents,
                            onSuccess: () {
                              provider.loadImageList();
                              ByNavRouterUtils.goBack(context);
                            },
                          );
                    },
                  ),
                ),
                // SizedBox(height: 10.h),
                // ByWidgetsUtil.commonRichText(
                //   texts: [
                //     const TextSpan(text: "不会写提示词，去看看提示词"),
                //     TextSpan(
                //       text: "编写攻略",
                //       style: const TextStyle(
                //           color: ByColorUtil.TabTextColorSelected),
                //       recognizer: TapGestureRecognizer()..onTap = () {},
                //     ),
                //     TextSpan(
                //       text: "›",
                //       style: TextStyle(
                //         color: ByColorUtil.TabTextColorSelected,
                //         fontSize: 20.sp,
                //       ),
                //       recognizer: TapGestureRecognizer()..onTap = () {},
                //     ),
                //   ],
                //   fontSize: 12.sp,
                // ),
                SizedBox(
                  height: 15.h + ByScreenUtils.bottomSafeHeight,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _buildTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          SizedBox(
            width: 18.w,
            height: 14.h,
          ),
          const Spacer(),
          ByWidgetsUtil.commonText(
            text: "AI重绘",
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).pop();
            },
            child: SizedBox(
              width: 18.w,
              height: 14.h,
              child: Image.asset(
                "assets/home/icon_close_dark.png",
                width: 14.w,
                height: 14.h,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
    );
  }
}
