import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/v2/aiVideo/widgets/ai_video_generation_mode_tips.dart';
import '../../../utils/http/http_utils.dart';
import '../../../widgets/common/bgm_dialog.dart';
import '../models/ai_video_square_model.dart';
import '_custom_slider_sharp.dart';

class GenerationSettingsCard extends StatefulWidget {
  const GenerationSettingsCard({
    super.key,
    required this.type,
    required this.onExpandChanged,
    this.cfgScale,
    this.mode,
    this.duration,
    this.aspectRatio,
    this.num,
    required this.bgmUrlChange,
  });

  final AiVideoGenerationType type;
  final ValueChanged<bool> onExpandChanged;
  final double? cfgScale;
  final String? aspectRatio;
  final int? duration;
  final String? mode;
  final int? num;

  final ValueChanged<String> bgmUrlChange;

  @override
  State<GenerationSettingsCard> createState() => GenerationSettingsCardState();
}

class GenerationSettingsCardState extends State<GenerationSettingsCard> {
  Map<String, dynamic>? _config;

  bool get optimizePrompt => optimizePromptNotifier.value;
  final optimizePromptNotifier = ValueNotifier(true);

  bool get optionExpanded => optionExpandedNotifier.value;
  final optionExpandedNotifier = ValueNotifier(true);

  double get cfgScale => cfgScaleNotifier.value;
  final cfgScaleNotifier = ValueNotifier(0.5);

  String get aspectRatio => aspectRatioNotifier.value;
  final aspectRatioNotifier = ValueNotifier("16:9");

  int get duration => durationNotifier.value;
  final durationNotifier = ValueNotifier(5);

  String get mode => modeNotifier.value;
  final modeNotifier = ValueNotifier("std");

  int get num => numNotifier.value;
  final numNotifier = ValueNotifier(1);

  void _loadConfig() {
    HttpUtils.post(
      "VideoAi/getBaseInfo",
      {
        "right_type": switch (widget.type) {
          AiVideoGenerationType.textToVideo => "ai_text2_video",
          AiVideoGenerationType.imageToVideo => "ai_image2_video",
          AiVideoGenerationType.embraceVideo => "ai_image2_video",
          AiVideoGenerationType.firstAndEndFrame => "ai_video_f2e",
          AiVideoGenerationType.multipleImages => "ai_video_multi",
        },
      },
      success: (data) {
        if (data["data"] is Map) {
          if (mounted) {
            setState(() {
              _config = data["data"]["config"];
              if (widget.aspectRatio == null && _config!["scale"] != null) {
                aspectRatioNotifier.value = _config!["scale"].first;
              }
              if (widget.duration == null && _config!["duration"] != null) {
                durationNotifier.value = _config!["duration"].first;
              }
              if (widget.mode == null && _config!["mode"] != null) {
                modeNotifier.value = _config!["mode"].first;
              }
              if (widget.num == null && _config!["num"] != null) {
                numNotifier.value = _config!["num"].first;
              }
            });
          }
        }
      },
      fail: (code, msg) {
        /// BotToast.showText(text: msg);
      },
    );
  }

  String? bgmUrl;
  String bgmTitle ="";
  String? id ;

  @override
  void initState() {
    super.initState();
    cfgScaleNotifier.value = widget.cfgScale ?? 0.5;
    aspectRatioNotifier.value = widget.aspectRatio ?? "16:9";
    durationNotifier.value = widget.duration ?? 5;
    modeNotifier.value = widget.mode ?? "std";
    _loadConfig();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_config == null) {
      return const SizedBox.shrink();
    }

    final items = [];

    // if (_config!['cfg_scale'] != null) {
    //   final configScale = _config!['cfg_scale'];
    //   items.add(Row(
    //     children: [
    //       Text(
    //         "创意想象力",
    //         style: TextStyle(
    //           fontSize: 14.sp,
    //           color: ByColorUtil.CommonTextColor,
    //         ),
    //       ),
    //       Expanded(
    //           child: SizedBox(
    //         height: 24,
    //         child: SliderTheme(
    //           data: SliderThemeData(
    //             thumbColor: Colors.white,
    //             activeTrackColor: const Color(0xFF5B4BF7),
    //             inactiveTrackColor: const Color(0xFFFF2BB2),
    //             trackShape: CustomSliderShape(),
    //           ),
    //           child: Slider(
    //             value: cfgScale,
    //             onChanged: (value) =>
    //                 setState(() => cfgScaleNotifier.value = value),
    //             min: configScale["min"].toDouble(),
    //             max: configScale["max"].toDouble(),
    //             thumbColor: Colors.white,
    //             activeColor: const Color(0xFF5B4BF7),
    //             inactiveColor: const Color(0xFFFF2BB2),
    //           ),
    //         ),
    //       )),
    //       Text(
    //         "创意相关性",
    //         style: TextStyle(
    //           fontSize: 14.sp,
    //           color: ByColorUtil.CommonTextColor,
    //         ),
    //       ),
    //     ],
    //   ));
    // }

