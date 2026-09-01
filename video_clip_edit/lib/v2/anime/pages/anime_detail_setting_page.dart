

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/anime/pages/anime_no_intergral_dialog.dart';
import '../../../modules/ai/ai_video/image_edit_controller.dart';
import '../../../widgets/common/integral_vip_view.dart';
import '../../aiVideo/widgets/generate_mode_dialog.dart';
import '../../aiVideo/widgets/video_ratio_dialog.dart';
import '../../integral/integral_vip_controller.dart';
import '../beans/anime_bean.dart';
import '../controllers/anime_controller.dart';

class AnimeDetailSettingPage extends StatefulWidget {
  const AnimeDetailSettingPage({super.key, required this.bean});

  final AnimeBean bean;

  @override
  State<AnimeDetailSettingPage> createState() => _AnimeDetailSettingPageState();
}

class _AnimeDetailSettingPageState extends State<AnimeDetailSettingPage> {
  ///视频比例（仅文生视频）
  String videoRatio = ImageAspectRatio.ratio3_4.label;

  ///分辨率
  int resolution = 0;

  ///画面风格
  int selected = 0;

  final IntegralVipController interController = IntegralVipController.getOrPut();

  final AnimeController controller = Get.find<AnimeController>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      interController.updateRequiredPoints(points: controller.consumeIntergral(resolution, widget.bean));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 449.w + ByScreenUtils.bottomSafeHeight,
      padding: EdgeInsets.fromLTRB(12.w, 0 ,12.w, 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 44.w,
            child: Stack(
              children: [
                Center(
                  child: ByWidgetsUtil.commonText(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    text: '风格设置'),
                ),
                // const Spacer(),
                Positioned(
                  top: 3.5.w,
                  right: 4.w,
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      width: 50,
                      height: 44.w,
                      alignment: Alignment.centerRight,
                      child: Image.asset(
                        "assets/home/icon_close_dark.png",
                        width: 15.w,
                        height: 15.w,),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Image.asset(
                "assets/v2/anime/anime_view_style.png",
                width: 16,
                height: 16,
              ),
              const SizedBox(
                width: 4,
              ),
              ByWidgetsUtil.commonText(
                  fontSize: 16.sp, fontWeight: FontWeight.bold, text: '画面风格'),
            ],
          ),
          SizedBox(height: 12.w,),
          SizedBox(
            height: 96.w,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.bean.styleBean!.length + 1,
                separatorBuilder: (context, index) {
                  return SizedBox(
                    width: 8.w,
                    height: 96.w,
                  );
                },
                itemBuilder: (context, index) {
                  AnimeStyleBean? style;
                  if(index > 0){
                    style  = widget.bean.styleBean![index - 1];
                  }
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selected = index;
                      });
                    },
                    child: Container(
                      width: 72.w,
                      height: 96.w,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              width: 2.0, color: selected == index ? ByColorUtil.LoginBtnBgColor : const Color(0xFFEBEEFD))),
                      child: index == 0
                          ? Center(
                            child: Image.asset(
                                  "assets/v2/anime/anime_view_none.png",
                                  width: 28,
                                  height: 28,
                                ),
                          )
                          : Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl:style!.url!),
                                ),
                              ),
                              Positioned(
                                left: 5,
                                right: 5,
                                bottom: 4,
                                child: ByWidgetsUtil.commonText(
                                  fontSize: 10.sp,
                                  textColor: ByColorUtil.WhiteColor.withOpacity(0.8),
                                  text: style.title ?? '')),
                            ],
                          ),
                    ),
                  );
                }),
          ),
          SizedBox(height: 12.w,),
          Row(
            children: [
              Image.asset(
                "assets/v2/anime/anime_video_settings.png",
                width: 16,
                height: 16,
              ),
              const SizedBox(
                width: 4,
              ),
              ByWidgetsUtil.commonText(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                text: '视频设置'),
            ],
          ),
          SizedBox(height: 12.w,),
          SizedBox(
            height: 64.w,
            child: Row(
              children: [
                _buildVideoCell(resolution == 0 ? '标准（480P）' : resolution == 1 ? '高清（720P）' : '超高清（1080P）', '分辨率', (){
                  showDialog(
                    context: Get.context!,
                    builder: (ctx) {
                      return GenerateModeDialog(
                        videoQuality: resolution,
                        showQuality: true,
                        showSuperQualityItem: true,
                      );
                    },
                  ).then((value) {
                    if (value != null && value is List && value.isNotEmpty) {
                      setState(() {
                        resolution = value[0];
                      });
                      interController.updateRequiredPoints(points: controller.consumeIntergral(resolution, widget.bean));
                    }
                  });
                }),
                const SizedBox(width: 9,),
                _buildVideoCell(videoRatio, '视频比例', (){
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return VideoRatioDialog(
                        videoRatio: videoRatio,
                      );
                    },
                  ).then((value) {
                    if (value != null && value is List && value.isNotEmpty) {
                      setState(() {
                        videoRatio = value[0];
                      });
                    }
                  });
                }),
              ],
            ),
          ),
          const Spacer(),
          ByWidgetsUtil.commonTipsBar("内容由AI生成仅供参考，禁止利用功能从事违法活动。"),
          SizedBox(height: 10.w,),
          _buildIntegralVipView(),
          // Row(
          //   children: [
          //     Text(
          //         "本次消耗x积分",
          //         style: TextStyle(
          //           fontSize: 12.sp,
          //           color: const Color(0xFF0B1843).withOpacity(0.5),
          //         ),
          //     ),
          //     const Spacer(),
          //     Image.asset("assets/ai/aiVideo/coin@2x.png", scale: 2),
          //     SizedBox(width: 4.w),
          //     ByWidgetsUtil.commonRichText(
          //       texts: [
          //         const TextSpan(
          //          text: '剩余',
          //         ),
          //         TextSpan(
          //          text: " ${interController.currentUserPoints} ",
          //          style: const TextStyle(
          //           color: ByColorUtil.colorFF8902
          //          )
          //         ),
          //         const TextSpan(
          //          text: '积分',
          //         ),
          //       ],
          //       fontSize: 12.sp
          //     ),
          //   ],
          // ),
          SizedBox(
            height: 50.w,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    ///历史记录
                    controller.gotoRecord();
                  },
                  child: Container(
                    width: 91.w,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFEAEEFF),
                    ),
                    child: Center(
                      child: ByWidgetsUtil.commonText(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        textColor: const Color(0xFF5B4BF7),
                        text: '历史记录'),
                    ),
                  ),
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: ByWidgetsUtil.commonBtn(
                      fontSize: 16.sp,
                      title: '立即生成',
                      onClick: () {
                        // 检查是否是vip以及使用次数
                        if (controller.canCreate()) {
                          if (!interController.canContinueUse()) {
                            ///显示积分不够弹窗
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AnimeNoIntergralDialog(
                                    action: () {
                                      interController.showIntegralPayDialog();
                                    },
                                  );
                                });
                          }
                          else {
                            controller.createAnime(
                              widget.bean.id!,
                              selected == 0
                                  ? ''
                                  : widget.bean.styleBean![selected - 1].id!,
                              videoRatio.replaceAll('/', ':'),
                              resolution == 0
                                  ? '480P'
                                  : resolution == 1
                                      ? '720P'
                                      : '1080P');
                          }
                        }
                      }),
                )
              ],
            ),
          ),
          SizedBox(height: ByScreenUtils.bottomSafeHeight)
        ],
      ),
    );
  }
  
  // 积分-vip-次数-消耗模块-老照片高清修复
  Widget _buildIntegralVipView() {
    return IntegralVipView(
      requiredPoints: controller.consumeIntergral(resolution, widget.bean),
      type: '',
    );
  }

  ///视频设置
  Widget _buildVideoCell(String title, String desc, Function() onPress) {
    return Expanded(
        child: GestureDetector(
          onTap: onPress,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 10.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(width: 1.0, color: const Color(0xFFEBEEFD))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ByWidgetsUtil.commonText(
                  text: title,
                  fontWeight: FontWeight.bold,),
                SizedBox(height: 4.w,),
                Row(
                  children: [
                    ByWidgetsUtil.commonText(
                      text: desc,
                      textColor: ByColorUtil.CommonTextColor.withOpacity(0.8),
                      fontSize: 12.sp,
                    ),
                    const SizedBox(width: 16,),
                    Image.asset(
                      "assets/ai/ai_cartoon_item_more.png",
                      width: 12,
                      height: 12,
                    ),
                  ],
                ),
              ],
            ),
        )
      )
    );
  }
}