import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/guid/providers/guide_pop_providers.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/modules/home/widgets/banner_view.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiOralVideos/ai_oral_music_dialog.dart';
import 'package:video_clip_edit/v2/aiOralVideos/ai_oral_video_management_page.dart';
import 'package:video_clip_edit/v2/aiOralVideos/beans/ai_oral_dubbing_clone_detail_bean.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_dubbing_anchor_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_dubbing_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_video_management_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_videos_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/widgets/ai_oral_copy_notice_dialog.dart';
import 'package:video_clip_edit/v2/aiOralVideos/widgets/ai_oral_video_list_view.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_audio_status_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/song/beans/rights_by_type.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_video_player.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';
import 'package:video_clip_edit/widgets/common/right_navigation_bar.dart';
import 'package:video_clip_edit/widgets/common/integral_vip_view.dart';
import '../../controller/user_controller.dart';
import '../../utils/comon/by_common_events.dart';
import '../aiSquare/cartoon/beans/ai_cartoon_dubbing_bean.dart';
import '../aiSquare/cartoon/provider/ai_cartoon_provider.dart';
import '../aiSquare/cartoon/widgets/ai_cartoon_prohibited_words_dailog.dart';
import 'ai_oral_text_view.dart';

///数字人创作页面 后续需业务逻辑重构
class AiOralVideosCreatePage extends StatefulWidget {
  const AiOralVideosCreatePage({super.key});

  @override
  State<AiOralVideosCreatePage> createState() => _AiOralVideosCreatePageState();
}

class _AiOralVideosCreatePageState extends State<AiOralVideosCreatePage> {
  Timer? _timer;
  int _tid = -1;
  final CancelToken _cancelToken = CancelToken();
  Timer? _timerAudio;
  int _tidAudio = -1;
  final CancelToken _cancelTokenAudio = CancelToken();

  ///todo
  ///在已有逻辑基础上增加查询我的历史上传逻辑（前端这里为轮询）
  Timer? _myVideoHistorySearchTimer;
  bool needSearchHistoryData = true;

  ///默认可查询 无数据执行关闭
  final int loopTime = 2;

  ///默认5秒查询一次
  ///订阅查询上传历史
  StreamSubscription<RequestMyAIOralVideoDataEvent>?
  _myVideoHistorySubscription;

  ///选择的AI主播配音id
  int selectAiMusicId = -1;

  ///选择的我的克隆音色id
  int selectMineAiMusicId = -1;

  ///是否第一次加载
  bool isFirstLoadAiMusic = true;

  List<MusicModel> showMusicModelList = [];

  String selectMusicName = "";
  String selectDemoUrl = "";
  dynamic refContent;

  StreamSubscription<InsertCloneMusicModelEvent>? _insertStreamSubscription;

  bool isCurrentPage = true;

  final FocusNode focusNode = FocusNode();

  ScrollController scrollController = ScrollController();

  final ByAudioPlayer audioPlayer = ByAudioPlayer.sharedInstance;

  bool isPlaying = false;

  ScrollController musicScrollController = ScrollController();

  String coverUrl = "";

  @override
  void initState() {
    super.initState();
    initStreamSubscription();
    loadDubbingList();
  }

  ///初始化订阅监听
  initStreamSubscription() {
    _myVideoHistorySubscription = eventBus
        .on<RequestMyAIOralVideoDataEvent>()
        .listen((e) {
          needSearchHistoryData = e.needRequestData;
          if (needSearchHistoryData) {
            loadMyVideoList();
          }
        });

    eventBus.fire(const RequestMyAIOralVideoDataEvent(needRequestData: true));

    _insertStreamSubscription = eventBus
        .on<InsertCloneMusicModelEvent>()
        .listen((e) {
          selectAiMusicId = -1;
          selectMineAiMusicId = e.model.id;
          selectMusicName = e.model.name;
          selectDemoUrl = e.model.demoUrl;
          refContent = e.model.refContent;

          isCurrentPage = false;
          final provider = context.read<AiOralVideosProvider>();
          provider.selectedMusicModel = e.model;
          provider.insertCloneMusicModel = false;
          Get.log("事件监听到了====>${provider}");
          if (mounted) {
            setState(() {});
          }
        });

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        Get.log("===键盘被弹起了===");
        scrollController.animateTo(
          260.w,
          duration: const Duration(milliseconds: 300),
          curve: Curves.linear,
        );
        if (mounted) {
          setState(() {});
        }
      } else {
        Get.log("===键盘被收回了===");
      }