    // if (_config!['mode'] != null) {
    //   final modeList = _config!['mode'] as List;
    //   items.add(Row(
    //     children: [
    //       SizedBox(
    //         width: 80.w,
    //         child: Row(
    //           children: [
    //             Flexible(
    //               child: Text(
    //                 "生成模式",
    //                 style: TextStyle(
    //                   fontSize: 14.sp,
    //                   color: ByColorUtil.CommonTextColor,
    //                 ),
    //               ),
    //             ),
    //             SizedBox(width: 4.w),
    //             GestureDetector(
    //                 onTap: () => showAiVideoGenerationModeTips(context),
    //                 child:
    //                     Image.asset("assets/ai/aiVideo/info@2x.png", scale: 2)),
    //           ],
    //         ),
    //       ),
    //       if (modeList.contains("std")) ...[
    //         GestureDetector(
    //           behavior: HitTestBehavior.opaque,
    //           onTap: () => setState(() => modeNotifier.value = "std"),
    //           child: SizedBox(
    //             width: 66.w,
    //             child: Row(
    //               children: [
    //                 mode == "std"
    //                     ? Image.asset("assets/ai/aiVideo/radio_checked@2x.png",
    //                         scale: 2)
    //                     : Image.asset("assets/ai/aiVideo/radio@2x.png",
    //                         scale: 2),
    //                 SizedBox(width: 5.w),
    //                 Text(
    //                   "标准",
    //                   style: TextStyle(
    //                     fontSize: 14.sp,
    //                     color: ByColorUtil.CommonTextColor,
    //                   ),
    //                 )
    //               ],
    //             ),
    //           ),
    //         ),
    //         SizedBox(width: 15.w)
    //       ],
    //       if (modeList.contains("pro"))
    //         GestureDetector(
    //           behavior: HitTestBehavior.opaque,
    //           onTap: () => setState(() => modeNotifier.value = "pro"),
    //           child: SizedBox(
    //             width: 66.w,
    //             child: Row(
    //               children: [
    //                 mode == "pro"
    //                     ? Image.asset("assets/ai/aiVideo/radio_checked@2x.png",
    //                         scale: 2)
    //                     : Image.asset("assets/ai/aiVideo/radio@2x.png",
    //                         scale: 2),
    //                 SizedBox(width: 5.w),
    //                 Text(
    //                   "高品质",
    //                   style: TextStyle(
    //                     fontSize: 14.sp,
    //                     color: ByColorUtil.CommonTextColor,
    //                   ),
    //                 )
    //               ],
    //             ),
    //           ),
    //         )
    //     ],
    //   ));
    // }

    // if (_config!["optimize_prompt"] == true) {
    //   items.add(Row(
    //     children: [
    //       SizedBox(
    //         width: 80.w,
    //         child: Text(
    //           "提示词优化",
    //           style: TextStyle(
    //             fontSize: 14.sp,
    //             color: ByColorUtil.CommonTextColor,
    //           ),
    //         ),
    //       ),
    //       SizedBox(
    //         height: 36,
    //         child: CupertinoSwitch(
    //           value: optimizePrompt,
    //           onChanged: (value) =>
    //               setState(() => optimizePromptNotifier.value = value),
    //           activeColor: const Color(0xFF5B4BF7),
    //           trackColor: const Color(0xFFB5B9C6),
    //           thumbColor: Colors.white,
    //         ),
    //       )
    //     ],
    //   ));
    // }

