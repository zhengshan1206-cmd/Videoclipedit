import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/home/widgets/banner_view.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/guide_page.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/providers/video_extraction_provider.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_color_utils.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/ai_vip_guid_page.dart';
import 'package:video_clip_edit/v2/aiSquare/providers/ai_vip_guid_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/song/ai_song_tasks_page.dart';
import 'package:video_clip_edit/providers/general_prohibite_words_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/song/beans/rights_by_type.dart';
import 'package:video_clip_edit/v2/aiSquare/song/provider/ai_song_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/song/beans/ai_song_getconfig_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/song/beans/ai_song_task_detail_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/song/provider/ai_song_tasks_provider.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/prohibited_words_dailog.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';
import 'package:video_clip_edit/widgets/common/integral_vip_view.dart';
import 'package:video_clip_edit/widgets/common/right_navigation_bar.dart';

// ignore: must_be_immutable
class AiSongPage extends StatefulWidget {
  late AiSongTaskDetailBean? aiSongTaskDetailBean;

  AiSongPage({super.key, this.aiSongTaskDetailBean});

  @override
  State<AiSongPage> createState() => _AiSongPageState();
}

class _AiSongPageState extends State<AiSongPage> {
  late AiSongProvider provider;

  @override
  void initState() {
    super.initState();
    provider = context.read<AiSongProvider>();
    _initData();
  }

  _initData() {
    provider.getAiMusicHintText();
    provider.getTaskList();
    provider.myLoadCloudVideos(
      aiSongTaskDetailBean: widget.aiSongTaskDetailBean,
    );
    provider.loadBanners(postion: 11);
  }

