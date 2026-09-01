import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/modules/home/providers/words_extract_provider.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/modules/profile/beans/mine_legalright_bean.dart';
import 'package:video_clip_edit/modules/profile/mine_video_materials_management_page.dart';
import 'package:video_clip_edit/modules/profile/mine_videos_management_page.dart';
import 'package:video_clip_edit/modules/profile/mine_words_management_page.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_scores_provider.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_video_materials_management_provider.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_videos_management_provider.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_words_management_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/providers/settings_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_storage_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/profile/settings_page.dart';
import 'package:video_clip_edit/providers/mine_page_provider.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/profile/beans/user_info_bean.dart';
import 'package:video_clip_edit/modules/profile/widgets/mine_heaeder.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/guide_page.dart';
import 'package:video_clip_edit/modules/profile/beans/mine_works_count_item_bean.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/providers/video_extraction_provider.dart';
import 'package:video_clip_edit/utils/consts/const_keys.dart';
import 'package:video_clip_edit/v2/aiOralVideos/ai_oral_my_dubbing_list_page.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_videos_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/ai_draw_management_page.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_work_management_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/song/ai_song_tasks_page.dart';
import 'package:video_clip_edit/v2/aiSquare/song/provider/ai_song_tasks_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/writing/provider/ai_writing_provider.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  UserController get userController => Get.find<UserController>();

  UserInfoBean? get userInfo => userController.user.value;

  @override
  void initState() {
    super.initState();
    _loadPageData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColorUtil.WhiteColor,
      body: Consumer<MinePageProvider>(
        builder:
            (BuildContext context, MinePageProvider provider, Widget? child) {
          return Stack(
            children: [
              Container(
                color: ByColorUtil.WhiteColor,
                width: double.infinity,
                height: 350.h,
              ),
              CustomScrollView(
                slivers: [
                  ExtendedSliverAppbar(
                    onBuild: (context, shrinkOffset, minExtent, maxExtent,
                        overlapsContent) {},
                    leading: Container(),
                    toolBarColor: ByColorUtil.WhiteColor,
                    // title: _buidLeadingWidget(context),
                    mainAxisAlignment: MainAxisAlignment.start,
                    background: Column(
                      children: [
                        const MinePageHeader(),
                        _mineFunctionsView(context),
                        _buildMineLegalright(context),
                      ],
                    ),
                  ),

                  // _buildMineLegalright(context),
                  _buildListHeader(context),
                  _buildWorkList(context),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      child: Row(
                        children: [
                          const Spacer(),
                          ByWidgetsUtil.commonText(
                            fontSize: 12.sp,
                            text:
                                "版本号:${ByStorageUtils.getString(ConstKeys.kAppVersion) ?? "5.0.0"}",
                            fontWeight: FontWeight.normal,
                            textColor:
                                ByColorUtil.CommonTextColor.withOpacity(0.5),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                  // if (provider.hasWorks) _buildWorkList(context),
                  // if (!provider.hasWorks) _buildNoContents(context),
                ],
              ),
              _buildSettingBtn(context)
            ],
          );
        },
      ),
    );
  }

  Positioned _buildSettingBtn(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      right: 0.w,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ByNavRouterUtils.jumpWebViewPage(
                context,
                "在线客服",
                userInfo?.kfUrl ?? "",
              );
            },
            child: Container(
              width: 30.w,
              height: kToolbarHeight,
              alignment: Alignment.centerRight,
              child: ByWidgetsUtil.imageBtn(
                image: "assets/mine/mine_customer.png",
                width: 30.w,
                height: 30.w,
                imageWidth: 16.w,
                imageHeight: 16.w,
                onClick: () {},
              ),
            ),
          ),
          SizedBox(width: 7.w),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ByNavRouterUtils.push(
                context,
                ChangeNotifierProvider<SettingsProvider>(
                  create: (context) => SettingsProvider(),
                  child: const SettingsPage(),
                ),
              );
            },
            child: Container(
              width: 30.w,
              height: kToolbarHeight,
              alignment: Alignment.center,
              child: ByWidgetsUtil.imageBtn(
                image: "assets/mine/mine_settings.png",
                width: 30.w,
                height: 30.w,
                imageWidth: 16.w,
                imageHeight: 16.w,
                onClick: () {},
              ),
            ),
          ),
          SizedBox(width: 12.w),
        ],
      ),
    );
  }

  SliverPinnedToBoxAdapter _buildListHeader(BuildContext context) {
    return SliverPinnedToBoxAdapter(
      child: Container(
        color: ByColorUtil.CommonPageBgColor,
        child: Container(
          padding:
              EdgeInsets.only(left: 15.w, right: 15.w, top: 14.h, bottom: 14.h),
          margin: EdgeInsets.only(top: 5.h),
          decoration: BoxDecoration(
            color: ByColorUtil.WhiteColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14.w),
              topRight: Radius.circular(14.w),
            ),
          ),
          child: Row(
            children: [
              Image.asset(
                "assets/mine/mine_works.png",
                width: 18.w,
                height: 18.w,
              ),
              SizedBox(width: 5.w),
              Text(
                "我的创作",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: ByColorUtil.CommonTextColor,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mineFunctionsView(BuildContext context) {
    return Container(
      color: ByColorUtil.CommonPageBgColor,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 10.h,
        ),
        decoration: BoxDecoration(
          color: ByColorUtil.CommonPageBgColor,
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                ByNavRouterUtils.push(
                    context,
                    ChangeNotifierProvider(
                      create: (context) => VideoExtractionProvider(),
                      child: const GuidePage(),
                    ));
              },
              child: SizedBox(
                width: 193.w,
                height: 128.h,
                child: Image.asset(
                  "assets/mine/mine_functons_tutor.png",
                  fit: BoxFit.fill,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: SizedBox(
                height: 128.h,
                child: Column(
                  children: [
                    Expanded(
                        child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        ByNavRouterUtils.jumpWebViewPage(
                          context,
                          "在线客服",
                          userInfo?.kfUrl ?? "",
                        );
                      },
                      child: ByWidgetsUtil.commonContainer(
                          bgColor: const Color(0xFFF0F1FB),
                          borerRadius: 8.w,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 14.h),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: Image.asset(
                                  "assets/mine/mine_functons_custom_icon.png",
                                  fit: BoxFit.fill,
                                ),
                              ),
                              SizedBox(width: 7.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      "assets/mine/mine_functons_custom_title.png",
                                      height: 14,
                                      fit: BoxFit.fitHeight,
                                    ),
                                    const Spacer(),
                                    ByWidgetsUtil.commonText(
                                      text: "专属客服一对一",
                                      fontSize: 10,
                                      textColor: const Color(0xFF5D5DDC),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    )),
                    SizedBox(height: 8.h),
                    Expanded(
                        child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        ByNavRouterUtils.jumpWebViewPage(
                          context,
                          "投诉建议",
                          userInfo?.complaintUrl ?? "",
                        );
                      },
                      child: ByWidgetsUtil.commonContainer(
                          bgColor: const Color(0xFFF9ECF2),
                          borerRadius: 8.w,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 14.h),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: Image.asset(
                                  "assets/mine/mine_functons_ts_icon.png",
                                  fit: BoxFit.fill,
                                ),
                              ),
                              SizedBox(width: 7.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      "assets/mine/mine_functons_ts_title.png",
                                      height: 14,
                                      fit: BoxFit.fitHeight,
                                    ),
                                    const Spacer(),
                                    ByWidgetsUtil.commonText(
                                      text: "反馈您的意见",
                                      fontSize: 10,
                                      textColor: const Color(0xFFCA4975),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    )),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _buidLeadingWidget(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 12.w),
        userInfo?.avatar == null
            ? Image.asset(
                "assets/mine/mine_avarta.png",
                width: 30,
                height: 30,
                fit: BoxFit.cover,
              )
            : CachedNetworkImage(
                width: 30,
                height: 30,
                fit: BoxFit.cover,
                imageUrl: userInfo?.avatar ?? "",
              ),
        const SizedBox(width: 9),
        Text(
          userInfo?.nickName ?? "",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: ByColorUtil.CommonTextColor,
          ),
        ),
        SizedBox(width: 5.w),
        Offstage(
          offstage: (userInfo?.isVip ?? 0) == 0,
          child: Image.asset(
            "assets/mine/icon_vip.png",
            width: 20,
            height: 20,
          ),
        ),
      ],
    );
  }

  _buildWorkList(BuildContext context) {
    final worksCountItemBeans =
        context.select<MinePageProvider, List<MyWorksCountItemBean>>(
      (val) => val.worksCountItemBeans,
    );
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      sliver: SliverGrid.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10.w,
          crossAxisSpacing: 10.w,
          childAspectRatio: 11 / 10,
        ),
        itemBuilder: (context, index) {
          final bean = worksCountItemBeans[index];
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              switch (index) {
                case 0:
                  ByNavRouterUtils.push(
                      context,
                      MultiProvider(
                        providers: [
                          ChangeNotifierProvider(
                              create: (context) =>
                                  MineVideosManagementProvider()),
                        ],
                        child: const MineVideosManagementPage(),
                      ));
                  // child: const AiCartoonVideoManagementPage(),
                  break;
                case 1:
                  ByNavRouterUtils.push(
                    context,
                    ChangeNotifierProvider(
                      create: (context) => AiDrawWorkManagementProvider(),
                      child: const AiDrawManagementPage(),
                    ),
                  );
                  break;
                case 2:
                  ByNavRouterUtils.push(
                      context,
                      MultiProvider(
                        providers: [
                          ChangeNotifierProvider(
                              create: (context) =>
                                  MineWordsManagementProvider()),
                          ChangeNotifierProvider(
                              create: (context) => AiWritingProvider()),
                          ChangeNotifierProvider(
                              create: (context) => WordsExtractProvider()),
                        ],
                        child: const MineWordsManagementPage(),
                      ));
                  break;
                case 3:
                  ByNavRouterUtils.push(
                      context,
                      ChangeNotifierProvider(
                        create: (context) => AiSongTasksProvider(),
                        child: const AiSongTasksPage(),
                      ));
                  break;
                case 4:
                  ByNavRouterUtils.push(
                    context,
                    MultiProvider(
                      providers: [
                        ChangeNotifierProvider(
                          create: (context) => AiOralVideosProvider(),
                        ),
                        ChangeNotifierProvider.value(
                            value: ByAudioPlayer.sharedInstance.statusProvider),
                      ],
                      child: const AiOralMyDubbingListPage(showSelect: false),
                    ),
                  );
                  break;

                /// 我的素材
                case 5:
                  ByNavRouterUtils.push(
                    context,
                    MultiProvider(
                      providers: [
                        ChangeNotifierProvider(
                          create: (context) =>
                              MineVideoMaterialsManagementProvider(),
                        ),
                      ],
                      child: const MineVideoMaterialsManagementPage(),
                    ),
                  );
                  break;
                default:
              }
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: ByWidgetsUtil.commonContainer(
                    borerRadius: 12.w,
                    margin: EdgeInsets.symmetric(vertical: 2.w),
                    bgColor: const Color(0xFFF6F7FE),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: ByColorUtil.BlackColor.withOpacity(0.05),
                    //     blurRadius: 4.w,
                    //   ),
                    // ],
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 32.w,
                            height: 32.h,
                            child: Image.asset(
                              bean.icon,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          ByWidgetsUtil.commonText(
                            text: bean.title,
                            textColor: ByColorUtil.CommonTextColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.normal,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 2.w,
                  right: 0,
                  child: Offstage(
                    offstage: bean.worksCount <= 0,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFF),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12.w),
                            topRight: Radius.circular(12.w),
                          ),
                        ),
                        child: ByWidgetsUtil.commonText(
                          text: "${bean.worksCount}",
                          fontSize: 10.sp,
                          fontWeight: FontWeight.normal,
                          textColor:
                              ByColorUtil.CommonTextColor.withOpacity(.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        itemCount: worksCountItemBeans.length,
      ),
    );
  }

  void _loadPageData() {
    final minePorvider = context.read<MinePageProvider>();

    /// 加载作品列表
    minePorvider.loadMinePageData();

    /// 获取个人权益
    minePorvider.loadMineLegalright();

    context.read<MineScoresProvider>().loadScoresInfo();
  }

  _buildMineLegalright(BuildContext context) {
    final legalrightBean =
        context.select<MinePageProvider, MineLegalrightBean?>(
      (value) => value.legalrightBean,
    );
    final showLegalright =
        legalrightBean != null && legalrightBean.leafletsStatus == 1;
    return Offstage(
      offstage: !showLegalright,
      child: showLegalright
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    SubFunction item = SubFunction.fromJson({
                      "id": 1001,
                      "title": "",
                      "img_url": legalrightBean.leafletsImage,
                      "jump_url": legalrightBean.leafletsUrl,
                      "jump_param": {},
                      "type": legalrightBean.leafletsType,
                      "des": "",
                      "isNew": false,
                    });
                    ByCommonUtils.subFunctionCase(context, item);
                  },
                  child: Container(
                    padding:
                        EdgeInsets.only(left: 12.w, right: 12.w, bottom: 10.h),
                    color: ByColorUtil.CommonPageBgColor,
                    child: CachedNetworkImage(
                      imageUrl: legalrightBean.leafletsImage,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                Positioned(
                  right: 12.w,
                  top: -5,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      final legalrightBeanCopy = legalrightBean.copyWith();
                      legalrightBeanCopy.leafletsStatus = 0;
                      context
                          .read<MinePageProvider>()
                          .updateMineLegalrightBean(legalrightBeanCopy);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: ByColorUtil.BlackColor.withOpacity(0.1),
                            blurRadius: 4.w,
                          )
                        ],
                      ),
                      child: Image.asset(
                        "assets/ai/ai_cartoon_config_close1.png",
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Container(),
    );
  }
}
