/*
 * @Author: cold-x
 * @Date: 2025-04-27 14:16:17
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-05-08 20:14:47
 * @FilePath: /video_clip_edit/lib/v2/folkStory/widget/folk_story_success_create.dart
 * @Description: 民间故事创建成功后非VIP的跳转结果页
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/core/network/api.dart';
import 'package:video_clip_edit/core/widget/toolbar/top_tool_bar.dart';
import 'package:video_clip_edit/utils/consts/const.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';

import '../../../core/util/fonts.dart';
import '../../../modules/purchase/scale_transition_widget.dart';
import '../../../providers/launch_provider.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/comon/by_colors.dart';
import '../../../utils/http/apis.dart';
import '../../../widgets/common_button.dart';
import '../../aiCreate/controllers/create_folk_story_controller.dart';

class FolkStorySuccessCreate extends StatefulWidget {
  const FolkStorySuccessCreate({super.key, this.themeId});

  final String? themeId;

  @override
  State<FolkStorySuccessCreate> createState() => _FolkStorySuccessCreateState();
}

class _FolkStorySuccessCreateState extends State<FolkStorySuccessCreate> {
  //定时器当前执行次数
  int _counter = 0;
  //设置持续时间
  final int _duration = 3;
  //设置定时器执行间隔(毫秒)
  static const int millisecond = 10;
  //定时器执行次数
  int _maxCounter = 0;
  //最大进度条
  final int _maxProgress = 99;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    //定时器执行次数
    _maxCounter = (_duration * 1000) ~/ millisecond;
    _timer = Timer.periodic(const Duration(milliseconds: millisecond), (timer) {
      setState(() {
        _counter++;
        if (_counter >= _maxCounter) {
          _timer.cancel();
          showVideoDialog(context);
        }
      });
    });
    postData();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  //展示创建视频成功后的弹窗
  void showVideoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FolkStorySuccessCreatePopup(
          themeId: widget.themeId,
        );
        // return const FolkStorySuccessCreateVIPAwailable();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }

  Widget _buildContent() {
    //进度条总长度
    final maxWidth = 280.w;
    //进度条长度
    var progressWidth = maxWidth * _counter / _maxCounter;
    //进度条进度
    int progress = (_counter * _maxProgress) ~/ _maxCounter;
    //进度条显示信息三个档<=33 , >33<=66 ,>66
    String progressString = '角色绘制中';
    if (progress > 33 && progress <= 66) {
      progressString = '分镜绘制中';
    } else if (progress > 66) {
      progressString = '视频合成中';
    }
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Center(
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset(
                  "assets/v2/folk/folk_story_success_create_banner.png",
                  width: double.infinity,
                  height: 250.w,
                ),
                // Positioned(top: 50.w, left: 17.w, child: TopToolBackBar()),
              ],
            ),
            Image.asset(
              "assets/v2/folk/folk_story_success_create_gift.gif",
              width: 150.w,
              height: 150.w,
            ),
            Container(
              width: maxWidth,
              height: 24.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.w),
                color: const Color(0xFFE9EFF5),
              ),
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: progressWidth,
                    height: 18.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9.w),
                      // color: Colors.yellow,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF839EFF), Color(0xFFFFB9FB)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 3),
                      child: Text(
                          textAlign: TextAlign.right,
                          "$progress%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          )),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30.w,
            ),
            Text(
              progressString,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }

  ///上报中间页面
  void postData() {
    String eventFunction = "";
    String? themeId = widget.themeId;
    if (themeId == "5") {
      eventFunction = Consts.FUNCTION_FOLK_STORY;
    } else if (themeId == "6") {
      eventFunction = Consts.FUNCTION_PICTURE_BOOK;
    } else if (themeId == "7") {
      eventFunction = Consts.FUNCTION_NOVEL_TWEETS;
    }

    HttpUtils.post(APIs.apiPost, {
      "event": Consts.EVENT_PAID_PAGE,
      "event_function": eventFunction,
      "event_action": Consts.ACTION_SHOW_MIDDLE_PAGE_REPORT,
      "page_path": "/folk_story_success_create",
      "pre_page_path": Routes.createFolkStoryPage,
      "payment_page_tag":"",
      "middle_page_tag":"middle_page_one",
    });
  }
}

//视频创建成功后的弹窗引导页
class FolkStorySuccessCreatePopup extends StatelessWidget {
  const FolkStorySuccessCreatePopup({super.key, this.themeId});

  final String? themeId;

  @override
  Widget build(BuildContext context) {
    return _buildView(context);
  }

  Widget _buildView(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            SizedBox(
              height: 206.w,
            ),
            SizedBox(
              width: 300.w,
              height: 400.w,
              child: Stack(
                children: [
                  Positioned.fill(
                      child: SizedBox(
                    width: 300.w,
                    height: 400.w,
                    child: Image.asset(
                      'assets/v2/folk/folk_story_success_create_bg.png',
                      // fit: BoxFit.fill,
                    ),
                  )),
                  Positioned.fill(
                      child: Column(children: [
                    const Spacer(),
                    SizedBox(
                      height: 70.w,
                      //开通会员
                      child: Stack(children: [
                        CommonButton(
                            onPressed: () => {
                                 postData(),
                                  goPay(context),
                                },
                            child: ScaleTransitionWidget(
                              child: Image.asset(
                                'assets/v2/folk/folk_story_success_create_click.png',
                                fit: BoxFit.fill,
                              ),
                            )),
                        Positioned(
                            left: 193.w,
                            top: 20.w,
                            child: SizedBox(
                              width: 52.w,
                              height: 45.w,
                              child: ScaleTransitionWidget(
                                child: Image.asset(
                                  'assets/v2/folk/folk_story_success_create_click_thumb.png',
                                  fit: BoxFit.fill,
                                ),
                              ),
                            )),
                      ]),
                    ),
                  ])),
                ],
              ),
            ),
            SizedBox(
              height: 25.w,
            ),
            //关闭按钮
            CommonButton(
              onPressed: () => {
                Get.back(),
                Get.back(),
              },
              child: SizedBox(
                width: 30.w,
                height: 30.w,
                child: Image.asset(
                  'assets/v2/folk/folk_story_success_create_close.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //跳转VIP页面
  void goPay(BuildContext context) {
    Get.back();
    Get.back();
    final provider = context.read<LaunchProvider>();
    provider.isFolkStoryPayback = true;
    Get.log("===跳转Vip页面=== ${themeId}");
    String eventFunction = "";
    if (themeId == "5") {
      eventFunction = Consts.FUNCTION_FOLK_STORY;
    } else if (themeId == "6") {
      eventFunction = Consts.FUNCTION_PICTURE_BOOK;
    } else if (themeId == "7") {
      eventFunction = Consts.FUNCTION_NOVEL_TWEETS;
    }

    HttpUtils.post(APIs.apiPost, {
      "event": Consts.EVENT_PAID_PAGE,
      "event_function": eventFunction,
      "event_action": Consts.ACTION_OPEN_PAY_PAGE_REPORT,
      "page_path": "/folk_story_success_create",
      "pre_page_path": Routes.createFolkStoryPage,
      "payment_page_tag":provider.launchInfo?.verConfig.halfScreenPage,
      "middle_page_tag":"",
    });
    provider.showPayHalfDialog(context, "create_fold_story",
        themeId: themeId,
        eventFunction: eventFunction,
        prePagePath: Routes.createFolkStoryPage,
        pagePath: "/folk_story_success_create");
  }

  postData() {
    String eventFunction = "";
    if (themeId == "5") {
      eventFunction = Consts.FUNCTION_FOLK_STORY;
    } else if (themeId == "6") {
      eventFunction = Consts.FUNCTION_PICTURE_BOOK;
    } else if (themeId == "7") {
      eventFunction = Consts.FUNCTION_NOVEL_TWEETS;
    }

    HttpUtils.post(APIs.apiPost, {
      "event": Consts.EVENT_PAID_PAGE,
      "event_function": eventFunction,
      "event_action": Consts.ACTION_OPEN_MIDDLE_PAGE_REPORT,
      "page_path": "/create_fold_story",
      "pre_page_path": "/",
      "middle_page_tag":"middle_page_one",
      "payment_page_tag": "",
    });
  }
}

//付费成功成为vip后的引导页面
class FolkStorySuccessCreateVIPAwailable extends StatelessWidget {
  const FolkStorySuccessCreateVIPAwailable({super.key});
  @override
  Widget build(BuildContext context) {
    final launchProvider = context.read<LaunchProvider>();
    launchProvider.isFolkStoryPayback = false;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Center(
        child: Stack(
            //背景图
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Image.asset(
                    "assets/v2/folk/folk_story_success_create_banner.png",
                    width: double.infinity,
                    height: 250.w,
                    fit: BoxFit.cover),
              ),
              Positioned(
                left: 18.w,
                top: 75.h,
                child: Image.asset(
                    "assets/v2/folk/folk_story_success_create_vip_bg.png",
                    width: 339.w,
                    height: 307.w,
                    fit: BoxFit.cover),
              ),
              Positioned(
                left: 47.5.w,
                top: 134.5.w,
                child: Image.asset(
                    "assets/v2/folk/folk_story_success_create_vip_gift.gif",
                    width: 280.w,
                    height: 140.w,
                    fit: BoxFit.cover),
              ),
              Positioned(
                left: 62.5.w,
                top: 371.w,
                child: SizedBox(
                  width: 250.w,
                  height: 60.w,
                  child: CommonButton(
                    padding: EdgeInsets.zero,
                    minSize: 60.h,
                    borderRadius: BorderRadius.circular(30.h),
                    disabledColor: ByColorUtil.LoginBtnBgColor,
                    color: ByColorUtil.LoginBtnBgColor,
                    onPressed: () => {
                      _checkVideos(),
                    },
                    child: BYText.instance('查看视频', 16.sp,
                        color: ByColorUtil.WhiteColor,
                        fontWeight: BYFontWeight.medium),
                  ),
                ),
              ),
            ]),
      ),
    );
  }

  //查看视频
  void _checkVideos() {
    CreateFolkStoryController controller =
        Get.find<CreateFolkStoryController>();
    controller.createFolkStory(true);
  }
}
