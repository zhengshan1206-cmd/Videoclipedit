import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:svgaplayer_flutter_rhr/svgaplayer_flutter.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/guide_page.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/providers/video_extraction_provider.dart';
import 'package:video_clip_edit/widgets/common/right_navigation_bar.dart';

import '../../../modules/guid/providers/guide_pop_providers.dart';
import '../models/ai_video_square_model.dart';
import '_image_to_video_form.dart';
import '_text_to_video_form.dart';
import '_embrace_video_form.dart';

class NewAiVideoPage extends StatefulWidget {
  const NewAiVideoPage(
      {super.key,
      this.initType,
      this.prompt,
      this.negativePrompt,
      this.images,
      this.cfgScale,
      this.aspectRatio,
      this.duration,
      this.mode,
      this.pagePath= "",
      });

  final AiVideoGenerationType? initType;
  final String? prompt;
  final String? negativePrompt;
  final List<String>? images;
  final double? cfgScale;
  final String? aspectRatio;
  final int? duration;
  final String? mode;
  final String pagePath;


  @override
  State<NewAiVideoPage> createState() => _NewAiVideoPageState();
}

class _NewAiVideoPageState extends State<NewAiVideoPage>
    with SingleTickerProviderStateMixin {
  late AiVideoGenerationType generationType;
  late final _bgAnimationController = SVGAAnimationController(vsync: this);
  String textPrompt = "";
  String imagePrompt = "";

  @override
  void initState() {
    super.initState();
    textPrompt = widget.prompt ?? "";
    imagePrompt = widget.prompt ?? "";
    _loadBgAnimation();
    generationType = widget.initType ?? AiVideoGenerationType.textToVideo;
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    super.dispose();
  }

  void _loadBgAnimation() async {
    final videoItem =
        await SVGAParser.shared.decodeFromAssets("assets/ai/aiVideo/dtvbo.svga");

    ///防止离开当前页面后依然执行代码造成报错
    _bgAnimationController.videoItem = videoItem;
    _bgAnimationController
        .repeat()
        .whenComplete(() => _bgAnimationController.videoItem = null);
  }

  @override
  Widget build(BuildContext context) {


    log("===generationType==== ${widget.initType}");

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFE8EFF2),
      // appBar: AppBar(
      //   foregroundColor: Colors.white,
      //   backgroundColor: Colors.transparent,
      //   surfaceTintColor: Colors.transparent,
      //   elevation: 0,
      //   leading: GestureDetector(
      //     behavior: HitTestBehavior.opaque,
      //     onTap: () {
      //       ByNavRouterUtils.goBack(context);
      //     },
      //     child: Container(
      //       width: 30,
      //       height: 30,
      //       alignment: Alignment.center,
      //       child: Image.asset(
      //         "assets/home/icon_back.png",
      //         color: Colors.white,
      //         width: 16,
      //         height: 16,
      //       ),
      //     ),
      //   ),
      //   actions: [

      //     Center(
      //       child: Container(
      //         height: 30.h,
      //         margin: EdgeInsets.only(right: 12.w),
      //         child: ByWidgetsUtil.btnWithIcon(
      //           context: context,
      //           iconH: 12.w,
      //           iconW: 12.w,
      //           fontSize: 12.sp,
      //           title: "使用攻略",
      //           borderRadius: 100.w,
      //           padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10.w),
      //           bgColor: ByColorUtil.WhiteColor,
      //           iconPath: "assets/home/icon_strategy.png",
      //           textColor: ByColorUtil.CommonTextColor,
      //           onClick: () {
      //             ByNavRouterUtils.push(
      //                 context,
      //                 ChangeNotifierProvider(
      //                   create: (context) => VideoExtractionProvider(),
      //                   child: const GuidePage(),
      //                 ));
      //           },
      //         ),
      //       ),
      //     )

      //   ],
      // ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: generationType == AiVideoGenerationType.embraceVideo
                  ? Image.asset(
                      "assets/ai/aiVideo/embrace_banner.png",
                      fit: BoxFit.fitWidth,
                    )
                  : SVGAImage(
                      // background
                      _bgAnimationController,
                      fit: BoxFit.fitWidth,
                      clearsAfterStop: false,
                      allowDrawingOverflow: false,
                      preferredSize: Size(375.w, 240.h),
                    ),
            ),
            Positioned(
              top: 45.w,
                left: 17.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                  GestureDetector(
                    onTap: (){
                      Get.back();
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      child: Image.asset(
                        "assets/home/icon_back.png",
                        color: Colors.white,
                        width: 16,
                        height: 16,
                      ),
                    ),
                  ),
                  SizedBox(width:230.w ,),
                  //首页民间故事与工具箱里爆文创作是一样
                  //文生视频 ai_text_to_video，图生视频 ai_image_to_video 双图模式 拥抱视频 ai_embrace_video
                  //拥抱视频与文生视频、图生视频不在同一页面内，hasMultipilePage为true，图生视频未默认页面，故而hasMultipilePage为默认false
                  switch (generationType) {
                    AiVideoGenerationType.textToVideo =>
                      const RightNavigationBar(
                        entranceType: GuideEntranceType.aiTextToVideo,
                        hasMultipilePage: true,
                      ),
                    AiVideoGenerationType.imageToVideo =>
                      const RightNavigationBar(
                        entranceType: GuideEntranceType.aiImageToVideo,
                        hasMultipilePage: true,
                      ),
                    AiVideoGenerationType.embraceVideo =>
                      const RightNavigationBar(
                        entranceType: GuideEntranceType.aiEmbraceVideo,
                      ),

                    ///还不确定首尾帧与多图该往哪里跳
                    AiVideoGenerationType.firstAndEndFrame =>
                      throw UnimplementedError(),
                    AiVideoGenerationType.multipleImages =>
                      throw UnimplementedError(),
                  },
                  SizedBox(width: 17.w,)
            ],),
            
            ),
            _buildBody(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 150.w),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: _buildTabBar(),
          ),
          Expanded(
              child: switch (generationType) {
            AiVideoGenerationType.textToVideo => TextToVideoForm(
                prompt: textPrompt,
                negativePrompt: widget.negativePrompt,
                cfgScale: widget.cfgScale,
                aspectRatio: widget.aspectRatio,
                duration: widget.duration,
                mode: widget.mode,
                onChanged: (p0) {
                  textPrompt = p0;
                },
              ),
            AiVideoGenerationType.imageToVideo => ImageToVideoForm(
                prompt: imagePrompt,
                negativePrompt: widget.negativePrompt,
                image: (widget.images?.isNotEmpty ?? false)
                    ? widget.images!.first
                    : null,
                cfgScale: widget.cfgScale,
                aspectRatio: widget.aspectRatio,
                duration: widget.duration,
                mode: widget.mode,
                onChanged: (p0) {
                  imagePrompt = p0;
                },
              ),
            AiVideoGenerationType.embraceVideo => EmbraceVideoForm(
                prompt: widget.prompt,
                negativePrompt: widget.negativePrompt,
                images: widget.images,
                prePagePath: widget.pagePath,
              ),

            ///还不确定首尾帧与多图该往哪里跳
            AiVideoGenerationType.firstAndEndFrame =>
              throw UnimplementedError(),
            AiVideoGenerationType.multipleImages => throw UnimplementedError(),
          }),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    if (generationType == AiVideoGenerationType.embraceVideo) {
      return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                "穿越时空的拥抱",
                style: TextStyle(
                  color: const Color(0xFFFFD669),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 4.w),
              Image.asset("assets/ai/aiVideo/wave@2x.png", scale: 2),
            ],
          ));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(
                () => generationType = AiVideoGenerationType.textToVideo),
            child: Builder(builder: (context) {
              final isActive =
                  generationType == AiVideoGenerationType.textToVideo;
              return Column(
                children: [
                  Text(
                    "文生视频",
                    style: TextStyle(
                      color: isActive ? const Color(0xFFFFD669) : Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  if (isActive)
                    Image.asset("assets/ai/aiVideo/tab_underline@2x.png",
                        scale: 2),
                ],
              );
            }),
          ),
          SizedBox(width: 20.5.w),
          GestureDetector(
            onTap: () => setState(
                () => generationType = AiVideoGenerationType.imageToVideo),
            child: Builder(builder: (context) {
              final isActive =
                  generationType == AiVideoGenerationType.imageToVideo;
              return Column(
                children: [
                  Text(
                    "图生视频",
                    style: TextStyle(
                      color: isActive ? const Color(0xFFFFD669) : Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  if (isActive)
                    Image.asset("assets/ai/aiVideo/tab_underline@2x.png",
                        scale: 2),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  bool chekVip() {
    final isVip = context.read<LaunchProvider>().launchInfo?.isVip ?? 0;
    return isVip == 1;
    // if (isVip != 1) {
    //   context.read<PurchaseProvider>().loadVIPItems(
    //     onSuccess: () {
    //       showDialog(
    //         context: context,
    //         builder: (context) {
    //           return const DailogBonusLowestPrice();
    //         },
    //       );
    //     },
    //   );
    // }
  }

  /// **************************************** UI ****************************************
}
