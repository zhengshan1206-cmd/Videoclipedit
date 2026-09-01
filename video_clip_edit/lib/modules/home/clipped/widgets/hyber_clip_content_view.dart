// ignore_for_file: must_be_immutable, use_build_context_synchronously, unnecessary_null_comparison, prefer_is_empty
import 'dart:io';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_assets_util.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/clipped/beans/dubbing_bean.dart';
import 'package:video_clip_edit/modules/download/providers/download_provider.dart';
import 'package:video_clip_edit/modules/home/clipped/voiceover_subtitle_page.dart';
import 'package:video_clip_edit/modules/home/clipped/video_clip_hyber_preview.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/modules/home/providers/show_recreate_provider.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/voice_select_dailog.dart';

class HyberClipContentView<T extends MaterialBaseProvider>
    extends StatefulWidget {
  bool type;

  HyberClipContentView({
    super.key,
    this.showCommentary = true,
    this.type = true,
  });

  ///  是否显示顶部的解说列表
  final bool showCommentary;

  @override
  State<HyberClipContentView<T>> createState() =>
      _HyberClipContentViewState<T>();
}

class _HyberClipContentViewState<T extends MaterialBaseProvider>
    extends State<HyberClipContentView<T>> {
  @override
  void initState() {
    super.initState();

    /// 配音列表
    _loadDubbingList();
  }

  // ignore: prefer_typing_uninitialized_variables
  late T _provider;
  List<String> filePaths = [];
  List<String> syntheticSubtitlesFilePaths = [];
  List<String> srts = [];

  @override
  Widget build(BuildContext context) {
    final bool isClip = MaterialProviderTypeExt.providerTypeFromType(T) ==
        MaterialProviderType.clip;
    _provider = context.watch<T>();
    final bool isSpeedy = context.select<T, bool>(
      (p) {
        return p.generatingMode == null
            ? false
            : p.generatingMode == MaterialProviderGeneratingMode.speedy;
      },
    );
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            if (isClip && widget.showCommentary) _buildVoiceList(context),
            if (!isClip && isSpeedy) ..._buildCopywriterSection(context),
            // if (!isClip && !isSpeedy) _buildVoiceList(context),

            /// 视频比例
            ..._buildVideoRatiosSection(context),

            /// 解说字幕
            ..._buildSubtitlesSection(context),

            /// 选择模式
            ..._buildModesSection(context),

            /// 选择特效
            ..._buildSpecialEffectsSection(context),

            /// 背景音乐
            ..._buildBgmSection(context),

            // if (MaterialProviderTypeExt.providerTypeFromType(T) ==
            //     MaterialProviderType.recreate &&
            //     !isSpeedy)
            //   _buildSectionTitle(
            //     title: "去除视频原声",
            //     rightWidget: Selector<T, Tuple2<T, bool>>(
            //         selector: (p0, p1) => Tuple2(p1, p1.removeVideoAudio),
            //         builder: (
            //             context,
            //             tuple,
            //             child,
            //             ) {
            //           return Switch(
            //             value: tuple.item2,
            //             activeColor: ByColorUtil.WhiteColor,
            //             activeTrackColor: ByColorUtil.LoginBtnBgColor,
            //             inactiveTrackColor:
            //             ByColorUtil.CommonTextColor.withOpacity(0.2),
            //             inactiveThumbColor: const Color(0xFFF8F8F8),
            //             trackOutlineColor:
            //             const WidgetStatePropertyAll(Colors.transparent),
            //             onChanged: (value) {
            //               tuple.item1
            //                   .updateRemoveVideoAudioStatus(!tuple.item2);
            //             },
            //           );
            //         }),
            //   ),

            // _buildSectionTitle(
            //   title: "去除视频原声",
            //   rightWidget: Selector<T, Tuple2<T, bool>>(
            //       selector: (p0, p1) => Tuple2(p1, p1.removeVideoAudio),
            //       builder: (
            //         context,
            //         tuple,
            //         child,
            //       ) {
            //         return Switch(
            //           value: tuple.item2,
            //           activeColor: ByColorUtil.WhiteColor,
            //           activeTrackColor: ByColorUtil.LoginBtnBgColor,
            //           inactiveTrackColor:
            //               ByColorUtil.CommonTextColor.withOpacity(0.2),
            //           inactiveThumbColor: const Color(0xFFF8F8F8),
            //           trackOutlineColor:
            //               const WidgetStatePropertyAll(Colors.transparent),
            //           onChanged: (value) {
            //             tuple.item1.updateRemoveVideoAudioStatus(!tuple.item2);
            //           },
            //         );
            //       }),
            // ),

            /// 安全距离
            SliverToBoxAdapter(
              child: SizedBox(height: ByScreenUtils.bottomInsetForOverlayBar + 60.h),
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          child: Container(
            width: ByScreenUtils.screenWidth,
            color: ByColorUtil.WhiteColor,
            padding: EdgeInsets.only(
              left: 12.w,
              right: 12.w,
              top: 8.h,
              bottom: 8.h + ByScreenUtils.bottomInsetForOverlayBar,
            ),
            child: ByWidgetsUtil.commonBtn(
              title: "确定",
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              borderRadius: 12.w,
              onClick: () async {
                // syntheticSubtitlesFilePaths.clear();
                // filePaths.clear();
                // srts.clear();

                // /// 1、二创的精细和极速模式、混剪的极速模式都是将所有的视频合并成为了一个视频,混剪精细是多个本地视频
                // List assets = (isSpeedy || !isClip)
                //     ? [_provider.assetSpeedy!]
                //     : _provider.selectedMaterials;

                // /// 2、获取视频的本地资源路径
                // for (var item in assets) {
                //   if (item is AssetEntity) {
                //     final file = await item.file;
                //     if (file != null) {
                //       filePaths.add(file.path);
                //     }
                //   } else if (item is File) {
                //     filePaths.add(item.path);
                //   }
                // }

                // // int duration=0;
                // // for(int i=0;i<filePaths.length;i++){
                // //   await ChannelOperate.getMultimediaFilesDuration(filePaths[i]).then((data){
                // //     if(data!=null){
                // //       int du=data["duration"];
                // //       duration=du+duration;
                // //     }
                // //   });
                // // }
                // //
                // // if(duration<10){
                // //   BotToast.showText(text: "视频时长必须大于3秒");
                // //   return;
                // // }

                // /// 3、开始下载字幕文件
                // srts = await _downloadSrtFiles(
                //   provider: _provider,
                //   context: context,
                //   assets: assets,
                //   isSpeedy: isSpeedy,
                //   isClip: isClip,
                // );

                // final bool isRecreate =
                //     MaterialProviderTypeExt.providerTypeFromType(T) ==
                //         MaterialProviderType.recreate;

                // /// 二创处理
                // if (isRecreate) {
                //   /// 解说配音文件列表
                //   List<Map<String, dynamic>> audionList = [];

                //   /// 取消的剧情列表，将在SDK中删除改此视频片段
                //   List<Map<String, dynamic>> removeList = [];

                //   final provider = context.read<T>() as ShowRecreateProvider;
                //   final List<CommentaryItemBean> commentaryItemBeans =
                //       provider.commentaryItemBeans;

                //   /// 当前移除剧情片段的时长
                //   double removedDuraion = 0;
                //   BySrtUtils srtUtil = BySrtUtils();

                //   /// 4、开始计算配音的语音文件的起始、结束时间以及文件路径
                //   for (var element in commentaryItemBeans) {
                //     /// 如果解说文案的配音文件路径存在，则表示选择的是解说
                //     if (element.audioLocalPath.isNotEmpty) {
                //       final commentaryDuration = element.commentaryDuration;
                //       final duration = element.duration;
                //       double startTime = element.commentary.startTime;
                //       final totalDuration = duration * 1000;
                //       if (commentaryDuration < totalDuration) {
                //         startTime = startTime +
                //             (totalDuration - commentaryDuration) * 0.5 / 1000;
                //       }
                //       double endTime = startTime + commentaryDuration / 1000;

                //       audionList.add({
                //         "audioPath": element.audioLocalPath,
                //         "start_time": startTime - removedDuraion,
                //         "end_time": endTime - removedDuraion
                //       });
                //       var length = commentaryItemBeans.indexOf(element);
                //       srts ??= [];
                //       if (srts != null) {
                //         try {
                //           var srt = srts.length >= length ? srts[length] : "";
                //           if (srt != "") {
                //             srtUtil.addFilePath(
                //                 startTime - removedDuraion, srt);
                //           }
                //         } catch (e) {
                //           byDebugPrint(e);
                //         }
                //       }
                //     } else {
                //       /// 如果解说文案的配音文件路径不存在，则表示选择的是剧情
                //       for (var talk in element.talk) {
                //         if (!talk.selected) {
                //           removeList.add({
                //             "start_time": talk.startTime - removedDuraion,
                //             "end_time": talk.endTime - removedDuraion,
                //           });
                //           removedDuraion += (talk.endTime - talk.startTime);
                //         }
                //       }
                //     }
                //   }

                //   if (isSpeedy && srts != null && srts.length > 0) {
                //     //二创极速模式
                //     for (var i = 0; i < srts.length; i++) {
                //       if (srts[i] != "") {
                //         srts[i] = BySrtUtils.handleSingleFilePath(0, srts[i]);
                //       }
                //     }

                //     for (int i = 0; i < assets.length; i++) {
                //       var file = assets[i];
                //       final path = (file as File).path;

                //       // if (provider.audioFilePahMap[path] != null) {
                //       //
                //       // }
                //       String getMultimediaFilesDurationStart = "-1";
                //       String getMultimediaFilesDurationEnd = "-1";

                //       audionList.add({
                //         "audioPath": provider.audioFilePahMap[path],
                //         "start_time": getMultimediaFilesDurationStart,
                //         "end_time": getMultimediaFilesDurationEnd
                //       });
                //     }
                //   }

                //   /// 5、将所有解说文案生成的多个音频文件对应的字幕文件合并成一个字幕文件
                //   if (srtUtil.getSize() > 0) {
                //     //写文件
                //     srts.clear();
                //     try {
                //       final directory = await getApplicationCacheDirectory();
                //       final filePath =
                //           "${directory.path}/DCIM/flutter/audios/${DateTime.now().microsecondsSinceEpoch}.srt";
                //       File nsrtFile = srtUtil.toFile(filePath);
                //       if (nsrtFile.existsSync()) {
                //         srts.add(filePath);
                //       }
                //     } catch (e) {
                //       byDebugPrint(e);
                //     }
                //   }

                //   if (_provider.removeVideoAudio) {
                //     await ChannelOperate.toVideoEdit(
                //       true,
                //       dialogTitle: "视频原音处理中",
                //       // isSplictShowDialog: true,
                //       isShowLoadDialog: true,
                //       isExportVideo: true,
                //       // srtFilePaths: srts,
                //       isSplictShowDialog: true,
                //       isOriginalSoundtrack: _provider.removeVideoAudio,
                //       videoLocalFilePathParameter: filePaths,
                //     ).then((data) {
                //       if (data != null) {
                //         toRecreateMainVideoPage(audionList, removeList,
                //             [data[ChannelApi.editResult]]);
                //       }
                //     });
                //   } else {
                //     toRecreateMainVideoPage(audionList, removeList, filePaths);
                //   }
                // }

                // /// 混剪处理
                // else if (MaterialProviderTypeExt.providerTypeFromType(T) ==
                //     MaterialProviderType.clip) {
                //   List<Map<String, dynamic>> audionList = [];
                //   final provider = context.read<T>();
                //   for (int i = 0; i < assets.length; i++) {
                //     var file = assets[i];
                //     String path = "";
                //     if (file is File) {
                //       path = file.path;
                //     } else if (file is AssetEntity) {
                //       final ass = await file.file;
                //       path = ass?.path ?? "";
                //     }

                //     if (provider.audioFilePahMap[path] != null) {
                //       if (provider.audioFilePahMap[path]!.isNotEmpty) {
                //         isFondFile = true;
                //       }
                //     }
                //     audionList.add({
                //       "audioPath": provider.audioFilePahMap[path],
                //       "start_time": -1,
                //       "end_time": -1
                //     });
                //   }

                //   bool minxSubTitleBool = false;
                //   if (_provider.selectedSubTitle == "有字幕") {
                //     for (int i = 0; i < srts.length; i++) {
                //       if (srts[i].trim().toString().isNotEmpty) {
                //         minxSubTitleBool = true;
                //       }
                //     }
                //     if (minxSubTitleBool) {
                //       syntheticSubtitlesFilePaths.clear();
                //       for (int i = 0; i < srts.length; i++) {
                //         if (srts[i].isNotEmpty) {
                //           //格式化字幕文件
                //           srts[i] = BySrtUtils.handleSingleFilePath(0, srts[i]);
                //           await ChannelOperate.toVideoEdit(
                //             true,
                //             isExportVideo: true,
                //             isShowLoadDialog: true,
                //             srtFilePathsAll: false,
                //             srtFilePaths: [srts[i]],
                //             dialogTitle: "生成第${i + 1}个视频字幕中",
                //             videoLocalFilePathParameter: [filePaths[i]],
                //             subtitles: _provider.selectedSubTitle,
                //           ).then((data) async {
                //             if (data != null) {
                //               filePaths[i] = data[ChannelApi.editResult];
                //               // syntheticSubtitlesFilePaths
                //               //     .add(data[ChannelApi.editResult]);
                //               if (i == srts.length - 1) {
                //                 await toClipVideoPage(audionList);
                //               }
                //             }
                //           });
                //         } else {
                //           if (i == srts.length - 1) {
                //             await toClipVideoPage(audionList);
                //           }
                //           BotToast.showText(text: "第${i + 1}个视频没有字幕文件!");
                //         }
                //       }
                //     } else {
                //       BotToast.showText(text: "没有生成字幕文件!");
                //     }
                //   } else {
                //     await toClipVideoPage(audionList);
                //   }
                // }
              },
            ),
          ),
        ),
      ],
    );
  }

  getFilePath() {
    if (syntheticSubtitlesFilePaths.isNotEmpty) {
      return syntheticSubtitlesFilePaths;
    } else {
      return filePaths;
    }
  }

  //二创主流程
  toRecreateMainVideoPage(List<Map<String, dynamic>> audionList,
      List<Map<String, dynamic>> removeList, List<String> filePaths) async {
    // if (removeList.isNotEmpty) {
    //   await ChannelOperate.toVideoEdit(
    //     true,
    //     dialogTitle: "视频剪辑中",
    //     // isSplictShowDialog: true,
    //     isShowLoadDialog: true,
    //     isExportVideo: true,
    //     // srtFilePaths: srts,
    //     isSplictShowDialog: true,
    //     // isOriginalSoundtrack:getRemoveVideoAudio(),
    //     removeList: removeList,
    //     videoLocalFilePathParameter: filePaths,
    //   ).then((data) async {
    //     if (data != null) {
    //       final file = data[ChannelApi.editResult];
    //       if (audionList.isNotEmpty) {
    //         toRecreateVideoPage(audionList, [file], srts);
    //       } else {
    //         toClipVideoPageSing([file]);
    //       }
    //     }
    //   });
    // } else if (audionList.isNotEmpty) {
    //   toRecreateVideoPage(audionList, filePaths, srts);
    // } else {
    //   toClipVideoPageSing(filePaths);
    // }
  }

  //二创的声音处理
  toRecreateVideoPage(List<Map<String, dynamic>> audionList, List<String> path,
      List<String> srts) async {
    // print("ddddddddddddddddd111${path}");
    // print("ddddddddddddddddd222${srts}");
    // print("ddddddddddddddddd333${audionList}");
    // await ChannelOperate.toVideoEdit(true,
    //         commentaryDubbingList: audionList,
    //         isExportVideo: true,
    //         isShowLoadDialog: true,
    //         // isOriginalSoundtrack:getRemoveVideoAudio(),
    //         isSplictShowDialog: true,
    //         videoLocalFilePathParameter: path,
    //         // videoRatio: _provider.selectedRatio,
    //         // selectionMode: _provider.selectedModes,
    //         // selectionEffect: _provider.selectedSpeciaEffect,
    //         // selectMusic: _provider.bgmFilePath,
    //         // isOriginalSoundtrack: _provider.removeVideoAudio,
    //         dialogTitle: "视频配音中")
    //     .then((data) async {
    //   if (data != null) {
    //     toClipVideoPageSing([data[ChannelApi.editResult]]);
    //     // exportVideoPage(data[ChannelApi.editResult]);
    //   }
    // });
  }

  bool isFondFile = false;

  //混剪
  toClipVideoPage(
    List<Map<String, dynamic>> audionList,
  ) async {
    if (isFondFile) {
      // for (int i = 0; i < audionList.length; i++) {
      //   await ChannelOperate.toVideoEdit(
      //     true,
      //     isExportVideo: true,
      //     dialogTitle: "第${i + 1}个视频配音中",
      //     isShowLoadDialog: true,
      //     commentaryDubbingListSing: [audionList[i]],
      //     videoLocalFilePathParameter: [filePaths[i]],
      //   ).then((data) async {
      //     if (data != null) {
      //       filePaths[i] = data[ChannelApi.editResult];
      //       if (i == audionList.length - 1) {
      //         toClipVideoPageFinish();
      //       }
      //     }
      //   });
      // }
    } else {
      toClipVideoPageFinish();
    }
  }

