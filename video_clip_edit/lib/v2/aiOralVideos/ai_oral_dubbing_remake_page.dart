import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_dialog_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/v2/aiOralVideos/beans/ai_oral_clone_bean.dart';
import 'package:video_clip_edit/v2/aiOralVideos/beans/ai_oral_dubbing_clone_detail_bean.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_videos_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/widgets/ai_common_input_view.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_dubbing_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/widgets/ai_oral_copy_notice_dialog.dart';
import 'package:video_clip_edit/v2/aiOralVideos/widgets/ai_oral_my_dubbing_list_view.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/widgets/ai_cartoon_prohibited_words_dailog.dart';

/// 数字人-复刻音色配音页面
class AiOralDubbingRemakePage extends StatefulWidget {
  const AiOralDubbingRemakePage({super.key});

  @override
  State<AiOralDubbingRemakePage> createState() => _AiOralDubbingRemakePageState();
}

class _AiOralDubbingRemakePageState extends State<AiOralDubbingRemakePage> {
  Timer? _timer;
  int _tid = -1;
  CancelToken _cancelToken = CancelToken();
  AiOralDubbingCloneDetailBean? detailBean;

  @override
  void initState() {
    super.initState();

    final provider = context.read<AiOralVideosProvider>();
    provider.selectedCloneId = -1;
    provider.listeningDubbingId = -1;
    provider.getUserAudioCloneList(reset: true,selectFirst: true);
  }

  @override
  void dispose() {
    EasyLoading.dismiss();
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
    _timer = Timer.periodic(
      const Duration(milliseconds: 2000),
      _checkStussatus,
    );
  }

  _checkStussatus(Timer t) {
    // EasyLoading.show();
    _resetTimer();
    try {
      final provider = context.read<AiOralVideosProvider>();
      provider.getUserDubbingAudioTTS(
        id: _tid,
        isShowLoading: false,
        cancelToken: _cancelToken,
        onSuccess: (bean) {
          EasyLoading.dismiss();
          _resetTimer();
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
        .select<AiOralVideosProvider, List<AiOralCloneBean>>(
          (value) => value.cloneBeans,
        )
        .isNotEmpty;
    return PopScope(
      canPop: true,
      // onPopInvoked: (value) async {
      //   if (value) return;
      //
      //   EasyLoading.dismiss();
      //   _cancelToken.cancel();
      //
      //   _cancelToken = CancelToken();
      //
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
        appBar: ByWidgetsUtil.appBar(context: context, title: "复刻音色配音"),
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
                        text: "我的声音",
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      const Spacer(),
                      ByWidgetsUtil.btnWithIcon(
                        padding: EdgeInsets.zero,
                        height: 20.h,
                        bgColor: ByColorUtil.WhiteColor,
                        title: "复刻声音",
                        fontSize: 14.sp,
                        iconH: 14,
                        iconW: 14,
                        contentGap: 3,
                        fontWeight: FontWeight.w600,
                        textColor: ByColorUtil.TabTextColorSelected,
                        iconPath: "assets/ai/oralVideos/ai_oral_icon_add.png",
                        onClick: () async {

                          await ByAudioPlayer.sharedInstance.stop();
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
                              child:  AiOralCopyNoticeDialog(provider: context.read<AiOralVideosProvider>(),),
                            ),
                          );

                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Expanded(
                    child: hasDubbings
                        ? const AiOralMyDubbingListView()
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
                      bgColor: hasDubbings
                          ? const Color(0XFF5B4BF7)
                          : const Color(0XFFB5B9C6),
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
                          final List<AiOralCloneBean> cloneBeans =
                              provider.cloneBeans;
                          final selectedCloneId = provider.selectedCloneId;
                          if (cloneBeans.isEmpty || selectedCloneId == -1) {
                            BotToast.showText(text: "请选择声音");
                            return;
                          }
                          final cloneBean = cloneBeans
                              .firstWhere((e) => e.id == selectedCloneId);

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
                                  if (value != null ) {
                                    if(value["desc"]!=null){
                                      ///同步修改后的值到输入框
                                      // Get.log("修改后value===> ${value["desc"]}");
                                      context.read<AiOralDubbingProvider>().updateInputValue(value["desc"]) ;
                                    }
                                  }
                                });
                              } else {
                                // 没有违禁词，直接创建音频
                                provider.createUserAudioTTS(
                                  ttsType: 2,
                                  userAudioCloneId: cloneBean.id,
                                  refContent: desc,
                                  referenceAudioUrl: cloneBean.audioUrl,
                                  content: cloneBean.refContent,
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
                                      audioUrl: cloneBean.audioUrl,
                                      deleteTime: 0,
                                      type: 0,
                                      status: 0,
                                      createAt: '${DateTime.now().toString().substring(0,19)}',
                                      updateAt: '',
                                      title: formattedDateTime,
                                    ));
                                    Get.log("合成音频后的id===> $_tid");
                                    BotToast.showText(text: "合成音频成功~");
                                    Get.back();

                                    // EasyLoading.show(status: "音频合成中，请耐心等待...");
                                    // provider.getUserDubbingAudioTTS(
                                    //   id: _tid,
                                    //   isShowLoading: false,
                                    //   cancelToken: _cancelToken,
                                    //   onSuccess: (AiOralDubbingCloneDetailBean bean) {
                                    //     EasyLoading.dismiss();
                                    //     detailBean = bean;
                                    //     provider
                                    //         .updateDubbingCloneDetailBean(bean);
                                    //     ByNavRouterUtils.goBack(context);
                                    //     _resetTimer();
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
    return ByWidgetsUtil.commonListNoDataView(
      prompts: "暂无内容",
      bottomWidget: Padding(
        padding: EdgeInsets.only(top: 22.h),
        child: Center(
          child: SizedBox(
            child: _buildCreateBtn(),
          ),
        ),
      ),
    );
  }

  ///立即创作按钮
  Widget _buildCreateBtn() {
    return GestureDetector(
      onTap: () {
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
            child:  AiOralCopyNoticeDialog(provider: context.read<AiOralVideosProvider>(),),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0XFFEAEEFF),
          borderRadius: BorderRadius.circular(10.w),
        ),
        padding: EdgeInsets.only(
            left: 22.5.w, right: 22.5.w, top: 11.w, bottom: 11.w),
        child: Text(
          "立即创作",
          style: TextStyle(
              color: const Color(0XFF5B4BF7),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
