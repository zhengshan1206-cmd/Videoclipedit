// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_permission_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_videos_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/widgets/ai_oral_copy_voice_record_dialog.dart';
import 'package:video_clip_edit/v2/aiOralVideos/widgets/ai_oral_my_dubbing_list_view.dart';

class AiOralCopyNoticeDialog extends StatelessWidget {
  final AiOralVideosProvider provider;
  const AiOralCopyNoticeDialog({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> tips =
        context.select<AiOralVideosProvider, List<String>>(
      (value) => value.tips,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 20.h, width: double.infinity),
        ByWidgetsUtil.commonText(
          text: "声音复刻须知",
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 20.h),
        ByWidgetsUtil.commonContainer(
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          bgColor: const Color(0xFFF4F6FA),
          padding: EdgeInsets.only(bottom: 17.h),
          borerRadius: 18.w,
          child: ListView.builder(
            itemCount: tips.length + 1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/ai/oralVideos/ai_oral_icon_dubbing_tips.png",
                        width: 16,
                        height: 16,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: ByWidgetsUtil.commonText(
                          maxLines: 10,
                          fontSize: 12.sp,
                          height: 16 / 12.sp,
                          fontWeight: FontWeight.normal,
                          textColor:
                              ByColorUtil.CommonTextColor.withOpacity(0.5),
                          text: "为保证音色复刻效果，请您参考以下说明，录制自己的声音素材。",
                        ),
                      )
                    ],
                  ),
                );
              }
              return AiOralDubbingListCell(
                index: index,
                content: tips[index - 1],
              );
            },
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          height: 50.h,
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          child: ByWidgetsUtil.commonBtn(
            title: "接受并继续",
            fontSize: 16.sp,
            borderRadius: 12.w,
            fontWeight: FontWeight.w600,
            textColor: ByColorUtil.WhiteColor,
            onClick: () async {
              final permission = await ByPermissionUtils.microphone();
              if (permission == false) return;
              final provider = context.read<AiOralVideosProvider>();
              Get.back();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true, // 允许高度自适应
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                ),
                builder: (ctx) => ChangeNotifierProvider.value(
                    value: provider,
                    child:  AiOralCopyVoiceRecordDialog(provider: provider,)),
              );
              // Get.back();
            },
          ),
        ),
        SizedBox(height: 10.h + ByScreenUtils.bottomSafeHeight),
      ],
    );
  }
}
