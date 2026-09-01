import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_permission_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_download_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/widgets/banner_view.dart';
import 'package:video_clip_edit/modules/tool_box/beans/link_extraction_bean.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/guide_page.dart';
import 'package:video_clip_edit/modules/download/providers/download_provider.dart';
import 'package:video_clip_edit/modules/tool_box/beans/extraction_record_bean.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/video_downloading_page.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/widgets/extraction_task_view.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/extraction_recent_tasks_page.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/providers/video_extraction_provider.dart';
import 'package:video_clip_edit/widgets/pan_to_unfocus.dart';
import 'package:video_clip_edit/widgets/physical_wrapper.dart';
import 'package:video_clip_edit/widgets/pop_scope_widget.dart';

class VideoExtractionPage extends StatefulWidget {
  const VideoExtractionPage({super.key});

  @override
  State<VideoExtractionPage> createState() => _VideoExtractionPageState();
}

class _VideoExtractionPageState extends State<VideoExtractionPage> {
  final TextEditingController linkController = TextEditingController();

  /// 是否正在解析视频链接
  bool parsing = false;
  String _platforms = "";

  final ScrollController _scrollController = ScrollController();
  final double maxInset = 180.h;
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlatforms();

      _loadRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScopeWidget(
      canPop:parsing == false? true:false,
      contents: "现在返回将中断提取，是否继续退出?",
      confirmBtnTitle: "退出",
      whiteList: () => parsing == false,
      child: Scaffold(
        backgroundColor: ByColorUtil.CommonPageBgColor,
        body: PanToUnfocus(
          child: Stack(
            children: [
              /// banner
              _buildBannerBg(context),

              _buildBanner(context),

              // _buildCover(context),

              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: 200.h)),

                  /// 输入框
                  _buildInputArea(context),

                  /// 提取按钮
                  _buildBtn(context),

                  SliverToBoxAdapter(
                    child: SizedBox(height: 20.h),
                  ),

                  SliverToBoxAdapter(
                      child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: ByWidgetsUtil.commonText(
                        text: "温馨提示：", fontSize: 14.sp),
                  )),

                  SliverToBoxAdapter(child: SizedBox(height: 10.h)),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: ByWidgetsUtil.commonText(
                        text: _platforms,
                        fontSize: 12.sp,
                        textColor: ByColorUtil.CommonTextColor.withOpacity(0.6),
                      ),
                    ),
                  ),

                  /// 最近任务header
                  _buildRecentTasksHeader(context),

                  /// 最近任务
                  _buildRecentTasks(context),

