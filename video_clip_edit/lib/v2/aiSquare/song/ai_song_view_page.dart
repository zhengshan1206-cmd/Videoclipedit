import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/widgets/base_web_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_color_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/song/ai_song_page.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/song/beans/lyrics_bean.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/v2/aiSquare/song/provider/ai_song_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/song/beans/ai_song_task_detail_bean.dart';

// ignore: must_be_immutable
class AiSongViewPage extends StatefulWidget {
  List<AiSongTaskDetailBean> aiSongTasksBean = [];
  int index;
  bool type;

  AiSongViewPage(this.aiSongTasksBean, this.index, this.type, {super.key});

  @override
  State<AiSongViewPage> createState() => _AiSongViewPageState();
}

class _AiSongViewPageState extends State<AiSongViewPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  // late AiSongViewProvder provider;
  late AiSongTaskDetailBean aiSongTaskDetailBean;

  // double playProcess = 0;
  // String playDuration = "";
  bool isPlay = true;
  Duration? _duration;
  Duration? _position;
  List<AiSongTaskDetailBean> finishAiSongTasksBean = [];
  late int nowIndexMusicd;

  String durationText() {
    return _duration?.toString().split('.').first ?? '';
  }

  String positionText() {
    return _position?.toString().split('.').first ?? '';
  }

  late AnimationController _animationController;
  late Animation<double> _animation;
  String lyrics = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    play(widget.aiSongTasksBean[widget.index]);
    for (int i = 0; i < widget.aiSongTasksBean.length; i++) {
      if (widget.aiSongTasksBean[i].status == 3) {
        finishAiSongTasksBean.add(widget.aiSongTasksBean[i]);

        if (widget.aiSongTasksBean[i].id ==
            widget.aiSongTasksBean[widget.index].id) {
          nowIndexMusicd = i;
        }
      }
    }
    _animationController = AnimationController(
      duration: const Duration(seconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 1,
      end: 300,
    ).animate(_animationController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // 动画完成后反转
          _animationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          // 反转回初始状态时继续播放，实现无限循环
          _animationController.forward();
        }
      });

    _animationController.forward();

    if (aiSongTaskDetailBean.lyrics.isNotEmpty) {
      final caseBeans = List<LyricsBean>.from(
          convert.jsonDecode(aiSongTaskDetailBean.lyrics).map(
                (ele) => LyricsBean.fromJson(ele),
              ));
      for (var data in caseBeans) {
        lyrics += data.text;
      }
      setState(() {});
    }
  }

  play(AiSongTaskDetailBean aiSongTaskDetailBean) {
    this.aiSongTaskDetailBean = aiSongTaskDetailBean;
    ByAudioPlayer.sharedInstance.play(aiSongTaskDetailBean.audioUrl).then((v) {
      ByAudioPlayer.sharedInstance.getDuration().then((Duration? duation) {
        if (mounted) {
          setState(() {
            _duration = duation;
          });
        }
      });
      ByAudioPlayer.sharedInstance.onPositionChanged((position) {
        if (mounted) {
          setState(() => _position = position);
        }
        // _position?.toString().split('.').first ?? '';
        // setState(() {
        //   playProcess =position!.inMilliseconds / double.parse(aiSongTaskDetailBean.duration);
        // });
      });

      ByAudioPlayer.sharedInstance.listener((s) {
        if (mounted) {
          if (s == PlayerState.playing) {
            if (mounted) {
              setState(() {
                isPlay = true;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                isPlay = false;
              });
            }
          }
        }
      });
    });
  }

  doSameCase() {
    ByNavigatorUtil.checkLogin(
        context: context,
        nextStepEvent: () {
          _isPlayOrPaue(false);
          setState(() {});
          // ByNavRouterUtils.push(
          //   context,
          //   ChangeNotifierProvider(
          //     create: (context) => AiSongProvider(),
          //     child:  AiSongPage(aiSongTaskDetailBean: aiSongTaskDetailBean,),
          //   ),
          // );

          if (widget.type) {
            ByNavRouterUtils.goBackWithParams(context, aiSongTaskDetailBean);
          } else {
            // ByNavRouterUtils.goBackWithParams(context, aiSongTaskDetailBean);
            ByNavRouterUtils.push(
              context,
              name: "/AiSongPage",
              ChangeNotifierProvider(
                create: (context) => AiSongProvider(),
                child: AiSongPage(
                  aiSongTaskDetailBean: aiSongTaskDetailBean,
                ),
              ),
            );
          }
        });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (mounted) {
      switch (state) {
        case AppLifecycleState.resumed:
          debugPrint('应用程序可见并响应用户输入。');
          // if (!ByAudioPlayer.sharedInstance.isPlaying) {
          //   // ByAudioPlayer.sharedInstance.resume();
          //   _isPlayOrPaue(true);
          //   setState(() {});
          // }
          break;
        case AppLifecycleState.inactive:
          debugPrint('应用程序处于非活动状态，并且未接收用户输入');
          _isPlayOrPaue(false);
          setState(() {});
          break;
        case AppLifecycleState.paused:
          debugPrint('用户当前看不到应用程序，没有响应');
          // ByAudioPlayer.sharedInstance.pause();
          _isPlayOrPaue(false);
          setState(() {});
          break;
        case AppLifecycleState.detached:
          debugPrint('该应用程序仍托管在颤振引擎上，但与任何主机视图分离');
          // ByAudioPlayer.sharedInstance.pause();
          _isPlayOrPaue(false);
          setState(() {});
          break;
        default:
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // aiSongTaskDetailBean = widget.aiSongTasksBean[widget.index];
    // provider = context.watch<AiSongViewProvder>();
    double position = (_position != null &&
            _duration != null &&
            _position!.inMilliseconds > 0 &&
            _position!.inMilliseconds < _duration!.inMilliseconds)
        ? _position!.inMilliseconds / _duration!.inMilliseconds
        : 0.0;
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            height: double.infinity,
            width: double.infinity,
            "assets/ai/ai_app_aisong_gequbeijin.png",
            fit: BoxFit.fill,
          ),
          Column(
            children: [
              Expanded(
                  child: ListView(
                children: [
                  Container(
                    height: 130.h,
                  ),
                  _buildSongPlayWidget(),
                ],
              )),
              Container(
                margin: const EdgeInsets.only(top: 25),
                child: Column(
                  children: [
                    SizedBox(
                      height: 23.h,
                      width: double.infinity,
                      child: Slider(
                        onChanged: (value) {
                          final duration = _duration;
                          if (duration == null) {
                            return;
                          }
                          final position = value * duration.inMilliseconds;
                          ByAudioPlayer.sharedInstance.audioPlayer
                              .seek(Duration(milliseconds: position.round()));
                        },
                        value: position,
                        activeColor: Colors.white,
                        inactiveColor: ByColorUtils.hexColor("#8986FD"),
                        thumbColor: Colors.white,
                      ),
                    ),
                    // LinearProgressIndicator(
                    //   borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    //   minHeight: 8.h,
                    //   value: position,
                    //   // 进度值，0.5表示50%
                    //   backgroundColor: ByColorUtils.hexColor("#8986FD"),
                    //   // 进度条的背景颜色
                    //   valueColor:
                    //   AlwaysStoppedAnimation<Color>(Colors.white), // 进度条的颜色
                    // ),
                    Container(
                      margin: const EdgeInsets.only(left: 25, right: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Opacity(
                            opacity: 0.5,
                            child: Text(
                              positionText(),
                              style: TextStyle(
                                  color: ByColorUtils.hexColor("#FEFEFE"),
                                  fontSize: 14.sp),
                            ),
                          ),
                          Opacity(
                            opacity: 0.5,
                            child: Text(
                              durationText(),
                              style: TextStyle(
                                  color: ByColorUtils.hexColor("#FEFEFE"),
                                  fontSize: 14.sp),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 10.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (mounted) {
                        setState(() {
                          if (nowIndexMusicd > 0) {
                            nowIndexMusicd -= 1;
                            play(finishAiSongTasksBean[nowIndexMusicd]);
                          } else {
                            BotToast.showText(text: "没有上一首了!");
                          }
                        });
                      }
                    },
                    child: Image.asset(
                      "assets/ai/ai_app_bar_zbf.png",
                      fit: BoxFit.contain,
                      width: 28.w,
                      height: 21.h,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isPlay) {
                          _isPlayOrPaue(false);
                        } else {
                          _isPlayOrPaue(true);
                        }
                      });
                    },
                    child: Image.asset(
                      isPlay
                          ? "assets/ai/ai_app_bar_zt.png"
                          : "assets/ai/ai_app_bar_bf.png",
                      fit: BoxFit.contain,
                      width: 74.w,
                      height: 74.h,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (mounted) {
                        setState(() {
                          if (nowIndexMusicd <
                              finishAiSongTasksBean.length - 1) {
                            nowIndexMusicd += 1;
                            play(finishAiSongTasksBean[nowIndexMusicd]);
                          } else {
                            BotToast.showText(text: "没有下一首了!");
                          }
                        });
                      }
                    },
                    child: Image.asset(
                      "assets/ai/ai_app_bar_ybf.png",
                      fit: BoxFit.contain,
                      width: 28.w,
                      height: 21.h,
                    ),
                  )
                ],
              ),
              Container(
                height: 10.h,
              ),
              _buildBottomWidget(),
              Container(
                height: 10.h,
              ),
            ],
          ),
          _buildAppBarWidget(),
        ],
      ),
    );
  }

  _buildSongPlayWidget() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Center(
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            height: 400.h,
                            width: 300.w,
                            child: Column(
                              children: [
                                Container(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Image.asset(
                                      width: 24.w,
                                      height: 24.h,
                                      "assets/login/login_close.png",
                                    ),
                                  ),
                                ),
                                Text(
                                  aiSongTaskDetailBean.title,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                    child: Container(
                                  margin: const EdgeInsets.only(
                                      top: 30, bottom: 10),
                                  child: SingleChildScrollView(
                                    child: Text(
                                      lyrics,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: ByColorUtils.hexColor("#0B1843"),
                                      ),
                                    ),
                                  ),
                                )),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(
                                      ClipboardData(
                                        text: lyrics,
                                      ),
                                    );
                                    BotToast.showText(text: "复制成功");
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          height: 44.h,
                                          decoration: BoxDecoration(
                                            color: ByColorUtil
                                                .TabTextColorSelected,
                                            borderRadius:
                                                BorderRadius.circular(22),
                                          ),
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                "复制歌词",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 16.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 10, top: 1),
                child: ClipOval(
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      // Opacity(
                      //     opacity: 0.4,
                      //     child: Container(
                      //         clipBehavior: Clip.hardEdge,
                      //         width: 240.w,
                      //         height: 240.h,
                      //         decoration: BoxDecoration(
                      //             borderRadius: const BorderRadius.all(
                      //                 Radius.circular(1000.0)),
                      //             color: ByColorUtils.hexColor("#BBBDFD")))),
                      Opacity(
                          opacity: 0.4,
                          child: ClipOval(
                            child: Container(
                              width: 240,
                              height: 240,
                              color: ByColorUtils.hexColor("#BBBDFD"),
                            ),
                          )),
                      RotationTransition(
                        alignment: Alignment.center,
                        turns: _animation,
                        child: ClipOval(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                "assets/ai/ai_yyxg_hjcp.png",
                                fit: BoxFit.contain,
                                width: 200,
                                height: 200,
                              ),
                              ClipOval(
                                child: CachedNetworkImage(
                                  height: 132,
                                  width: 132,
                                  fit: BoxFit.cover,
                                  imageUrl: aiSongTaskDetailBean.coverUrl,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(left: 10, right: 10, top: 15),
                child: Column(
                  children: [
                    Text(
                      aiSongTaskDetailBean.title,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold),
                    ),
                    Container(
                      height: 80,
                      margin: const EdgeInsets.only(top: 15),
                      child: SingleChildScrollView(
                        child: Text(
                          lyrics,
                          style: TextStyle(
                              color: ByColorUtils.hexColor("#FEFEFE"),
                              fontSize: 14.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  _isPlayOrPaue(bool play) {
    if (play) {
      if (mounted) {
        ByAudioPlayer.sharedInstance.resume();
        _animationController.forward();
      }
    } else {
      if (mounted) {
        ByAudioPlayer.sharedInstance.pause();
        _animationController.stop();
      }
    }
  }

  _buildBottomWidget() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 22, bottom: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              LaunchProvider provider = context.read<LaunchProvider>();
              if (provider.launchInfo?.isVip != 1) {
                provider.gotoPay(
                  context,
                  closePay: true,
                  replace: false,
                );
                return;
              }
              // Clipboard.setData(
              //   ClipboardData(
              //     text: aiSongTaskDetailBean.audioUrl,
              //   ),
              // );
              // BotToast.showText(text: "已复制下载链接");

              _isPlayOrPaue(false);
              setState(() {});
              // ByNavRouterUtils.jumpWebViewPageResult(
              //     context,
              //     aiSongTaskDetailBean.title ?? "",
              //     aiSongTaskDetailBean.audioUrl);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => BaseWebView(
                      title: aiSongTaskDetailBean.title,
                      direction: "http://www.baidu.com",
                      url: aiSongTaskDetailBean.audioUrl),
                ),
              ).then((data) {
                _isPlayOrPaue(false);
                setState(() {});
                // _isPlayOrPaue(true);
                // setState(() {});
                // _isPlayOrPaue(false);
                // setState(() {
                // });
              });

              // final navigator = Navigator.of(context);
              // final Uri uri = Uri.parse(aiSongTaskDetailBean.audioUrl);
              // await launchUrl(
              // uri,
              // mode: LaunchMode.externalApplication,
              // );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: ByColorUtils.hexColor("#EAEEFF"),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    width: 50.w,
                    height: 50.h,
                    alignment: Alignment.center,
                  ),
                ),
                Image.asset(
                  "assets/ai/ai_app_bar_xiazai.png",
                  fit: BoxFit.contain,
                  width: 24.w,
                  height: 24.h,
                )
              ],
            ),
          ),
          Container(
            width: 10,
          ),
          Expanded(
              child: GestureDetector(
            onTap: () {
              doSameCase();
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: ByColorUtils.hexColor("#EAEEFF"),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    height: 50.h,
                    alignment: Alignment.center,
                  ),
                ),
                Text(
                  "做同款",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                )
              ],
            ),
          ))
        ],
      ),
    );
  }

  Column _buildAppBarWidget() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 15, right: 10, left: 10),
          alignment: Alignment.center,
          height: ByScreenUtils.navigationBarHeight,
          child: Container(
            height: kToolbarHeight,
            child: Row(
              children: [
                GestureDetector(
                  // behavior: HitTestBehavior.opaque,
                  onTap: () {
                    ByNavRouterUtils.goBack(context);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: 0.1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: ByColorUtils.hexColor("#000000"),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          width: 30.w,
                          height: 30.h,
                          alignment: Alignment.center,
                        ),
                      ),
                      Image.asset(
                        "assets/ai/ai_app_aisong_bsjiantou.png",
                        fit: BoxFit.contain,
                        width: 16.w,
                        height: 16.h,
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    textAlign: TextAlign.center,
                    isPlay ? "正在播放" : "未播放",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 30.w,
                )
              ],
            ),
          ),
          // child: AppBar(
          //   backgroundColor: Colors.transparent,
          //   // elevation: 0,
          //   leading: GestureDetector(
          //     // behavior: HitTestBehavior.opaque,
          //     onTap: () {
          //       ByNavRouterUtils.goBack(context);
          //     },
          //     child: Stack(
          //       alignment: Alignment.center,
          //       children: [
          //         Opacity(
          //           opacity: 0.1,
          //           child: Container(
          //             decoration: BoxDecoration(
          //               color: ByColorUtils.hexColor("#000000"),
          //               borderRadius: BorderRadius.circular(6),
          //             ),
          //             width: 30.w,
          //             height: 30.h,
          //             alignment: Alignment.center,
          //           ),
          //         ),
          //         Image.asset(
          //           "assets/ai/ai_app_aisong_bsjiantou.png",
          //           fit: BoxFit.contain,
          //           width: 16.w,
          //           height: 16.h,
          //         )
          //       ],
          //     ),
          //   ),
          //   title: Text(
          //     isPlay ? "正在播放" : "未播放",
          //     style: TextStyle(
          //         color: Colors.white,
          //         fontSize: 16.sp,
          //         fontWeight: FontWeight.bold),
          //   ),
          //   centerTitle: true,
          //   // actions: [
          //   //   // GestureDetector(
          //   //   //   onTap: () {},
          //   //   //   child: Stack(
          //   //   //     alignment: Alignment.center,
          //   //   //     children: [
          //   //   //       Opacity(
          //   //   //         opacity: 0.1,
          //   //   //         child: Container(
          //   //   //           decoration: BoxDecoration(
          //   //   //             color: ByColorUtils.hexColor("#000000"),
          //   //   //             borderRadius: BorderRadius.circular(15),
          //   //   //           ),
          //   //   //           width: 65.w,
          //   //   //           height: 30.h,
          //   //   //           alignment: Alignment.center,
          //   //   //         ),
          //   //   //       ),
          //   //   //       Row(
          //   //   //         children: [
          //   //   //           Image.asset(
          //   //   //             "assets/ai/ai_app_aisong_jubao.png",
          //   //   //             fit: BoxFit.contain,
          //   //   //             width: 12.w,
          //   //   //             height: 12.h,
          //   //   //           ),
          //   //   //           Text(
          //   //   //             " 举报",
          //   //   //             style:
          //   //   //                 TextStyle(color: Colors.white, fontSize: 12.sp),
          //   //   //           )
          //   //   //         ],
          //   //   //       )
          //   //   //     ],
          //   //   //   ),
          //   //   // )
          //   // ],
          // ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ByAudioPlayer.sharedInstance.playerDispose();
    _animationController.stop();
    _animationController.dispose();
    super.dispose();
  }
}
