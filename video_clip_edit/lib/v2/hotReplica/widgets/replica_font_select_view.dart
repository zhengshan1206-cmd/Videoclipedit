import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_video_font_bean.dart';
import 'package:video_clip_edit/v2/hotReplica/providers/hot_case_replica_provider.dart';
import 'package:video_clip_edit/v2/hotReplica/widgets/replica_cartoon_video_fonts_dialog.dart';

class ReplicaFontSelectView extends StatelessWidget {
  const ReplicaFontSelectView({super.key});
  @override
  Widget build(BuildContext context) {
    final moreSettingsOn = context.select<HotCaseReplicaProvider, bool>(
      (value) => value.moreSettingsOn,
    );
    if (!moreSettingsOn) return const SliverToBoxAdapter(child: SizedBox());
    final selectedFontId =
        context.select<AiClipProvider, int>((value) => value.selectedFontId);
    bool selected = selectedFontId >= 0;

    return SliverPadding(
      padding: EdgeInsets.only(top: 10.h, left: 12.w, right: 12.w),
      sliver: SliverToBoxAdapter(
        child: SizedBox(
          height: 60.h,
          child: ByWidgetsUtil.commonContainer(
            bgColor: const Color(0xFFF8FAFB),
            border: Border.all(
              color: const Color(0xFFF3F5F9),
              width: 0.5,
            ),
            borerRadius: 10.w,
            child: selected
                ? _buildSelectedView(context)
                : _buildUnselectedView(context),
          ),
        ),
      ),
    );
  }

  void _showFontDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: context.read<AiClipProvider>()),
          ],
          child: const ReplicaCartoonVideoFontsDialog<AiClipProvider>(),
        );
      },
    );
  }

  /// 未选择
  _buildUnselectedView(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        _showFontDialog(context);
      },
      child: Row(
        children: [
          SizedBox(width: 10.w),
          Image.asset(
            "assets/ai/clip/ai_clip_material_add.png",
            width: 24.w,
            height: 24.h,
          ),
          SizedBox(width: 6.w),
          ByWidgetsUtil.commonText(
            text: "字幕设置",
            fontWeight: FontWeight.w500,
          ),
          const Spacer(),
          SizedBox(
            height: 32.h,
            child: ByWidgetsUtil.commonContainer(
              bgColor: const Color(0xFFEAEEFF),
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              alignment: Alignment.center,
              borerRadius: 8.w,
              child: ByWidgetsUtil.commonText(
                text: "去选择",
                fontSize: 12.sp,
                textColor: ByColorUtil.TabTextColorSelected,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
    );
  }

  /// 已选择
  Widget _buildSelectedView(BuildContext context) {
    final provider = context.read<AiClipProvider>();
    final selectedFontId = provider.selectedFontId;
    AiCartoonVideoFontBean? fontBean;
    if (selectedFontId != 0) {
      fontBean = provider.videoFontBeans.firstWhere(
        (element) => element.id == selectedFontId,
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        _showFontDialog(context);
      },
      child: Row(
        children: [
          SizedBox(width: 10.w),
          ByWidgetsUtil.commonText(
            text: selectedFontId == 0 ? "不需要字幕" : fontBean!.title,
            fontWeight: FontWeight.w500,
          ),
          const Spacer(),
          SizedBox(
            height: 32.h,
            child: ByWidgetsUtil.commonContainer(
              bgColor: const Color(0xFFEAEEFF),
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              alignment: Alignment.center,
              borerRadius: 8.w,
              child: ByWidgetsUtil.commonText(
                text: "重新选择",
                fontSize: 12.sp,
                textColor: ByColorUtil.TabTextColorSelected,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
    );
  }
}
