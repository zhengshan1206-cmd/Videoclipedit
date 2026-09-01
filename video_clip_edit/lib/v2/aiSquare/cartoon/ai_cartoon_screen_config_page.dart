import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/core/util/manager/auth.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_dialog_util.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_image_preview_page.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_ffmpeg_util.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/words/beans/upload_info_bean.dart';
import 'package:video_clip_edit/modules/home/providers/words_extract_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_image_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_select_image_page.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_video_management_page.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_video_record_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_select_image_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/widgets/ai_cartoon_video_regenerate_dialog.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_video_management_provider.dart';

class AiCartoonScreenConfigPage extends StatefulWidget {
  const AiCartoonScreenConfigPage({
    super.key,
    this.isRecovery,
    this.bean,
  });

  /// 是否是从继续成片恢复
  final bool? isRecovery;
  final AiCartoonVideoRecordBean? bean;

  @override
  State<AiCartoonScreenConfigPage> createState() =>
      _AiCartoonScreenConfigPageState();
}

class _AiCartoonScreenConfigPageState extends State<AiCartoonScreenConfigPage> {
  CancelToken cancelToken = CancelToken();

  final CancelToken _cancelToken = CancelToken();
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    final provider = context.read<AiCartoonProvider>();
    if (widget.isRecovery == true) {
      provider.pid = widget.bean!.id.toString();
    }

    _startCheckingStatus();
  }

  Future<void> _checkStatus() async {
    try {
      final provider = context.read<AiCartoonProvider>();

      /// 获取分段图片数据
      provider.loadImageList(
        cancelToken: cancelToken,
        onSuccess: (List<AiCartoonImageBean> beans) {
          _stopCheckingStatus();
        },
        onFaild: (token) {
          cancelToken = token;
          _startTimer();
        },
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        // BotToast.showText(text: '查询已取消');
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 2), _checkStatus);
  }

  void _startCheckingStatus() {
    _checkStatus();
  }

  void _stopCheckingStatus() {
    _timer?.cancel();
    _cancelToken.cancel('取消查询');
    cancelToken.cancel('取消查询');
  }

  @override
  void dispose() {
    // 页面销毁时，停止查询
    _stopCheckingStatus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const tips =
        "1、若出现“图片违规”任务将转为手动模式，请在“草稿箱”中处理后生成视频。\n2、图片根据分段生成，可使用“手动换行”调整文章分段。\n3、修改图片时上传的素材请和所选智能视频尺寸相同。";
    List<AiCartoonImageBean> imageBeans =
        context.select<AiCartoonProvider, List<AiCartoonImageBean>>(
      (value) => value.imageBeans,
    );
    List<String> paragraphs = context.select<AiCartoonProvider, List<String>>(
      (value) => value.paragraphs,
    );
    final imagesGenerating =
        context.select<AiCartoonProvider, bool>((p) => p.imagesGenerating);

    return PopScope(
      canPop: false,
      onPopInvoked: (value) async {
        if (value) return;
        final navigator = Navigator.of(context);
        ByDialogUtil.showPopScopeDialog(
          context: context,
          contents: "图片正在生成中，离开后已经生成的图片将不受影响，是否要离开？",
          confirmBtnTitle: "确定",
          confirmCallback: () {
            navigator.popUntil((route) => route.isFirst);
          },
          cancelCallback: () {},
        );
      },
      child: Scaffold(
        backgroundColor: ByColorUtil.CommonPageBgColor,
        appBar: ByWidgetsUtil.appBar(
          context: context,
          title: "画面配置",
          popScop: true,
          contents: "图片正在生成中，离开后已经生成的图片将不受影响，是否要离开？",
          popScopConfirmBtnTitle: "确定",
          popScopeExt: false,
          onPop: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        body:Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Column(
                children: [
                  // SizedBox(height: 8.h),
                  // Padding(
                  //   padding: EdgeInsets.only(top: 8.h, bottom: 5.5.h),
                  //   child: ByWidgetsUtil.commonTipsBar2(
                  //     title: "温馨提示",
                  //     tips: tips,
                  //   ),
                  // ),
                  // SizedBox(height: 5.5.h),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(bottom: 66.h),
                      itemCount: imagesGenerating
                          ? paragraphs.length + 1
                          : imageBeans.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: EdgeInsets.only(top: 8.h, bottom: 5.5.h),
                            child: ByWidgetsUtil.commonTipsBar2(
                              title: "温馨提示",
                              tips: tips,
                            ),
                          );
                        }
                        return AiCartoonScreenConfigCell(index: index - 1);
                      },
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 66.h,
              child: PhysicalModel(
                color: ByColorUtil.BlackColor,
                child: Container(
                  color: Colors.white,
                  padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  child: ByWidgetsUtil.commonBtn(
                    title: "下一步",
                    borderRadius: 12.w,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    onClick: () {
                      if (imagesGenerating) {
                        BotToast.showText(text: "图片正在生成中，请等待图片生成完成");
                        return;
                      }
                      final provider = context.read<AiCartoonProvider>();
                      provider.videoSubmit(
                        onSuccess: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext ctx) => MultiProvider(
                                providers: [
                                  ChangeNotifierProvider(
                                      create: (context) =>
                                          AiCartoonVideoManagementProvider()),
                                ],
                                child: AiCartoonVideoManagementPage(
                                  type: AiCartoonVideoManagementPageType.normal,
                                  source: provider.entranceSource,
                                ),
                              ),
                            ),
                                (route) => route.isFirst,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        )
      ),
    );
  }
}

class AiCartoonScreenConfigCell extends StatelessWidget {
  const AiCartoonScreenConfigCell({
    super.key,
    required this.index,
  });
  final int index;

  @override
  Widget build(BuildContext context) {
    final imagesGenerating =
        context.select<AiCartoonProvider, bool>((p) => p.imagesGenerating);

    AiCartoonScreenConfigImageStatus status =
        AiCartoonScreenConfigImageStatus.generating;
    final provider = context.read<AiCartoonProvider>();
    String content = "";
    if (imagesGenerating) {
      content = provider.paragraphs[index];
    } else {
      content = provider.imageBeans[index].text;
      status = AiCartoonScreenConfigImageStatusExt.fromRawValue(
          provider.imageBeans[index].status);
    }
    return ByWidgetsUtil.commonContainer(
      margin: EdgeInsets.symmetric(
        vertical: 2.5.h,
      ),
      border: Border.all(
        color: const Color(0xFFF3F5F9),
        width: 0.5,
      ),
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 12.h,
        bottom: 12.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ByWidgetsUtil.commonText(
            fontSize: 14.sp,
            maxLines: 100,
            text: content,
            textColor: ByColorUtil.CommonTextColor,
          ),
          SizedBox(height: 11.h),
          Container(
            color: const Color(0xFFF3F5F9),
            height: 0.5,
          ),
          SizedBox(height: 4.h),
          AiCartoonScreenConfigImageCell(
            status: status,
            index: index,
          ),
        ],
      ),
    );
  }
}

