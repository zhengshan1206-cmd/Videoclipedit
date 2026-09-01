// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'dart:math';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/core/util/manager/auth.dart';
import 'package:video_clip_edit/modules/home/widgets/short_video_link_view.dart';
import 'package:video_clip_edit/utils/comon/by_download_util.dart';
import 'package:video_clip_edit/utils/comon/by_ffmpeg_util.dart';
import 'package:video_clip_edit/utils/comon/by_permission_utils.dart';
import 'package:video_clip_edit/widgets/physical_wrapper.dart';
import '../../../providers/launch_provider.dart';
import 'words_extraction_tasks_page.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/widgets/banner_view.dart';
import 'package:video_clip_edit/modules/home/widgets/words_task_cell.dart';
import 'package:video_clip_edit/modules/home/words/audio_handle_page.dart';
import 'package:video_clip_edit/modules/home/beans/words_task_cell_bean.dart';
import 'package:video_clip_edit/modules/home/words/beans/upload_info_bean.dart';
import 'package:video_clip_edit/modules/home/providers/words_extract_provider.dart';
import 'package:video_clip_edit/modules/home/words/words_extraction_result_page.dart';

class WordsExtractionPage extends StatefulWidget {
  const WordsExtractionPage({super.key});

  @override
  State<WordsExtractionPage> createState() => _WordsExtractionPageState();
}

