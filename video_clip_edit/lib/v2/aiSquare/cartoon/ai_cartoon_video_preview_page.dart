// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_clip_edit/modules/main/controllers/main_controller.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_color_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_permission_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_video_management_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/widgets/ai_videos_downoad_dialog.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_video_record_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/widgets/ai_cartoon_copy_text_dialog.dart';
import 'package:video_clip_edit/modules/profile/widgets/mine_videos_management_gride_view.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/widgets/video_player_widget.dart';

import '../../../modules/common/widget/common_dialog.dart';
import '../../../modules/guid/widgets/guide_pop_page.dart';
import '../../../modules/profile/providers/mine_videos_single_page_provider.dart';
import '../../aiVideo/provider/ai_video_management_provider.dart';
import '../../hotReplica/providers/replica_video_management_provider.dart';
import '../mixin/ai_settings_mixin.dart';
import 'beans/kuaishou_douyin_model.dart';

class AiCartoonVideoPreviewPage extends StatefulWidget {
  final AiCartoonVideoRecordBean videoBean;
  final bool backToHme;
  final bool showCopyBtn;
  final MineVideoType type;
  MineVideosSinglePageProvider? provider;
  ReplicaVideoManagementProvider? provider2;
  AiCartoonVideoManagementProvider? provider3;
  int? videoQueryType;
  EntranceSource? source;

  AiCartoonVideoPreviewPage({
    super.key,
    this.backToHme = false,
    required this.videoBean,
    this.showCopyBtn = true,
    this.type = MineVideoType.aiClip,
    this.provider,
    this.provider2,
    this.provider3,
    this.videoQueryType,
    this.source,
  });

  @override
  State<AiCartoonVideoPreviewPage> createState() =>
      _AiCartoonVideoPreviewPageState();
}

