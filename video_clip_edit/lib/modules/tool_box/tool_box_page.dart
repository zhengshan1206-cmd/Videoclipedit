import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/main/controllers/main_controller.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/providers/toolbox_provider.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/modules/home/widgets/banner_view.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/modules/home/widgets/main_funcs_view.dart';
import 'package:video_clip_edit/modules/tool_box/widgets/toolbox_cell.dart';

class ToolBoxPage extends StatefulWidget {
  const ToolBoxPage({super.key});

  @override
  State<ToolBoxPage> createState() => _ToolBoxPageState();
}

class _ToolBoxPageState extends State<ToolBoxPage> {
  late ToolBoxPageProvider provider;

  @override
  void initState() {
    super.initState();
    provider = context.read<ToolBoxPageProvider>();
    provider.loadMenuData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColorUtil.WhiteColor,
      body: Consumer<ToolBoxPageProvider>(
        builder: (
          BuildContext context,
          ToolBoxPageProvider provider,
          Widget? child,
        ) {
          return Column(
            children: [
              _buildAppBar(context),
              Expanded(
                  child: CustomScrollView(
                shrinkWrap: true,
                slivers: [
                  /// Banner + 主要功能
                  _buildBanner(context),

                  //短剧视频
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15.w, vertical: 15),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/toolbox/gjx_djysbxzq.png",
                            height: 16.h,
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),

                  _buildShortFilmsWidget(),

                  // //推文变现
                  // SliverToBoxAdapter(
                  //   child: Container(
                  //     margin: const EdgeInsets.only(
                  //         left: 15, right: 15, top: 20, bottom: 10),
                  //     child: Row(
                  //       children: [
                  //         Image.asset(
                  //           "assets/toolbox/ai_box_twbx.png",
                  //           height: 16.h,
                  //         ),
                  //         const Spacer(),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  //
                  // _buildMonetizeTweets(),

                  //AI成片变现专区
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 15, right: 15, top: 20, bottom: 10),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/toolbox/filmMonetizatioZone.png",
                            height: 16.h,
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),

                  _buildAIFilmMonetizatioZone(),

                  //变现辅助工具
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 15, right: 15, top: 20, bottom: 10),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/toolbox/monetizationAools.png",
                            height: 16.h,
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),

                  _buildMonetizationAools(),

                  // SliverToBoxAdapter(
                  //   child: Padding(
                  //     padding: EdgeInsets.symmetric(horizontal: 15.w,vertical: 15),
                  //     child: Row(
                  //       children: [
                  //         Image.asset(
                  //           "assets/toolbox/title_video.png",
                  //           width: 31.w,
                  //           height: 16.h,
                  //         ),
                  //         const Spacer(),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  //
                  // _buildMonetizeTweets(),
                  //
                  // _buildVideoTools(),
                  //
                  // SliverToBoxAdapter(
                  //   child: Padding(
                  //     padding: EdgeInsets.symmetric(horizontal: 15.w),
                  //     child: Row(
                  //       children: [
                  //         Image.asset(
                  //           "assets/toolbox/title_tools.png",
                  //           width: 47.w,
                  //           height: 16.h,
                  //         ),
                  //         const Spacer(),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  //
                  // _buildSmallTools(),
                  //
                  // SliverToBoxAdapter(
                  //   child: Padding(
                  //     padding: EdgeInsets.symmetric(horizontal: 15.w),
                  //     child: Row(
                  //       children: [
                  //         Image.asset(
                  //           "assets/toolbox/title_words.png",
                  //           width: 32.w,
                  //           height: 16.h,
                  //         ),
                  //         const Spacer(),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  //
                  // _buildWordTools(),
                ],
              ))
            ],
          );
        },
      ),
    );
  }

  _buildAppBar(BuildContext context) {
    return Container(
      height: ByScreenUtils.navigationBarHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: AssetImage("assets/ai/ai_app_bar_bg.png"),
          fit: BoxFit.fill,
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        // AppBar 背景透明
        elevation: 0,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            final mainController = Get.find<MainController>();
            mainController.tabChanged(mainController.tabBarPages.length - 1);
          },
          child: Center(
            child: Image.asset(
              "assets/ai/ai_app_bar_avarta.png",
              width: 32,
              height: 32,
            ),
          ),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/ai/aigongjuxiang.png",
              height: 17,
              fit: BoxFit.fitHeight,
            ),
            // const SizedBox(height: 3),
            // Container(
            //   padding: const EdgeInsets.symmetric(
            //     horizontal: 6,
            //     vertical: 3,
            //   ),
            //   decoration: BoxDecoration(
            //     border: Border.all(
            //       color: ByColorUtil.CommonTextColor.withOpacity(0.4),
            //       width: 0.5,
            //     ),
            //     borderRadius: BorderRadius.circular(20),
            //   ),
            //   child: ByWidgetsUtil.commonText(
            //     text: context.select<AiSquareProvider, String>(
            //         (p) => p.finishedPeopleNum),
            //     textColor: ByColorUtil.CommonTextColor.withOpacity(0.4),
            //     fontSize: 10.sp,
            //   ),
            // )
          ],
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              context.read<LaunchProvider>().gotoPay(context, closePay: true);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Image.asset(
                "assets/home/home_vip.png",
                width: 30.w,
                height: 30.w,
              ),
            ),
          )
        ],
      ),
    );
  }

  _buildShortFilmsWidget() {
    return SliverToBoxAdapter(
      child: MainFuncsView(
        functions: [
          MainFunctionBean(url: "assets/toolbox/new_main_func_1.png"),
          MainFunctionBean(url: "assets/toolbox/main_func_0.png"),
          MainFunctionBean(url: "assets/toolbox/main_func_3.png"),
        ],
      ),
    );
  }

  //推文变现
  _buildMonetizeTweets() {
    final beans = [
      ToolboxCellBean(
          icon: "assets/toolbox/ai_box_znhj.png",
          title: ToolboxCell.aiBoxSmart,
          desc: ToolboxCell.aiBoxSmart,
          type: CellType.blue),
      ToolboxCellBean(
          icon: "assets/toolbox/ai_box_mjgs.png",
          title: ToolboxCell.aiBoxFolkTales,
          desc: ToolboxCell.aiBoxFolkTales,
          type: CellType.blue),
      ToolboxCellBean(
          icon: "assets/toolbox/ai_box_ethb.png",
          title: ToolboxCell.aiBoxHildrenPictureBooks,
          desc: ToolboxCell.aiBoxHildrenPictureBooks,
          type: CellType.green),
      ToolboxCellBean(
          icon: "assets/toolbox/ai_box_kbgs.png",
          title: ToolboxCell.aiBoxHorrorStories,
          desc: ToolboxCell.aiBoxHorrorStories,
          type: CellType.blue),
    ];
    return _buildTools(beans, true);
  }

  //变现辅助工具
  _buildMonetizationAools() {
    final beans = [
      ToolboxCellBean(
          icon: "assets/toolbox/aiBoxImgWatermark.png",
          title: ToolboxCell.aiBoxImgWatermark,
          desc: ToolboxCell.aiBoxImgWatermark,
          type: CellType.blue),
      ToolboxCellBean(
          icon: "assets/toolbox/aiBoxImgWatermark.png",
          title: ToolboxCell.aiBoxVideoWatermark,
          desc: ToolboxCell.aiBoxVideoWatermark,
          type: CellType.blue),
      ToolboxCellBean(
          icon: "assets/toolbox/aibox_new_yjtq.png",
          title: ToolboxCell.aiBoxVideoExtraction,
          desc: ToolboxCell.aiBoxVideoExtraction,
          type: CellType.blue),
      ToolboxCellBean(
          icon: "assets/toolbox/aiBoxBannedWordFiltering.png",
          title: ToolboxCell.aiBoxBannedWordFiltering,
          desc: ToolboxCell.aiBoxBannedWordFiltering,
          type: CellType.green),
      ToolboxCellBean(
          icon: "assets/toolbox/aiBoxMd5Modification.png",
          title: ToolboxCell.aiBoxMd5Modification,
          desc: ToolboxCell.aiBoxMd5Modification,
          type: CellType.blue),
      ToolboxCellBean(
          icon: "assets/toolbox/aiBoxTxtExtraction.png",
          title: ToolboxCell.aiBoxTxtExtraction,
          desc: ToolboxCell.aiBoxTxtExtraction,
          type: CellType.green),
      ToolboxCellBean(
          icon: "assets/toolbox/aiNovel.png",
          title: ToolboxCell.aiNovel,
          desc: ToolboxCell.aiNovel,
          type: CellType.green),
      ToolboxCellBean(
          icon: "assets/toolbox/aiBoxImgWatermark.png",
          title: ToolboxCell.aiBoxOldPhotoFix,
          desc: ToolboxCell.aiBoxOldPhotoFix,
          type: CellType.green),
      ToolboxCellBean(
          icon: "assets/toolbox/aiBoxImgWatermark.png",
          title: ToolboxCell.aiBoxHdPhotoFix,
          desc: ToolboxCell.aiBoxHdPhotoFix,
          type: CellType.green),
    ];
    return _buildTools(beans, true);
  }

  //AI成片变现专区
  _buildAIFilmMonetizatioZone() {
    final beans = [
      // ToolboxCellBean(
      //     icon: "assets/toolbox/aiBoxWorkingCatSeries.png",
      //     title: ToolboxCell.aiBoxWorkingCatSeries,
      //     desc: ToolboxCell.aiBoxWorkingCatSeries,
      //     type: CellType.green),
      // ToolboxCellBean(
      //     icon: "assets/toolbox/aiBoxFigureVideo.png",
      //     title: ToolboxCell.aiBoxDynamicScenery,
      //     desc: ToolboxCell.aiBoxDynamicScenery,
      //     type: CellType.blue),
      ToolboxCellBean(
          icon: "assets/toolbox/ai_box_aitw.png",
          title: ToolboxCell.aiBoxCmicTweets,
          desc: ToolboxCell.aiBoxCmicTweets,
          type: CellType.blue),
      ToolboxCellBean(
          icon: "assets/toolbox/ai_box_xxs.png",
          title: ToolboxCell.aiBoxaiCmicTweets,
          desc: ToolboxCell.aiBoxaiCmicTweets,
          type: CellType.green),
      ToolboxCellBean(
          icon: "assets/toolbox/aibox_aiht.png",
          title: ToolboxCell.aiBoxImageErase,
          desc: ToolboxCell.aiBoxImageErase,
          type: CellType.green),
      ToolboxCellBean(
          icon: "assets/toolbox/aibox_new_aixg.png",
          title: ToolboxCell.aiBoxAISongwriting,
          desc: ToolboxCell.aiBoxAISongwriting,
          type: CellType.green),
      ToolboxCellBean(
          icon: "assets/toolbox/ai_box_aitw.png",
          title: ToolboxCell.aiBoxCmicClip,
          desc: ToolboxCell.aiBoxCmicClip,
          type: CellType.green),
      ToolboxCellBean(
          icon: "assets/toolbox/ai_box_aitw.png",
          title: ToolboxCell.aiOralVideos,
          desc: ToolboxCell.aiOralVideos,
          type: CellType.green),
      ToolboxCellBean(
          icon: "assets/toolbox/aiBoxVincentVideo.png",
          title: ToolboxCell.aiTextToVideo,
          desc: ToolboxCell.aiTextToVideo,
          type: CellType.green),
      ToolboxCellBean(
          icon: "assets/toolbox/aiBoxFigureVideo.png",
          title: ToolboxCell.aiImageToVideo,
          desc: ToolboxCell.aiImageToVideo,
          type: CellType.green),
      ToolboxCellBean(
          icon: "assets/toolbox/aiBoxTimeEmbrace.png",
          title: ToolboxCell.aiBoxTimeEmbrace,
          desc: ToolboxCell.aiBoxTimeEmbrace,
          type: CellType.blue),
    ];
    return _buildTools(beans, false);
  }

  _buildVideoTools() {
    final beans = [
      ToolboxCellBean(
          icon: "assets/toolbox/icon_video_edit.png",
          title: "视频混剪",
          desc: "视频混剪",
          type: CellType.blue),
      ToolboxCellBean(
          icon: "assets/toolbox/icon_video_recreate.png",
          title: "影视二创",
          desc: "影视二创",
          type: CellType.blue),
      ToolboxCellBean(
          icon: "assets/toolbox/video_auth.png",
          title: "短剧授权",
          desc: "短剧授权",
          type: CellType.blue),
      ToolboxCellBean(
          icon: "assets/toolbox/icon_video_clip.png",
          title: "视频剪辑",
          desc: "视频剪辑",
          type: CellType.green),
    ];
    return _buildTools(beans, true);
  }

  _buildSmallTools() {
    final beans = [
      // ToolboxCellBean(
      //     icon: "assets/toolbox/icon_water_mark.png",
      //     title: "图片去水印",
      //     desc: "图片去水印",
      //     type: CellType.green),
      // ToolboxCellBean(
      //     icon: "assets/toolbox/icon_water_mark.png",
      //     title: "视频去水印",
      //     desc: "视频去水印",
      //     type: CellType.green),
      // ToolboxCellBean(
      //     icon: "assets/toolbox/icon_video_split.png",
      //     title: "视频拆分",
      //     desc: "视频拆分",
      //     type: CellType.blue),
      ToolboxCellBean(
          icon: "assets/toolbox/icon_video_synthesis.png",
          title: "视频合成",
          desc: "视频合成",
          type: CellType.blue),
      // ToolboxCellBean(
      //     icon: "assets/toolbox/icon_image_erase.png",
      //     title: "图片擦除",
      //     desc: "图片擦除",
      //     type: CellType.green),
      ToolboxCellBean(
          icon: "assets/toolbox/icon_video_erase.png",
          title: "视频擦除",
          desc: "视频擦除",
          type: CellType.blue),
      ToolboxCellBean(
          icon: "assets/toolbox/icon_extract.png",
          title: "一键提取",
          desc: "一键提取",
          type: CellType.blue),
      ToolboxCellBean(
          icon: "assets/toolbox/icon_video_deduplication.png",
          title: "视频去重",
          desc: "视频去重",
          type: CellType.green),
      // ToolboxCellBean(
      //     icon: "assets/toolbox/icon_remove_subtitles.png",
      //     title: "去除字幕",
      //     desc: "去除字幕",
      //     type: CellType.blue),
    ];
    return _buildTools(beans, true);
  }

  _buildWordTools() {
    final beans = [
      ToolboxCellBean(
          icon: "assets/toolbox/icon_banned_words_detection.png",
          title: "违禁词检测",
          desc: "违禁词检测",
          type: CellType.green),
      ToolboxCellBean(
          icon: "assets/toolbox/icon_copywriting_extraction.png",
          title: "文案提取",
          desc: "文案提取",
          type: CellType.green),
      ToolboxCellBean(
          icon: "assets/toolbox/icon_story_create.png",
          title: "故事创作",
          desc: "故事创作",
          type: CellType.green),
      ToolboxCellBean(
          icon: "assets/ai/aixiege.png",
          title: "AI写歌",
          desc: "AI写歌",
          type: CellType.green),
    ];
    return _buildTools(beans, false);
  }

  _buildTools(
    List<ToolboxCellBean> beans,
    bool checkPermissions,
  ) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 170 / 60,
          mainAxisSpacing: 10,
          crossAxisSpacing: 11,
        ),
        itemCount: beans.length,
        itemBuilder: (context, index) {
          final bean = beans[index];
          return ToolboxCell(
            cellBean: bean,
          );
        },
      ),
    );
  }

  _buildBanner(BuildContext context) {
    List<String> menuItemBeansImgs =
        context.select<ToolBoxPageProvider, List<String>>((provider) {
      return provider.menuItemBeansImgs;
    });

    return SliverPadding(
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 4.h,
      ),
      sliver: SliverToBoxAdapter(
        child: Stack(
          children: [
            /// banner
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 140.h,
              child: GestureDetector(
                onTap: () {
                  context.read<LaunchProvider>().gotoPay(
                        context,
                        closePay: true,
                      );
                },
                child: BannerView(
                  fit: BoxFit.fill,
                  urls: menuItemBeansImgs,
                  onTap: (index) {
                    SubFunction? item = provider.menuItemBeans?[index];
                    if (item != null) {
                      ByCommonUtils.subFunctionCase(context, item);
                    }
                    // if (isVip) {
                    //   RouteUtils.gotoPage(context, "/guide");
                    // } else {
                    //   context
                    //       .read<LaunchProvider>()
                    //       .gotoPay(context, closePay: true, replace: false);
                    // }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // return SliverPadding(
    //   padding: EdgeInsets.only(
    //     left: 12.w,
    //     right: 12.w,
    //     top: 4.h,
    //   ),
    //   sliver: SliverToBoxAdapter(
    //     child: SizedBox(
    //       height: 128.h,
    //       child: Row(
    //         children: [
    //           _buildFunctionItem(
    //             imgPath: "assets/ai/ai_square_vip.png",
    //             ontap: () {},
    //             fit: BoxFit.fitHeight,
    //           ),
    //           SizedBox(width: 8.w),
    //           Expanded(
    //             child: Column(children: [
    //               Expanded(
    //                 child: _buildFunctionItem(
    //                   imgPath: "assets/ai/ai_square_tweets_auth.png",
    //                   ontap: () {
    //                     ByNavRouterUtils.jumpWebViewPage(
    //                       context,
    //                       "小说授权",
    //                       "https://xiaoguofanxing.lizhibj.cn/h5/?token=874ef8bac6b77a22631bc67dbbc30cda&channel_id=29",
    //                     );
    //                   },
    //                   fit: BoxFit.fill,
    //                 ),
    //               ),
    //               SizedBox(height: 8.h),
    //               Expanded(
    //                 child: _buildFunctionItem(
    //                   imgPath: "assets/ai/ai_square_cash.png",
    //                   ontap: () {},
    //                   fit: BoxFit.fill,
    //                 ),
    //               ),
    //             ]),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