class _WordsExtractionPageState extends State<WordsExtractionPage> {
  final ScrollController _scrollController = ScrollController();
  final double maxInset = 100.h;
  double opacity = 1.0;
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentOffset = _scrollController.position.pixels;
    final double alpha = min(currentOffset / maxInset, 1);
    setState(() {
      opacity = 1 - alpha;
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: Stack(
        children: [
          _buildBanner(context),
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: 189.h)),

              /// 热门授权
              _buildFunctiionList(context),

              // _biuldNoData(),
              _buildRecords(context),
            ],
          ),
          Positioned(child: _buildAppBar(context)),
        ],
      ),
    );
  }

  SliverList _buildFunctiionList(BuildContext context) {
    return SliverList.builder(
      itemCount: context.read<WordsExtractProvider>().functionList.length,
      itemBuilder: (ctx, index) {
        final auth = context.read<WordsExtractProvider>().functionList[index];
        return GestureDetector(
          onTap: () async {
            switch (auth.title) {
              case "图片提取":
                _showImagePickerDailog(
                  context,
                  MediaType.picture,
                );
                break;
              case "视频提取":
                _showImagePickerDailog(
                  context,
                  MediaType.video,
                );
                break;
              case "音频提取":
                _showImagePickerDailog(
                  context,
                  MediaType.audio,
                );
                break;
              case "链接提取":
                _showLinkDailog(context);
                break;
              default:
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
            margin: EdgeInsets.only(
              bottom: 8.h,
              left: 12.w,
              right: 12.w,
            ),
            decoration: BoxDecoration(
              color: ByColorUtil.WhiteColor,
              borderRadius: BorderRadius.circular(16.w),
              border: Border.all(
                color: ByColorUtil.MainTextColor.withOpacity(0.05),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 44.w,
                  height: 44.w,
                  child: Image.asset(
                    auth.icon,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 27.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        auth.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: const Color(0xFF0E1840),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 9.h),
                      Text(
                        auth.desc,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF0E1840),
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  "assets/home/arrow_right_bold.png",
                  width: 16.w,
                  height: 16.w,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  _buildBanner(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      width: MediaQuery.of(context).size.width,
      height: 200.h,
      child: Opacity(
        opacity: opacity,
        child: const BannerView(
          urls: ["assets/home/banner_wordsExtraction.png"],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return PhysicalWrapper(
      opacity: opacity,
      child: Container(
        height: statusBarHeight + 44,
        color: ByColorUtil.WhiteColor.withOpacity(1 - opacity),
        padding: EdgeInsets.only(left: 12.w, right: 12.w, top: statusBarHeight),
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                ByNavRouterUtils.goBack(context);
              },
              child: Container(
                width: 44.w,
                height: 44,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 5.w),
                child: Image.asset(
                  "assets/home/icon_back.png",
                  width: 16,
                  height: 16,
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                context.read<LaunchProvider>().gotoPay(context, closePay: true);
              },
              child: Image.asset(
                "assets/home/home_vip.png",
                width: 30.w,
                height: 30.w,
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildRecords(BuildContext context) {
    List<WordsTaskCellBean> taskBeans =
        context.select<WordsExtractProvider, List<WordsTaskCellBean>>(
            (p) => p.taskBeans);
    List<WordsTaskCellBean> ds = [];
    if (taskBeans.isNotEmpty) {
      ds = taskBeans.length > 5 ? taskBeans.sublist(0, 5) : taskBeans;
    }

    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 15.h),
        decoration: BoxDecoration(
          color: ByColorUtil.WhiteColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ds.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTopbar(context),
                  if (ds.isEmpty) ByWidgetsUtil.noDataViewNormal(height: 220.h)
                ],
              );
            }

            return WordsTaskCell(
              bgColor: ByColorUtil.CommonPageBgColor,
              taskCellBean: ds[index - 1],
              showBottomMargin: index < taskBeans.length - 1,
            );
          },
        ),
      ),
    );
  }

  _buildTopbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Image.asset(
            "assets/home/icon_records.png",
            width: 15.w,
            height: 15.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 5.w),
          ByWidgetsUtil.commonText(
            text: "提取记录",
            fontWeight: FontWeight.bold,
            textColor: const Color(0xFF0E1840),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              context.read<WordsExtractProvider>().resetPages();
              ByNavRouterUtils.push(
                context,
                ChangeNotifierProvider.value(
                    value: context.read<WordsExtractProvider>(),
                    child: const WordsExtractionTasksPage()),
              );
            },
            child: ByWidgetsUtil.commonText(
              text: "更多",
              textColor: const Color(0xFF0E1840).withOpacity(0.5),
              fontSize: 12.sp,
            ),
          ),
          const SizedBox(width: 5),
          Image.asset(
            "assets/mine/arrow_right.png",
            width: 8.w,
            height: 13.w,
          )
        ],
      ),
    );
  }

  /// 选择图片选择方式
  void _showImagePickerDailog(
    BuildContext context,
    MediaType mediaType,
  ) {
    if (mediaType == MediaType.audio) {
      ByCommonUtils.pickAssetsWithAudio(
        context,
        maxCount: 1,
        onSelectedCallback: (asstes) async {
          if (asstes.isEmpty) return;
          File? file = await asstes.first.file;
          if (file == null) return;
          final provider = context.read<WordsExtractProvider>();

          /// 获取上传图片参数
          _uploadFile(
            provider,
            mediaType,
            file.path,
            context,
          );
        },
      );
      return;
    }
    AuthManager.materialAuth(onSuccess: () {
      ByCommonUtils.pickAssetsByType(
      context,
      maxCount: 1,
      type: mediaType.uploadFileType,
      onSelectedCallback: (asstes) async {
        if (asstes.isEmpty) return;
        File? file = await asstes.first.file;
        if (file == null) return;

        final provider = context.read<WordsExtractProvider>();
        if (mediaType == MediaType.video) {
          EasyLoading.show(status: "音频分离中");
          await ByFfmpegUtil.splitAudioFileFromVideo(
            file,
            onSuccess: (content) async {
              EasyLoading.dismiss();
              final audioPath = content.item2;
              byDebugPrint(audioPath, tag: "File:");
              if (audioPath.isEmpty) {
                BotToast.showText(text: "分离音频文件失败");
                return;
              }

              /// 获取上传图片参数
              _uploadFile(
                provider,
                MediaType.audio,
                audioPath,
                context,
              );
            },
          );
          return;
        }

        /// 获取上传图片参数
        _uploadFile(
          provider,
          mediaType,
          file.path,
          context,
        );
      },
    );
    },);
    
  }

  void _uploadFile(
    WordsExtractProvider provider,
    MediaType mediaType,
    String filePath,
    BuildContext context,
  ) {
    ByFfmpegUtil.loadUploadInfo(
      type: mediaType,
      onSuccess: (UploadInfoBean infoBean) {
        /// 上传
        ByFfmpegUtil.uploadFile(
          infoBean: infoBean,
          filePath: filePath,
          onSuccess: (resp) {
            final provider = context.read<WordsExtractProvider>();
            if (mediaType == MediaType.picture) {
              /// OCR识别图片
              ByFfmpegUtil.textExtractByImage(
                imgUrl: infoBean.objectUrl,
                onSuccess: (data) {
                  final content = data["data"]["Content"] ?? "";
                  provider.updateExtractedContent(content);
                  provider.loadRecords();
                  ByNavRouterUtils.push(
                    context,
                    WordsExtractionResultPage(contents: content),
                  );
                },
              );
            } else if (mediaType == MediaType.audio) {
              /// 识别语音
              ByFfmpegUtil.textExtractByAudio(
                audioUrl: infoBean.objectUrl,
                onSuccess: (String requestID) {
                  ByNavRouterUtils.push(
                    context,
                    ChangeNotifierProvider.value(
                      value: context.read<WordsExtractProvider>(),
                      child: AudioHandlePage(requestID: requestID),
                    ),
                  );
                },
              );
            }
          },
        );
      },
    );
  }

  ///视频链接提取
  void _showLinkDailog(BuildContext context) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (ctx) {
        return ChangeNotifierProvider.value(
          value: context.read<WordsExtractProvider>(),
          child: ShortVideoLinkView(
            onSuccess: (videoUrl) async {
              final status = await ByPermissionUtils.videos();
              if (!status) return;
              final provider = context.read<WordsExtractProvider>();
              final saveName =
                  "${DateTime.now().millisecondsSinceEpoch}_tmp.mp4";
              ByDownloadUtil.downloadVideo(
                videoUrl,
                saveName,
                saveToAlbum: false,
                deleteWhenFinished: false,
                onSuccess: (filePath) async {
                  EasyLoading.show(status: "音频分离中");
                  await ByFfmpegUtil.splitAudioFileFromVideo(
                    File(filePath),
                    onSuccess: (audioInfoTuple) {
                      EasyLoading.dismiss();
                      _uploadFile(
                        provider,
                        MediaType.audio,
                        audioInfoTuple.item2,
                        context,
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
