import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/routes/route_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_color_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/song/ai_song_page.dart';
import 'package:video_clip_edit/widgets/my_custom_header_build.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/song/provider/ai_song_provider.dart';

class AiMonetizationCreationPage extends StatefulWidget {
  static const String dyTxt = "抖音";
  static const String ksTxt = "快手";
  static const String xhsTxt = "小红书";
  static const String bzTxt = "bilibili";

  static const String wyyTxt = "网易云";
  static const String qqyyTxt = "QQ音乐";
  static const String qsyyTxt = "汽水音乐";
  static const String kgyyTxt = "酷狗音乐";

  const AiMonetizationCreationPage({super.key});

  @override
  State<AiMonetizationCreationPage> createState() =>
      _AiMonetizationCreationPageState();
}

class _AiMonetizationCreationPageState
    extends State<AiMonetizationCreationPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: ByColorUtils.hexColor("#DEEEFE"),
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                    pinned: false,
                    floating: false,
                    delegate:
                        MyCustomHeaderBuild(max: 360.h, min: 360.h, (ctx, off) {
                      return Stack(
                        children: [
                          Image.asset(
                            "assets/ai/ai_aibx_bianxianbanner.png",
                            fit: BoxFit.fill,
                            height: 360.h,
                            width: double.infinity.w,
                          ),
                        ],
                      );
                    })),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 15),
                        decoration: BoxDecoration(
                          // 边色与边宽度
                          color: ByColorUtils.hexColor("#F3E064"),
                          // 底色
                          //        borderRadius: new BorderRadius.circular((20.0)), // 圆角度
                          borderRadius: BorderRadius.circular(24), // 也可控件一边圆角大小
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            // 边色与边宽度
                            color: Colors.white,
                            // 底色
                            //        borderRadius: new BorderRadius.circular((20.0)), // 圆角度
                            borderRadius:
                                BorderRadius.circular(24), // 也可控件一边圆角大小
                          ),
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 17),
                                child: Image.asset(
                                  "assets/ai/ai_bx_czbx.png",
                                  fit: BoxFit.contain,
                                  width: 172.w,
                                  height: 42.h,
                                ),
                              ),
                              _buildComicTweetsWidget(),
                              _buildAiMuicWidget(),
                              _buildAiClipWidget(),
                              _buildAiKouboWidget(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 55, left: 20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 0.5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      width: 30.w,
                      height: 30.h,
                      alignment: Alignment.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ByNavRouterUtils.goBack(context);
                    },
                    child: Image.asset(
                      "assets/home/icon_back.png",
                      fit: BoxFit.contain,
                      width: 16.w,
                      height: 16.h,
                    ),
                  )
                ],
              ),
            ),
          ],
        ));
  }

  //制作漫画推文视频
  _buildComicTweetsWidget() {
    return Container(
      width: 300.w,
      margin: const EdgeInsets.only(top: 15),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "assets/ai/ai_czbx_zjbj.png",
            fit: BoxFit.fill,
            width: 300.w,
            height: 230.h,
          ),
          Positioned.fill(
              child: Column(
            children: [
              Container(
                height: 15.h,
              ),
              Text(
                "制作漫画推文视频",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                height: 15.h,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/ai/aiczshrassf.png",
                    fit: BoxFit.contain,
                    width: 13.w,
                    height: 13.h,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: Text(
                      "发布至",
                      style: TextStyle(
                        color: ByColorUtils.hexColor("#090A0B"),
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  Image.asset(
                    "assets/ai/aiczshrassf.png",
                    fit: BoxFit.contain,
                    width: 13.w,
                    height: 13.h,
                  ),
                ],
              ),
              Container(
                height: 15.h,
              ),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    _buildPushLlatform(
                        "assets/ai/ai_czbx_dy.png",
                        AiMonetizationCreationPage.dyTxt,
                        "https://creator.douyin.com/"),
                    _buildPushLlatform(
                        "assets/ai/ai_czbx_ks.png",
                        AiMonetizationCreationPage.ksTxt,
                        "https://cp.kuaishou.com/profile"),
                    _buildPushLlatform(
                        "assets/ai/ai_czbx_xhs.png",
                        AiMonetizationCreationPage.xhsTxt,
                        "https://creator.xiaohongshu.com/login"),
                    _buildPushLlatform(
                        "assets/ai/ai_czbx_bz.png",
                        AiMonetizationCreationPage.bzTxt,
                        "https://passport.bilibili.com/login"),
                  ],
                ),
              ),
              Container(
                height: 15.h,
              ),
              GestureDetector(
                onTap: () {
                  // final isVipVal = context.read<LaunchProvider>().launchInfo?.isVip ?? 0;
                  // final isVip = isVipVal == 1;
                  RouteUtils.gotoPage(context, "/ai_tweets");
                  // if (isVip) {
                  //   RouteUtils.gotoPage(context, "/ai_tweets");
                  // } else {
                  //   context
                  //       .read<LaunchProvider>()
                  //       .gotoPay(context, closePay: true);
                  // }

                  // ByNavRouterUtils.push(
                  //   context,
                  //   ChangeNotifierProvider(
                  //     create: (context) => AiCartoonProvider(),
                  //     child: const AiCartoonPage(),
                  //   ),
                  // );
                },
                child: Container(
                  width: 178.w,
                  height: 39.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1), // 边色与边宽度
                    color: Colors.white, // 底色
                    //        borderRadius: new BorderRadius.circular((20.0)), // 圆角度
                    borderRadius: BorderRadius.circular(24), // 也可控件一边圆角大小
                  ),
                  child: Text(
                    "去创作",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  //AI音乐制作
  _buildAiMuicWidget() {
    return Container(
      width: 300.w,
      margin: const EdgeInsets.only(top: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "assets/ai/ai_czbx_zjbj.png",
            fit: BoxFit.fill,
            width: 300.w,
            height: 230.h,
          ),
          Positioned.fill(
              child: Column(
            children: [
              Container(
                height: 15.h,
              ),
              Text(
                "AI音乐创作",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                height: 15.h,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/ai/aiczshrassf.png",
                    fit: BoxFit.contain,
                    width: 13.w,
                    height: 13.h,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: Text(
                      "发布至",
                      style: TextStyle(
                        color: ByColorUtils.hexColor("#090A0B"),
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  Image.asset(
                    "assets/ai/aiczshrassf.png",
                    fit: BoxFit.contain,
                    width: 13.w,
                    height: 13.h,
                  ),
                ],
              ),
              Container(
                height: 15.h,
              ),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    _buildPushLlatform(
                        "assets/ai/ai_cs_wyyTxt.png",
                        AiMonetizationCreationPage.wyyTxt,
                        "https://y.music.163.com/m/login?targetUrl=%2Fcreatorcenter"),
                    _buildPushLlatform(
                        "assets/ai/ai_cs_qqyyTxt.png",
                        AiMonetizationCreationPage.qqyyTxt,
                        "https://y.qq.com/m/client/qmplatform/welcome.html"),
                    _buildPushLlatform(
                        "assets/ai/ai_cs_qsyyTxt.png",
                        AiMonetizationCreationPage.qsyyTxt,
                        "https://music.douyin.com/"),
                    _buildPushLlatform(
                        "assets/ai/ai_cs_kgyyTxt.png",
                        AiMonetizationCreationPage.kgyyTxt,
                        "https://h5.kugou.com/apps/musician-enter/build/index.html#/"),
                  ],
                ),
              ),
              Container(
                height: 15.h,
              ),
              GestureDetector(
                onTap: () {
                  ByNavRouterUtils.push(
                    context,
                    name: "/AiSongPage",
                    ChangeNotifierProvider(
                      create: (context) => AiSongProvider(),
                      child: AiSongPage(),
                    ),
                  );
                },
                child: Container(
                  width: 178.w,
                  height: 39.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1), // 边色与边宽度
                    color: Colors.white, // 底色
                    //        borderRadius: new BorderRadius.circular((20.0)), // 圆角度
                    borderRadius: BorderRadius.circular(24), // 也可控件一边圆角大小
                  ),
                  child: Text(
                    "去创作",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  // 制作混剪推文视频
  _buildAiClipWidget() {
    return Container(
      width: 300.w,
      margin: const EdgeInsets.only(top: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "assets/ai/ai_czbx_zjbj.png",
            fit: BoxFit.fill,
            width: 300.w,
            height: 230.h,
          ),
          Positioned.fill(
              child: Column(
            children: [
              Container(
                height: 15.h,
              ),
              Text(
                "制作混剪推文视频",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                height: 15.h,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/ai/aiczshrassf.png",
                    fit: BoxFit.contain,
                    width: 13.w,
                    height: 13.h,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: Text(
                      "发布至",
                      style: TextStyle(
                        color: ByColorUtils.hexColor("#090A0B"),
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  Image.asset(
                    "assets/ai/aiczshrassf.png",
                    fit: BoxFit.contain,
                    width: 13.w,
                    height: 13.h,
                  ),
                ],
              ),
              Container(
                height: 15.h,
              ),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    _buildPushLlatform(
                        "assets/ai/ai_cs_wyyTxt.png",
                        AiMonetizationCreationPage.wyyTxt,
                        "https://y.music.163.com/m/login?targetUrl=%2Fcreatorcenter"),
                    _buildPushLlatform(
                        "assets/ai/ai_cs_qqyyTxt.png",
                        AiMonetizationCreationPage.qqyyTxt,
                        "https://y.qq.com/m/client/qmplatform/welcome.html"),
                    _buildPushLlatform(
                        "assets/ai/ai_cs_qsyyTxt.png",
                        AiMonetizationCreationPage.qsyyTxt,
                        "https://music.douyin.com/"),
                    _buildPushLlatform(
                        "assets/ai/ai_cs_kgyyTxt.png",
                        AiMonetizationCreationPage.kgyyTxt,
                        "https://h5.kugou.com/apps/musician-enter/build/index.html#/"),
                  ],
                ),
              ),
              Container(
                height: 15.h,
              ),
              GestureDetector(
                onTap: () {
                  RouteUtils.gotoPage(context, "/ai_clip");
                  // ByNavRouterUtils.push(
                  //   context,
                  //   name: "/ai_clip",
                  //   ChangeNotifierProvider(
                  //     create: (context) => AiSongProvider(),
                  //     child: AiSongPage(),
                  //   ),
                  // );
                },
                child: Container(
                  width: 178.w,
                  height: 39.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1), // 边色与边宽度
                    color: Colors.white, // 底色
                    //        borderRadius: new BorderRadius.circular((20.0)), // 圆角度
                    borderRadius: BorderRadius.circular(24), // 也可控件一边圆角大小
                  ),
                  child: Text(
                    "去创作",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  // 制作漫画推文视频
  _buildAiKouboWidget() {
    return Container(
      width: 300.w,
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "assets/ai/ai_czbx_zjbj.png",
            fit: BoxFit.fill,
            width: 300.w,
            height: 230.h,
          ),
          Positioned.fill(
              child: Column(
            children: [
              Container(
                height: 15.h,
              ),
              Text(
                "制作AI口播视频",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                height: 15.h,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/ai/aiczshrassf.png",
                    fit: BoxFit.contain,
                    width: 13.w,
                    height: 13.h,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: Text(
                      "发布至",
                      style: TextStyle(
                        color: ByColorUtils.hexColor("#090A0B"),
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  Image.asset(
                    "assets/ai/aiczshrassf.png",
                    fit: BoxFit.contain,
                    width: 13.w,
                    height: 13.h,
                  ),
                ],
              ),
              Container(
                height: 15.h,
              ),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    _buildPushLlatform(
                        "assets/ai/ai_cs_wyyTxt.png",
                        AiMonetizationCreationPage.wyyTxt,
                        "https://y.music.163.com/m/login?targetUrl=%2Fcreatorcenter"),
                    _buildPushLlatform(
                        "assets/ai/ai_cs_qqyyTxt.png",
                        AiMonetizationCreationPage.qqyyTxt,
                        "https://y.qq.com/m/client/qmplatform/welcome.html"),
                    _buildPushLlatform(
                        "assets/ai/ai_cs_qsyyTxt.png",
                        AiMonetizationCreationPage.qsyyTxt,
                        "https://music.douyin.com/"),
                    _buildPushLlatform(
                        "assets/ai/ai_cs_kgyyTxt.png",
                        AiMonetizationCreationPage.kgyyTxt,
                        "https://h5.kugou.com/apps/musician-enter/build/index.html#/"),
                  ],
                ),
              ),
              Container(
                height: 15.h,
              ),
              GestureDetector(
                onTap: () {
                  RouteUtils.gotoPage(context, "/ai_oral_videos");
                  // ByNavRouterUtils.push(
                  //   context,
                  //   name: "/ai_oral_videos",
                  //   ChangeNotifierProvider(
                  //     create: (context) => AiSongProvider(),
                  //     child: AiSongPage(),
                  //   ),
                  // );
                },
                child: Container(
                  width: 178.w,
                  height: 39.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1), // 边色与边宽度
                    color: Colors.white, // 底色
                    //        borderRadius: new BorderRadius.circular((20.0)), // 圆角度
                    borderRadius: BorderRadius.circular(24), // 也可控件一边圆角大小
                  ),
                  child: Text(
                    "去创作",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  _buildPushLlatform(String icon, String txt, String url) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ByNavRouterUtils.jumpWebViewPage(context, txt, url);
        },
        child: Column(
          children: [
            Image.asset(
              icon,
              fit: BoxFit.contain,
              width: 32.w,
              height: 32.h,
            ),
            Container(
              margin: const EdgeInsets.only(top: 5),
              child: Text(
                txt,
                style: TextStyle(
                  color: ByColorUtils.hexColor("#090A0B"),
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
