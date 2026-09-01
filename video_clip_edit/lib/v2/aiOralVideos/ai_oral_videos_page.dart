import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/guide_page.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/providers/video_extraction_provider.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/widgets/video_player_widget.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_storage_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/consts/const.dart';
import 'package:video_clip_edit/v2/aiOralVideos/ai_oral_videos_create_page.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_dubbing_anchor_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_dubbing_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_videos_provider.dart';

import '../../widgets/common/right_navigation_bar.dart';

class AiOralVideosPage extends StatefulWidget {
  const AiOralVideosPage({super.key});

  @override
  State<AiOralVideosPage> createState() => _AiOralVideosPageState();
}

class _AiOralVideosPageState extends State<AiOralVideosPage> {
  final GlobalKey<VideoPlayerWidgetState> _playerKey =
      GlobalKey<VideoPlayerWidgetState>();
  bool muted = false;

  @override
  void initState() {
    super.initState();
    muted = ByStorageUtils.getBool(Consts.kOralMuted) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                "assets/ai/oralVideos/ai_oral_videos_home_bg.png",
                fit: BoxFit.fitWidth,
              )),
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: ByScreenUtils.navigationBarHeight + 75.h),
                  Image.asset(
                    "assets/ai/oralVideos/ai_oral_videos_home_tips.png",
                    height: 25.h,
                    fit: BoxFit.fitHeight,
                  ),
                  SizedBox(height: 10.h),
                  Container(
                      height: 28.h,
                      width: 200.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.h),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF4BB1FF),
                            Color(0xFFE6F1FC),
                            Color(0xFFFBB1FF),
                          ],
                          stops: [0, 0.5, 1],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        "assets/ai/oralVideos/ai_oral_videos_home_generate.png",
                        height: 14.h,
                        fit: BoxFit.fitHeight,
                      )),
                  SizedBox(height: 20.h),
                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(0.w),
                          child: SizedBox(
                            height: 360.h,
                            child: VideoPlayerWidget(
                              mute: muted,
                              key: _playerKey,
                              url:
                                  "https://gamecdn.beiyinapp.com/2024-12-31/sys/495746b411f047f8750b30f6a521d1e2.mp4",
                              coverUrl:
                                  "https://gamecdn.beiyinapp.com/2025-01-02/sys/73614bd97dde6e922291483807dad524.jpg",
                              autoPlay: true,
                              userInteractive: false,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 24.w,
                        top: 14.w,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              muted = !muted;
                              _playerKey.currentState?.changeMuteStatus(muted);
                              ByStorageUtils.saveBool(Consts.kOralMuted, muted);
                            });
                          },
                          child: ClipOval(
                            child: Container(
                              width: 32.w,
                              height: 32.w,
                              alignment: Alignment.center,
                              color: const Color(0xFF000000).withOpacity(0.8),
                              child: ByWidgetsUtil.svgAsset(
                                filePath:
                                    "assets/ai/oralVideos/${muted ? "oral_muted" : "oral_unmute"}.svg",
                                width: 18.w,
                                height: 18.w,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 78.h),
                  SizedBox(
                    height: 60,
                    width: 240.w,
                    child: ByWidgetsUtil.gradientBtn(
                      title: "立即定制",
                      onClick: () {
                        _playerKey.currentState?.stopPlay();
                        // final provider = context.read<AiOralVideosProvider>();
                        ByNavRouterUtils.pushReplacement(
                          context,
                          // MultiProvider(
                          //   providers: [
                          //     ChangeNotifierProvider.value(value: provider),
                          //     ChangeNotifierProvider.value(
                          //       value:
                          //           ByAudioPlayer.sharedInstance.statusProvider,
                          //     ),
                          //   ],
                          MultiProvider(
                            providers: [
                              ChangeNotifierProvider(
                                create: (context) => AiOralVideosProvider(),
                              ),
                              ChangeNotifierProvider.value(
                                  value: ByAudioPlayer
                                      .sharedInstance.statusProvider),
                              ChangeNotifierProvider(
                                create: (context) => AiOralDubbingProvider(),
                              ),
                              ChangeNotifierProvider(
                                create: (context) => AiOralDubbingAnchorProvider(),
                              ),
                            ],
                            child: const AiOralVideosCreatePage(),
                          ),
                        ).then((_) {
                          _playerKey.currentState?.resumePlay();
                        });
                      },
                      fontSize: 18.sp,
                      borderRadius: 40,
                      fontWeight: FontWeight.bold,
                      textColor: const Color(0xFF1F2B52),
                      gradient: ByColorUtil.lineareGradientMultiple(),
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            height: ByScreenUtils.navigationBarHeight,
            child: Padding(
              padding: EdgeInsets.only(
                top: ByScreenUtils.topSafeHeight,
              ),
              child:  Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      ByNavRouterUtils.goBack(context);
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      child: Image.asset(
                        "assets/home/icon_back.png",
                        width: 16,
                        height: 16,
                      ),
                    ),
                  ),
                  SizedBox(width: 45.w),
                  const Spacer(),
                  Image.asset(
                    "assets/ai/oralVideos/ai_oral_videos_home_app_bar.png",
                    width: 100,
                    fit: BoxFit.fitWidth,
                  ),
                  const Spacer(),
                  const Center(
                    child: SizedBox(),
                  ),
                ],
              ),
              // child: ByWidgetsUtil.gradientBgContainer(
              //   child: Row(
              //     children: [
              //       GestureDetector(
              //         behavior: HitTestBehavior.opaque,
              //         onTap: () async {
              //           ByNavRouterUtils.goBack(context);
              //         },
              //         child: Container(
              //           width: 30,
              //           height: 30,
              //           alignment: Alignment.center,
              //           child: Image.asset(
              //             "assets/home/icon_back.png",
              //             width: 16,
              //             height: 16,
              //           ),
              //         ),
              //       ),
              //       SizedBox(width: 45.w),
              //       const Spacer(),
              //       Image.asset(
              //         "assets/ai/oralVideos/ai_oral_videos_home_app_bar.png",
              //         width: 100,
              //         fit: BoxFit.fitWidth,
              //       ),
              //       const Spacer(),
              //       Center(
              //         child: Container(
              //           height: 30.h,
              //           margin: EdgeInsets.only(right: 12.w),
              //           child: ByWidgetsUtil.btnWithIcon(
              //             context: context,
              //             iconH: 12.w,
              //             iconW: 12.w,
              //             fontSize: 12.sp,
              //             title: "使用攻略",
              //             borderRadius: 100.w,
              //             padding: EdgeInsets.symmetric(
              //                 vertical: 0, horizontal: 10.w),
              //             bgColor: ByColorUtil.WhiteColor,
              //             iconPath: "assets/home/icon_strategy.png",
              //             textColor: ByColorUtil.CommonTextColor,
              //             onClick: () {
              //               _playerKey.currentState?.stopPlay();
              //               ByNavRouterUtils.push(
              //                   context,
              //                   ChangeNotifierProvider(
              //                     create: (context) =>
              //                         VideoExtractionProvider(),
              //                     child: const GuidePage(),
              //                   )).then((_) {
              //                 _playerKey.currentState?.resumePlay();
              //               });
              //             },
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              //   // gradient: ByColorUtil.lineareGradient(
              //   //   colorStart: const Color(0xFF0E101F),
              //   //   colorEnd: const Color(0xFF341B26),
              //   // ),
              //   gradient: null
              // ),
            ),
            // child: ByWidgetsUtil.customAppBar(
            //   context: context,
            //   title: Image.asset(
            //     "assets/ai/oralVideos/ai_oral_videos_home_app_bar.png",
            //     width: 100,
            //     fit: BoxFit.fitWidth,
            //   ),
            //   showBottmLine: false,
            //   backgroundColor: Colors.transparent,
            //   actions: [
            //     Center(
            //       child: Container(
            //         height: 30.h,
            //         margin: EdgeInsets.only(right: 12.w),
            //         child: ByWidgetsUtil.btnWithIcon(
            //           context: context,
            //           iconH: 12.w,
            //           iconW: 12.w,
            //           fontSize: 12.sp,
            //           title: "使用攻略",
            //           borderRadius: 100.w,
            //           padding:
            //               EdgeInsets.symmetric(vertical: 0, horizontal: 10.w),
            //           bgColor: ByColorUtil.WhiteColor,
            //           iconPath: "assets/home/icon_strategy.png",
            //           textColor: ByColorUtil.CommonTextColor,
            //           onClick: () {
            //             _playerKey.currentState?.stopPlay();
            //             ByNavRouterUtils.push(
            //                 context,
            //                 ChangeNotifierProvider(
            //                   create: (context) => VideoExtractionProvider(),
            //                   child: const GuidePage(),
            //                 )).then((_) {
            //               _playerKey.currentState?.resumePlay();
            //             });
            //           },
            //         ),
            //       ),
            //     )
            //   ],
            // ),
          ),
        ],
      ),
    );
  }
}
