import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_dialog_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/v2/aiOralVideos/beans/ai_oral_dubbing_clone_detail_bean.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_videos_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/widgets/ai_common_input_view.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_dubbing_bean.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_dubbing_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/widgets/ai_oral_anchor_dubbing_list_view.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_dubbing_anchor_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/widgets/ai_cartoon_prohibited_words_dailog.dart';

class AiOralDubbingAnchorPage extends StatefulWidget {
  const AiOralDubbingAnchorPage({super.key});

  @override
  State<AiOralDubbingAnchorPage> createState() =>
      _AiOralDubbingAnchorPageState();
}

class _AiOralDubbingAnchorPageState extends State<AiOralDubbingAnchorPage> {
  Timer? _timer;
  int _tid = -1;
  CancelToken _cancelToken = CancelToken();
  AiOralDubbingCloneDetailBean? detailBean;

  @override
  void initState() {
    super.initState();
    final provdier = context.read<AiOralDubbingAnchorProvider>();
    provdier.selectedDubbingId = -1;
    provdier.loadDubbingList(showLoading: true);
  }

  @override
  void dispose() {
    ByAudioPlayer.sharedInstance.stop();
    _resetTimer();
    _cancelToken.cancel();
    EasyLoading.dismiss();
    super.dispose();
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
    final dubbingBeans =
        context.select<AiOralDubbingAnchorProvider, List<AiCartoonDubbingBean>>(
      (value) => value.dubbingBeans,
    );
    final selectedDubbingId = context.select<AiOralDubbingAnchorProvider, int>(
      (value) => value.selectedDubbingId,
    );

    return PopScope(
      canPop: true,
      // onPopInvoked: (value)async,
      // onPopInvoked: (value) async {
      //   if (value) return;
      //
      //   EasyLoading.dismiss();
      //   _cancelToken.cancel();
      //
      //   _cancelToken = CancelToken();
      //   final navigator = Navigator.of(context);
      //   final provider = context.read<AiOralVideosProvider>();
      //   final audioCreateQuerying = provider.audioCreateQuerying;
      //
      //   if (!audioCreateQuerying) {
      //     navigator.pop();
      //     return;
      //   }
      //
      //   ByDialogUtil.showPopScopeDialog(
      //     context: context,
      //     contents: "如果当前有音频正在生成，离开后音频将会被取消，是否要离开？",
      //     confirmBtnTitle: "确定",
      //     confirmCallback: () {
      //       provider.deleteUserAudioTTS(
      //         id: _tid,
      //         onSuccess: () {
      //           provider.audioCreateQuerying = false;
      //           navigator.pop();
      //         },
      //       );
      //     },
      //     cancelCallback: () {
      //       EasyLoading.show();
      //       provider.getUserDubbingAudioTTS(
      //         id: _tid,
      //         isShowLoading: false,
      //         cancelToken: _cancelToken,
      //         onSuccess: (AiOralDubbingCloneDetailBean bean) {
      //           EasyLoading.dismiss();
      //           detailBean = bean;
      //           provider.updateDubbingCloneDetailBean(bean);
      //           ByNavRouterUtils.goBack(context);
      //           _resetTimer();
      //         },
      //         onFaild: () {
      //           if (provider.audioCreateQuerying) {
      //             _startTimer();
      //           }
      //         },
      //       );
      //     },
      //   );
      // },
      child: Scaffold(
        appBar: ByWidgetsUtil.appBar(context: context, title: "AI主播配音"),
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 12.w,
                right: 12.w,
              ),
              child: Column(
                children: [
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 180.h,
                    width: double.infinity,
                    child: const AiCommonInputView<AiOralDubbingProvider>(
                      maxWords: 500,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      ByWidgetsUtil.svgAsset(
                        filePath:
                            "assets/ai/oralVideos/ai_oral_icon_dubbing.svg",
                        width: 16,
                        height: 16,
                      ),
                      SizedBox(width: 5.w),
                      ByWidgetsUtil.commonText(
                        text: "AI配音主播",
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Expanded(
                    child: hasDubbings
                        ? const AiOralAnchorDubbingListView()
                        : _buildEmptyView(context),
                  )
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: PhysicalModel(
                color: Colors.black,
                child: ByWidgetsUtil.commonContainer(
                  borerRadius: 0,
                  padding: EdgeInsets.only(
                    top: 8.h,
                    left: 12.w,
                    right: 12.w,
                    bottom: 8.h + ByScreenUtils.bottomSafeHeight,
                  ),
                  child: SizedBox(
                    height: 50.h,
                    child: ByWidgetsUtil.commonBtn(
                      title: "合成音频",
                      bgColor: ByColorUtil.TabTextColorSelected.withOpacity(
                          hasDubbings ? 1 : 0.3),
                      fontSize: 16.sp,
                      borderRadius: 12.w,
                      onClick: () {
                        ByAudioPlayer.sharedInstance.stop();
                        Future.delayed(const Duration(milliseconds: 200), () {
                          final desc =
                              context.read<AiOralDubbingProvider>().inputValue;
                          if (desc.isEmpty) {
                            BotToast.showText(text: "请输入文案");
                            return;
                          }
                          final provider = context.read<AiOralVideosProvider>();

                          if (dubbingBeans.isEmpty || selectedDubbingId == -1) {
                            BotToast.showText(text: "请选择声音");
                            return;
                          }

                          final cloneBean = dubbingBeans
                              .firstWhere((e) => e.id == selectedDubbingId);

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
                                  builder: (ctx) =>
                                      ChangeNotifierProvider.value(
                                    value: cartoonProvider,
                                    child: const AiCartoonProhibitedWordsDailog<
                                        AiCartoonProvider>(),
                                  ),
                                ).then((value) {
                                  // if (value != null && value is String) {
                                  //   // 同步修改后的值到输入框
                                  //   context
                                  //       .read<AiOralDubbingProvider>()
                                  //       .inputValue = value;
                                  // }
                                  Get.log("修改后value===> ${value}");

                                  if (value != null) {
                                    if (value["desc"] != null) {
                                      ///同步修改后的值到输入框
                                      // Get.log("修改后value===> ${value["desc"]}");
                                      context
                                          .read<AiOralDubbingProvider>()
                                          .updateInputValue(value["desc"]);
                                    }
                                  }
                                });
                              } else {
                                /// 没有违禁词，直接创建音频
                                provider.createUserAudioTTS(
                                  ttsType: 1,
                                  ttsParamId: cloneBean.id,
                                  refContent: desc,
                                  referenceAudioUrl: cloneBean.demoUrl,
                                  onSuccess: (tid) {
                                    // 获取当前日期时间
                                    DateTime now = DateTime.now();
                                    // 定义日期时间格式
                                    String pattern = 'yyyyMMddHHmmss';
                                    // 创建 DateFormat 对象
                                    DateFormat dateFormat = DateFormat(pattern);
                                    // 格式化日期时间为数字字符串
                                    String formattedDateTime = dateFormat.format(now);

                                    _tid = tid;
                                    provider.ttsId = _tid;
                                    provider.updateDubbingCloneDetailBean(AiOralDubbingCloneDetailBean(
                                      id: _tid,
                                      date: '',
                                      userId: 0,
                                      ttsType: 0,
                                      ttsParamId: 0,
                                      userAudioCloneId: 0,
                                      platform: '',
                                      taskId: '',
                                      refAudioUrl: '',
                                      refContent: '',
                                      content: '',
                                      costIntegral: 0,
                                      integral: 0,
                                      audioUrl: cloneBean.demoUrl,
                                      deleteTime: 0,
                                      type: 0,
                                      status: 0,
                                      createAt: '${DateTime.now().toString().substring(0,19)}',
                                      updateAt: '',
                                      title: formattedDateTime,
                                    ));
                                    BotToast.showText(text: "合成音频成功~");
                                    Get.back();
                                    // provider.getUserDubbingAudioTTS(
                                    //   id: _tid,
                                    //   isShowLoading: false,
                                    //   cancelToken: _cancelToken,
                                    //   onSuccess:
                                    //       (AiOralDubbingCloneDetailBean bean) {
                                    //     _resetTimer();
                                    //     EasyLoading.dismiss();
                                    //     detailBean = bean;
                                    //     provider
                                    //         .updateDubbingCloneDetailBean(bean);
                                    //     ByNavRouterUtils.goBack(context);
                                    //   },
                                    //   onFaild: () {
                                    //     if (provider.audioCreateQuerying) {
                                    //       _startTimer();
                                    //     }
                                    //   },
                                    // );
                                  },
                                );
                              }
                            },
                          );
                        });
                      },
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return ByWidgetsUtil.commonListNoDataView(prompts: "暂无内容");
  }
}