      if (ByAudioPlayer.sharedInstance.isPlaying) {
        ByAudioPlayer.sharedInstance.pause();
      }
      eventBus.fire(const PauseVideoEvent());
    });
  }

  @override
  void dispose() {
    ByAudioPlayer.sharedInstance.stop();
    byDebugPrint("-------------------AiOralVideosCreatePage:dispose");
    final provider = context.read<AiOralVideosProvider>();
    provider.selectedUserVideoId = -1;
    _timer?.cancel();
    _resetTimerAudio();
    _cancelToken.cancel();
    _cancelTokenAudio.cancel();
    _myVideoHistorySearchTimer?.cancel();
    _myVideoHistorySubscription?.cancel();
    _insertStreamSubscription?.cancel();
    scrollController.dispose();
    focusNode.dispose();
    musicScrollController.dispose();
    EasyLoading.dismiss();
    super.dispose();
  }

  _resetTimer() {
    _timer?.cancel();
    _timer = null;
  }

  _resetTimerAudio() {
    _timerAudio?.cancel();
    _timerAudio = null;
  }

  _startTimer() {
    _timer = Timer.periodic(
      const Duration(milliseconds: 2000),
      _checkStussatus,
    );
  }

  _startTimerAudio() {
    _timerAudio = Timer.periodic(
      const Duration(milliseconds: 100),
      _checkStussatusAudio,
    );
  }

  _checkStussatus(Timer t) {
    _resetTimer();
    try {
      final provider = context.read<AiOralVideosProvider>();

      provider.getDigitalHumanDetails(
        id: _tid,
        cancelToken: _cancelToken,
        onSuccess: (bean) {
          _resetTimer();

          ByNavRouterUtils.push(
            context,
            MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (context) => AiOralVideoManagementProvider(),
                ),
              ],
              child: const AiOralVideoManagementPage(),
            ),
          );
        },
        onFail: () {
          _startTimer();
        },
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        // BotToast.showText(text: '查询已取消');
      }
    }
  }

  _checkStussatusAudio(Timer t) {
    _resetTimerAudio();
    try {
      final provider = context.read<AiOralVideosProvider>();
      provider.getUserDubbingAudioTTS(
        id: _tidAudio,
        isShowLoading: false,
        cancelToken: _cancelTokenAudio,
        onSuccess: (bean) {
          EasyLoading.dismiss();
          _resetTimerAudio();
          // detailBean = bean;
          provider.updateDubbingCloneDetailBean(bean);
        },
        onFaild: () {
          _startTimerAudio();
        },
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        // BotToast.showText(text: '查询已取消');
      }
    }
  }

  void loadMyVideoList() {
    final provider = context.read<AiOralVideosProvider>();
    provider.loadMyVideoList(
      reset: true,
      cancelToken: _cancelToken,
      onSuccess: (underReview) {
        if (underReview) {
          // ignore: prefer_conditional_assignment
          if (_timer == null) {
            _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
              loadMyVideoList();
            });
          }
        } else {
          if (_timer != null) {
            _timer!.cancel();
            _timer = null;
          }
        }
      },
    );
  }

  ///加载AI角色配音列表数据
  void loadDubbingList() {
    AiOralDubbingAnchorProvider provider = context
        .read<AiOralDubbingAnchorProvider>();
    provider.loadDubbingList();
  }

  @override
  Widget build(BuildContext context) {
    byDebugPrint("-------------------AiOralVideosCreatePage:build");
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SizedBox(width: 1.sw, height: 1.sh),
          _buildPage(context),
          _buildAppBar(context),
          _buildCreateBtn(context),
        ],
      ),
    );
  }

  /// ********************************* UI *********************************

  Positioned _buildAppBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: ByScreenUtils.navigationBarHeight,
        decoration: const BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage("assets/ai/ai_app_bar_bg.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent, // AppBar 背景透明
          elevation: 0,
          leading: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
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
          title: Image.asset(
            "assets/ai/oralVideos/ai_oral_videos_home_app_bar.png",
            width: 100,
            fit: BoxFit.fitWidth,
          ),
          centerTitle: true,
          actions: const [
            Center(
              ///数字人创建 ai_oral_videos
              child: RightNavigationBar(
                entranceType: GuideEntranceType.aiOralVideos,
              ),
              // child: SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  _buildPage(BuildContext context) {
    byDebugPrint("-------_buildPage");
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),

      ///这里包裹的要使用sliver组件
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: ByScreenUtils.navigationBarHeight + 10.h),
          ),
          _buildBanner(context),
          SliverToBoxAdapter(
            child: ByWidgetsUtil.commonContainer(
              borerRadius: 12.w,
              bgColor: const Color(0xFFFFFFFF),
              // padding: const EdgeInsets.all(12),
              child: AiOralVideoListView(onUpload: loadMyVideoList),
            ),
          ),
          // SliverPadding(
          //   padding: EdgeInsets.only(top: 14.h, bottom: 6.h),
          //   sliver: SliverToBoxAdapter(
          //     child: GestureDetector(
          //       behavior: HitTestBehavior.opaque,
          //       onTap: () {},
          //       child: Row(
          //         children: [
          //           ByWidgetsUtil.commonText(
          //             text: "添加配音",
          //             fontSize: 16.sp,
          //             fontWeight: FontWeight.w600,
          //           ),
          //           const Spacer(),
          //           SizedBox(
          //             height: 28.h,
          //             child: ByWidgetsUtil.btnWithSvgIcon(
          //               title: "我的音频",
          //               borderRadius: 20,
          //               textDirection: TextDirection.rtl,
          //               fontWeight: FontWeight.normal,
          //               bgColor: ByColorUtil.WhiteColor,
          //               padding: EdgeInsets.only(left: 12.w, right: 6.w),
          //               textColor: ByColorUtil.CommonTextColor.withOpacity(0.8),
          //               iconPath:
          //                   "assets/ai/oralVideos/ai_oral_videos_my_audios_more.svg",
          //               iconW: 11,
          //               iconH: 11,
          //               contentGap: 4.w,
          //               onClick: () {
          //                 ByAudioPlayer.sharedInstance.playerDispose();
          //
          //                 final provider = context.read<AiOralVideosProvider>();
          //                 ByNavRouterUtils.push(
          //                   context,
          //                   MultiProvider(
          //                     providers: [
          //                       ChangeNotifierProvider.value(value: provider),
          //                       ChangeNotifierProvider.value(
          //                           value: ByAudioPlayer
          //                               .sharedInstance.statusProvider),
          //                     ],
          //                     child: const AiOralMyDubbingListPage(),
          //                   ),
          //                 );
          //               },
          //             ),
          //           )
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          SliverPadding(
            padding: EdgeInsets.only(top: 15.w),
            sliver: SliverToBoxAdapter(
              child: Text(
                "口播文案",
                style: TextStyle(
                  color: const Color(0XFF0B1843),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          _aiOralTextView(),
          _voiceConfigView(),
          _voiceContentView(),
          // AiOralDubbingListView(
          //   onSelect: (filePah) async {
          //     EasyLoading.show();
          //     final provider = context.read<AiOralVideosProvider>();
          //     ByFfmpegUtil.loadUploadInfo(
          //       showLoading: false,
          //       type: MediaType.audio,
          //       onSuccess: (UploadInfoBean infoBean) {
          //         /// 上传
          //         ByFfmpegUtil.uploadFile(
          //           infoBean: infoBean,
          //           filePath: filePah,
          //           showLoading: false,
          //           onSuccess: (resp) {
          //             byDebugPrint(resp);
          //             provider.createUserAudioTTS(
          //               ttsType: 3,
          //               referenceAudioUrl: infoBean.objectUrl,
          //               onSuccess: (tid) {
          //                 _tidAudio = tid;
          //
          //                 EasyLoading.show();
          //                 provider.getUserDubbingAudioTTS(
          //                   id: _tidAudio,
          //                   isShowLoading: false,
          //                   cancelToken: _cancelTokenAudio,
          //                   onSuccess: (AiOralDubbingCloneDetailBean bean) {
          //                     EasyLoading.dismiss();
          //                     _resetTimerAudio();
          //                     // detailBean = bean;
          //                     provider.updateDubbingCloneDetailBean(bean);
          //                   },
          //                   onFaild: () {
          //                     _startTimerAudio();
          //                   },
          //                 );
          //               },
          //             );
          //           },
          //         );
          //       },
          //     );
          //   },
          // ),
          // const AiOralSelectedDubbingView(),
          SliverToBoxAdapter(
            child: SizedBox(height: 120.h + ByScreenUtils.bottomSafeHeight),
          ),
        ],
      ),
    );
  }

  _buildCreateBtn(BuildContext context) {
    return const Positioned(bottom: 0, left: 0, right: 0, child: BottomBar());
  }

  _buildBanner(BuildContext context) {
    return const BannerViewWidget();
  }

  /// ********************************* UI *********************************

  ///口播文案
  Widget _aiOralTextView() {
    return SliverPadding(
      padding: EdgeInsets.only(top: 14.h, bottom: 6.h),
      sliver: SliverToBoxAdapter(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.w),
          child: SizedBox(
            height: 120.h,
            width: double.infinity,
            child: AiOralTextView<AiOralDubbingProvider>(
              maxWords: 500,
              padding: EdgeInsets.zero,
              focusNode: focusNode,
              needAiHintText: false,
            ),
          ),
        ),
      ),
    );
  }

  ///配音设置
  Widget _voiceConfigView() {
    return SliverPadding(
      padding: EdgeInsets.only(top: 15.w, bottom: 12.w),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Text(
              "配音设置",
              style: TextStyle(
                color: const Color(0XFF0B1843),
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                ///默认就关闭一次音频

                if (isPlaying) {
                  audioPlayer.pause();
                }

                final aiOralVideosProvider = context
                    .read<AiOralVideosProvider>();
                // aiOralVideosProvider.updateSelectMyCloneMusicIndex();
                Get.log(
                  "selectAiMusicId===>$selectAiMusicId  selectMineAiMusicId===>$selectMineAiMusicId",
                );

                eventBus.fire(const PauseVideoEvent());
                showModalBottomSheet(
                  useSafeArea: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18.w),
                    ),
                  ),
                  isScrollControlled: true,
                  context: context,
                  builder: (context) {
                    return MultiProvider(
                      providers: [
                        ChangeNotifierProvider(
                          create: (context) => AiOralDubbingAnchorProvider(),
                        ),
                        ChangeNotifierProvider(
                          create: (context) => AiOralDubbingProvider(),
                        ),
                        ChangeNotifierProvider(
                          create: (context) => AiOralVideosProvider(),
                        ),
                        ChangeNotifierProvider.value(
                          value: ByAudioPlayer.sharedInstance.statusProvider,
                        ),
                      ],
                      child: AiOralMusicDialog(
                        selectAiMusicId: selectAiMusicId,
                        selectMineAiMusicId: selectMineAiMusicId,
                        aiOralVideosProvider: aiOralVideosProvider,
                      ),
                    );
                  },
                ).then((value) {
                  final provider = context.read<AiOralVideosProvider>();

                  if (value != null) {
                    if (value["currentIndex"] == 0) {
                      selectAiMusicId = value["selectAiMusicId"];
                      selectMineAiMusicId = -1;
                      selectMusicName = value["name"];
                      selectDemoUrl = value["demoUrl"] ?? "";
                      refContent = value["refContent"];

                      coverUrl = value["coverUrl"] ?? "";

                      provider.selectedMusicModel = MusicModel(
                        id: selectAiMusicId,
                        name: selectMusicName,
                        type: 0,
                        demoUrl: selectDemoUrl,
                        refContent: refContent,
                        coverUrl: coverUrl,
                      );
                    }
                    if (value["currentIndex"] == 1) {
                      selectAiMusicId = -1;
                      selectMineAiMusicId = value["selectMineAiMusicId"];
                      selectMusicName = value["name"];
                      selectDemoUrl = value["demoUrl"] ?? "";
                      refContent = value["refContent"];
                      provider.selectedMusicModel = MusicModel(
                        id: selectMineAiMusicId,
                        name: selectMusicName,
                        type: 1,
                        demoUrl: selectDemoUrl,
                        refContent: refContent,
                        coverUrl: coverUrl,
                      );
                    }
                    if (mounted) {
                      setState(() {});
                    }
                    isCurrentPage = false;
                  }
                });
              },
              child: Row(
                children: [
                  Text(
                    "更多音色",
                    style: TextStyle(
                      color: const Color(0XFF0B1843).withOpacity(0.8),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: const Color(0XFF0B1843).withOpacity(0.8),
                    size: 12.w,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///配音内容的数据页面
  Widget _voiceContentView() {
    List<AiCartoonDubbingBean> showAiCartoonDubbingBeanList = [];
    List<AiCartoonDubbingBean> dubbingBeans = context
        .select<AiOralDubbingAnchorProvider, List<AiCartoonDubbingBean>>(
          (value) => value.dubbingBeans,
        );
    if (dubbingBeans.length >= 3 && isFirstLoadAiMusic) {
      showAiCartoonDubbingBeanList = dubbingBeans.sublist(0, 3);
    }

    if (isFirstLoadAiMusic) {
      ///todo 是否第一次加载ai_music
      // musicScrollController.animateTo(
      //   50.w,
      //   duration: const Duration(milliseconds: 300),
      //   curve: Curves.linear,
      // );
      if (showAiCartoonDubbingBeanList.isNotEmpty) {
        selectAiMusicId = showAiCartoonDubbingBeanList[0].id;
        for (var e in showAiCartoonDubbingBeanList) {
          showMusicModelList.add(
            MusicModel(
              id: e.id,
              name: e.name,
              type: 0,
              demoUrl: e.demoUrl,
              refContent: refContent,
              coverUrl: e.headerImage,
            ),
          );
        }
        isFirstLoadAiMusic = false;
      }
    } else {
      if (!isCurrentPage) {
        List<MusicModel> newShowMusicModelList = [];

        ///如果选择了新的aiMusic
        if (selectAiMusicId != -1) {
          ///判断是否包含这个音乐
          bool containAiMusicId = false;
          if (showMusicModelList.isNotEmpty) {
            for (var e in showMusicModelList) {
              if (e.id == selectAiMusicId) {
                containAiMusicId = true;
                newShowMusicModelList.add(e);
              }
            }

            ///不包含这个音乐
            if (!containAiMusicId) {
              newShowMusicModelList.add(
                MusicModel(
                  id: selectAiMusicId,
                  name: selectMusicName,
                  type: 0,
                  demoUrl: selectDemoUrl,
                  refContent: refContent,
                  coverUrl: coverUrl,
                ),
              );
              for (var e in showMusicModelList) {
                if (e.id != selectAiMusicId) {
                  newShowMusicModelList.add(e);
                }
              }
              showMusicModelList = newShowMusicModelList;
            } else {
              for (var e in showMusicModelList) {
                if (e.id != selectAiMusicId) {
                  newShowMusicModelList.add(e);
                }
              }
              showMusicModelList = newShowMusicModelList;
            }
          }

          if (showMusicModelList.length >= 3) {
            showMusicModelList = showMusicModelList.sublist(0, 3);
          }
        }

        if (selectMineAiMusicId != -1) {
          ///判断是否包含这个音乐
          bool containMineAiMusicId = false;
          if (showMusicModelList.isNotEmpty) {
            for (var e in showMusicModelList) {
              if (e.id == selectMineAiMusicId) {
                containMineAiMusicId = true;
                newShowMusicModelList.add(e);
              }
            }

            ///不包含这个音乐
            if (!containMineAiMusicId) {
              newShowMusicModelList.add(
                MusicModel(
                  id: selectMineAiMusicId,
                  name: selectMusicName,
                  type: 1,
                  demoUrl: selectDemoUrl,
                  refContent: refContent,
                  coverUrl: coverUrl,
                ),
              );
              for (var e in showMusicModelList) {
                if (e.id != selectMineAiMusicId) {
                  newShowMusicModelList.add(e);
                }
              }
              showMusicModelList = newShowMusicModelList;
            } else {
              for (var e in showMusicModelList) {
                if (e.id != selectMineAiMusicId) {
                  newShowMusicModelList.add(e);
                }
              }
              showMusicModelList = newShowMusicModelList;
            }
          }

          if (showMusicModelList.length >= 3) {
            showMusicModelList = showMusicModelList.sublist(0, 3);
          }
        }
      }
    }

    UserController userController = Get.find<UserController>();

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 90.w,
        child: ListView(
          scrollDirection: Axis.horizontal,
          controller: musicScrollController,
          children: [
            GestureDetector(
              onTap: () async {
                ByNavigatorUtil.checkLogin(
                  context: context,
                  nextStepEvent: () {
                    // await ByAudioPlayer.sharedInstance.stop();

                    eventBus.fire(const PauseVideoEvent());
                    if (ByAudioPlayer.sharedInstance.isPlaying) {
                      ByAudioPlayer.sharedInstance.pause();
                    }

                    LaunchProvider provider = context.read<LaunchProvider>();
                    final provider2 = context.read<AiOralVideosProvider>();

                    provider2.insertCloneMusicModel = true;
                    if (userController.user.value?.isVip != 1) {
                      // provider.gotoPay(
                      //   context,
                      //   closePay: true,
                      //   replace: false,
                      // );
                      provider.showPayHalfDialog(context, "ai_oral_videos");
                      return;
                    }
                    // Get.back();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true, // 允许高度自适应
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                      ),
                      builder: (ctx) => ChangeNotifierProvider.value(
                        value: context.read<AiOralVideosProvider>(),
                        child: AiOralCopyNoticeDialog(
                          provider: context.read<AiOralVideosProvider>(),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Stack(
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: 140.w,
                    height: 90.w,
                    decoration: BoxDecoration(
                      color: const Color(0XFFF9FAFF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.w),
                        bottomRight: Radius.circular(12.w),
                        bottomLeft: Radius.circular(12.w),
                        topRight: Radius.circular(12.w),
                      ),
                      border: Border.all(color: const Color(0XFFEAEEFF)),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 19.w),
                        Image.asset(
                          "assets/ai/oralVideos/voice_icon.png",
                          width: 32.w,
                          height: 32.w,
                        ),
                        SizedBox(height: 10.w),
                        Text(
                          "克隆声音",
                          style: TextStyle(
                            color: const Color(0XFF5B4BF7),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (userController.user.value?.isVip != 1)
                    Positioned(
                      top: -8.w,
                      right: 0,
                      child: Image.asset(
                        "assets/ai/oralVideos/ai_oral_video_vip.png",
                        width: 30.w,
                        height: 30.w,
                      ),
                    ),
                ],
              ),
            ),
            ...showMusicModelList.map(
              (e) => _voiceItemContentView(
                coverUrl: e.coverUrl,
                name: e.name,
                id: e.id,
                type: e.type,
                demoUrl: e.demoUrl,
                refContent: e.refContent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///配音设置的内容
  Widget _voiceItemContentView({
    required String name,
    required int id,
    required int type,
    required String demoUrl,
    required dynamic refContent,
    required String coverUrl,
  }) {
    final provider = context.read<AiOralVideosProvider>();
    bool selected = false;
    if (id == selectAiMusicId || id == selectMineAiMusicId) {
      selected = true;
      provider.selectedMusicModel = MusicModel(
        id: id,
        name: name,
        type: type,
        demoUrl: demoUrl,
        refContent: refContent,
        coverUrl: coverUrl,
      );
    }

    /// 播放状态
    final status = context
        .select<AiCartoonAudioStatusProvider, AiCartoonAudioStatus>(
          (val) => val.currentStatus,
        );

    isPlaying =
        status == AiCartoonAudioStatus.playing ||
        status == AiCartoonAudioStatus.resume;

    if (name.length > 6) {
      name = name.substring(0, 6);
    }

    return GestureDetector(
      onTap: () {
        if (type == 0 && id != selectAiMusicId) {
          Get.log("点击了====> $selectAiMusicId");
          isCurrentPage = true;
          if (mounted) {
            setState(() {
              selectAiMusicId = id;
              selectMineAiMusicId = -1;
            });
          }
        }

        if (type == 1 && id != selectMineAiMusicId) {
          isCurrentPage = true;
          if (mounted) {
            setState(() {
              selectMineAiMusicId = id;
              selectAiMusicId = -1;
            });
          }
        }

        ///只有被选中的才能播放和暂停
        if (selected) {
          if (isPlaying) {
            audioPlayer.pause();
          } else {
            eventBus.fire(const PauseVideoEvent());
            audioPlayer.play(demoUrl);
          }
        } else {
          eventBus.fire(const PauseVideoEvent());
          audioPlayer.play(demoUrl);
        }

        if (mounted) {
          setState(() {});
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0XFFF9FAFF),
          borderRadius: BorderRadius.circular(12.w),
          border: Border.all(
            width: 2,
            color: selected ? const Color(0XFF5B4BF7) : const Color(0XFFF9FAFF),
          ),
        ),
        width: 90.w,
        height: 90.w,
        margin: EdgeInsets.only(left: 10.w),
        padding: EdgeInsets.only(
          top: 10.w,
          left: 12.w,
          right: 12.w,
          bottom: 9.w,
        ),
        child: Column(
          children: [
            ClipOval(
              child: Stack(
                children: [
                  coverUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: coverUrl,
                          width: 50.w,
                          height: 50.w,
                        )
                      : Image.asset(
                          "assets/ai/oralVideos/ai_oral_user_head_icon.png",
                          width: 50.w,
                          height: 50.w,
                        ),
                  if (selected)
                    Positioned.fill(
                      child: Container(
                        color: const Color(0xFF000000).withOpacity(0.2),
                      ),
                    ),
                  if (selected)
                    Positioned(
                      top: 15.w,
                      left: 20.w,
                      child: ByWidgetsUtil.svgAsset(
                        filePath: isPlaying
                            ? "assets/home/voice_pause.svg"
                            : "assets/home/voice_play.svg",
                        width: 15.w,
                        height: 15.h,
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              "$name",
              style: TextStyle(
                color: const Color(0XFF5B4BF7),
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BannerViewWidget extends StatelessWidget {
  const BannerViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bannerBeans = context.select<AiOralVideosProvider, List<SubFunction>>(
      (value) => value.banners,
    );
    final showBanner = context.select<AiOralVideosProvider, bool>(
      (value) => value.showBanner,
    );
    final showBanners = bannerBeans.isNotEmpty && showBanner;
    if (showBanners) {
      return SliverPadding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        sliver: SliverToBoxAdapter(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: double.infinity,
                height: 40.h,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.w),
                  child: BannerView(
                    onError: () {
                      context.read<AiOralVideosProvider>().updateShowBanner(
                        false,
                      );
                    },
                    urls: bannerBeans.map((e) => e.imgUrl).toList(),
                    fit: BoxFit.cover,
                    onTap: (index) {
                      ByCommonUtils.subFunctionCase(
                        context,
                        bannerBeans[index],
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                right: 5.w,
                top: 5.h,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    context.read<AiOralVideosProvider>().updateShowBanner(
                      false,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: ByColorUtil.BlackColor.withOpacity(0.1),
                          blurRadius: 4.w,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      "assets/ai/ai_cartoon_config_close1.png",
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SliverToBoxAdapter(child: Container());
  }
}

class EnhancementView extends StatelessWidget {
  const EnhancementView({super.key});

  @override
  Widget build(BuildContext context) {
    final enableEnhance = context.select<AiOralVideosProvider, bool>(
      (value) => value.enableEnhance,
    );
    return SliverPadding(
      padding: EdgeInsets.only(
        // left: 12.w,
        // right: 12.w,
        top: 20.h,
      ),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            ByWidgetsUtil.commonText(
              text: "画质面部增强",
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
            const Spacer(),
            CupertinoSwitch(
              value: enableEnhance,
              activeColor: ByColorUtil.LoginBtnBgColor,
              trackColor: const Color(0xFFB5B9C6),
              thumbColor: const Color(0xFFF8F8F8),
              // activeColor: ByColorUtil.WhiteColor,
              // activeTrackColor: ByColorUtil.LoginBtnBgColor,
              // inactiveTrackColor: ByColorUtil.CommonTextColor.withOpacity(0.2),
              // inactiveThumbColor: const Color(0xFFF8F8F8),
              // trackOutlineColor:
              //     const WidgetStatePropertyAll(Colors.transparent),
              onChanged: (value) {
                context.read<AiOralVideosProvider>().changeEnableEnhance(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  void _createVideo({
    required AiOralVideosProvider provider,
    required IntegralVipController integralVipController,
    required BuildContext context,
    int taskType = 2,
    int ttsType = 2,
    String? content,
    int? ttsParamId,
    String? userAudioCloneId,
    String? referenceAudioUrl,
    String? refContent,
  }) {
    if (provider.userVideoBeans.isEmpty) {
      BotToast.showText(text: "请先上传视频");
      return;
    }
    if (provider.selectedUserVideoId == -1) {
      BotToast.showText(text: "请选择视频");
      return;
    }
    String audioUrl = "";
    bool underReview = true;
    for (var ele in provider.userVideoBeans) {
      if (ele.id == provider.selectedUserVideoId) {
        audioUrl = ele.url;
        underReview = ele.status == 1;
        break;
      }
    }
    if (underReview) {
      BotToast.showText(text: '视频正在审核中，请稍后再试');
      return;
    }
    if (audioUrl.isEmpty) {
      BotToast.showText(text: '该视频文件无法播放');
      return;
    }

    // if (provider.ttsId == null) {
    //   BotToast.showText(text: '该音频为空，请重新生成');
    //   return;
    // }

    provider.createDigitalHuman(
      refVideoUrl: audioUrl,
      refAudioUrl: "",
      userAudioTTSId: provider.ttsId,
      ttsType: ttsType,
      ttsParamId: ttsParamId,
      refContent: refContent,
      referenceAudioUrl: referenceAudioUrl,
      content: content,
      userAudioCloneId: userAudioCloneId,
      taskType: taskType,
      onSuccess: (tid) {
        integralVipController.init(requiredPoints: 0, type: "digital_human");
        ByNavRouterUtils.pushReplacement(
          context,
          MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => AiOralVideoManagementProvider(),
              ),
            ],
            child: const AiOralVideoManagementPage(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vipRights = context.select<AiOralVideosProvider, RightsByType?>(
      (value) => value.rightsByType,
    );
    final times = vipRights?.freeCount ?? 0;
    final integral = vipRights?.userIntegral ?? 0;
    final price = vipRights?.currentIntegral ?? 0;
    final purchaseProvider = context.read<PurchaseProvider>();
    return PhysicalModel(
      color: const Color(0xFF000000).withOpacity(0.5),
      elevation: 1,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          top: 12.h,
          // bottom: 8.h + ByScreenUtils.bottomSafeHeight,
          bottom: 16.h,
          left: 12.w,
          right: 12.w,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIntegralVipView(),
            Row(
              children: [
                if (chekVip(context))
                  SizedBox(
                    width: 91.w,
                    height: 50.h,
                    child: ByWidgetsUtil.commonBtn(
                      title: '创作记录',
                      onClick: () {
                        if (ByAudioPlayer.sharedInstance.isPlaying) {
                          ByAudioPlayer.sharedInstance.pause();
                        }

                        ByNavRouterUtils.push(
                          context,
                          MultiProvider(
                            providers: [
                              ChangeNotifierProvider(
                                create: (context) =>
                                    AiOralVideoManagementProvider(),
                              ),
                            ],
                            child: const AiOralVideoManagementPage(),
                          ),
                        );
                      },
                      fontSize: 16.sp,
                      borderRadius: 12.w,
                      fontWeight: FontWeight.normal,
                      bgColor: const Color(0xFFEAEEFF),
                      textColor: ByColorUtil.TabTextColorSelected,
                    ),
                  ),
                if (chekVip(context)) SizedBox(width: 9.w),
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (ByAudioPlayer.sharedInstance.isPlaying) {
                            ByAudioPlayer.sharedInstance.pause();
                          }
                          final purchaseProvider = context
                              .read<PurchaseProvider>();
                          if (purchaseProvider.preLoginCheck(context) ==
                              false) {
                            return;
                          }
                          final integralVipController =
                              IntegralVipController.getOrPut();

                          ///不是会员并且无试用-付费弹窗
                          if (!chekVip(context) &&
                              integralVipController.isTest <= 0) {
                            final provider = context.read<AiSquareProvider>();
                            String mark = 'ai_oral_videos';
                            provider.showModelPayDialog(context, mark);
                            return;
                          }
                          // 检查积分是否足够
                          if (!integralVipController.canContinueUse()) {
                            integralVipController.showIntegralPayDialog();
                            return;
                          }
                          ByAudioPlayer.sharedInstance.playerDispose();
                          final provider = context.read<AiOralVideosProvider>();

                          ///todo 先创建音频
                          ByAudioPlayer.sharedInstance.stop();
                          final desc = context
                              .read<AiOralDubbingProvider>()
                              .inputValue;
                          if (desc.isEmpty) {
                            BotToast.showText(text: "请输入文案");
                            return;
                          }
                          if (provider.selectedMusicModel.id == -1) {
                            BotToast.showText(text: "请选择声音");
                            return;
                          }
                          final cloneBean = provider.selectedMusicModel;
                          // 添加违禁词检测
                          final cartoonProvider = AiCartoonProvider();
                          cartoonProvider.desc = desc; // 设置当前内容
                          cartoonProvider.detect(
                            context,
                            desc,
                            onSuccess: () {
                              if (cartoonProvider.bandedWords.isNotEmpty) {
                                BotToast.showText(text: "当前存在违禁词");
                                showDialog(
                                  context: context,
                                  useSafeArea: false,
                                  barrierDismissible: true,
                                  builder: (ctx) => ChangeNotifierProvider.value(
                                    value: cartoonProvider,
                                    child:
                                        const AiCartoonProhibitedWordsDailog<
                                          AiCartoonProvider
                                        >(),
                                  ),
                                ).then((value) {
                                  Get.log("修改后value===> ${value}");
                                  if (value != null) {
                                    if (value["desc"] != null) {
                                      context
                                          .read<AiOralDubbingProvider>()
                                          .updateInputValue(value["desc"]);
                                    }
                                  }
                                });
                              } else {
                                /// 没有违禁词，直接创建音频
                                ///生成视频接口
                                _createVideo(
                                  provider: provider,
                                  integralVipController: integralVipController,
                                  context: context,
                                  ttsType: cloneBean.type == 0 ? 1 : 3,
                                  ttsParamId: cloneBean.id,
                                  refContent: desc,
                                  referenceAudioUrl: cloneBean.demoUrl,
                                  content: desc,
                                );
                              }
                            },
                          );
                        },
                        child: SizedBox(
                          height: 50.h,
                          child: ByWidgetsUtil.commonContainer(
                            borerRadius: 12.w,
                            alignment: Alignment.center,
                            bgColor: ByColorUtil.LoginBtnBgColor,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ByWidgetsUtil.commonText(
                                  text: "生成视频",
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  textColor: ByColorUtil.WhiteColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Offstage(
              offstage: times > 0,
              child: SizedBox(height: 7.h),
            ),
          ],
        ),
      ),
    );
  }

  // 积分-vip-次数-消耗模块-口播数字人
  Widget _buildIntegralVipView() {
    return const IntegralVipView(
      requiredPoints: 0,
      type: "digital_human", // 通过这个type请求权益接口获取实际积分
    );
  }

  bool chekVip(BuildContext context) {
    final isVip = context.read<LaunchProvider>().launchInfo?.isVip ?? 0;
    return isVip == 1;
  }
}

class AiOralSelectedDubbingView extends StatelessWidget {
  const AiOralSelectedDubbingView({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedCloneDetailBean = context
        .select<AiOralVideosProvider, AiOralDubbingCloneDetailBean?>(
          (value) => value.dubbingCloneDetailBean,
        );
    if (selectedCloneDetailBean == null) {
      return SliverToBoxAdapter(child: Container());
    }
    final currentStatus = context
        .select<AiCartoonAudioStatusProvider, AiCartoonAudioStatus>(
          (value) => value.currentStatus,
        );
    final playing = [
      AiCartoonAudioStatus.playing,
      AiCartoonAudioStatus.resume,
    ].contains(currentStatus);

    return SliverToBoxAdapter(
      child: ByWidgetsUtil.commonContainer(
        borerRadius: 12.w,
        bgColor: const Color(0xFFF4F6FA),
        padding: EdgeInsets.only(top: 15.h, bottom: 15.h, left: 15.w),
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                final audioUrl = selectedCloneDetailBean.audioUrl;

                Get.log("audioUrl===> $audioUrl");

                if (audioUrl == null) return;
                if (audioUrl.isEmpty) {
                  BotToast.showText(text: "该音频正在合成中，暂无法播放~");
                  return;
                }

                if (playing) {
                  ByAudioPlayer.sharedInstance.pause();
                } else {
                  if (currentStatus == AiCartoonAudioStatus.pause) {
                    ByAudioPlayer.sharedInstance.resume();
                  } else {
                    ByAudioPlayer.sharedInstance.play(audioUrl);
                  }
                }
              },
              child: SizedBox(
                width: 50.w,
                height: 50.w,
                child: ClipOval(
                  child: Stack(
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            width: 50.w,
                            height: 50.w,
                            child: Image.asset(
                              "assets/mine/mine_avarta.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                      Positioned.fill(
                        child: Center(
                          child: playing
                              ? ByWidgetsUtil.svgAsset(
                                  filePath: "assets/home/voice_pause.svg",
                                  width: 15.w,
                                  height: 15.h,
                                )
                              : ByWidgetsUtil.svgAsset(
                                  filePath: "assets/home/voice_play.svg",
                                  width: 15.w,
                                  height: 15.h,
                                ),
                          // Image.asset(
                          //     "assets/home/voice_pause.png",
                          //     width: 15.w,
                          //     height: 15.h,
                          //     fit: BoxFit.contain,
                          //   )
                          // : Image.asset(
                          //     "assets/home/voice_play.png",
                          //     width: 15.w,
                          //     height: 15.h,
                          //     fit: BoxFit.contain,
                          //   )
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ByWidgetsUtil.commonText(
                    text: selectedCloneDetailBean.title,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    textColor: ByColorUtil.CommonTextColor,
                  ),
                  SizedBox(height: 2.h),
                  ByWidgetsUtil.commonText(
                    text: selectedCloneDetailBean.createAt,
                    fontSize: 12.sp,
                    textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                ByAudioPlayer.sharedInstance.playerDispose();
                context
                    .read<AiOralVideosProvider>()
                    .updateDubbingCloneDetailBean(null);
              },
              child: ByWidgetsUtil.svgAsset(
                filePath: "assets/ai/ai_cartoon_input_delete.svg",
                width: 18,
                height: 18,
                fit: BoxFit.fitHeight,
              ),
              // "assets/ai/ai_cartoon_input_delete.svg",
              // height: 18,
              // child: Image.asset(
              //   "assets/ai/ai_cartoon_input_delete.svg",
              //   height: 18,
              //   fit: BoxFit.fitWidth,
              //   color: Colors.black,
              // ),
            ),
            SizedBox(width: 12.w),
          ],
        ),
      ),
    );
  }
}

class MusicModel {
  final int id;
  final String name;
  final int type;
  final String demoUrl;
  dynamic refContent;
  final String coverUrl;

  MusicModel({
    required this.id,
    required this.name,
    required this.type,
    required this.demoUrl,
    required this.refContent,
    required this.coverUrl,
  });
}
