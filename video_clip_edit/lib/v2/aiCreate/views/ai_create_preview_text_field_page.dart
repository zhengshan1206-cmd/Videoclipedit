import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/core/base/base_view.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/text_field/ai_create_text_field_view.dart';

class AiCreatePreviewTextFieldPage extends StatefulWidget {
  const AiCreatePreviewTextFieldPage({super.key});

  @override
  State<AiCreatePreviewTextFieldPage> createState() =>
      _AiCreatePreviewTextFieldPageState();
}

class _AiCreatePreviewTextFieldPageState
    extends State<AiCreatePreviewTextFieldPage> {
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: '民间故事',
      hasFlexibleSpace: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: AiCreateTextFieldView(
          showExpand: false,
          scrollController: scrollController,
          onValueChanged: (value) {
            _scrollToBottom();
          },
          onDone: () {
            Future.delayed(const Duration(milliseconds: 70), _scrollToBottom);
          },
        ),
      ),
    );
  }

  void _scrollToBottom() {
    if (!mounted) return;
    // 确保在下一帧滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