    // if (_config!['duration'] != null) {
    //   final durationList = _config!['duration'] as List;
    //   items.add(Row(
    //     children: [
    //       SizedBox(
    //         width: 80.w,
    //         child: Text(
    //           "生成时长",
    //           style: TextStyle(
    //             fontSize: 14.sp,
    //             color: ByColorUtil.CommonTextColor,
    //           ),
    //         ),
    //       ),
    //       for (var val in durationList)
    //         Padding(
    //           padding: EdgeInsets.only(right: 15.w),
    //           child: GestureDetector(
    //             behavior: HitTestBehavior.opaque,
    //             onTap: () => setState(() => durationNotifier.value = val),
    //             child: SizedBox(
    //               width: 64.w,
    //               child: Row(
    //                 children: [
    //                   duration == val
    //                       ? Image.asset(
    //                           "assets/ai/aiVideo/radio_checked@2x.png",
    //                           scale: 2)
    //                       : Image.asset("assets/ai/aiVideo/radio@2x.png",
    //                           scale: 2),
    //                   SizedBox(width: 5.w),
    //                   Text(
    //                     "${val}s",
    //                     style: TextStyle(
    //                       fontSize: 14.sp,
    //                       color: ByColorUtil.CommonTextColor,
    //                     ),
    //                   )
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ),
    //     ],
    //   ));
    // }

    if (_config!['scale'] != null) {
      final aspectRatioList = _config!['scale'] as List;
      items.add(Row(
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              "视频比例",
              style: TextStyle(
                fontSize: 14.sp,
                color: ByColorUtil.CommonTextColor,
              ),
            ),
          ),
          if (aspectRatioList.contains("16:9"))
            Padding(
              padding: EdgeInsets.only(right: 30.w),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => aspectRatioNotifier.value = "16:9"),
                child: Builder(builder: (context) {
                  final isActive = aspectRatio == "16:9";
                  return Column(
                    children: [
                      Image.asset(
                        "assets/ai/aiVideo/ratio_16v9@2x.png",
                        color: isActive
                            ? const Color(0xFF5B4BF7)
                            : ByColorUtil.CommonTextColor,
                        scale: 2,
                      ),
                      SizedBox(width: 3.5.w),
                      Text(
                        "16:9",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isActive
                              ? const Color(0xFF5B4BF7)
                              : ByColorUtil.CommonTextColor,
                        ),
                      )
                    ],
                  );
                }),
              ),
            ),
          if (aspectRatioList.contains("9:16"))
            Padding(
              padding: EdgeInsets.only(right: 30.w),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => aspectRatioNotifier.value = "9:16"),
                child: Builder(builder: (context) {
                  final isActive = aspectRatio == "9:16";
                  return Column(
                    children: [
                      Image.asset(
                        "assets/ai/aiVideo/ratio_9v16@2x.png",
                        color: isActive
                            ? const Color(0xFF5B4BF7)
                            : ByColorUtil.CommonTextColor,
                        scale: 2,
                      ),
                      SizedBox(width: 3.5.w),
                      Text(
                        "9:16",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isActive
                              ? const Color(0xFF5B4BF7)
                              : ByColorUtil.CommonTextColor,
                        ),
                      )
                    ],
                  );
                }),
              ),
            ),
          if (aspectRatioList.contains("1:1"))
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => aspectRatioNotifier.value = "1:1"),
              child: Builder(builder: (context) {
                final isActive = aspectRatio == "1:1";
                return Column(
                  children: [
                    Image.asset(
                      "assets/ai/aiVideo/ratio_1v1@2x.png",
                      color: isActive
                          ? const Color(0xFF5B4BF7)
                          : ByColorUtil.CommonTextColor,
                      scale: 2,
                    ),
                    SizedBox(width: 3.5.w),
                    Text(
                      "1:1",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isActive
                            ? const Color(0xFF5B4BF7)
                            : ByColorUtil.CommonTextColor,
                      ),
                    )
                  ],
                );
              }),
            ),
        ],
      ));
    }
    // Row(
    //     children: [
    //       SizedBox(
    //         width: 80.w,
    //         child: Text(
    //           "生成数量",
    //           style: TextStyle(
    //             fontSize: 14.sp,
    //             color: ByColorUtil.CommonTextColor,
    //           ),
    //         ),
    //       ),
    //     ],
    //   )

    // final needExpander = items.length > 3;
    // if (needExpander && !optionExpanded) {
    //   items.removeRange(3, items.length);
    // }
    items.add( InkResponse(
      onTap: (){
        log("===点击了背景音乐===");
        _showBgmDialog(context);
      },
      child:  Row(
        children: [
          Text(
            "背景音乐",
            style: TextStyle(
              fontSize: 14.sp,
              color: ByColorUtil.CommonTextColor,
            ),
          ),
          const Spacer(),
          Text(
            bgmTitle.isEmpty? "选择":bgmTitle,
            style: TextStyle(
              fontSize: 14.sp,
              color: ByColorUtil.CommonTextColor.withOpacity(0.8),
            ),
          ),
          SizedBox(width: 5.w,),
          Image.asset("assets/ai/ai_back_icon.png",width: 15.w,height: 15.w,)
        ],
      ),
    ));
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.5.w, vertical: 14.5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.w),
        border: Border.all(
          color: Colors.white,
          width: 0.5.w,
        ),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF6DBFE),
            Colors.white,
          ],
          begin: Alignment.topRight,
          end: Alignment(0.5, 0.01),
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // setState(() => optionExpandedNotifier.value = !optionExpanded);
              // widget.onExpandChanged.call(optionExpanded);
            },
            child: Row(
              children: [
                Image.asset("assets/ai/aiVideo/settings@2x.png", scale: 2),
                SizedBox(width: 3.w),
                Text(
                  "参数设置",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: ByColorUtil.CommonTextColor,
                  ),
                ),
                const Spacer(),
                // if (needExpander)
                //   optionExpanded
                //       ? Image.asset("assets/ai/aiVideo/expand_down@2x.png",
                //           scale: 2)
                //       : RotatedBox(
                //           quarterTurns: -1,
                //           child: Image.asset(
                //               "assets/ai/aiVideo/expand_down@2x.png",
                //               scale: 2)),
              ],
            ),
          ),
          SizedBox(height: 10.h,),
          for (final item in items)
            SizedBox(
              height: 49.h,
              child: item,
            ),
        ],
      ),
    );
  }

  void _showBgmDialog(BuildContext context) {
    showDialog(
      useSafeArea: false,
      context: context,
      builder: (ctx) {
        return  BgmDialog(id: id,type: 1,);
      },
    ).then((value){
      if(value!=null){
        bgmUrl = value[0];
        bgmTitle = value[1];
        id = value[2];
        widget.bgmUrlChange.call(bgmUrl!);
        setState(() {
        });
      }
      log("选中的音频数据===> $value");
    });
  }

}
