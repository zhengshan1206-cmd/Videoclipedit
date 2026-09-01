import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_dubbing_anchor_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_videos_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/widgets/ai_oral_anchor_dubbing_list_view.dart';
import 'package:video_clip_edit/v2/aiOralVideos/widgets/ai_oral_copy_notice_dialog.dart';
import 'package:video_clip_edit/v2/aiOralVideos/widgets/ai_oral_my_dubbing_list_view.dart';
import '../../controller/user_controller.dart';
import '../../modules/home/providers/by_audio_player.dart';
import '../../providers/launch_provider.dart';
import '../../utils/comon/by_nav_router_utils.dart';
import '../../utils/comon/by_widgets_util.dart';
import '../aiSquare/cartoon/beans/ai_cartoon_dubbing_bean.dart';
import 'beans/ai_oral_clone_bean.dart';
import 'beans/ai_oral_dubbing_clone_detail_bean.dart';

///AI数字人-音乐选择弹窗 仅只针对数字人页面
class AiOralMusicDialog extends StatefulWidget {
  ///选择的AI主播配音id
  final int selectAiMusicId;

  ///选择的我的克隆音色id
  final int selectMineAiMusicId;
  final AiOralVideosProvider aiOralVideosProvider;

  const AiOralMusicDialog({
    super.key,
    required this.selectAiMusicId,
    required this.selectMineAiMusicId,
    required this.aiOralVideosProvider,
  });

  @override
  State<AiOralMusicDialog> createState() => _AiOralMusicDialogState();
}