//混剪最后一部
  toClipVideoPageFinish() async {
    // await ChannelOperate.toVideoEdit(
    //   true,
    //   isExportVideo: true,
    //   isShowLoadDialog: true,
    //   videoLocalFilePathParameter: filePaths,
    //   dialogTitle: "视频合成中",
    //   videoRatio: _provider.selectedRatio,
    //   selectionMode: [_provider.selectedModes],
    //   selectionEffect: [_provider.selectedSpeciaEffect],
    //   selectMusic: _provider.bgmFilePath,
    //   // isOriginalSoundtrack: _provider.removeVideoAudio,
    // ).then((data) async {
    //   if (data != null) {
    //     exportVideoPage(data[ChannelApi.editResult]);
    //   }
    // });
  }

  bool subTitleBool = false;
  //二创的的最后一部
  toClipVideoPageSing(
    List<String> path,
  ) async {
    if (_provider.selectedSubTitle == "有字幕") {
      for (int i = 0; i < srts.length; i++) {
        if (srts[i].trim().toString().isNotEmpty) {
          subTitleBool = true;
        }
      }
      if (subTitleBool) {
        // await ChannelOperate.toVideoEdit(
        //   true,
        //   isExportVideo: true,
        //   isShowLoadDialog: true,
        //   srtFilePathsAll: true,
        //   srtFilePaths: srts,
        //   // commentaryDubbingList: audionList,
        //   // srtFilePathsSing: srts[0],
        //   dialogTitle: "生成字幕中...",
        //   videoLocalFilePathParameter: path,
        //   subtitles: _provider.selectedSubTitle,
        // ).then((data) async {
        //   await ChannelOperate.toVideoEdit(
        //     true,
        //     isExportVideo: true,
        //     isShowLoadDialog: true,
        //     videoLocalFilePathParameter: [data[ChannelApi.editResult]],
        //     dialogTitle: "视频合成中",
        //     videoRatio: _provider.selectedRatio,
        //     selectionMode: [_provider.selectedModes],
        //     selectionEffect: [_provider.selectedSpeciaEffect],
        //     selectMusic: _provider.bgmFilePath,
        //     isOriginalSoundtrack: _provider.removeVideoAudio,
        //   ).then((data) async {
        //     if (data != null) {
        //       exportVideoPage(data[ChannelApi.editResult]);
        //     }
        //   });
        // });
      } else {
        BotToast.showText(text: "没有生成字幕文件!");
      }
    } else {
      // await ChannelOperate.toVideoEdit(
      //   true,
      //   // isSavePhoto: true,
      //   // srtFilePaths: srts,
      //   isExportVideo: true,
      //   isShowLoadDialog: true,
      //   // commentaryDubbingList: audionList,
      //   videoLocalFilePathParameter: path,
      //   dialogTitle: "视频合成中",
      //   videoRatio: _provider.selectedRatio,
      //   // subtitles: _provider.selectedSubTitle,
      //   selectionMode: [_provider.selectedModes],
      //   selectionEffect: [_provider.selectedSpeciaEffect],
      //   selectMusic: _provider.bgmFilePath,
      //   isOriginalSoundtrack: _provider.removeVideoAudio,
      // ).then((data) async {
      //   if (data != null) {
      //     exportVideoPage(data[ChannelApi.editResult]);
      //   }
      // });
    }
  }

  void exportVideoPage(String path) {
    try {
      /// 更新作品任务进度为完成
      final workId = _provider.workId;
      if (workId.isNotEmpty) {
        _provider.updateWork(
          params: {
            "id": workId,
            "status": "2",
            "file_url": path,
            "file_cover_url": path,
          },
          onSuccess: (data) {
            byDebugPrint(data, tag: "更新作品: $workId");
          },
        );
      }

      ByNavRouterUtils.push(
        context,
        VideoClipHyberPrevicew(path, backToHme: true),
      );
    } catch (e) {
      // byDebugPrint(e);
    }
  }

  /// 人声列表
  _buildVoiceList(BuildContext context) {
    final provider = context.watch<T>();
    List<DubbingBean> dubbingBeans = provider.dubbingBeans ?? [];
    const int lenDisplay = 6;
    if (dubbingBeans.length > lenDisplay) {
      dubbingBeans = dubbingBeans.sublist(0, lenDisplay);
    }
    return SliverToBoxAdapter(
      child: dubbingBeans.isEmpty
          ? Container()
          : Container(
              height: 135.h,
              margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 11.h),
              decoration: BoxDecoration(
                color: ByColorUtil.WhiteColor,
                borderRadius: BorderRadius.circular(12.w),
                boxShadow: [
                  BoxShadow(
                    color: ByColorUtil.BlackColor.withOpacity(0.05),
                    blurRadius: 4.w,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      ByWidgetsUtil.commonText(
                        text: "解说人声",
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            useSafeArea: false,
                            builder: (ctx) => MultiProvider(
                              providers: [
                                ChangeNotifierProvider.value(
                                    value: context.read<T>()),
                              ],
                              child: VoiceSelectDailog<T>(),
                            ),
                          );
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ByWidgetsUtil.commonText(
                              text: "更多",
                              fontSize: 14.sp,
                            ),
                            SizedBox(width: 5.w),
                            Image.asset(
                              "assets/mine/arrow_right.png",
                              width: 8.w,
                              height: 13.w,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 9.h),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: dubbingBeans.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final bean = dubbingBeans[index];
                        final selected = provider.selectedDubbingIdx == index;
                        return GestureDetector(
                          onTap: () {
                            provider.updateSelectedDubbingIdx(index);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            margin: EdgeInsets.only(right: 10.w),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipOval(
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 50.w,
                                        height: 50.h,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: selected
                                                ? ByColorUtil
                                                    .TabTextColorSelected
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: bean.headerImage,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Center(
                                          child: Image.asset(
                                            "assets/home/icon_voice_play_white.png",
                                            width: 14.w,
                                            height: 14.h,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                ByWidgetsUtil.commonText(
                                  text: bean.showName,
                                  fontSize: 12.sp,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  textColor: selected
                                      ? ByColorUtil.TabTextColorSelected
                                      : ByColorUtil.CommonTextColor,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// 背景音乐组
  List<Widget> _buildBgmSection(BuildContext context) {
    final provider = context.watch<T>();
    return [
      _buildSectionTitle(title: "背景音乐"),
      _buildSectionGride(
        itemCount: provider.bgms.length,
        crossAxisCount: 3,
        childAspectRatio: 109 / 36,
        itemBuilder: (ctx, index) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (index == 0) {
                provider.updateSelectedBgm('', index);
              } else if (index == 1) {
                provider.updateSelectedBgm('智能配乐', index);
              } else {
                _uploadBgm(provider);
              }
            },
            child: _buildBGMCell(provider, index),
          );
        },
      ),
    ];
  }

  Container _buildBGMCell(T provider, int index) {
    bool select = provider.selectedBgmIndex == index;
    if (select) {
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ByColorUtil.LoginBtnBgColor,
          borderRadius: BorderRadius.circular(8.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SizedBox(width: 16.w),
            ByWidgetsUtil.commonText(
              text: provider.bgms[provider.selectedBgmIndex],
              textColor: ByColorUtil.WhiteColor,
              fontWeight: FontWeight.bold,
            ),
            // const Spacer(),
            // Opacity(
            //   opacity: index != 0 ? 1.0 : 0.0,
            //   child: Image.asset(
            //     "assets/home/ic_right_arrow.png",
            //     color: Colors.white,
            //   ),
            // )
          ],
        ),
      );
    } else {
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ByColorUtil.WhiteColor,
          borderRadius: BorderRadius.circular(8.w),
        ),
        child: ByWidgetsUtil.commonText(
          text: provider.bgms[index],
          textColor: ByColorUtil.CommonTextColor,
          fontWeight: FontWeight.normal,
        ),
      );
    }
  }

  /// 模式组
  _buildModesSection(BuildContext context) {
    final provider = context.watch<T>();
    return [
      _buildSectionTitle(title: "选择模式"),
      _buildSectionGride(
        itemCount: provider.modes.length,
        crossAxisCount: 4,
        childAspectRatio: 20 / 9,
        itemBuilder: (ctx, index) {
          final modes = provider.modes;
          var selected = provider.selectedModes.contains(modes[index]);
          return GestureDetector(
            onTap: () {
              provider.updateSelectedModes(modes[index]);
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? ByColorUtil.LoginBtnBgColor
                    : ByColorUtil.WhiteColor,
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: ByWidgetsUtil.commonText(
                text: provider.modes[index],
                textColor: selected
                    ? ByColorUtil.WhiteColor
                    : ByColorUtil.CommonTextColor,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    ];
  }

  /// 特效组
  _buildSpecialEffectsSection(BuildContext context) {
    final provider = context.watch<T>();
    return [
      _buildSectionTitle(title: "选择特效"),
      _buildSectionGride(
        itemCount: provider.speciaEffects.length,
        crossAxisCount: 4,
        childAspectRatio: 20 / 9,
        itemBuilder: (ctx, index) {
          final speciaEffects = provider.speciaEffects;
          var selected =
              provider.selectedSpeciaEffect.contains(speciaEffects[index]);
          return GestureDetector(
            onTap: () {
              provider.updateSelectedSpeciaEffect(speciaEffects[index]);
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? ByColorUtil.LoginBtnBgColor
                    : ByColorUtil.WhiteColor,
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: ByWidgetsUtil.commonText(
                text: provider.speciaEffects[index],
                textColor: selected
                    ? ByColorUtil.WhiteColor
                    : ByColorUtil.CommonTextColor,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    ];
  }

  /// 视频比例组
  _buildVideoRatiosSection(BuildContext context) {
    final Tuple3<List<String>, String, T> ratiosTuple =
        context.select<T, Tuple3<List<String>, String, T>>(
      (p) => Tuple3(p.ratios, p.selectedRatio, p),
    );
    return [
      _buildSectionTitle(title: "视频比例"),
      _buildSectionGride(
        itemCount: ratiosTuple.item1.length,
        crossAxisCount: 5,
        childAspectRatio: 5 / 3,
        itemBuilder: (ctx, index) {
          final ratios = ratiosTuple.item1;
          var selected = ratios[index] == ratiosTuple.item2;
          return GestureDetector(
            onTap: () {
              ratiosTuple.item3.updateSelectedRatio(ratios[index]);
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? ByColorUtil.LoginBtnBgColor
                    : ByColorUtil.WhiteColor,
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: ByWidgetsUtil.commonText(
                text: ratiosTuple.item1[index],
                textColor: selected
                    ? ByColorUtil.WhiteColor
                    : ByColorUtil.CommonTextColor,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    ];
  }

  /// 字幕组
  _buildSubtitlesSection(BuildContext context) {
    final provider = context.watch<T>();
    return [
      _buildSectionTitle(title: "解说字幕"),
      _buildSectionGride(
        itemCount: provider.subTitles.length,
        crossAxisCount: 4,
        childAspectRatio: 20 / 9,
        itemBuilder: (ctx, index) {
          final current = provider.subTitles[index];
          var selected = current == provider.selectedSubTitle;
          return GestureDetector(
            onTap: () {
              provider.updateSelectedSubTitle(current);
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? ByColorUtil.LoginBtnBgColor
                    : ByColorUtil.WhiteColor,
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: ByWidgetsUtil.commonText(
                text: provider.subTitles[index],
                textColor: selected
                    ? ByColorUtil.WhiteColor
                    : ByColorUtil.CommonTextColor,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    ];
  }

  _buildCopywriterSection(BuildContext ctx) {
    return [
      _buildSectionTitle(
          title: "解说文案",
          rightWidget: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              final provider = ctx.read<T>();
              ByNavRouterUtils.push(
                  context,
                  ChangeNotifierProvider.value(
                    value: ctx.read<T>(),
                    child: VoiceoverSubtitlePage<T>(
                      contents: provider.subtitlesBean.wordsOrigin,
                      workID: '',
                      assetEntity: provider.assetSpeedy,
                    ),
                  ));
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/home/icon_edit.png",
                  width: 12.w,
                  height: 12.h,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 5),
                ByWidgetsUtil.commonText(
                  text: "修改",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  textColor: ByColorUtil.TabTextColorSelected,
                )
              ],
            ),
          )),
      SliverToBoxAdapter(
        child: ByWidgetsUtil.commonContainer(
          margin: EdgeInsets.only(
            left: 12.w,
            right: 12.w,
            bottom: 10.h,
          ),
          padding: EdgeInsets.all(12.w),
          child: ByWidgetsUtil.commonText(
            maxLines: 10,
            text: ctx.watch<T>().subtitlesBean.wordsOrigin.isEmpty
                ? "未识别到文案"
                : ctx.watch<T>().subtitlesBean.wordsOrigin,
            fontSize: 14.sp,
          ),
        ),
      ),
    ];
  }

  /// 上传本地bgm
  void _uploadBgm(T priv) {
    ByCommonUtils.pickAssetsWithAudio(
      context,
      maxCount: 1,
      onSelectedCallback: (asstes, {List<String>? urls}) async {
        String? path;
        if (urls != null && urls.isNotEmpty) {
          final f = File(urls.first);
          if (f.existsSync()) path = f.path;
        } else if (asstes.isNotEmpty) {
          final file = await asstes[0].file;
          path = file?.path;
        }
        if (path != null) {
          priv.updateSelectedBgm(path, 2);
        }
      },
    );
  }

  void _loadDubbingList() {
    context.read<T>().loadDubbingList();
  }

  /// 下载
  Future<List<String>> _downloadSrtFiles({
    required T provider,
    required BuildContext context,
    required List<dynamic> assets,
    required bool isSpeedy,
    required bool isClip,
  }) async {
    final selectedMaterials = assets;
    if (provider.selectedSubTitle == "有字幕") {
      final List<String> urls = [];

      /// 二创精细：字幕文件路径在
      /// VideoRecreateDubbingProvider - commentaryItemBeans - srtUrl
      if (!isClip) {
        //极速
        if (isSpeedy) {
          for (var ele in selectedMaterials) {
            final path = await ByAssetsUtil.filePathForAsset(ele);
            if (path.isNotEmpty) {
              final url = provider.srtMap[path] ?? "";
              if (url.isNotEmpty) {
                urls.add(url);
              } else {
                urls.add("");
              }
            } else {
              urls.add("");
            }
          }
        } else {
          // 精细
          final commentaryItemBeans =
              (provider as ShowRecreateProvider).commentaryItemBeans;
          for (var commentary in commentaryItemBeans) {
            final srtUrl = commentary.srtUrl;
            urls.add(srtUrl);
          }
        }
      } else {
        for (var ele in selectedMaterials) {
          final path = await ByAssetsUtil.filePathForAsset(ele);
          if (path.isNotEmpty) {
            final url = provider.srtMap[path] ?? "";
            if (url.isNotEmpty) {
              urls.add(url);
            } else {
              urls.add("");
            }
          } else {
            urls.add("");
          }
        }
      }
      final dowloadProvider = context.read<DownloadProvider>();
      final urlsDownload = urls.where((e) => e.isNotEmpty).toList();
      final srtFilesPaths = await dowloadProvider.downloadFiles(urlsDownload);
      byDebugPrint(srtFilesPaths, tag: "下载字幕文件:");
      final results = urls.map((e) {
        if (e.isEmpty) return e;
        final index = urlsDownload.indexOf(e);
        if (srtFilesPaths.length > index) {
          final srt = srtFilesPaths[index] ?? "";
          return srt;
        }
        return e;
      }).toList();
      return results;
    }

    return [];
  }
}

/// 组标题
_buildSectionTitle({
  required String title,
  Widget? rightWidget,
}) {
  return SliverToBoxAdapter(
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 10.h,
      ),
      child: Row(
        children: [
          ByWidgetsUtil.commonText(
            text: title,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
          const Spacer(),
          if (rightWidget != null) rightWidget
        ],
      ),
    ),
  );
}

/// 获取时长
getSrtTime(String filePath) {
  File file = File(filePath);
  if (!file.existsSync()) {
    return false;
  }
  var content = file.readAsStringSync();
  RegExp exp = RegExp(
      r'(\d{2}:\d{2}:\d{2}),(\d{3})\s+-->\s+(\d{2}:\d{2}:\d{2}),(\d{3})');
  Iterable<Match> matches = exp.allMatches(content);
  for (Match match in matches) {
    var endtime = match.group(3) ?? "";
    var endtimehm = match.group(4) ?? "";
    List<String> parts = endtime.split(":");
    double e = int.parse(parts[0]) * 3600 +
        int.parse(parts[1]) * 60 +
        int.parse(parts[2]) +
        int.parse(endtimehm) / 1000;
    return e;
  }
}

/// 九宫格
_buildSectionGride({
  required int crossAxisCount,
  required int? itemCount,
  required Widget Function(BuildContext, int) itemBuilder,
  double childAspectRatio = 1.0,
}) {
  return SliverPadding(
    padding: EdgeInsets.only(
      left: 12.w,
      right: 12.w,
      bottom: 10.h,
    ),
    sliver: SliverGrid.builder(
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: childAspectRatio),
      itemBuilder: (context, index) {
        return itemBuilder(context, index);
      },
    ),
  );
}
