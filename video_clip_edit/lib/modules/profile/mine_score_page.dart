import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/profile/beans/user_info_bean.dart';
import 'package:video_clip_edit/modules/profile/mine_score_rules_page.dart';
import 'package:video_clip_edit/modules/profile/mine_score_records_page.dart';
import 'package:video_clip_edit/modules/profile/widgets/mine_scores_widgets.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_scores_provider.dart';

class MineScorePage extends StatefulWidget {
  const MineScorePage({super.key});

  @override
  State<MineScorePage> createState() => _MineScorePageState();
}

class _MineScorePageState extends State<MineScorePage> {
  UserController get userController => Get.find<UserController>();

  UserInfoBean? get userInfo => userController.user.value;
  CancelToken _cancelToken = CancelToken();
  Timer? _timer;
  @override
  void initState() {
    super.initState();

    _registerPaymethods();

    _loadData();
  }

  void _registerPaymethods() {
    final provider = context.read<MineScoresProvider>();

    /// 订阅微信支付通知
    // provider.subscribeWXPayResp(
    //   context,
    //   onSuccess: () {
    //     _startCheckingStatus();
    //   },
    // );

    /// 订阅支付宝支付通知
    // provider.subscribeAliPayResp(
    //   context,
    //   onSuccess: () {
    //     _startCheckingStatus();
    //   },
    // );
  }

  void _loadData() {
    final provider = context.read<MineScoresProvider>();
    provider.loadScoreHappys();

    provider.loadScoresInfo();
  }

  Future<void> _checkStatus() async {
    try {
      final provider = context.read<MineScoresProvider>();

      /// 获取分段图片数据
      provider.querryOrderStatus(
        cancelToken: _cancelToken,
        onSuccess: () {
          _stopCheckingStatus();
        },
        onFaild: (token) {
          _cancelToken = token;
          _startTimer();
        },
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        // BotToast.showText(text: '查询已取消');
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 2), _checkStatus);
  }

  void _startCheckingStatus() {
    _checkStatus();
  }

  void _stopCheckingStatus() {
    final provider = context.read<MineScoresProvider>();
    provider.loadScoresInfo();
    _timer?.cancel();
    _cancelToken.cancel('取消查询');
  }

  @override
  void dispose() {
    // 页面销毁时，停止查询
    _stopCheckingStatus();
    super.dispose();
  }

  /// ******************************************
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(),
          _buildBody(context),
          _buildBottomBar(context),
          _buildAppBar(context),
        ],
      ),
    );
  }

  Positioned _buildAppBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: ByScreenUtils.navigationBarHeight,
        decoration: const BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage("assets/mine/mine_score_appbar_bg.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: ByWidgetsUtil.appBar(
          context: context,
          title: "积分充值",
          showBottmLine: true,
          backgroundColor: Colors.transparent,
          actions: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => ChangeNotifierProvider.value(
                    value: context.read<MineScoresProvider>(),
                    child: const MineScoreRulesPage(),
                  ),
                );
              },
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 3.w),
                    child: ByWidgetsUtil.svgAsset(
                      width: 11,
                      height: 11,
                      filePath: "assets/mine/mine_score_rules.svg",
                    ),
                  ),
                  ByWidgetsUtil.commonText(
                    text: "积分规则",
                    fontSize: 12.sp,
                    fontWeight: FontWeight.normal,
                  ),
                  SizedBox(width: 12.w),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildBody(BuildContext context) {
    return Positioned.fill(
        child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildUserInfo(context),
          ),
          const MineScoresBalanceView(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: ByWidgetsUtil.commonText(
                text: "积分充值",
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const ScoreListView(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(bottom: 10.h, top: 20.h),
              child: ByWidgetsUtil.commonText(
                text: "选择支付方式",
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const ScorePaymentMethodsView(),
          const MineScoresNoticeView(),
          SliverToBoxAdapter(child: SizedBox(height: 94.h)),
        ],
      ),
    ));
  }

  Widget _buildUserInfo(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: ByScreenUtils.navigationBarHeight + 12.h),
      child: Row(
        children: [
          userInfo?.avatar == null
              ? Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: ByColorUtil.BlackColor.withOpacity(0.1),
                        blurRadius: 2.w,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      "assets/mine/mine_avarta.png",
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: ByColorUtil.BlackColor.withOpacity(0.1),
                        blurRadius: 2.w,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                      imageUrl: userInfo?.avatar ?? "",
                    ),
                  ),
                ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    userInfo?.nickName ?? "",
                    style: TextStyle(
                      fontSize: 14.sp,
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
              ),
              SizedBox(height: 5.h),
              Text(
                userInfo?.userId != null ? "ID: ${userInfo?.userId}" : "",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  color: ByColorUtil.CommonTextColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 90.w,
            height: 36.h,
            child: ByWidgetsUtil.commonBtn(
              padding: EdgeInsets.zero,
              title: "积分记录",
              onClick: () {
                ByNavRouterUtils.push(
                  context,
                  ChangeNotifierProvider.value(
                    value: context.read<MineScoresProvider>(),
                    child: const MineScoreRecordsPage(),
                  ),
                );
              },
              fontSize: 14.sp,
              borderRadius: 100,
              fontWeight: FontWeight.normal,
              bgColor: const Color(0xFFF5F8F9),
              textColor: ByColorUtil.CommonTextColor,
            ),
          )
        ],
      ),
    );
  }

  _buildBottomBar(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: PhysicalModel(
        color: const Color(0xFF000000),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(
            left: 27,
            right: 27,
            top: 8,
            bottom: 10 + ByScreenUtils.bottomSafeHeight,
          ),
          child: Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  context.read<MineScoresProvider>().createOrder(
                        onSuccess: (payOrderBean) {
                          // Navigator.pop(context);
                        },
                        context: context,
                      );
                },
                child: SizedBox(
                  height: 54,
                  child: ByWidgetsUtil.gradientBgContainer(
                    borderRadius: 30,
                    padding: EdgeInsets.zero,
                    gradient: ByColorUtil.lineareGradient(
                      colorStart: const Color(0xFFFF8D05),
                      colorEnd: const Color(0xFFFFC763),
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    child: ByWidgetsUtil.commonText(
                      text: "立即购买",
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      textColor: const Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  final launchProvider = context.read<LaunchProvider>();
                  final userintegral =
                      launchProvider.launchInfo!.config.userintegral;
                  if (userintegral.isEmpty) return;
                  ByNavRouterUtils.jumpWebViewPage(context, "", userintegral);
                },
                child: ByWidgetsUtil.commonRichText(
                  texts: [
                    const TextSpan(text: "购买积分即代表已阅读并同意"),
                    const TextSpan(
                      text: "《积分服务协议》",
                      style: TextStyle(
                        color: ByColorUtil.TabTextColorSelected,
                      ),
                    ),
                  ],
                  fontSize: 12.sp,
                  textColor: const Color(0xFF8F929F),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
