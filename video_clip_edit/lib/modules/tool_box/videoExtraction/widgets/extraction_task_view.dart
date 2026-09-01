import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/common/widget/common_dialog.dart';
import 'package:video_clip_edit/modules/tool_box/beans/extraction_record_bean.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/providers/video_extraction_provider.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/video_extraction_detail_page.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_datetime_ext.dart';
import 'package:video_clip_edit/utils/comon/by_download_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class ExtractionTaskView extends StatefulWidget {
  final ExtractionRecordBean myWorkBean;
  const ExtractionTaskView({
    super.key,
    required this.myWorkBean,
  });

  @override
  State<ExtractionTaskView> createState() => _ExtractionTaskViewState();
}

class _ExtractionTaskViewState extends State<ExtractionTaskView> {
  bool fileExists = true;

  @override
  void initState() {
    super.initState();

    _checkVideoExists();
  }

  @override
  Widget build(BuildContext context) {
    final coverUrl = widget.myWorkBean.content?.coverUrl ?? "";
    return GestureDetector(
      onTap: () {
        if (!fileExists) {
          BotToast.showText(text: "视频不存在");
          return;
        }
        // 上报点击埋点
        ByNavigatorUtil.reportDataPoint(
          pageTag: "myworks_list_video_extraction_works",
          operateType: "click",
          funcDetailTag: widget.myWorkBean.id?.toString() ?? "",
          funcDetailImg: coverUrl,
        );
        ByNavRouterUtils.push(
            context,
            ChangeNotifierProvider.value(
              value: context.read<VideoExtractionProvider>(),
              child: VideoExtractionDetailsPage(
                fileName: widget.myWorkBean.shareUrlMd5,
              ),
            ));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.w),
        child: Stack(
          children: [
            Positioned.fill(
              child: coverUrl.isEmpty
                  ? Container()
                  : CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: coverUrl,
                    ),
            ),
            Positioned.fill(
              child: Offstage(
                offstage: fileExists,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/mine/work_failed_bg.png"),
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      width: 82.w,
                      height: 82.w,
                      fit: BoxFit.contain,
                      "assets/mine/work_failed.png",
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Offstage(
                offstage: true,
                child: Container(
                  alignment: Alignment.center,
                  color: ByColorUtil.WhiteColor.withOpacity(0.5),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 90.w,
                      height: 32.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: ByColorUtil.LoginBtnBgColor,
                      ),
                      child: Text(
                        "继续编辑",
                        style: TextStyle(
                          color: ByColorUtil.WhiteColor,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Offstage(
                offstage: !fileExists,
                child: Container(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 40.w,
                    height: 40.h,
                    child: Image.asset("assets/home/icon_audio_play.png"),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10.w,
              bottom: 5.w,
              child: Text(
                widget.myWorkBean.createAt.formattedTime(),
                style: TextStyle(
                  color: ByColorUtil.WhiteColor,
                  fontSize: 12.sp,
                ),
              ),
            ),
            Positioned.fill(
              child: Offstage(
                offstage: true,
                child: Container(
                  color: const Color(0xFFE6E9EB),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoActivityIndicator(
                        color: const Color(0xFF0E1840),
                        radius: 16.w,
                      ),
                      SizedBox(height: 30.h),
                      ByWidgetsUtil.commonText(
                          text: "去重中...",
                          textColor:
                              ByColorUtil.CommonTextColor.withOpacity(0.5))
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 5.w,
              top: 5.h,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
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
                              context.read<VideoExtractionProvider>();
                          provider.removeRecord(
                            ids: [widget.myWorkBean.id.toString()],
                            onSuccess: () {
                              provider.loadParseRecords(refresh: true);
                            },
                          );
                        },
                      );
                    },
                  );
                },
                child: Container(
                  alignment: Alignment.topRight,
                  width: 35.w,
                  height: 35.h,
                  child: Image.asset(
                    "assets/purchase/dailog_bonus_close.png",
                    width: 20.w,
                    height: 20.h,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _checkVideoExists() async {
    final fileName = "${widget.myWorkBean.shareUrlMd5}.mp4";
    final fileCachePath =
        await ByDownloadUtil.videoCachePathFromFileName(fileName);
    final fileCache = File(fileCachePath);
    final exists = await fileCache.exists();
    if (!exists) {
      setState(() {
        fileExists = false;
      });
      return false;
    }
    return true;
  }
}