class _AiOralMusicDialogState extends State<AiOralMusicDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<TabModel> tabModelList = const [
    TabModel(tabName: "AI主播", index: 0),
    TabModel(tabName: "克隆音色", index: 1),
  ];
  int currentTabIndex = 0;
  Timer? _timer;
  int _tid = -1;
  CancelToken _cancelToken = CancelToken();
  AiOralDubbingCloneDetailBean? detailBean;

  List<Widget> tabBarPages = [
    MyAiMusicView(),
    MyCloneMusicView()
  ];

  @override
  void initState() {
    _tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: const Duration(milliseconds: 100),
    );
    _initData();
    super.initState();
  }

  @override
  void dispose() {
    _closeDialog();
    super.dispose();
  }

  Widget _tabItemView({
    required TabModel model,
  }) {
    bool selected = false;
    if (model.index == currentTabIndex) {
      selected = true;
    }
    return GestureDetector(
      onTap: () {
        currentTabIndex = model.index;
        _tabController.animateTo(currentTabIndex);
        ByAudioPlayer.sharedInstance.stop();
        if (mounted) {
          setState(() {});
        }
      },
      child: Container(
        width: 120.w,
        color: Colors.transparent,
        child: Column(
          children: [
            SizedBox(
              height: 16.w,
            ),
            Text(
              model.tabName,
              style: TextStyle(
                color: selected
                    ? const Color(0XFF5B4BF7)
                    : const Color(0XFF0B1843),
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
              ),
            ),
            if (selected)
              Container(
                width: 15.w,
                height: 3.w,
                color: const Color(0XFF5B4BF7),
              )
          ],
        ),
      ),
    );
  }

  ///初始化数据
  void _initData() {
    Get.log(
        "当前选中的id ${widget.selectAiMusicId}   ${widget.selectMineAiMusicId}");
    _tabController.addListener(() {
      ByAudioPlayer.sharedInstance.stop();
      if (mounted) {
        setState(() {
          currentTabIndex = _tabController.index;
        });
      }
    });
    final provider = context.read<AiOralDubbingAnchorProvider>();
    provider.selectedDubbingId = widget.selectAiMusicId;
    provider.loadDubbingList(showLoading: false, loadFirstSelected: false);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final provider = context.read<AiOralVideosProvider>();
      provider.getUserAudioCloneList(reset: true, selectFirst: false);
      provider.updateSelectedCloneId(widget.selectMineAiMusicId);
    });




    if (mounted) {
      setState(() {
        if (widget.selectAiMusicId != -1) {
          currentTabIndex = 0;
        }

        if (widget.selectMineAiMusicId != -1) {
          currentTabIndex = 1;
        }

        _tabController.animateTo(currentTabIndex);
      });
    }
  }

  void _closeDialog() {
    ByAudioPlayer.sharedInstance.stop();
    _resetTimer();
    _cancelToken.cancel();
    EasyLoading.dismiss();
    _tabController.dispose();
  }

  _resetTimer() {
    _timer?.cancel();
    _timer = null;
  }

  _startTimer() {
    _timer =
        Timer.periodic(const Duration(milliseconds: 2000), _checkStussatus);
  }

  _checkStussatus(Timer t) {
    if (!mounted) {
      return;
    }
    _resetTimer();
    try {
      final provider = context.read<AiOralVideosProvider>();
      provider.getUserDubbingAudioTTS(
        id: _tid,
        isShowLoading: false,
        cancelToken: _cancelToken,
        onSuccess: (bean) {
          _resetTimer();
          EasyLoading.dismiss();
          detailBean = bean;
          provider.updateDubbingCloneDetailBean(bean);
          ByNavRouterUtils.goBack(context);
        },
        onFaild: () {
          _startTimer();
        },
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        // BotToast.showText(text: '查询已取消');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasDubbings = context
        .select<AiOralDubbingAnchorProvider, List<AiCartoonDubbingBean>>(
          (value) => value.dubbingBeans,
        )
        .isNotEmpty;

    return SizedBox(
        height: 0.7.sh,
        child: Stack(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 60.w,
                    ),
                    _tabItemView(model: tabModelList.first),
                    const Spacer(),
                    _tabItemView(model: tabModelList.last),
                    // SizedBox(
                    //   width: 66.w,
                    // ),
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 16.w),
                        child: Icon(
                          Icons.close,
                          size: 24.w,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15.w,
                    ),
                  ],
                ),
                // Expanded(
                //   child: TabBarView(
                //     controller: _tabController,
                //     children: [
                //       hasDubbings
                //           ? Padding(
                //               padding: EdgeInsets.only(
                //                 left: 12.w,
                //                 right: 12.w,
                //                 top: 22.w,
                //               ),
                //               child: const AiOralAnchorDubbingListView(),
                //             )
                //           : ByWidgetsUtil.commonListNoDataView(prompts: "暂无内容"),
                //       _cloneMusicView(),
                //     ],
                //   ),
                // ),


                Expanded(child: TabBarView(children: tabBarPages,controller: _tabController,))
                


              ],
            ),
            Positioned(
              bottom: 0,
              child: Container(
                  padding: EdgeInsets.only(
                    bottom: 36.h,
                    left: 12.w,
                    right: 12.w,
                    top: 12.w,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.05),
                        offset: Offset(0, -4),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: InkResponse(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                    onTap: () {
                      final provider =
                          context.read<AiOralDubbingAnchorProvider>();
                      final provider2 = context.read<AiOralVideosProvider>();
                      Get.log(
                          "===currentIndex===$currentTabIndex  selectAiMusicId===${provider.selectedDubbingId}  selectMineAiMusicId===${provider2.selectedCloneId}");
                      String name = "";
                      String demoUrl = "";
                      dynamic refContent;
                      String coverUrl = "";
                      if (currentTabIndex == 0) {
                        if (provider.selectedDubbingId != -1) {
                          if (provider.dubbingBeans.isNotEmpty) {
                            for (var e in provider.dubbingBeans) {
                              if (e.id == provider.selectedDubbingId) {
                                name = e.name;
                                demoUrl = e.demoUrl;
                                coverUrl = e.headerImage;
                              }
                            }
                          }
                        }
                      } else if (currentTabIndex == 1) {
                        if (provider2.selectedCloneId != -1) {
                          if (provider2.cloneBeans.isNotEmpty) {
                            for (var e in provider2.cloneBeans) {
                              if (e.id == provider2.selectedCloneId) {
                                name = e.title;
                                demoUrl = e.audioUrl ?? "";
                                refContent = e.refContent;
                                coverUrl = e.coverUrl;
                              }
                            }
                          }
                        }
                      }

                      Get.back(result: {
                        "currentIndex": currentTabIndex,
                        "selectAiMusicId": provider.selectedDubbingId,
                        "selectMineAiMusicId": provider2.selectedCloneId,
                        "name": name,
                        "demoUrl": demoUrl,
                        "refContent": refContent,
                        "coverUrl": coverUrl,
                      });
                    },
                    child: Container(
                      width: 350.w,
                      decoration: BoxDecoration(
                        color: const Color(0XFF5B4BF7),
                        // color: Colors.red,
                        borderRadius: BorderRadius.circular(12.w),
                      ),
                      padding: EdgeInsets.only(
                        top: 17.5.w,
                        bottom: 17.5.w,
                      ),
                      margin: EdgeInsets.only(right: 12.w),
                      alignment: Alignment.center,
                      child: Text(
                        "确定",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )),
            )
          ],
        ));

    // return Stack(
    //   children: [
    //     SizedBox(
    //       height: 0.7.sh,
    //       child: Column(
    //         children: [
    //           Row(
    //             children: [
    //               SizedBox(
    //                 width: 110.w,
    //               ),
    //               _tabItemView(model: tabModelList.first),
    //               const Spacer(),
    //               _tabItemView(model: tabModelList.last),
    //               SizedBox(
    //                 width: 66.w,
    //               ),
    //               GestureDetector(
    //                 onTap: () {
    //                   Get.back();
    //                 },
    //                 child: Padding(
    //                   padding: EdgeInsets.only(top: 16.w),
    //                   child: Icon(
    //                     Icons.close,
    //                     size: 24.w,
    //                   ),
    //                 ),
    //               ),
    //               SizedBox(
    //                 width: 15.w,
    //               ),
    //             ],
    //           ),
    //
    //           // Expanded(
    //           //   child:
    //           // ),
    //
    //           // TabBarView(
    //           //   controller: _tabController,
    //           //   children: [
    //           //     // hasDubbings
    //           //     //     ? Padding(
    //           //     //   padding: EdgeInsets.only(
    //           //     //     left: 12.w,
    //           //     //     right: 12.w,
    //           //     //     top: 22.w,
    //           //     //   ),
    //           //     //   child: const AiOralAnchorDubbingListView(),
    //           //     // )
    //           //     //     : ByWidgetsUtil.commonListNoDataView(prompts: "暂无内容"),
    //           //     // _cloneMusicView(),
    //           //   ],
    //           // ),
    //         ],
    //       ),
    //     ),

    //     Positioned(
    //       bottom: 0,
    //       child: Container(
    //           padding: EdgeInsets.only(
    //             bottom: 36.h,
    //             left: 12.w,
    //             right: 12.w,
    //             top: 12.w,
    //           ),
    //           decoration: const BoxDecoration(
    //             color: Colors.white,
    //             boxShadow: [
    //               BoxShadow(
    //                 color: Color.fromRGBO(0, 0, 0, 0.05),
    //                 offset: Offset(0, -4),
    //                 blurRadius: 8,
    //                 spreadRadius: 0,
    //               ),
    //             ],
    //           ),
    //           child: InkResponse(
    //             highlightColor: Colors.transparent,
    //             splashColor: Colors.transparent,
    //             splashFactory: NoSplash.splashFactory,
    //             onTap: () {
    //               final provider = context.read<AiOralDubbingAnchorProvider>();
    //               final provider2 = context.read<AiOralVideosProvider>();
    //               Get.log("===currentIndex===$currentTabIndex  selectAiMusicId===${provider.selectedDubbingId}  selectMineAiMusicId===${provider2.selectedCloneId}");
    //               String name = "";
    //               String demoUrl = "";
    //               dynamic refContent;
    //               if(currentTabIndex==0){
    //                 if(provider.selectedDubbingId!=-1){
    //                   if (provider.dubbingBeans.isNotEmpty) {
    //                     for (var e in provider.dubbingBeans) {
    //                       if(e.id==provider.selectedDubbingId){
    //                         name = e.name;
    //                         demoUrl = e.demoUrl;
    //                       }
    //                     }
    //                   }
    //                 }
    //               }else if(currentTabIndex==1){
    //                 if(provider2.selectedCloneId!=-1){
    //                   if (provider2.cloneBeans.isNotEmpty) {
    //                     for (var e in provider2.cloneBeans) {
    //                       if(e.id==provider2.selectedCloneId){
    //                         name = e.title;
    //                         demoUrl = e.audioUrl??"";
    //                         refContent = e.refContent;
    //                       }
    //                     }
    //                   }
    //                 }
    //               }
    //
    //               Get.back(result: {
    //                 "currentIndex":currentTabIndex,
    //                 "selectAiMusicId":provider.selectedDubbingId,
    //                 "selectMineAiMusicId":provider2.selectedCloneId,
    //                 "name":name,
    //                 "demoUrl":demoUrl,
    //                 "refContent":refContent,
    //               });
    //             },
    //             child: Container(
    //               width: 350.w,
    //               decoration: BoxDecoration(
    //                 color: const Color(0XFF5B4BF7),
    //                 // color: Colors.red,
    //                 borderRadius: BorderRadius.circular(12.w),
    //               ),
    //               padding: EdgeInsets.only(
    //                 top: 17.5.w,
    //                 bottom: 17.5.w,
    //               ),
    //               margin: EdgeInsets.only(right: 12.w),
    //               alignment: Alignment.center,
    //               child: Text(
    //                 "确定",
    //                 style: TextStyle(
    //                   color: Colors.white,
    //                   fontSize: 16.sp,
    //                   fontWeight: FontWeight.w600,
    //                 ),
    //               ),
    //             ),
    //           )),
    //     )
    //   ],
    // );
  }
}