class _AiCartoonVideoPreviewPageState extends State<AiCartoonVideoPreviewPage>
    with RouteAware {
  _AiCartoonVideoPreviewPageState();
  final GlobalKey<VideoPlayerWidgetState> _playerKey =
      GlobalKey<VideoPlayerWidgetState>();

  bool deleteSuccess = false;

  ///快手 抖音数据 临时加在页面 后续优化
  KShouDYinModel? kShouDYinModel;

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  void dispose() {
    _stopPlayer();
    super.dispose();
  }

  ///删除视频点击事件
  void deleteVideo() {
    // widget.provider3?.loadDouYinOrKShou();
    // Get.log("当前数据===> ${widget.videoBean.toJson()}");
    // return;
    // return;
    if (deleteSuccess) {
      return;
    }
    _stopPlayer();
    showDialog(
      context: context,
      builder: (ctx) {
        return CommonDialog(
          reverse: false,
          maxLine: 10,
          contents: "请确认是否删除，删除后将不可回恢复，请谨慎操作",
          confirmBtnTitle: "删除",
          confirmCallback: () {},
        );
      },
    ).then((value) {
      // log("同意删除==== provider=${widget.provider}  provider2=${widget.provider2}  provider3=${widget.provider3} source==> ${widget.source}");
      // return;
      if (value == true) {
        MineVideosSinglePageProvider? provider = widget.provider;
        ReplicaVideoManagementProvider? provider2 = widget.provider2;
        AiCartoonVideoManagementProvider? provider3 = widget.provider3;
        if (provider != null) {
          EasyLoading.show(
              status: "删除中",
              maskType: EasyLoadingMaskType.black,
              dismissOnTap: false);
          provider.deleteVideos([widget.videoBean.id], type: widget.type,
              onSuccess: () {
            provider.updateSelectAllStatus(false);
            provider.loadVideoList(type: widget.type, isRefresh: true);
            EasyLoading.dismiss();
            setState(() {
              deleteSuccess = true;
            });
            Navigator.pop(context);
          });
        }

        if (provider2 != null) {
          EasyLoading.show(
              status: "删除中",
              maskType: EasyLoadingMaskType.black,
              dismissOnTap: false);
          provider2.deleteVideos([widget.videoBean.id], onSuccess: () {
            provider2.updateSelectAllStatus(false);
            provider2.loadVideoList(isRefresh: true);
            EasyLoading.dismiss();
            setState(() {
              deleteSuccess = true;
            });
            Navigator.pop(context);
          });
        }

        if (provider3 != null) {
          EasyLoading.show(
              status: "删除中",
              maskType: EasyLoadingMaskType.black,
              dismissOnTap: false);
          provider3.deleteVideos([widget.videoBean.id], onSuccess: () {
            provider3.resetPages();
            provider3.updateSelectAllStatus(false);
            if (widget.source != null) {
              provider3.loadVideoList(
                  videoQueryType: widget.videoQueryType,
                  source: widget.source!);
            } else {
              provider3.loadVideoList(videoQueryType: widget.videoQueryType);
            }

            EasyLoading.dismiss();
            setState(() {
              deleteSuccess = true;
            });
            Navigator.pop(context);
          });
        }
      }
    });
  }

  ///快手推广教程 常见问题view
  Widget helpView() {
    int materialPlatformId = widget.videoBean.materialPlatformId;
    String text = "";
    if (materialPlatformId == 0) {
      return const SizedBox();
    } else if (materialPlatformId == 1) {
      text = "推小果";
    } else if (materialPlatformId == 2) {
      text = "抖音";
    } else if (materialPlatformId == 3) {
      text = "快手";
    }
    return Row(
      children: [
        SizedBox(
          width: 12.w,
        ),
        Image.asset(
          "assets/replica/video_course_icon.png",
          width: 26.w,
          height: 18.w,
        ),
        SizedBox(
          width: 4.w,
        ),
        Text(
          // "$text授权推广教程",
          "授权推广教程",
          style: TextStyle(
              fontSize: 18.sp,
              color: const Color(0xFF5A4BF7),
              fontWeight: FontWeight.w600),
        )
      ],
    );
  }

  Widget helpItemView({
    required String iconPath,
    required String text,
    required VoidCallback onTapEvent,
  }) {
    return GestureDetector(
      onTap: () {
        onTapEvent();
        log("===点击事件===");
      },
      child: Container(
        padding:
            EdgeInsets.only(left: 12.w, right: 12.w, top: 13.w, bottom: 13.w),
        decoration: BoxDecoration(
          color: const Color(0XFFF1F4FD),
          borderRadius: BorderRadius.circular(10.w),
        ),
        alignment: Alignment.center,
        child: Row(
          children: [
            Image.asset(
              iconPath,
              width: 18.w,
              height: 18.w,
            ),
            SizedBox(
              width: 10.w,
            ),
            Text(
              text,
              style: TextStyle(
                  color: const Color(0XFF5A4BF7),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }

  ///初始化抖音快手数据
  initData() {
    if (widget.provider3 != null) {
      widget.provider3!.loadDouYinOrKShou(
          onSuccess: () {
            kShouDYinModel = widget.provider3!.kShouDYinModel;
            setState(() {});
          },
          platform: widget.videoBean.materialPlatformId);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isNewData = false;
    int materialPlatformId = widget.videoBean.materialPlatformId;
    String text = "";

    if (materialPlatformId == 2 || materialPlatformId == 3) {
      isNewData = true;
    }
    if (materialPlatformId == 0) {
      text = "";
    } else if (materialPlatformId == 1) {
      text = "推小果";
    } else if (materialPlatformId == 2) {
      text = "抖音";
    } else if (materialPlatformId == 3) {
      text = "快手";
    }
    return Scaffold(
        appBar: ByWidgetsUtil.appBar(
          context: context,
          title: "视频详情",
          onPop: () {
            if (widget.backToHme) {
              Get.find<MainController>().backToMain();
            } else {
              ByNavRouterUtils.goBack(context);
            }
          },
          actions: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    deleteVideo();
                  },
                  child: Text(
                    "删除",
                    style: TextStyle(
                        color: const Color(0XFF0B1843),
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp),
                  ),
                ),
                SizedBox(
                  width: 12.w,
                )
              ],
            )
          ],
        ),
        backgroundColor: ByColorUtil.CommonPageBgColor,
        body: isNewData
            ? newBodyView(text: text, materialPlatformId: materialPlatformId)
            : Stack(
                // clipBehavior: Clip.none,
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.h, horizontal: 12.w),
                        child: ByWidgetsUtil.commonTipsBar(
                            "内容由AI生成仅供参考，禁止利用功能从事违法活动。"),
                      ),
                      // helpView(),
                      Expanded(
                        child: Center(
                          child: VideoPlayerWidget(
                            key: _playerKey,
                            url: widget.videoBean.videoUrl,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      _bottomSettingWidget()
                    ],
                  ),
                  Positioned(
                    right: 12.w,
                    bottom: 120.h,
                    width: 44.w,
                    height: 44.w,
                    child: GestureDetector(
                      onTap: () async {
                        await Share.shareUri(
                            Uri.parse(widget.videoBean.videoUrl));
                      },
                      child: ByWidgetsUtil.commonContainer(
                        alignment: Alignment.center,
                        borerRadius: 44,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5B4BF7).withOpacity(0.1),
                            blurRadius: 20.w,
                          )
                        ],
                        child: Image.asset(
                          "assets/ai/clip/ai_clip_video_share.png",
                          width: 24.w,
                          height: 24.w,
                        ),
                      ),
                    ),
                  ),
                ],
              ));
  }

  Widget _bottomSettingWidget() {
    return ByWidgetsUtil.physicalModel(
      color: Colors.white,
      elevation: 0,
      child: Container(
        height: 66.h,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        margin: EdgeInsets.only(bottom: 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (widget.showCopyBtn && widget.videoBean.jumpUrl.isEmpty)
              Expanded(
                  child: ByWidgetsUtil.commonBtn(
                title: "复制文案",
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                bgColor: ByColorUtils.hexColor('#CED1D9'),
                onClick: () {
                  showDialog(
                    context: context,
                    builder: (context) => AiCartoonCopyTextDialog(
                      videoBean: widget.videoBean,
                    ),
                  );
                },
              )),
            if (widget.showCopyBtn && widget.videoBean.jumpUrl.isNotEmpty)
              Expanded(
                  child: ByWidgetsUtil.commonBtn(
                title: "发布任务",
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                bgColor: ByColorUtils.hexColor('#FF3B79'),
                onClick: () {
                  ByNavRouterUtils.jumpWebViewPage(
                      context, "", widget.videoBean.jumpUrl);
                },
              )),
            if (widget.showCopyBtn) SizedBox(width: 12.w),
            // Expanded(
            //     child: ByWidgetsUtil.commonBtn(
            //   title: "优化视频",
            //   fontSize: 16.sp,
            //   fontWeight: FontWeight.w500,
            //   bgColor: ByColorUtils.hexColor('#1CCB71'),
            //   onClick: () async {
            //     _stopPlayer();
            //     final videoUrl = widget.videoBean.videoUrl;
            //     if (await ByPermissionUtils.storage() == false) return;
            //     final String path = await showDialog(
            //       context: context,
            //       builder: (c) {
            //         return AiVideosDownoadDialog(
            //           contents: "",
            //           maxLine: 10,
            //           cancelBtnTitle: "取消",
            //           confirmBtnTitle: "确定",
            //           confirmCallback: () {},
            //           videoUrls: [videoUrl],
            //           save: false,
            //         );
            //       },
            //     );
            //     if (path.isEmpty) return;
            //     final file = File(path);
            //     if (file.existsSync() == false) {
            //       BotToast.showText(text: "视频解析失败，请稍后再试");
            //       return;
            //     }
            //     await ChannelOperate.toVideoEdit(false,
            //         videoLocalFilePathParameter: [path]).then((data) {
            //       if (data != null) {
            //         final String pathResult = data["edit_result"] ?? "";
            //         if (pathResult.isNotEmpty) {
            //           ByNavRouterUtils.push(
            //               context, VideoClipHyberPrevicew(pathResult));
            //         } else {
            //           BotToast.showText(text: "视频剪辑失败");
            //         }
            //       }
            //     });
            //   },
            // )),
            // SizedBox(width: 12.w),
            Expanded(
                child: ByWidgetsUtil.commonBtn(
              title: "下载视频",
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              onClick: () async {
                if (await ByPermissionUtils.storage() == false) return;
                final videoUrl = widget.videoBean.videoUrl;
                showDialog(
                  context: context,
                  builder: (c) {
                    return AiVideosDownoadDialog(
                      contents: "",
                      maxLine: 10,
                      cancelBtnTitle: "取消",
                      confirmBtnTitle: "确定",
                      confirmCallback: () {},
                      videoUrls: [videoUrl],
                    );
                  },
                );
              },
            ))
          ],
        ),
      ),
    );
  }

  void _stopPlayer() {
    _playerKey.currentState?.stopPlay();
  }

  ///快手 抖音
  Widget newBodyView({
    required String text,
    required int materialPlatformId,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
          child: ByWidgetsUtil.commonTipsBar("内容由AI生成仅供参考，禁止利用功能从事违法活动。"),
        ),
        helpView(),
        Expanded(
            child: ListView(
          padding: EdgeInsets.only(left: 12.w, right: 12.w),
          children: [
            Container(
              padding: EdgeInsets.only(top: 12.w, bottom: 12.w),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(12.w)),
              height: 1.2.sw,
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.w),
                child: VideoPlayerWidget(
                  key: _playerKey,
                  url: widget.videoBean.videoUrl,
                  // aspectRatio: (0.1.sw)/(0.1.sw*(16/9)),
                ),
              ),
            ),

            ///快手 抖音一键授权推广
            GestureDetector(
              onTap: () async {
                // 上报点击埋点（只有短剧模块才上报）
                if (widget.source == EntranceSource.shortPlay) {
                  ByNavigatorUtil.reportDataPoint(
                    pageTag: "myworks_detail_short_drama_video_btn",
                    operateType: "click",
                    funcDetailTag: widget.videoBean.id.toString(),
                    funcDetailImg: widget.videoBean.imgUrl,
                  );
                }
                showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (c) {
                    return ReplicaDialog(
                      contents: "",
                      title2: "发布前需要先下载视频到您的手机，同时为保障您的收益，有效规避作品违规风险，请您务必观看并学习",
                      title3: "【$text推广教程】",
                      maxLine: 10,
                      title: "发布作品",
                      // cancelBtnTitle: "取消",
                      confirmBtnTitle: "确定",
                      confirmCallback: () {},
                      videoUrls: [],
                      clickEvent: () {
                        if (kShouDYinModel != null) {
                          showGuidePopDialog(
                              context, kShouDYinModel?.itemModel?.jumpTo?[0],
                              topHintText: "$text推广教程");
                        }
                      },
                    );
                  },
                ).then((value) async {
                  if (value != null) {
                    if (value == true) {
                      Get.log("点击了确定事件===> $value");
                      if (await ByPermissionUtils.storage() == false) return;
                      final videoUrl = widget.videoBean.videoUrl;
                      showDialog(
                        context: context,
                        builder: (c) {
                          return AiVideosDownoadDialog(
                            contents: "",
                            maxLine: 10,
                            cancelBtnTitle: "取消",
                            confirmBtnTitle: "确定",
                            confirmCallback: () {},
                            videoUrls: [videoUrl],
                          );
                        },
                      ).then((value) async {
                        if (value != null) {
                          if (value == true) {
                            ///触发抖音 快手逻辑
                            if (materialPlatformId == 2) {
                              ///抖音
                              String url = widget.videoBean.promotionUrl;
                              if (await canLaunchUrl(Uri.parse(url))) {
                                launchUrl(Uri.parse(url));
                              } else {
                                showDialog(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (c) {
                                    return ReplicaDialog(
                                      contents: "",
                                      title2: "您还没有安装抖音，请先安装抖音APP。",
                                      title3: "",
                                      maxLine: 10,
                                      // title: "发布作品",
                                      // cancelBtnTitle: "取消",
                                      confirmBtnTitle: "我知道了",
                                      confirmCallback: () {},
                                      videoUrls: [],
                                    );
                                  },
                                );
                              }
                            } else if (materialPlatformId == 3) {
                              ///快手
                              String url = '${widget.videoBean.promotionUrl}';
                              // String url = "snssdk1128://";
                              if (await canLaunchUrl(Uri.parse(url))) {
                                launchUrl(Uri.parse(url));
                              } else {
                                showDialog(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (c) {
                                    return ReplicaDialog(
                                      contents: "",
                                      title2: "您还没有安装快手，请先安装快手APP。",
                                      title3: "",
                                      maxLine: 10,
                                      // title: "发布作品",
                                      // cancelBtnTitle: "取消",
                                      confirmBtnTitle: "我知道了",
                                      confirmCallback: () {},
                                      videoUrls: [],
                                    );
                                  },
                                );
                              }
                            }
                          }
                        }
                      });
                    }
                  }
                });
              },
              child: Container(
                height: 50.h,
                width: 1.sw,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image:
                            AssetImage("assets/replica/btn_background.png"))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Image.asset(
                    //   materialPlatformId == 2
                    //       ? "assets/v2/promote/dou_yin_icon.png"
                    //       : "assets/replica/video_replica_icon.png",
                    //   width: 24.w,
                    //   height: 24.w,
                    // ),
                    Text(
                      // "$text一键授权推广",
                      "一键授权推广",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10.w,
            ),
            GestureDetector(
              onTap: () async {
                // 上报点击埋点（只有短剧模块才上报）
                if (widget.source == EntranceSource.shortPlay) {
                  ByNavigatorUtil.reportDataPoint(
                    pageTag: "myworks_detail_short_drama_video_save_btn",
                    operateType: "click",
                    funcDetailTag: widget.videoBean.id.toString(),
                    funcDetailImg: widget.videoBean.imgUrl,
                  );
                }

                ///下载事件
                if (await ByPermissionUtils.storage() == false) return;
                final videoUrl = widget.videoBean.videoUrl;
                showDialog(
                  context: context,
                  builder: (c) {
                    return AiVideosDownoadDialog(
                      contents: "",
                      maxLine: 10,
                      cancelBtnTitle: "取消",
                      confirmBtnTitle: "确定",
                      confirmCallback: () {},
                      videoUrls: [videoUrl],
                    );
                  },
                );
              },
              child: Container(
                height: 50.h,
                width: 1.sw,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: const Color(0XFFEAEEFF),
                    borderRadius: BorderRadius.circular(12.w)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "保存到本地",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                        color: Color(0XFF5B4BF7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h),

            ///提示性文案
            if (kShouDYinModel != null)
              Column(
                children: [
                  const SizedBox(
                    height: 12.0,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        "assets/replica/replica_answer_icon.png",
                        width: 18.w,
                        height: 18.w,
                      ),
                      SizedBox(
                        width: 6.w,
                      ),
                      Text(
                        "${kShouDYinModel?.compr?.header}",
                        style: TextStyle(
                          color: Color(0XFF0B1843),
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                  if (kShouDYinModel!.compr != null &&
                      kShouDYinModel!.compr!.questions!.isNotEmpty)
                    ...kShouDYinModel!.compr!.questions!
                        .map((e) => _itemTextView(q: e))
                ],
              ),
            if (kShouDYinModel != null)
              SizedBox(
                height: 200.w,
              )
          ],
        )),
      ],
    );
  }

  Widget _itemTextView({required Question q}) {
    return Column(
      children: [
        SizedBox(
          height: 10.w,
        ),
        Row(
          children: [
            Text(
              "${q.ask}".trim(),
              style: TextStyle(
                color: Color(0XFF0B1843),
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5.w,
        ),
        Text(
          "${q.answer}".trim(),
          style: TextStyle(
            color: Color(0XFF0B1843).withOpacity(0.5),
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }
}