enum AiCartoonScreenConfigImageStatus {
  /// 图片状态 0 未上传  1ai生成中 2 生成完成 3ai生成超时
  unuploaded,
  generating,
  finished,
  failed,
  regenerate,
}

extension AiCartoonScreenConfigImageStatusExt
    on AiCartoonScreenConfigImageStatus {
  static AiCartoonScreenConfigImageStatus fromRawValue(int value) {
    switch (value) {
      case 0:
        return AiCartoonScreenConfigImageStatus.unuploaded;
      case 1:
        return AiCartoonScreenConfigImageStatus.generating;
      case 2:
        return AiCartoonScreenConfigImageStatus.finished;
      case 3:
        return AiCartoonScreenConfigImageStatus.failed;
      default:
        return AiCartoonScreenConfigImageStatus.regenerate;
    }
  }

  int get rawValue {
    switch (this) {
      case AiCartoonScreenConfigImageStatus.unuploaded:
        return 0;
      case AiCartoonScreenConfigImageStatus.generating:
        return 1;
      case AiCartoonScreenConfigImageStatus.finished:
        return 2;
      case AiCartoonScreenConfigImageStatus.failed:
        return 3;
      case AiCartoonScreenConfigImageStatus.regenerate:
        return 4;
      default:
        return 0;
    }
  }
}

class AiCartoonScreenConfigImageCell extends StatefulWidget {
  const AiCartoonScreenConfigImageCell({
    super.key,
    required this.status,
    required this.index,
  });

  final int index;
  final AiCartoonScreenConfigImageStatus status;

  @override
  State<AiCartoonScreenConfigImageCell> createState() =>
      _AiCartoonScreenConfigImageCellState();
}