class TabModel {
  final String tabName;
  final int index;

  const TabModel({
    required this.tabName,
    required this.index,
  });
}

class MyAiMusicView extends StatefulWidget{
  const MyAiMusicView({super.key});

  @override
  State<MyAiMusicView> createState() => _MyAiMusicViewState();
}

class _MyAiMusicViewState extends State<MyAiMusicView> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    bool hasDubbings = context
        .select<AiOralDubbingAnchorProvider, List<AiCartoonDubbingBean>>(
          (value) => value.dubbingBeans,
    )
        .isNotEmpty;

    if (hasDubbings) {
      return Padding(
        padding: EdgeInsets.only(
          left: 12.w,
          right: 12.w,
          top: 22.w,
          bottom: 30.w,
        ),
        child: const AiOralAnchorDubbingListView(),
      );
    }
    return ByWidgetsUtil.commonListNoDataView(prompts: "暂无内容");
  }

  @override
  bool get wantKeepAlive => true;
}

class MyCloneMusicView extends StatefulWidget{
  const MyCloneMusicView({super.key,});

  @override
  State<MyCloneMusicView> createState() => _MyCloneMusicViewState();
}

class _MyCloneMusicViewState extends State<MyCloneMusicView> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider1 = context.read<AiOralVideosProvider>();

    bool hasDubbings = context
        .select<AiOralVideosProvider, List<AiOralCloneBean>>(
          (value) => value.cloneBeans,
    )
        .isNotEmpty;
    UserController userController = Get.find<UserController>();
    return Column(
      children: [
        GestureDetector(
            onTap: () async {
              await ByAudioPlayer.sharedInstance.stop();
              UserController userController = Get.find<UserController>();
              final provider = context.read<LaunchProvider>();
              if (userController.user.value?.isVip != 1) {
                provider.gotoPay(
                  context,
                  closePay: true,
                  replace: false,
                );
                return;
              }
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
                  value: AiOralVideosProvider(),
                  child:  AiOralCopyNoticeDialog(provider: AiOralVideosProvider(),),
                ),


                // builder: ChangeNotifierProvider(create: (BuildContext context) {  },)



              );
            },
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0XFFF9FAFF),
                    borderRadius: BorderRadius.circular(10.w),
                    border:
                    Border.all(color: const Color(0XFFEAEEFF), width: 1),
                  ),
                  height: 60.w,
                  margin: EdgeInsets.only(
                      top: 22.w, left: 12.w, right: 12.w, bottom: 5.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/ai/oralVideos/voice_icon.png",
                        width: 20.w,
                        height: 20.w,
                      ),
                      Text(
                        "克隆声音",
                        style: TextStyle(
                            color: const Color(0XFF5B4BF7),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                if (userController.user.value?.isVip != 1)
                  Positioned(
                      right: 12.w,
                      top: 22.w,
                      child: Image.asset(
                        "assets/ai/oralVideos/ai_oral_video_vip.png",
                        width: 30.w,
                        height: 18.w,
                      ))
              ],
            )),
        Expanded(
          child: hasDubbings
              ? Padding(
            padding: EdgeInsets.only(
              left: 12.w,
              right: 12.w,
              bottom: 50.w
            ),
            child: const AiOralMyDubbingListView(),
          )
              : ByWidgetsUtil.commonListNoDataView(prompts: "暂无内容"),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}