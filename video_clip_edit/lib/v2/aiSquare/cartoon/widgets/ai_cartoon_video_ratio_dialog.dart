import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_settings_mixin.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_item_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_video_ratio_bean.dart';

class AiCartoonVideoRatioDialog<T extends AiSettingsMixin>
    extends StatelessWidget {
  const AiCartoonVideoRatioDialog({
    super.key,
    required this.itemBean,
  });

  final AiCartoonItemBean itemBean;

  @override
  Widget build(BuildContext context) {
    byDebugPrint("AiCartoonVideoRatioDialog_build");

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20.h),
                _buildTitle(context),
                SizedBox(height: 20.h),
                _buildRatios(context),
                SizedBox(height: 30.h),
                Container(
                  padding: EdgeInsets.only(
                    left: 12.w,
                    right: 12.w,
                    bottom: 8.h,
                  ),
                  height: 50.h,
                  child: ByWidgetsUtil.commonBtn(
                    title: "确定",
                    fontSize: 16.sp,
                    borderRadius: 12.w,
                    padding: EdgeInsets.zero,
                    fontWeight: FontWeight.w500,
                    textColor: ByColorUtil.WhiteColor,
                    onClick: () {
                      Navigator.of(context).pop(
                        context.read<T>().selectedRatioId,
                      );
                    },
                  ),
                )
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
            text: "视频比例",
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

  _buildRatios(BuildContext context) {
    final ratios = context.select<T, List<AiCartoonVideoRatioBean>>(
      (value) => value.videoRatioBeans,
    );
    return GridView.builder(
      itemCount: ratios.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 109.w / 60.h,
      ),
      itemBuilder: (context, index) {
        return AiCartoonVideoRatioCell<T>(
          index: index,
          onSelected: (id) {
            // itemBean.value = ratios[index].scale;
            context
                .read<T>()
                .updateSectionConfigBeansFrom(itemBean, ratios[index].scale);
          },
        );
      },
    );
  }
}

class AiCartoonVideoRatioCell<T extends AiSettingsMixin>
    extends StatelessWidget {
  const AiCartoonVideoRatioCell({
    super.key,
    required this.index,
    required this.onSelected,
  });

  final int index;
  final void Function(int id) onSelected;
  @override
  Widget build(BuildContext context) {
    byDebugPrint("AiCartoonVideoRatioCell_build");
    final provider = context.read<T>();
    final ratios = provider.videoRatioBeans;
    final selectedRatioId = context.select<T, int>((p) => p.selectedRatioId);
    final ratio = ratios[index];
    final selected = selectedRatioId == ratio.id;
    return GestureDetector(
      onTap: () {
        provider.updateSelectedRatioId(ratio.id);
        onSelected.call(ratio.id);
      },
      child: Stack(
        children: [
          ByWidgetsUtil.commonContainer(
            alignment: Alignment.center,
            border: Border.all(
              width: 1,
              color: selected
                  ? ByColorUtil.TabTextColorSelected
                  : const Color(0xFFF3F5F9),
            ),
            bgColor: ByColorUtil.CommonPageBgColor,
            child: Row(
              children: [
                SizedBox(width: 15.w),
                Image.asset(
                  "assets/ai/ai_cartoon_video_ratio_${ratio.scale.replaceAll(":", "_")}.png",
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 6.w),
                ByWidgetsUtil.commonText(text: ratio.scale),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Offstage(
              offstage: !selected,
              child: Image.asset(
                "assets/ai/ai_cartton_selected.png",
                width: 24,
                height: 24,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