class _AiCartoonScreenConfigImageCellState
    extends State<AiCartoonScreenConfigImageCell> {
  CancelToken cancelToken = CancelToken();

  @override
  void dispose() {
    cancelToken.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.status) {
      case AiCartoonScreenConfigImageStatus.unuploaded:
        return _buildUnuploaded(context);

      case AiCartoonScreenConfigImageStatus.generating:
        return _buildGenerating(context);

      case AiCartoonScreenConfigImageStatus.finished:
        return _buildFinished(context);

      case AiCartoonScreenConfigImageStatus.failed:
        return _buildFaild(context);

      case AiCartoonScreenConfigImageStatus.regenerate:
        return _buildRegenerate(context);
    }
  }

  Row _buildUnuploaded(BuildContext context) {
    return Row(
      children: [
        _buildItem(
          icon: "assets/ai/ai_cartoon_config_regenerate.png",
          title: '图片生成',
          onTap: () {
            final provider = context.read<AiCartoonProvider>();
            final imageBean = provider.imageBeans[widget.index];
            context.read<AiCartoonProvider>().regernateImage(
                  imgId: imageBean.id,
                  isAi: 2,
                  imgUrl: imageBean.url,
                  prompt: imageBean.text,
                  onSuccess: () {
                    cancelToken = CancelToken();
                    provider.loadImageList(
                      cancelToken: cancelToken,
                      onFaild: (token) {
                        cancelToken = token;
                      },
                    );
                  },
                );
          },
        ),
        // _buildItem(
        //   icon: "assets/ai/ai_cartoon_config_upload.png",
        //   title: '上传图片',
        //   onTap: () {
        //     _selectImage(context, true);
        //   },
        // ),
      ],
    );
  }

  Row _buildGenerating(BuildContext context) {
    return Row(
      children: [
        _buildItem(
          icon: "assets/ai/ai_cartoon_config_regenerate.png",
          title: '绘图中',
          widget: ByWidgetsUtil.activityIndicator(radius: 10.w),
          onTap: () {},
        ),
      ],
    );
  }

  _showRegenerateDialog(BuildContext context) {
    final AiCartoonImageBean bean =
        context.read<AiCartoonProvider>().imageBeans[widget.index];
    showDialog(
      context: context,
      builder: (ctx) {
        return ChangeNotifierProvider.value(
            value: context.read<AiCartoonProvider>(),
            child: AiCartoonVideoRegenerateDialog(bean: bean));
      },
    );
  }

  Row _buildRegenerate(BuildContext context) {
    return Row(
      children: [
        _buildItem(
          icon: "assets/ai/ai_cartoon_config_regenerate.png",
          title: '图片生成',
          onTap: () {
            final provider = context.read<AiCartoonProvider>();
            final imageBean = provider.imageBeans[widget.index];
            context.read<AiCartoonProvider>().regernateImage(
                  imgId: imageBean.id,
                  isAi: 2,
                  imgUrl: imageBean.url,
                  prompt: imageBean.text,
                  onSuccess: () {
                    cancelToken = CancelToken();
                    provider.loadImageList(
                      cancelToken: cancelToken,
                      onFaild: (token) {
                        cancelToken = token;
                      },
                    );
                  },
                );
          },
        ),
        // _buildItem(
        //   icon: "assets/ai/ai_cartoon_config_upload.png",
        //   title: '上传图片',
        //   onTap: () {
        //     _selectImage(context, true);
        //   },
        // ),
      ],
    );
  }

  Row _buildFaild(BuildContext context) {
    return Row(
      children: [
        _buildItem(
          icon: "assets/ai/ai_cartoon_config_faild.png",
          title: '绘图失败',
          onTap: () {},
        ),
        _buildItem(
          icon: "assets/ai/ai_cartoon_config_regenerate.png",
          title: '重绘',
          onTap: () {
            _showRegenerateDialog(context);
          },
        ),
        // _buildItem(
        //   icon: "assets/ai/ai_cartoon_config_upload.png",
        //   title: '上传图片',
        //   onTap: () {
        //     _selectImage(context, true);
        //   },
        // ),
      ],
    );
  }

  Row _buildFinished(BuildContext context) {
    return Row(
      children: [
        _buildItem(
          icon: "assets/ai/ai_cartoon_config_faild.png",
          widget: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AiCartoonImagePreviewPage(
                  tag: context
                      .read<AiCartoonProvider>()
                      .imageBeans[widget.index]
                      .id,
                  url: context
                      .read<AiCartoonProvider>()
                      .imageBeans[widget.index]
                      .url,
                ),
              );
            },
            child: CachedNetworkImage(
              imageUrl: context
                  .read<AiCartoonProvider>()
                  .imageBeans[widget.index]
                  .url,
              fit: BoxFit.cover,
            ),
          ),
          showCloseBn: true,
          title: '绘图失败',
          onTap: () {
            final provider = context.read<AiCartoonProvider>();
            final imageBeans = provider.imageBeans;
            final id = imageBeans[widget.index].id;
            provider.deleteImage(
              imgId: id,
              onSuccess: () {
                cancelToken = CancelToken();
                provider.loadImageList(
                  checkStatus: false,
                  cancelToken: cancelToken,
                  onSuccess: (List<AiCartoonImageBean> beans) {},
                  onFaild: (token) {
                    cancelToken = token;
                  },
                );
              },
            );
          },
        ),
        _buildItem(
          icon: "assets/ai/ai_cartoon_config_regenerate.png",
          title: '换一张',
          onTap: () {
            _selectImage(context, false);
          },
        ),
        _buildItem(
          icon: "assets/ai/ai_cartoon_config_regenerate.png",
          title: '重绘',
          onTap: () {
            _showRegenerateDialog(context);
          },
        ),
        // _buildItem(
        //   icon: "assets/ai/ai_cartoon_config_upload.png",
        //   title: '上传图片',
        //   onTap: () {
        //     _selectImage(context, true);
        //   },
        // ),
      ],
    );
  }

  Widget _buildItem({
    required String icon,
    required String title,
    Widget? widget,
    bool showCloseBn = false,
    required void Function() onTap,
  }) {
    if (widget != null) {
      if (showCloseBn) {
        return Stack(
          children: [
            Container(
              margin: EdgeInsets.only(top: 8.5.h, right: 10.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: Container(
                width: 70.w,
                height: 70.w,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.w),
                ),
                child: widget,
              ),
            ),
            Positioned(
              top: 0,
              right: 1.5.w,
              child: Offstage(
                offstage: !showCloseBn,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTap,
                  child: Image.asset(
                    "assets/ai/ai_cartoon_config_close.png",
                    width: 15,
                    height: 15,
                  ),
                ),
              ),
            )
          ],
        );
      }
      return Container(
        margin: EdgeInsets.only(top: 8.5.h, right: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFEAEEFF),
          borderRadius: BorderRadius.circular(8.w),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            width: 70.w,
            height: 70.w,
            child: Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Spacer(),
                  widget,
                  SizedBox(height: 5.h),
                  ByWidgetsUtil.commonText(
                    text: title,
                    fontSize: 12.sp,
                    textColor: const Color(0xFF5B4BF7),
                  ),
                  SizedBox(height: 5.h),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Container(
      margin: EdgeInsets.only(top: 8.5.h, right: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEAEEFF),
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 70.w,
          height: 70.w,
          child: Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                const Spacer(),
                Image.asset(
                  icon,
                  width: 30.w,
                  height: 30.w,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 5.h),
                ByWidgetsUtil.commonText(
                  text: title,
                  fontSize: 12.sp,
                  textColor: const Color(0xFF5B4BF7),
                ),
                SizedBox(height: 5.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectImage(BuildContext context, bool isUpload) {
    final provider = context.read<AiCartoonProvider>();
    final bean = provider.imageBeans[widget.index];
    if (isUpload) {
      _pickImageFromAlbum(context);
      return;
    }
    ByNavRouterUtils.push(
        context,
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: provider),
            ChangeNotifierProvider(
              create: (context) => AiCartoonSelectImageProvider(),
            )
          ],
          child: AiCartoonSelectImagePage(
              isUpload: isUpload,
              imageBean: bean,
              pid: provider.pid,
              onFinish: () {
                cancelToken = CancelToken();
                provider.loadImageList(
                  cancelToken: cancelToken,
                  onSuccess: (List<AiCartoonImageBean> beans) {},
                  onFaild: (token) {
                    cancelToken = token;
                  },
                );
              }),
        ));
  }

  void _pickImageFromAlbum(BuildContext context) {
    AuthManager.materialAuth(onSuccess: () {
      ByCommonUtils.pickAssetsByType(
        context,
        type: RequestType.image,
        maxCount: 1,
        onSelectedCallback: (asstes) async {
          final file = await asstes.first.file;
          if (file == null || file.existsSync() == false) {
            BotToast.showText(text: "图片上传失败，请稍后重试");
            return;
          }
          _uploadFile(file.path, context);
        },
      );
    });
  }

  void _uploadFile(
    String filePath,
    BuildContext context,
  ) {
    ByFfmpegUtil.loadUploadInfo(
      type: MediaType.picture,
      showLoading: true,
      loadingText: "获取图片上传信息",
      onSuccess: (UploadInfoBean infoBean) {
        /// 上传
        ByFfmpegUtil.uploadFile(
          infoBean: infoBean,
          filePath: filePath,
          loadingText: "图片上传中",
          dismiss: true,
          onSuccess: (resp) {
            /// 鉴黄
            final provider = context.read<AiCartoonProvider>();
            final bean = provider.imageBeans[widget.index];
            provider.contentsRisk(
              type: "2",
              url: infoBean.objectUrl,
              onSuccess: () {
                provider.regernateImage(
                  imgId: bean.id,
                  isAi: 0,
                  imgUrl: infoBean.objectUrl,
                  prompt: bean.text,
                  onSuccess: () {
                    cancelToken = CancelToken();
                    provider.loadImageList(
                      cancelToken: cancelToken,
                      onFaild: (token) {
                        cancelToken = token;
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
