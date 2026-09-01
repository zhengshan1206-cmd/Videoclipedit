import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_settings_mixin.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_video_font_bean.dart';

class ReplicaCartoonVideoFontsDialog<T extends AiSettingsMixin>
    extends StatelessWidget {
  const ReplicaCartoonVideoFontsDialog({super.key});

  @override
  Widget build(BuildContext context) {
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
                _buildFonts(context),
                SizedBox(height: 15.h),
                _buildNoFontsBtn(context),
                SizedBox(height: 15.h),
                Container(
                  padding: EdgeInsets.only(
                    left: 12.w,
                    right: 12.w,
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
                      ByNavRouterUtils.goBack(context);
                    },
                  ),
                ),
                SizedBox(height: 8.h),
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
            text: "字幕设置",
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

  _buildFonts(BuildContext context) {
    final videoFontBeans = context.select<T, List<AiCartoonVideoFontBean>>(
        (value) => value.videoFontBeans);
    return GridView.builder(
      itemCount: videoFontBeans.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 15.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 17 / 5,
      ),
      itemBuilder: (context, index) {
        return AiCartoonVideoFontCell<T>(
            index: index, fontBean: videoFontBeans[index]);
      },
    );
  }

  _buildNoFontsBtn(BuildContext context) {
    final selectedFontId =
        context.select<T, int>((value) => value.selectedFontId);
    final selected = selectedFontId == 0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final provider = context.read<T>();
        provider.updateSelectedFontId(0);
      },
      child: Stack(
        children: [
          SizedBox(
            height: 50.h,
            child: ByWidgetsUtil.commonContainer(
              padding: EdgeInsets.zero,
              borerRadius: 12.w,
              margin: EdgeInsets.symmetric(horizontal: 12.w),
              border: Border.all(
                color:
                    selected ? ByColorUtil.LoginBtnBgColor : Colors.transparent,
              ),
              bgColor: ByColorUtil.CommonPageBgColor,
              alignment: Alignment.center,
              child: ByWidgetsUtil.commonText(
                text: "不需要字幕",
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                textColor: ByColorUtil.CommonTextColor,
              ),
            ),
          ),
          Positioned(
            right: 12.w,
            top: 0,
            child: Offstage(
              offstage: !selected,
              child: Image.asset(
                "assets/ai/ai_cartton_selected.png",
                width: 24.w,
                height: 24.h,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AiCartoonVideoFontCell<T extends AiSettingsMixin>
    extends StatelessWidget {
  const AiCartoonVideoFontCell({
    super.key,
    required this.index,
    required this.fontBean,
  });
  final AiCartoonVideoFontBean fontBean;
  final int index;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<T>();
    final selected = fontBean.id == provider.selectedFontId;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        provider.updateSelectedFontId(fontBean.id);
      },
      child: Stack(
        children: [
          Container(),
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: ByWidgetsUtil.commonContainer(
              borerRadius: 12.w,
              border: Border.all(
                color:
                    selected ? ByColorUtil.LoginBtnBgColor : Colors.transparent,
              ),
              bgColor: ByColorUtil.CommonPageBgColor,
              alignment: Alignment.center,
              child: CachedNetworkImage(imageUrl: fontBean.url),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Offstage(
              offstage: !selected,
              child: Image.asset(
                "assets/ai/ai_cartton_selected.png",
                width: 24.w,
                height: 24.h,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
    );
  }
}