                  /// 底部安全距离
                  SliverToBoxAdapter(
                      child: SizedBox(
                          height: ByScreenUtils.bottomSafeHeight + 10.h)),
                ],
              ),

              /// APP Bar
              Positioned(child: _buildAppBar(context)),
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildBtn(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        child: ByWidgetsUtil.commonBtn(
          title: "一键提取",
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          borderRadius: 12.w,
          onClick: () async {
            FocusScope.of(context).unfocus();
            final status = await ByPermissionUtils.videos();
            if (!status) return;
            final url = linkController.text;
            if (url.isEmpty) {
              BotToast.showText(text: "请输入视频链接");
              return;
            }
            parsing = true;
            ByDownloadUtil.parseShareUrl(
              url,
              onSuccess: (data) {
                parsing = false;
                LinkExtractionBean bean = LinkExtractionBean.fromJson(data);
                // 跳转至视频下载页面
                byDebugPrint(bean.videoUrl, tag: "视频下载地址：");
                if (bean.videoUrl.isEmpty) {
                  BotToast.showText(text: "获取视频链接失败，请重试");
                  return;
                }
                Future.delayed(const Duration(milliseconds: 500), () {
                  _loadRecords();
                });
                ByNavRouterUtils.push(
                  context,
                  MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(
                          value: context.read<VideoExtractionProvider>()),
                      ChangeNotifierProvider(
                          create: (context) => DownloadProvider()),
                    ],
                    child: VideoDownloadingPage(
                      videoUrl: bean.videoUrl,
                      md5Source: url,
                    ),
                  ),
                );
              },
              onFailed: () {
                parsing = false;
              },
            );
          },
        ),
      ),
    );
  }

  _buildBannerBg(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      width: MediaQuery.of(context).size.width,
      height: 200.h,
      child: Image.asset(
        "assets/toolbox/banner_video_extraction.png",
        fit: BoxFit.cover,
      ),
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
        child: BannerView(
          urls: const ["assets/toolbox/banner_video_extraction.svga"],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return PhysicalWrapper(
      opacity: opacity,
      child: Container(
        color: ByColorUtil.WhiteColor.withOpacity(1 - opacity),
        height: statusBarHeight + 44,
        padding: EdgeInsets.only(left: 12.w, right: 12.w, top: statusBarHeight),
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                final navigator = Navigator.of(context);
                if (parsing) return;

                /// 没有在解析，直接返回
                navigator.pop();
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


            SizedBox(
              height: 30.h,
              child: ByWidgetsUtil.btnWithIcon(
                iconH: 12.w,
                iconW: 12.w,
                fontSize: 12.sp,
                title: "使用攻略",
                borderRadius: 100.w,
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10.w),
                bgColor: ByColorUtil.WhiteColor,
                iconPath: "assets/home/icon_strategy.png",
                textColor: ByColorUtil.CommonTextColor,
                onClick: () {
                  ByNavRouterUtils.push(
                      context,
                      ChangeNotifierProvider.value(
                        value: context.read<VideoExtractionProvider>(),
                        child: const GuidePage(),
                      ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 输入框
  _buildInputArea(BuildContext context) {
    return SliverToBoxAdapter(
        child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Stack(
        children: [
          Container(
            height: 200.h,
            decoration: BoxDecoration(
                color: ByColorUtil.WhiteColor,
                borderRadius: BorderRadius.circular(12.w),
                border: Border.all(color: const Color(0xffecedf2), width: 1)),
          ),
          _buildTextArea(context, linkController),
          Positioned(
            bottom: 15.h,
            right: 12.w,
            child: Row(
              children: [
                Image.asset(
                  "assets/toolbox/icon_link.png",
                  width: 10.w,
                  height: 10.h,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 5.w),
                GestureDetector(
                  onTap: () async {
                    ClipboardData? data = await Clipboard.getData('text/plain');
                    linkController.text = data?.text ?? "";
                  },
                  child: ByWidgetsUtil.commonText(
                    text: "粘贴链接",
                    fontSize: 14.sp,
                  ),
                ),
                Container(
                  height: 29.h,
                  alignment: Alignment.center,
                  child: ByWidgetsUtil.commonText(
                    text: "  |  ",
                    fontSize: 12.sp,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    linkController.text = "";
                  },
                  child: ByWidgetsUtil.commonText(
                    text: "清空",
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ));
  }

  /// 输入框
  Positioned _buildTextArea(
    BuildContext context,
    TextEditingController controller,
  ) {
    return ByWidgetsUtil.positionedFillTextArea(
      context,
      controller,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0.h),
      hintText: "输入、粘贴视频分享链接",
    );
  }

  /// 最近任务
  _buildRecentTasks(BuildContext context) {
    final provider = context.watch<VideoExtractionProvider>();
    final List<ExtractionRecordBean> extractionRecordBeans =
        provider.extractionRecordBeans.length > 10
            ? provider.extractionRecordBeans.sublist(0, 10)
            : provider.extractionRecordBeans;
    return SliverToBoxAdapter(
      child: extractionRecordBeans.isEmpty
          ? Container()
          : Container(
              padding: EdgeInsets.only(top: 15.h, bottom: 15.h),
              color: ByColorUtil.WhiteColor,
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                shrinkWrap: true,
                itemCount: extractionRecordBeans.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ExtractionTaskView(
                    myWorkBean: extractionRecordBeans[index],
                  );
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                ),
              ),
            ),
    );
  }

  /// 最近任务header
  _buildRecentTasksHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: context
              .watch<VideoExtractionProvider>()
              .extractionRecordBeans
              .isEmpty
          ? Container()
          : Container(
              margin: EdgeInsets.only(top: 15.h),
              padding: EdgeInsets.only(top: 15.h, left: 12.w, right: 12.w),
              decoration: BoxDecoration(
                color: ByColorUtil.WhiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.w),
                  topRight: Radius.circular(18.w),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    height: 30.h,
                    child: ByWidgetsUtil.btnWithIcon(
                      iconH: 15.w,
                      iconW: 15.w,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      title: "最近任务",
                      borderRadius: 100.w,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 0.h),
                      bgColor: ByColorUtil.WhiteColor,
                      iconPath: "assets/home/icon_strategy.png",
                      textColor: ByColorUtil.CommonTextColor,
                      onClick: () {},
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      ByNavRouterUtils.push(
                          context,
                          ChangeNotifierProvider.value(
                            value: context.read<VideoExtractionProvider>(),
                            child: const ExtractionRecentTasksPage(),
                          ));
                    },
                    child: ByWidgetsUtil.commonText(
                      text: "更多",
                      fontSize: 14.sp,
                      textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Image.asset(
                    "assets/mine/arrow_right.png",
                    width: 8.w,
                    height: 13.w,
                  )
                ],
              ),
            ),
    );
  }

  void _loadRecords() {
    final provider = context.read<VideoExtractionProvider>();
    provider.loadParseRecords();
  }

  void _loadPlatforms() {
    context.read<VideoExtractionProvider>().loadSurpportedPlatforms(
          onSuccess: (plat) {
            if (mounted) {
              setState(() {
                _platforms = plat;
              });
            }
          },
          onFailed: () {},
        );
  }
}
/**
 canPop: false,
      onPopInvoked: (value) async {
        if (value) return;
        final navigator = Navigator.of(context);
        if (parsing == false) {
          /// 没有在解析，直接返回
          navigator.pop();
          return;
        }
        final bool res = await showDialog(
          context: context,
          builder: (ctx) {
            return const CommonDialog(
              reverse: false,
              maxLine: 10,
              contents: "现在返回将中断提取，是否继续退出?",
              confirmBtnTitle: "退出",
            );
          },
        );

        if (res) {
          navigator.pop();
        }
      },
 */
