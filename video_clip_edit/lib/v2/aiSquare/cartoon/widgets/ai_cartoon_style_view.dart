import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_screen_style_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/widgets/ai_cartoon_style_preview.dart';

class AiCartoonStyleView extends StatelessWidget {
  const AiCartoonStyleView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenStyleBeans =
        context.select<AiCartoonProvider, List<AiCartoonScreenStyleBean>>(
            (value) => value.screenStyleBeans);
    final selectedId = context
        .select<AiCartoonProvider, int>((value) => value.selectedStyleId);
    return SliverPadding(
      padding: EdgeInsets.only(top: 11.h),
      sliver: SliverToBoxAdapter(
        child: KeyboardDismissOnTap(
          dismissOnCapturedTaps: true,
          child: SizedBox(
            height: 98.h,
            child: ListView.builder(
              itemCount: screenStyleBeans.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final caseI = screenStyleBeans[index];
                final selected = caseI.id == selectedId;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    final provider = context.read<AiCartoonProvider>();
                    final modelId = caseI.id;
                    provider.updateSelectedStyleId(modelId);
                  },
                  child: Container(
                    width: 100.w,
                    margin: EdgeInsets.only(right: 8.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.w),
                      child: Stack(
                        children: [
                          Container(),
                          Positioned.fill(
                            child: CachedNetworkImage(
                              imageUrl: caseI.url,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: Offstage(
                              offstage: !selected,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.w),
                                  border: Border.all(
                                    color: ByColorUtil.TabTextColorSelected,
                                    width: 1.5.w,
                                  ),
                                  // color: const Color(0xFF020C2A).withOpacity(0.3),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Offstage(
                              offstage: !selected,
                              child: Image.asset(
                                "assets/ai/ai_cartton_selected.png",
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            top: 0,
                            left: 0,
                            child: Offstage(
                              offstage: !selected,
                              child: Center(
                                child: SizedBox(
                                  width: 63.w,
                                  height: 23.h,
                                  child: ByWidgetsUtil.commonBtn(
                                    padding: EdgeInsets.zero,
                                    borderRadius: 20.w,
                                    title: "点击查看",
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    bgColor: const Color(0xFFEAEEFF)
                                        .withOpacity(0.5),
                                    textColor: ByColorUtil.TabTextColorSelected,
                                    onClick: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        builder: (ctx) =>
                                            ChangeNotifierProvider.value(
                                          value:
                                              context.read<AiCartoonProvider>(),
                                          child: AiCartoonStylePreview(
                                            styleBean: caseI,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            height: 30.h,
                            child: ByWidgetsUtil.gradientBgContainer(
                                padding: EdgeInsets.zero,
                                borderRadius: 0,
                                gradient: LinearGradient(
                                  colors: [
                                    ByColorUtil.BlackColor.withOpacity(0.8),
                                    ByColorUtil.BlackColor.withOpacity(0),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                child: ByWidgetsUtil.commonText(
                                  text: caseI.title,
                                  textColor: ByColorUtil.WhiteColor,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.normal,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
