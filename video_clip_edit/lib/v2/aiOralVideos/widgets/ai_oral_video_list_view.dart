// ignore_for_file: use_build_context_synchronously

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_download_util.dart';
import 'package:video_clip_edit/utils/comon/by_ffmpeg_util.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/comon/by_permission_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/channel/channel_operate.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_package_utils.dart';
import 'package:video_clip_edit/modules/common/widget/common_dialog.dart';
import 'package:video_clip_edit/v2/aiOralVideos/ai_oral_video_record_page.dart';
import 'package:video_clip_edit/modules/home/words/beans/upload_info_bean.dart';
import 'package:video_clip_edit/modules/home/providers/words_extract_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/beans/ai_oral_my_video_bean.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_videos_provider.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/widgets/video_player_widget.dart';

import '../../../core/util/manager/auth.dart';
import '../../../modules/home/providers/by_audio_player.dart';

class AiOralVideoListView extends StatefulWidget {
  const AiOralVideoListView({
    super.key,
    required this.onUpload,
  });
  final void Function() onUpload;

  @override
  State<AiOralVideoListView> createState() => _AiOralVideoListViewState();
}

class _AiOralVideoListViewState extends State<AiOralVideoListView> {
  @override
  Widget build(BuildContext context) {
    final selectedUserVideoId = context.select<AiOralVideosProvider, int>(
        (value) => value.selectedUserVideoId);
    final userVideoBeans = context.read<AiOralVideosProvider>().userVideoBeans;
    final hasVideos = userVideoBeans.isNotEmpty;

    /// 是否有选择的视频
    final selected = selectedUserVideoId != -1 && hasVideos;

    /// selectedUserVideoId 对应的视频播放地址
    String url = "";
    bool underReview = context.select<AiOralVideosProvider, bool>(
      (value) => value.underReview,
    );

    /// selectedUserVideoId 是否包含在右侧的视频列表中
    bool containedInVideoList = true;
    if (selected) {
      for (var ele in userVideoBeans) {
        if (ele.id == selectedUserVideoId) {
          url = ele.url;
          containedInVideoList = false;
          break;
        }
      }
    }
    byDebugPrint(url, tag: "播放的url:");
    return Container(
      height: 250.h,
      decoration: BoxDecoration(
        color: const Color(0XFFF8FAFB),
        // color: Colors.red,
        borderRadius: BorderRadius.circular(12.w),
      ),
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          !selected
              ? AiUploadView(onUpload: widget.onUpload)
              : Stack(
                  children: [
                    SizedBox(
                      width: 200.w,
                      height: 320.h,
                    ),
                    underReview || containedInVideoList
                        ? Positioned.fill(
                            child: Container(
                              key: Key("$selectedUserVideoId"),
                              color: const Color(0xFFF4F6FA),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 36.w,
                                    height: 36.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 5,
                                      color: Color(0xFF5B4BF7),
                                      strokeCap: StrokeCap.round,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 50.w,
                                    child: Text(
                                      "视频上传中\n请耐心等待",
                                      style: TextStyle(
                                          color: const Color(0XFF0B1843)
                                              .withOpacity(0.5),
                                          fontSize: 12.sp),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        : ByWidgetsUtil.commonContainer(
                            bgColor: const Color(0xFFF4F6FA),
                            // borerRadius: 12.w,
                            child: Container(
                                width: 200.w,
                                height: double.infinity,
                                alignment: Alignment.center,
                                child: url.isEmpty
                                    ? _errorVideoView()
                                    : ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12.w),
                                        clipBehavior: Clip.hardEdge,
                                        child: VideoPlayerWidget(
                                          url: url,
                                          autoPlay: false,
                                          key: Key(url),
                                        ),
                                      )),
                          ),
                    if (url.isNotEmpty)
                      Positioned(
                        top: -6.w,
                        right: -5.w,
                        width: 38,
                        height: 38,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (ByAudioPlayer.sharedInstance.isPlaying) {
                              ByAudioPlayer.sharedInstance.pause();
                            }
                            context
                                .read<AiOralVideosProvider>()
                                .updateSelectedUserVideoId(-1);
                            context
                                .read<AiOralVideosProvider>()
                                .changeUploading(false);
                          },
                          child: Center(
                            child: Image.asset(
                              "assets/ai/oralVideos/ai_oral_videos_create_close.png",
                              width: 18,
                              height: 18,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
          SizedBox(width: 28.w),
          Expanded(
            child: VideoListView(
              onUpload: widget.onUpload,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle({
    required String title,
    required String icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          icon,
          width: 16,
          height: 16,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 5),
        ByWidgetsUtil.commonText(
          text: title,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }

  Widget _errorVideoView() {
    return SizedBox(
      width: 200.w,
      child: ByWidgetsUtil.commonContainer(
          bgColor: const Color(0xFFF4F6FA),
          borerRadius: 12.w,
          child: SizedBox(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  builder: (ctx) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 20.h),
                          ByWidgetsUtil.commonText(
                            text: "上传参考视频",
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                          SizedBox(height: 15.h),
                          ByWidgetsUtil.commonText(
                            text: "仅支持mp4/mov/wmv/wav格式，时长不超过2分钟",
                            fontSize: 12.sp,
                            fontWeight: FontWeight.normal,
                            textColor:
                                ByColorUtil.CommonTextColor.withOpacity(0.5),
                          ),
                          SizedBox(height: 10.h),
                          ByWidgetsUtil.commonContainer(
                            padding: EdgeInsets.only(
                              left: 15.w,
                              right: 15.w,
                              top: 15.h,
                              bottom: 10.h,
                            ),
                            borerRadius: 18.w,
                            bgColor: const Color(0xFFF4F6FA),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/ai/oralVideos/ai_oral_videos_create_eg2.png",
                                        width: 150.h,
                                        height: 150.h,
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(height: 10.h),
                                      Center(
                                        child: _buildTitle(
                                          title: "正脸自拍",
                                          icon:
                                              "assets/ai/oralVideos/ai_oral_videos_create_correct.png",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 21.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/ai/oralVideos/ai_oral_videos_create_eg3.png",
                                        width: 150.h,
                                        height: 150.h,
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(height: 10.h),
                                      Center(
                                        child: _buildTitle(
                                          title: "面部有干扰",
                                          icon:
                                              "assets/ai/oralVideos/ai_oral_videos_create_eg_wrong.png",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12.h),
                          SizedBox(
                            height: 50.h,
                            child: Row(
                              children: [
                                Expanded(
                                  child: ByWidgetsUtil.commonBtn(
                                    title: "相册导入",
                                    textColor: ByColorUtil.TabTextColorSelected,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    bgColor: const Color(0xFFEAEEFF),
                                    borderRadius: 12.w,
                                    onClick: () async {
                                      ByNavRouterUtils.goBack(context);
                                      if (ByPackageUtils.isOhos) {
                                        final status =
                                            await ByPermissionUtils.videos();
                                        if (!status) return;
                                        final List<dynamic> videos =
                                            await ChannelOperate
                                                .getVideoPathFromAlbum(1);
                                        if (videos.isEmpty) return;
                                        final String url =
                                            videos.first.toString();
                                        final int duration =
                                            await ChannelOperate
                                                .getAudioDuration(url);
                                        if (duration < 15 * 1000 ||
                                            duration > 2 * 60 * 1000) {
                                          BotToast.showText(
                                              text: "视频应大于15秒，小于2分钟");
                                          return;
                                        }
                                        _uploadVideo(
                                          videoPath: url,
                                          context: context,
                                          videoDuration: duration ~/ 1000,
                                          isFromCamera: false,
                                        );
                                        return;
                                      }
                                      final videos =
                                          await ByCommonUtils.pickVideos(
                                        context,
                                        maxCount: 1,
                                        durationLimitMin: 15,
                                        durationLimit: 120,
                                      );
                                      if (videos.isEmpty) return;
                                      final videoFile = await videos.first.file;
                                      if (videoFile == null ||
                                          videoFile.existsSync() == false) {
                                        BotToast.showText(
                                            text: "选取视频时出错，请稍后重试");
                                        return;
                                      }

                                      byDebugPrint(videoFile.path,
                                          tag: "===开始上传视频:");
                                      // final cover
                                      _uploadVideo(
                                        videoPath: videoFile.path,
                                        context: context,
                                        videoDuration: videos.first.duration,
                                        isFromCamera: false,
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: 11.h),
                                Expanded(
                                  child: ByWidgetsUtil.commonBtn(
                                    title: "直接拍摄",
                                    textColor: ByColorUtil.WhiteColor,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    bgColor: ByColorUtil.TabTextColorSelected,
                                    borderRadius: 12.w,
                                    onClick: () async {
                                      ByNavRouterUtils.goBack(context);
                                      final status =
                                          await ByPermissionUtils.camera();
                                      if (!status) return;
                                      if (ByPackageUtils.isOhos) {
                                        final String? video =
                                            await ChannelOperate
                                                .getVideoPathFromCamera();
                                        if (video == null || video.isEmpty)
                                          return;
                                        final int duration =
                                            await ChannelOperate
                                                .getAudioDuration(video);
                                        if (duration < 15 * 1000 ||
                                            duration > 2 * 60 * 1000) {
                                          BotToast.showText(
                                              text: "视频应大于15秒，小于2分钟");
                                          return;
                                        }
                                        _uploadVideo(
                                          videoPath: video,
                                          context: context,
                                          videoDuration: duration ~/ 1000,
                                          isFromCamera: true,
                                        );
                                        return;
                                      }
                                      ByNavRouterUtils.push(
                                        context,
                                        AiOralVideoRecordPage(
                                          onRecordFinished: (String videoPath,
                                              bool isFromCamera) async {
                                            byDebugPrint(videoPath,
                                                tag: "开始上传视频:");
                                            final videoInfo =
                                                await FlutterVideoInfo()
                                                    .getVideoInfo(videoPath);
                                            _uploadVideo(
                                              videoPath: videoPath,
                                              context: context,
                                              videoDuration: videoInfo?.duration
                                                      ?.floor() ??
                                                  0,
                                              isFromCamera: isFromCamera,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                              height: 10.h + ByScreenUtils.bottomSafeHeight),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 40.w,
                  ),
                  Text(
                    "视频内容存在敏感信息",
                    style: TextStyle(
                      color: Color(0XFFF62B60),
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(
                    height: 50.w,
                  ),
                  Image.asset(
                    "assets/ai/oralVideos/ai_oral_videos_create_upload.png",
                    width: 40.w,
                    height: 40.w,
                  ),
                  SizedBox(height: 12.h),
                  ByWidgetsUtil.commonText(
                    text: "请重新上传",
                    textColor: const Color(0xFF5B4BF7),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 7.h),
                  ByWidgetsUtil.commonText(
                    text: "仅支持mp4/mov/wmv/wav格式\n最短15S，总时长不超过2分钟",
                    maxLines: 10,
                    fontSize: 11.sp,
                    textAlign: TextAlign.center,
                    textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                    fontWeight: FontWeight.normal,
                  )
                ],
              ),
            ),
          )),
    );
  }

  void _uploadVideo({
    required String videoPath,
    required BuildContext context,
    required int videoDuration,
    required bool isFromCamera,
  }) async {
    final coverPath = await ByDownloadUtil.generateThumbnail(videoPath);
    final provider = context.read<AiOralVideosProvider>();
    provider.changeUploading(true);

    /// 获取上传的参数信息
    ByFfmpegUtil.loadUploadInfo(
      showLoading: false,
      type: MediaType.video,
      suffix: ".mp4",
      onSuccess: (UploadInfoBean infoBean) {
        /// 开始上传
        ByFfmpegUtil.uploadFile(
          showLoading: false,
          infoBean: infoBean,
          filePath: videoPath,
          onSuccess: (resp) {
            provider.changeUploading(false);

            /// 上传封面
            ByFfmpegUtil.loadUploadInfo(
              showLoading: false,
              type: MediaType.picture,
              onSuccess: (UploadInfoBean coverInfoBean) {
                /// 开始上传
                ByFfmpegUtil.uploadFile(
                  showLoading: false,
                  infoBean: coverInfoBean,
                  filePath: coverPath ?? "",
                  onSuccess: (resp) {
                    // final String url = resp.data['url'];
                    /// 上传成功后的操作
                    if (isFromCamera) {
                      /// 转换视频横竖屏
                      ByFfmpegUtil.convertVideoRatio(
                        filePath: infoBean.objectUrl,
                        onSuccess: (resp) {
                          /// 上传成功后的操作
                          final provider = context.read<AiOralVideosProvider>();
                          provider.changeUploading(false);
                          final url = resp["data"]["url"];
                          byDebugPrint(url, tag: "----------");
                          provider.saveUserVideo(
                            videoUrl: url,
                            cover: coverInfoBean.objectUrl,
                            videoDuration: videoDuration,
                            onSuccess: (resp) {
                              provider
                                  .updateSelectedUserVideoId(resp["id"] ?? -1);
                              widget.onUpload.call();
                            },
                          );
                        },
                        onFailed: () {
                          BotToast.showText(text: "文件上传失败,请稍后重试");
                          provider.changeUploading(false);
                        },
                      );
                    } else {
                      /// 上传成功后的操作
                      final provider = context.read<AiOralVideosProvider>();
                      provider.changeUploading(false);
                      provider.saveUserVideo(
                        videoUrl: infoBean.objectUrl,
                        cover: coverInfoBean.objectUrl,
                        videoDuration: videoDuration,
                        onSuccess: (resp) {
                          provider.updateSelectedUserVideoId(resp["id"] ?? -1);
                          widget.onUpload.call();
                        },
                      );
                    }
                  },
                  onFailed: () {
                    BotToast.showText(text: "文件上传失败,请稍后重试");
                    provider.changeUploading(false);
                  },
                );
              },
              onFailed: () {
                provider.changeUploading(false);
              },
            );
          },
          onFailed: () {
            provider.changeUploading(false);
          },
        );
      },
      onFailed: () {
        provider.changeUploading(false);
      },
    );
  }
}

class VideoListView extends StatelessWidget {
  const VideoListView({
    super.key,
    required this.onUpload,
  });

  final void Function() onUpload;
  @override
  Widget build(BuildContext context) {
    final videos =
        context.select<AiOralVideosProvider, List<AiOralMyVideoBean>>(
            (value) => value.userVideoBeans);
    final hasVideos = videos.isNotEmpty;
    if (hasVideos) {
      return _buildVideosList(context);
    }
    return _buildExamples(context);
    // hasVideos ? _buildVideosList(context) : _buildExamples(context),
  }

  Widget _buildTitle({
    required String title,
    required String icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          icon,
          width: 16,
          height: 16,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 5),
        ByWidgetsUtil.commonText(
          text: title,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }

  _buildVideosList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SizedBox(height: 5.h),
        ByWidgetsUtil.commonText(
          text: "上传历史",
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 6.h),
        Expanded(
          child: UserVideoListView(
            onDelete: onUpload,
          ),
        ),
      ],
    );
  }

  Column _buildExamples(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 0.h),
        Padding(
          padding: EdgeInsets.only(right: 32.w),
          child: ByWidgetsUtil.commonText(
            text: "示例",
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        // SizedBox(height: 12.h),
        // Image.asset(
        //   "assets/ai/oralVideos/ai_oral_videos_create_eg1.png",
        //   width: 93.h,
        //   height: 93.h,
        //   fit: BoxFit.cover,
        // ),
        SizedBox(height: 3.h),
        // _buildTitle(
        //   title: "正脸自拍",
        //   icon: "assets/ai/oralVideos/ai_oral_videos_create_correct.png",
        // ),
        // SizedBox(height: 7.h),
        Image.asset(
          "assets/ai/oralVideos/ai_oral_videos_create_eg2.png",
          width: 73.h,
          height: 73.h,
          fit: BoxFit.cover,
        ),
        SizedBox(height: 7.h),
        _buildTitle(
          title: "正脸自拍",
          icon: "assets/ai/oralVideos/ai_oral_videos_create_correct.png",
        ),
        const Spacer(),
        Image.asset(
          "assets/ai/oralVideos/ai_oral_videos_create_eg3.png",
          width: 73.h,
          height: 73.h,
          fit: BoxFit.cover,
        ),
        SizedBox(height: 7.h),
        _buildTitle(
          title: "面部有干扰",
          icon: "assets/ai/oralVideos/ai_oral_videos_create_eg_wrong.png",
        ),
      ],
    );
  }
}

class AiUploadView extends StatelessWidget {
  const AiUploadView({
    super.key,
    required this.onUpload,
  });
  final void Function() onUpload;

  @override
  Widget build(BuildContext context) {
    byDebugPrint("---------------------------:AiUploadView");
    final uploading = context.select<AiOralVideosProvider, bool>(
      (value) => value.uploading,
    );
    return SizedBox(
      width: 200.w,
      child: ByWidgetsUtil.commonContainer(
          bgColor: const Color(0xFFFF4F6FA),
          borerRadius: 12.w,
          child: uploading
              ? _buildUploadingView(context)
              : _buildUploadView(context),
          border: Border.all(width: 2, color: Color(0XFFEAEEFF))),
    );
  }

  Widget _buildUploadView(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ByNavigatorUtil.checkLogin(
          context: context,
          nextStepEvent: () {
            AuthManager.materialAuth(onSuccess: () {
              if (ByAudioPlayer.sharedInstance.isPlaying) {
                ByAudioPlayer.sharedInstance.pause();
              }
              _showVideoSourceDialog(context);
            });
          },
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/ai/oralVideos/ai_oral_videos_create_upload.png",
            width: 40.w,
            height: 40.w,
          ),
          SizedBox(height: 12.h),
          ByWidgetsUtil.commonText(
            text: "添加视频",
            textColor: const Color(0xFF5B4BF7),
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: 7.h),
          ByWidgetsUtil.commonText(
            text: "仅支持mp4/mov/wmv/wav格式\n最短15S，总时长不超过2分钟",
            maxLines: 10,
            fontSize: 11.sp,
            textAlign: TextAlign.center,
            textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
            fontWeight: FontWeight.normal,
          )
        ],
      ),
    );
  }

  Widget _buildUploadingView(BuildContext context) {
    return Stack(children: [
      Container(
          // width: 50.w,
          // height: 50.w,
          // decoration: BoxDecoration(
          //   color: const Color(0XFFF4F6FA),
          //   borderRadius: BorderRadius.circular(12.w),
          //   border: Border.all(
          //     color: Color(0xFF5B4BF7),
          //   )
          // ),
          ),
      Positioned.fill(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50.w,
              height: 50.w,
              child: const CircularProgressIndicator(
                strokeWidth: 6,
                color: Color(0xFF5B4BF7),
                strokeCap: StrokeCap.round,
              ),
            ),
            SizedBox(height: 18.h),
            ByWidgetsUtil.commonText(
              text: "视频上传中\n请耐心等待",
              maxLines: 10,
              fontSize: 11.sp,
              textAlign: TextAlign.center,
              textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
              fontWeight: FontWeight.normal,
            )
          ],
        ),
      ),
      // Positioned(
      //   top: 0,
      //   right: 0,
      //   width: 38,
      //   height: 38,
      //   child: GestureDetector(
      //     behavior: HitTestBehavior.opaque,
      //     onTap: () {
      //       showDialog(
      //         context: context,
      //         builder: (ctx) {
      //           return CommonDialog(
      //             reverse: false,
      //             maxLine: 10,
      //             contents: "请确认是否删除，删除后将不可回恢复，请谨慎操作",
      //             confirmBtnTitle: "删除",
      //             confirmCallback: () {},
      //           );
      //         },
      //       );
      //     },
      //     child: Center(
      //       child: Image.asset(
      //         "assets/ai/oralVideos/ai_oral_videos_create_close.png",
      //         width: 18,
      //         height: 18,
      //       ),
      //     ),
      //   ),
      // ),
    ]);
  }

  Future<dynamic> _showVideoSourceDialog(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(18),
        ),
      ),
      builder: (ctx) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20.h),
              ByWidgetsUtil.commonText(
                text: "上传参考视频",
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
              SizedBox(height: 15.h),
              ByWidgetsUtil.commonText(
                text: "仅支持mp4/mov/wmv/wav格式，时长不超过2分钟",
                fontSize: 12.sp,
                fontWeight: FontWeight.normal,
                textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
              ),
              SizedBox(height: 10.h),
              ByWidgetsUtil.commonContainer(
                padding: EdgeInsets.only(
                  left: 15.w,
                  right: 15.w,
                  top: 15.h,
                  bottom: 10.h,
                ),
                borerRadius: 18.w,
                bgColor: const Color(0xFFF4F6FA),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/ai/oralVideos/ai_oral_videos_create_eg2.png",
                            width: 150.h,
                            height: 150.h,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 10.h),
                          Center(
                            child: _buildTitle(
                              title: "正脸自拍",
                              icon:
                                  "assets/ai/oralVideos/ai_oral_videos_create_correct.png",
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 21.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/ai/oralVideos/ai_oral_videos_create_eg3.png",
                            width: 150.h,
                            height: 150.h,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 10.h),
                          Center(
                            child: _buildTitle(
                              title: "面部有干扰",
                              icon:
                                  "assets/ai/oralVideos/ai_oral_videos_create_eg_wrong.png",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                height: 50.h,
                child: Row(
                  children: [
                    Expanded(
                      child: ByWidgetsUtil.commonBtn(
                        title: "相册导入",
                        textColor: ByColorUtil.TabTextColorSelected,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        bgColor: const Color(0xFFEAEEFF),
                        borderRadius: 12.w,
                        onClick: () async {
                          ByNavRouterUtils.goBack(context);
                          if (ByPackageUtils.isOhos) {
                            final status = await ByPermissionUtils.videos();
                            if (!status) return;
                            final List<dynamic> videos =
                                await ChannelOperate.getVideoPathFromAlbum(1);
                            if (videos.isEmpty) return;
                            final String url = videos.first.toString();
                            final int duration =
                                await ChannelOperate.getAudioDuration(url);
                            if (duration < 15 * 1000 ||
                                duration > 2 * 60 * 1000) {
                              BotToast.showText(text: "视频应大于15秒，小于2分钟");
                              return;
                            }
                            _uploadVideo(
                              videoPath: url,
                              context: context,
                              videoDuration: duration ~/ 1000,
                              isFromCamera: false,
                            );
                            return;
                          }
                          final videos = await ByCommonUtils.pickVideos(
                            context,
                            maxCount: 1,
                            durationLimitMin: 15,
                            durationLimit: 120,
                          );
                          if (videos.isEmpty) return;
                          final videoFile = await videos.first.file;
                          if (videoFile == null ||
                              videoFile.existsSync() == false) {
                            BotToast.showText(text: "选取视频时出错，请稍后重试");
                            return;
                          }

                          byDebugPrint(videoFile.path, tag: "===开始上传视频:");
                          _uploadVideo(
                            videoPath: videoFile.path,
                            context: context,
                            videoDuration: videos.first.duration,
                            isFromCamera: false,
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 11.h),
                    Expanded(
                      child: ByWidgetsUtil.commonBtn(
                        title: "直接拍摄",
                        textColor: ByColorUtil.WhiteColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        bgColor: ByColorUtil.TabTextColorSelected,
                        borderRadius: 12.w,
                        onClick: () async {
                          ByNavRouterUtils.goBack(context);
                          final status = await ByPermissionUtils.camera();
                          if (!status) return;
                          if (ByPackageUtils.isOhos) {
                            final String? video =
                                await ChannelOperate.getVideoPathFromCamera();
                            if (video == null || video.isEmpty) return;
                            final int duration =
                                await ChannelOperate.getAudioDuration(video);
                            if (duration < 15 * 1000 ||
                                duration > 2 * 60 * 1000) {
                              BotToast.showText(text: "视频应大于15秒，小于2分钟");
                              return;
                            }
                            _uploadVideo(
                              videoPath: video,
                              context: context,
                              videoDuration: duration ~/ 1000,
                              isFromCamera: true,
                            );
                            return;
                          }
                          ByNavRouterUtils.push(
                            context,
                            AiOralVideoRecordPage(
                              onRecordFinished:
                                  (String videoPath, bool isFromCamera) async {
                                byDebugPrint(videoPath, tag: "开始上传视频:");
                                final videoInfo = await FlutterVideoInfo()
                                    .getVideoInfo(videoPath);
                                _uploadVideo(
                                  videoPath: videoPath,
                                  context: context,
                                  videoDuration:
                                      videoInfo?.duration?.floor() ?? 0,
                                  isFromCamera: isFromCamera,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h + ByScreenUtils.bottomSafeHeight),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitle({
    required String title,
    required String icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          icon,
          width: 16,
          height: 16,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 5),
        ByWidgetsUtil.commonText(
          text: title,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }

  void _uploadVideo({
    required String videoPath,
    required BuildContext context,
    required int videoDuration,
    required bool isFromCamera,
  }) async {
    final coverPath = await ByDownloadUtil.generateThumbnail(videoPath);

    final provider = context.read<AiOralVideosProvider>();
    provider.changeUploading(true);

    /// 获取上传的参数信息
    ByFfmpegUtil.loadUploadInfo(
      showLoading: false,
      type: MediaType.video,
      suffix: ".mp4",
      onSuccess: (UploadInfoBean infoBean) {
        /// 开始上传
        ByFfmpegUtil.uploadFile(
          showLoading: false,
          infoBean: infoBean,
          filePath: videoPath,
          onSuccess: (resp) {
            // provider.changeUploading(false);

            /// 上传封面
            ByFfmpegUtil.loadUploadInfo(
              showLoading: false,
              type: MediaType.picture,
              onSuccess: (UploadInfoBean coverInfoBean) {
                /// 开始上传
                ByFfmpegUtil.uploadFile(
                  showLoading: false,
                  infoBean: coverInfoBean,
                  filePath: coverPath ?? "",
                  onSuccess: (resp) {
                    // final String url = resp.data['url'];
                    /// 上传成功后的操作
                    if (isFromCamera) {
                      /// 转换视频横竖屏
                      ByFfmpegUtil.convertVideoRatio(
                        filePath: infoBean.objectUrl,
                        showLoading: false,
                        onSuccess: (resp) {
                          /// 上传成功后的操作
                          final provider = context.read<AiOralVideosProvider>();
                          // provider.changeUploading(false);
                          final url = resp["data"]["url"];
                          byDebugPrint(url, tag: "----------");
                          provider.saveUserVideo(
                            videoUrl: url,
                            cover: coverInfoBean.objectUrl,
                            videoDuration: videoDuration,
                            onSuccess: (resp) {
                              provider
                                  .updateSelectedUserVideoId(resp["id"] ?? -1);
                              onUpload.call();
                            },
                          );
                        },
                        onFailed: () {
                          BotToast.showText(text: "文件上传失败,请稍后重试");
                          provider.changeUploading(false);
                        },
                      );
                    } else {
                      /// 上传成功后的操作
                      final provider = context.read<AiOralVideosProvider>();
                      // provider.changeUploading(false);
                      provider.saveUserVideo(
                        videoUrl: infoBean.objectUrl,
                        cover: coverInfoBean.objectUrl,
                        videoDuration: videoDuration,
                        onSuccess: (resp) {
                          provider.updateSelectedUserVideoId(resp["id"] ?? -1);
                          onUpload.call();
                        },
                      );
                    }
                  },
                  onFailed: () {
                    BotToast.showText(text: "文件上传失败,请稍后重试");
                    provider.changeUploading(false);
                  },
                );
              },
              onFailed: () {
                provider.changeUploading(false);
              },
            );
          },
          onFailed: () {
            provider.changeUploading(false);
          },
        );
      },
      onFailed: () {
        provider.changeUploading(false);
      },
    );
  }
}

class UserVideoListView extends StatelessWidget {
  const UserVideoListView({
    super.key,
    this.onDelete,
  });
  final void Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    final userVideoBeans =
        context.select<AiOralVideosProvider, List<AiOralMyVideoBean>>(
      (value) => value.userVideoBeans,
    );
    byDebugPrint("xxxxxxxxxxxxxxxxx:UserVideoListView");
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: userVideoBeans.length,
      itemBuilder: (context, index) {
        final bean = userVideoBeans[index];
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            context
                .read<AiOralVideosProvider>()
                .updateSelectedUserVideoId(bean.id);
          },
          child: Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.w),
              child: Stack(
                children: [
                  SizedBox(width: 100.w, height: 100.w),
                  Positioned.fill(
                    child: bean.status == 1
                        ? Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Image.asset(
                                //   "assets/ai/oralVideos/ai_oral_videos_create_cloud.png",
                                //   width: 56,
                                //   height: 36,
                                //   fit: BoxFit.cover,
                                // ),
                                Container(
                                  width: 100.w,
                                  height: 100.w,
                                  decoration: BoxDecoration(
                                      color: const Color(0XFFF4F6FA),
                                      borderRadius: BorderRadius.circular(12.w),
                                      border: Border.all(
                                          color: const Color(0xFF5B4BF7),
                                          width: 2.w)),
                                ),
                                SizedBox(
                                  width: 24.w,
                                  height: 24.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Color(0xFF5B4BF7),
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: bean.cover.isNotEmpty
                                ? bean.cover
                                : "http://gips2.baidu.com/it/u=3944689179,983354166&fm=3028&app=3028&f=JPEG&fmt=auto?w=1024&h=1024",
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned.fill(
                    child: ByWidgetsUtil.commonContainer(
                      bgColor: Colors.transparent,
                      border: Border.all(
                        color: const Color(0xFFF8FAFB),
                        width: 1,
                      ),
                      child: Container(),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    width: 28,
                    height: 28,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (ByAudioPlayer.sharedInstance.isPlaying) {
                          ByAudioPlayer.sharedInstance.pause();
                        }
                        showDialog(
                          context: context,
                          builder: (ctx) {
                            return CommonDialog(
                              reverse: false,
                              maxLine: 10,
                              contents: "请确认是否删除，删除后将不可回恢复，请谨慎操作",
                              confirmBtnTitle: "删除",
                              confirmCallback: () {
                                final provider =
                                    context.read<AiOralVideosProvider>();
                                provider.deleteUserVideo(
                                  bean.id,
                                  onSuccess: () {
                                    provider.updateSelectedUserVideoId(-1);
                                    provider.changeUploading(false);
                                    onDelete?.call();
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                      child: Center(
                        child: Image.asset(
                          "assets/ai/oralVideos/ai_oral_videos_create_close.png",
                          width: 18,
                          height: 18,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
