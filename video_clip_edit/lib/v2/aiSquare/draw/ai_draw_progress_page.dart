import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/ai_draw_details_page.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_provider.dart';

class AiDrawProgressPage extends StatefulWidget {
  const AiDrawProgressPage({
    super.key,
    required this.taskId,
  });

  final int taskId;

  @override
  State<AiDrawProgressPage> createState() => _AiDrawProgressPageState();
}

class _AiDrawProgressPageState extends State<AiDrawProgressPage> {
  final _cancelToken = CancelToken();
  @override
  void initState() {
    super.initState();

    _checkImgProgress();
  }

  @override
  void dispose() {
    _cancelToken.cancel("查询已取消");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {},
      child: Scaffold(
        backgroundColor: ByColorUtil.WhiteColor,
        appBar: ByWidgetsUtil.appBar(
          context: context,
          title: "绘图创作",
          // onPop: () {},
        ),
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 153.h),
              Image.asset(
                "assets/common/loading_large.gif",
                width: 120.w,
                height: 124.h,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 45.h),
              ByWidgetsUtil.commonRichText(
                texts: [
                  const TextSpan(text: "图片生成中..."),
                ],
                fontSize: 15.sp,
              ),
              SizedBox(height: 45.h),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _checkImgProgress() {
    final provider = context.read<AiDrawProvider>();
    provider.imageProgressQuery(
      id: widget.taskId,
      cancelToken: _cancelToken,
      onSuccess: () {
        ByNavRouterUtils.pushReplacement(
          context,
          ChangeNotifierProvider.value(
            value: provider,
            child: AiDrawDetailsPage(taskId: widget.taskId),
          ),
        );
      },
      onFailed: () {
        BotToast.showText(text: "服务器异常，请稍后再试");
      },
    );
  }
}