  @override
  Widget build(BuildContext context) {
    provider = context.watch<AiSongProvider>();
    provider.aiSongContentController.addListener(() {
      provider.contentFondSize = provider.aiSongContentController.text.length;
      provider.notifyListeners();
    });
    return Scaffold(
      body: Column(
        children: [
          _buildAppBarWidget(context),
          Expanded(
              child: ListView(
            controller: ScrollController(keepScrollOffset: false),
            //取消滑动回弹动画
            padding: const EdgeInsets.only(top: 0),
            children: [
              _buildInputBodyWidget(),
              _buildParameterWidget(),
              SizedBox(height: 120.h), // 增加底部间距，避免内容被遮挡
            ],
          )),
          SizedBox(height: 10.h),
          BottomBar(
            onCreate: () {
              if (provider.aiSongContentController.text.length >
                  provider.aiSongContentControllerLength) {
                BotToast.showText(text: "字数超限，请修改!");
              } else if (provider.aiSongContentController.text.isEmpty ||
                  provider.aiSongTitleController.text.isEmpty) {
                BotToast.showText(text: "请输入名称和歌词内容");
              } else {
                _checkTitle(
                    onSuccess: () {
                      final integralVipController =
                          IntegralVipController.getOrPut();

                      ///不是会员并且无试用-付费弹窗
                      if (!chekVip() && integralVipController.isTest <= 0) {
                        // ByNavRouterUtils.push(
                        //   context,
                        //   ChangeNotifierProvider(
                        //     create: (BuildContext context) =>
                        //         AiVipGuidProvider(),
                        //     child: const AiVipGuidPage(),
                        //   ),
                        // );
                        final provider = context.read<AiSquareProvider>();
                        String mark = 'ai_music';
                        provider.showModelPayDialog(context, mark);
                        return;
                      }

                      /// 检查积分是否足够-积分购买
                      if (!integralVipController.canContinueUse()) {
                        integralVipController.showIntegralPayDialog();
                        return;
                      }
                      // provider.rghtsByType != null ? provider.rghtsByType!.freeCount : 0
                      provider.musicAiCreateTask(
                        () {
                          ByNavRouterUtils.pushNamedResult(
                            context,
                            ChangeNotifierProvider(
                              create: (context) => AiSongTasksProvider(),
                              child: const AiSongTasksPage(),
                            ),
                            (data) {
                              if (data != null) {
                                widget.aiSongTaskDetailBean = data;
                                _initData();
                              }
                            },
                          );
                        },
                      );
                    },
                    isShowSuccessMsg: false);
              }
            },
            onRecords: () {
              ByNavRouterUtils.pushNamedResult(
                  context,
                  ChangeNotifierProvider(
                    create: (context) => AiSongTasksProvider(),
                    child: const AiSongTasksPage(),
                  ), (data) {
                if (data != null) {
                  widget.aiSongTaskDetailBean = data;
                  _initData();
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Column _buildAppBarWidget(BuildContext context) {
    return Column(
      children: [
        Container(
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
            bottom: ByWidgetsUtil.appBarBottom(),
            elevation: 0,
            leading: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                ByNavRouterUtils.goBack(context);
              },
              child: Container(
                width: 30.w,
                height: 30.h,
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/home/icon_back.png",
                  width: 16.w,
                  height: 16.h,
                ),
              ),
            ),
            title: Image.asset(
              height: 19.h,
              fit: BoxFit.fitHeight,
              "assets/ai/ai_song_title.png",
            ),
            centerTitle: true,
            actions: const [
              Center(
                //ai写歌 ai_music
                // child: RightNavigationBar(entranceType: 6),
                child: SizedBox(),
              ),
            ],
          ),
        ),
        _buildBanner(context),
        Container(
          margin:
              const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  provider.setNowSongStatus(songStatusInspiration);
                },
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    _buildGradientStatusWidget(songStatusInspiration),
                    Text(
                      '灵感作歌',
                      style: TextStyle(
                          color: provider.nowSongStatus == songStatusInspiration
                              ? ByColorUtil.BlackColor
                              : ByColorUtils.hexColor('#777B8B'),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  provider.setNowSongStatus(songStatusLyrics);
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      _buildGradientStatusWidget(songStatusLyrics),
                      Column(
                        children: [
                          Text('歌词成歌',
                              style: TextStyle(
                                  color:
                                      provider.nowSongStatus == songStatusLyrics
                                          ? ByColorUtil.BlackColor
                                          : ByColorUtils.hexColor('#777B8B'),
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  _buildBanner(BuildContext context) {
    final bannerBeans = context.select<AiSongProvider, List<SubFunction>>(
      (value) => value.bannerBeans,
    );
    final showBanner = context.select<AiSongProvider, bool>(
      (value) => value.showBanner,
    );
    final showBanners = bannerBeans.isNotEmpty && showBanner;
    if (showBanners) {
      return Padding(
        padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 11.h),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              width: double.infinity,
              height: 40.h,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.w),
                child: BannerView(
                  urls: bannerBeans.map((e) => e.imgUrl).toList(),
                  fit: BoxFit.cover,
                  onTap: (index) {
                    ByCommonUtils.subFunctionCase(context, bannerBeans[index]);
                  },
                ),
              ),
            ),
            Positioned(
              right: 5.w,
              top: 5.h,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  context.read<AiSongProvider>().updateShowBanner(false);
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
        ),
      );
    }
    return Container();
  }

  //选中的渐变
  _buildGradientStatusWidget(int status) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      child: Opacity(
          opacity: provider.nowSongStatus == status ? 1 : 0,
          child: Container(
              width: 50.w,
              height: 8.h,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft, //渐变开始于上面的中间开始
                    end: Alignment.centerRight, //渐变结束于下面的中间
                    colors: [
                      ByColorUtils.hexColor('#DEADFF'),
                      ByColorUtils.hexColor('#A8C3FF')
                    ],
                  )))),
    );
  }

  //检查内容是否违规
  _checkConten({void Function()? onSuccess, bool isShowSuccessMsg = true}) {
    if (provider.aiSongContentController.text.isNotEmpty) {
      provider.checkContent(
          content: provider.aiSongContentController.text,
          onSuccess: (bool violationsContentCheckBean) {
            if (violationsContentCheckBean) {
              showDialog(
                context: context,
                useSafeArea: false,
                barrierDismissible: true,
                builder: (ctx) => ChangeNotifierProvider(
                  create: (context) => GeneralProhibiteWordsProvider(),
                  child: ProhibitedWordsDailog<GeneralProhibiteWordsProvider>(
                    content: provider.aiSongContentController.text,
                    contentLeng: provider.aiSongContentControllerLength,
                    onSure: (content) {
                      provider.aiSongContentController.text = content;
                      onSuccess?.call();
                    },
                  ),
                ),
              );
            } else {
              onSuccess?.call();
              if (isShowSuccessMsg) {
                BotToast.showText(text: "内容无违规");
              }
            }
          });
    } else {
      BotToast.showText(text: "请输入内容");
    }
  }

  _checkTitle({void Function()? onSuccess, bool isShowSuccessMsg = true}) {
    if (provider.aiSongTitleController.text.isNotEmpty) {
      provider.checkContent(
          content: provider.aiSongTitleController.text,
          onSuccess: (bool violationsContentCheckBean) {
            if (violationsContentCheckBean) {
              showDialog(
                context: context,
                useSafeArea: false,
                barrierDismissible: true,
                builder: (ctx) => ChangeNotifierProvider(
                  create: (context) => GeneralProhibiteWordsProvider(),
                  child: ProhibitedWordsDailog<GeneralProhibiteWordsProvider>(
                    content: provider.aiSongTitleController.text,
                    contentLeng: provider.aiSongContentControllerLength,
                    onSure: (content) {
                      provider.aiSongTitleController.text = content;
                      _checkConten(
                          onSuccess: onSuccess,
                          isShowSuccessMsg: isShowSuccessMsg);
                    },
                  ),
                ),
              );
            } else {
              _checkConten(
                  onSuccess: onSuccess, isShowSuccessMsg: isShowSuccessMsg);
            }
          });
    } else {
      BotToast.showText(text: "请输入歌曲名称");
    }
  }

  Container _buildInputBodyWidget() {
    return Container(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 8),
      margin: const EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
        border: Border.all(width: 1.0, color: ByColorUtil.TabTextColorSelected),
        // color: ByColorUtil.TabTextColorSelected,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 5),
                child: Image.asset(
                  width: 15.w,
                  height: 15.h,
                  "assets/ai/ai_app_bar_bianji.png",
                ),
              ),
              Expanded(
                  child: Column(
                children: [
                  TextField(
                      controller: provider.aiSongTitleController,
                      decoration: InputDecoration(
                        hintText: "请输入歌曲名称",
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 16.sp,
                          color: ByColorUtils.hexColor('#A2A5B0'),
                        ),
                      )),
                ],
              )),
            ],
          ),
          Container(
            color: ByColorUtils.hexColor('#EEEFF0'),
            height: 1,
          ),
          SizedBox(
            height: 200.h,
            child: Column(
              children: [
                Expanded(
                    flex: 1,
                    child: TextField(
                        maxLength: provider.aiSongContentControllerLength,
                        maxLines: 10,
                        controller: provider.aiSongContentController,
                        decoration: InputDecoration(
                          counterText: "",
                          border: InputBorder.none,
                          hintText: provider.contentHindText,
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: ByColorUtils.hexColor('#C8CAD1'),
                          ),
                        ))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        provider.musicAiLyrics(
                            provider.aiSongContentController.text);
                      },
                      child: Row(
                        children: [
                          Image.asset(
                            width: 15.w,
                            height: 15.h,
                            "assets/ai/ai_app_bar_saizi.png",
                          ),
                          Text(
                            " 试一试~",
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: ByColorUtil.TabTextColorSelected),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _checkTitle();
                          },
                          child: Text('违禁词检测  ',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: ByColorUtils.hexColor('#C8CAD1'))),
                        ),
                        GestureDetector(
                          onTap: () async {
                            ClipboardData? data =
                                await Clipboard.getData('text/plain');
                            provider.aiSongContentController.text =
                                data?.text ?? "";
                          },
                          child: Text('粘贴',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: ByColorUtils.hexColor('#C8CAD1'))),
                        ),
                        Text(' | ',
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: ByColorUtils.hexColor('#C8CAD1'))),
                        GestureDetector(
                          onTap: () {
                            provider.aiSongTitleController.clear();
                            provider.aiSongContentController.clear();
                            provider.notifyListeners();
                          },
                          child: Text('清空  ',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: ByColorUtils.hexColor('#C8CAD1'))),
                        ),
                        Text(
                            '${provider.contentFondSize}/${provider.aiSongContentControllerLength}',
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: ByColorUtils.hexColor('#C8CAD1')))
                      ],
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Container _buildSongTypeButtonWidget(Mode mode) {
    return Container(
      // margin: EdgeInsets.only(left:type==1?10:0,top: 15),
      child: GestureDetector(
        onTap: () {
          provider.setSelectSongAiModel(mode);
        },
        child: Container(
          alignment: Alignment.center,
          width: 80.w,
          height: 37.h,
          child: Text(mode.name,
              style: TextStyle(
                  color: provider.selectSongAiModel?.id == mode.id
                      ? ByColorUtil.TabTextColorSelected
                      : ByColorUtils.hexColor('#A0A3AE'),
                  fontSize: 14.sp)),
          decoration: BoxDecoration(
            border: Border.all(
                width: 1.0,
                color: provider.selectSongAiModel?.id == mode.id
                    ? ByColorUtil.TabTextColorSelected
                    : ByColorUtils.hexColor('#A0A3AE')),
            // color: ByColorUtil.TabTextColorSelected,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  _buildsingerGenderButtonWidget(Mode model) {
    return GestureDetector(
      onTap: () {
        provider.setSelectsongAiSinger(model);
      },
      child: Container(
        alignment: Alignment.center,
        width: 80.w,
        height: 37.h,
        decoration: BoxDecoration(
          border: Border.all(
              width: 1.0,
              color: provider.selectsongAiSinger?.id == model.id
                  ? ByColorUtil.TabTextColorSelected
                  : ByColorUtils.hexColor('#A0A3AE')),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(model.name,
            style: TextStyle(
                color: provider.selectsongAiSinger?.id == model.id
                    ? ByColorUtil.TabTextColorSelected
                    : ByColorUtils.hexColor('#A0A3AE'),
                fontSize: 14.sp)),
      ),
    );
  }

  Container _buildParameterWidget() {
    return Container(
      margin: const EdgeInsets.only(left: 22, right: 22, top: 15),
      child: Column(
        children: [
          Visibility(
              visible: provider.nowSongStatus == songStatusInspiration
                  ? true
                  : false,
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "assets/ai/ai_app_aisong_yylx.png",
                        width: 15,
                        height: 15,
                      ),
                      Text(
                        " 音乐类型",
                        style: TextStyle(
                            color: ByColorUtil.TabTextColorSelected,
                            fontSize: 16.sp),
                      )
                    ],
                  ),
                  GridView.builder(
                      padding: const EdgeInsets.only(top: 10),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.songAiModel.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 5,
                              crossAxisSpacing: 10,
                              childAspectRatio: 1 / 0.49),
                      itemBuilder: (_, position) {
                        return _buildSongTypeButtonWidget(
                            provider.songAiModel[position]);
                      }),
                  // )
                ],
              )),
          Visibility(
            // opacity:provider.nowSongStatus == songStatusInspiration ? 0.0 : 1.0,
            visible:
                provider.nowSongStatus == songStatusInspiration ? false : true,
            child: Container(
              // margin: EdgeInsets.only(top: 15),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "assets/ai/ai_app_aisong_gsxb.png",
                        width: 15,
                        height: 15,
                      ),
                      Text(
                        " 歌手性别",
                        style: TextStyle(
                            color: ByColorUtil.TabTextColorSelected,
                            fontSize: 16.sp),
                      )
                    ],
                  ),
                  GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      // 设置禁止滚动
                      padding: const EdgeInsets.only(top: 10),
                      shrinkWrap: true,
                      itemCount: provider.songAiSinger.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 5,
                              crossAxisSpacing: 10,
                              childAspectRatio: 1 / 0.49),
                      itemBuilder: (_, position) {
                        return _buildsingerGenderButtonWidget(
                            provider.songAiSinger[position]);
                      }),
                ],
              ),
            ),
          ),
          Visibility(
              // opacity:provider.nowSongStatus == songStatusInspiration ? 0.0 : 1.0,
              visible: provider.nowSongStatus == songStatusInspiration
                  ? false
                  : true,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ByColorUtils.hexColor('#F8FAFB'),
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(top: 28),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  "assets/ai/ai_app_aisong_fgxz.png",
                                  width: 15,
                                  height: 15,
                                ),
                                Text(
                                  " 风格要求",
                                  style: TextStyle(
                                      color: ByColorUtil.TabTextColorSelected,
                                      fontSize: 16.sp),
                                ),
                              ],
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            _showBottomDialog();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: 90.w,
                            height: 28.h,
                            decoration: BoxDecoration(
                              color: ByColorUtil.TabTextColorSelected,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Text(
                              "选择音乐风格",
                              style: TextStyle(
                                  color: ByColorUtil.WhiteColor,
                                  fontSize: 12.sp),
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 7),
                      color: ByColorUtils.hexColor('#EEEFF0'),
                      height: 1,
                    ),
                    SizedBox(
                      height: 100.h,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Visibility(
                              visible:
                                  provider.selectSongAiStyleModel.isNotEmpty
                                      ? true
                                      : false,
                              child: SizedBox(
                                height: 25.h,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        provider.selectSongAiStyleModel.length,
                                    itemBuilder: (_, p) {
                                      return GestureDetector(
                                        onTap: () {
                                          _showBottomDialog();
                                        },
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(left: 5),
                                          alignment: Alignment.center,
                                          width: 60.w,
                                          height: 28.h,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1.0,
                                                color: ByColorUtils.hexColor(
                                                    '#A0A3AE')),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                              provider.selectSongAiStyleModel[p]
                                                  .name,
                                              style: TextStyle(
                                                  color: ByColorUtils.hexColor(
                                                      '#A0A3AE'),
                                                  fontSize: 12.sp)),
                                        ),
                                      );
                                    }),
                              )),
                          Expanded(
                              child: TextField(
                                  maxLines: 10,
                                  controller:
                                      provider.aiSongStyleCustomController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText:
                                        "请输入或选择您希望的音乐风格或要求，将尽量按照您要求的元素创作歌曲。例如：中国流行，普通话，欢快",
                                    hintStyle: TextStyle(
                                      fontSize: 14.sp,
                                      color: ByColorUtils.hexColor('#C8CAD1'),
                                    ),
                                  )))
                        ],
                      ),
                    )
                  ],
                ),
              )),
        ],
      ),
    );
  }

  _showBottomDialog() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(18),
          ),
        ),
        builder: (BuildContext context) {
          //构建弹框中的内容
          return StatefulBuilder(builder: (c, setBottomSheetState) {
            return Container(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(),
                      Text(
                        "选择音乐风格",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Image.asset(
                          "assets/login/login_dialog_close.png",
                          width: 12.9,
                          height: 12.7,
                        ),
                      )
                    ],
                  ),
                  Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: provider.songAiStyle.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              alignment: Alignment.centerLeft,
                              margin:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    provider.songAiStyle[index].title,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  GridView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.only(top: 10),
                                      shrinkWrap: true,
                                      itemCount: provider
                                          .songAiStyle[index].items.length,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        mainAxisSpacing: 10,
                                        crossAxisSpacing: 12,
                                        childAspectRatio: 1 / 0.5,
                                      ),
                                      itemBuilder: (_, position) {
                                        return _buildAiSongStyleItemWidget(
                                            provider.songAiStyle[index].title,
                                            provider.songAiStyle[index]
                                                .items[position],
                                            setBottomSheetState);
                                      })
                                ],
                              ),
                            );
                          })),
                  Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              provider.randomSelectSongAiStyleModel(() {
                                setBottomSheetState(() {});
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 50.h,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1.0,
                                    color: ByColorUtils.hexColor('#A0A3AE')),
                                // color: ByColorUtil.TabTextColorSelected,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/ai/ai_app_aisong_suijizuhe.png",
                                    width: 16,
                                    height: 16,
                                  ),
                                  Text("  随机组合",
                                      style: TextStyle(
                                          color:
                                              ByColorUtils.hexColor('#A0A3AE'),
                                          fontSize: 14.sp))
                                ],
                              ),
                            ),
                          )),
                      Container(
                        width: 10,
                      ),
                      Expanded(
                          child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          provider.updSelectSongAiStyleModel();
                        },
                        child: Container(
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: ByColorUtil.TabTextColorSelected,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "确定",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                    ],
                  )
                ],
              ),
            );
          });
        },
        context: context);
  }

  _buildAiSongStyleItemWidget(String title, Mode mode, StateSetter setState) {
    return GestureDetector(
      onTap: () {
        provider.updSongAiStyle(title, mode);
        setState(() {});
      },
      child: Container(
        height: 35.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: mode.isSelect
              ? ByColorUtils.hexColor("#EAEEFF")
              : ByColorUtils.hexColor("#F8FAFB"),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          mode.name,
          style: TextStyle(
              color: mode.isSelect
                  ? ByColorUtils.hexColor("#5B4BF7")
                  : Colors.black,
              fontSize: 14.sp),
        ),
      ),
    );
  }

  bool chekVip() {
    final isVip = context.read<LaunchProvider>().launchInfo?.isVip ?? 0;
    return isVip == 1;
  }

  GestureDetector _buildConfirmWidget() {
    return GestureDetector(
      onTap: () {
        if (provider.aiSongContentController.text.length >
            provider.aiSongContentControllerLength) {
          BotToast.showText(text: "字数超限，请修改!");
        } else if (provider.aiSongContentController.text.isEmpty ||
            provider.aiSongTitleController.text.isEmpty) {
          BotToast.showText(text: "请输入名称和歌词内容");
        } else {
          _checkTitle(
              onSuccess: () {
                if (!chekVip()) {
                  ByNavRouterUtils.push(
                    context,
                    ChangeNotifierProvider(
                      create: (BuildContext context) => AiVipGuidProvider(),
                      child: const AiVipGuidPage(),
                    ),
                  );
                  return;
                }
                // provider.rghtsByType != null ? provider.rghtsByType!.freeCount : 0
                provider.musicAiCreateTask(
                  () {
                    ByNavRouterUtils.pushNamedResult(
                      context,
                      ChangeNotifierProvider(
                        create: (context) => AiSongTasksProvider(),
                        child: const AiSongTasksPage(),
                      ),
                      (data) {
                        if (data != null) {
                          widget.aiSongTaskDetailBean = data;
                          _initData();
                        }
                      },
                    );
                  },
                );
              },
              isShowSuccessMsg: false);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Container(
            //   width: 60.w,
            //   alignment: Alignment.center,
            //   decoration: BoxDecoration(
            //     color: ByColorUtils.hexColor('#00FF9B'),
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Text(
            //     "限免x3",
            //     style: TextStyle(
            //         color: ByColorUtil.BlackColor,
            //         fontSize: 12.sp,
            //         fontWeight: FontWeight.bold),
            //   ),
            // ),
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10),
              height: 50.h,
              decoration: BoxDecoration(
                color: ByColorUtil.TabTextColorSelected,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "一键创作",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    child: Text(
                      "(剩余次数${provider.rghtsByType != null ? provider.rghtsByType!.freeCount : 0})",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    this.onCreate,
    this.onRecords,
  });

  final void Function()? onCreate;
  final void Function()? onRecords;

  // 积分-vip-次数-消耗模块-ai绘图
  Widget _buildIntegralVipView() {
    return const IntegralVipView(
      requiredPoints: 0,
      type: "ai_music", // 通过这个type请求权益接口获取实际积分
    );
  }

  @override
  Widget build(BuildContext context) {
    final vipRights = context
        .select<AiSongProvider, RightsByType?>((value) => value.rghtsByType);
    final times = vipRights?.freeCount ?? 0;
    final integral = vipRights?.userIntegral ?? 0;
    final price = vipRights?.currentIntegral ?? 0;
    final isVip = context.read<LaunchProvider>().launchInfo?.isVip ?? 0;
    return PhysicalModel(
      color: const Color(0xFF000000).withOpacity(0.5),
      elevation: 1,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          top: 8.h,
          bottom: 8.h + ByScreenUtils.bottomSafeHeight,
          left: 12.w,
          right: 12.w,
        ),
        child: Column(
          children: [
            _buildIntegralVipView(),
            Row(
              children: [
                if (isVip == 1)
                  SizedBox(
                    width: 91.w,
                    height: 50.h,
                    child: ByWidgetsUtil.commonBtn(
                      title: '创作记录',
                      onClick: () => onRecords?.call(),
                      fontSize: 16.sp,
                      borderRadius: 12.w,
                      fontWeight: FontWeight.normal,
                      bgColor: const Color(0xFFEAEEFF),
                      textColor: ByColorUtil.TabTextColorSelected,
                    ),
                  ),
                if (isVip == 1) SizedBox(width: 9.w),
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onCreate?.call(),
                        child: SizedBox(
                          height: 50.h,
                          child: ByWidgetsUtil.commonContainer(
                            borerRadius: 12.w,
                            alignment: Alignment.center,
                            bgColor: ByColorUtil.LoginBtnBgColor,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ByWidgetsUtil.commonText(
                                  text: "一键创作",
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  textColor: ByColorUtil.WhiteColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Positioned(
                      //   right: 0.w,
                      //   top: -12.h,
                      //   child: Offstage(
                      //     offstage: times == 0,
                      //     child: SizedBox(
                      //       height: 24.h,
                      //       child: ByWidgetsUtil.commonContainer(
                      //         borerRadius: 20.h,
                      //         alignment: Alignment.center,
                      //         padding: EdgeInsets.symmetric(horizontal: 11.w),
                      //         child: ByWidgetsUtil.commonText(
                      //           text: "限免x${times}",
                      //           fontSize: 12.sp,
                      //           fontWeight: FontWeight.w500,
                      //           textColor: ByColorUtil.WhiteColor,
                      //         ),
                      //         bgColor: const Color(0xFFFF2A70),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
            // Offstage(
            //   offstage: times > 0,
            //   child: SizedBox(height: 7.h),
            // ),
            // Offstage(
            //   offstage: times > 0,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Image.asset(
            //         "assets/mine/mine_score_coin.png",
            //         width: 18,
            //         height: 18,
            //         fit: BoxFit.fill,
            //       ),
            //       const SizedBox(width: 4),
            //       ByWidgetsUtil.commonText(
            //         text: "${integral}",
            //         fontSize: 14.sp,
            //         fontWeight: FontWeight.w500,
            //         textColor: ByColorUtil.CommonTextColor,
            //       ),
            //       const SizedBox(width: 10),
            //       ByWidgetsUtil.commonText(
            //         text: "本次消耗$price积分",
            //         textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
            //         fontSize: 12.sp,
            //         fontWeight: FontWeight.normal,
            //       )
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
