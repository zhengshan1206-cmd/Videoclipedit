import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/ai_draw_management_page.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/beans/ai_draw_style_case_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_work_management_provider.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';
import 'package:video_clip_edit/widgets/common/integral_vip_view.dart';

class AiSameStyleCasesPage extends StatefulWidget {
  const AiSameStyleCasesPage({
    super.key,
  });

  @override
  State<AiSameStyleCasesPage> createState() => _AiSameStyleCasesPageState();
}

class _AiSameStyleCasesPageState extends State<AiSameStyleCasesPage> {
  final _carouselController = CarouselSliderController();
  int _currentPage = 0;
  List<AiDrawStyleCaseBean> _styleCases = [];
  @override
  void initState() {
    super.initState();

    _initaialization();
  }

  void _initaialization() {
    final provider = context.read<AiDrawProvider>();
    final cases = provider.styleCases;
    _styleCases = cases;

    final currentPage = cases.indexOf(
        cases.firstWhere((element) => element.id == provider.selectedCaseId));
    _currentPage = currentPage;
    setState(() {});
  }

  // 积分-vip-次数-消耗模块-ai绘图
  Widget _buildIntegralVipView() {
    return const IntegralVipView(
      requiredPoints: 0,
      type: "ai_qiumi_paint", // 通过这个type请求权益接口获取实际积分
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(context: context, title: "最近任务"),
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Stack(
        children: [
          Container(),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 38.h),
                SizedBox(
                  height: 400.h,
                  child: CarouselSlider(
                    carouselController: _carouselController,
                    items: _styleCases.map((e) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(15.w),
                        child: CachedNetworkImage(
                          imageUrl: e.picUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: double.infinity,
                      viewportFraction: 0.8,
                      initialPage: _currentPage,
                      enableInfiniteScroll: false,
                      reverse: false,
                      autoPlay: false,
                      autoPlayInterval: const Duration(seconds: 3),
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      enlargeFactor: 0.3,
                      onPageChanged: (index, reason) {
                        _currentPage = index;
                        context
                            .read<AiDrawProvider>()
                            .updateSelectedCaseId(_styleCases[index].id);
                        setState(() {});
                      },
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                ByWidgetsUtil.commonContainer(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
                    margin: EdgeInsets.symmetric(horizontal: 12.w),
                    bgColor: ByColorUtil.WhiteColor,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              ByWidgetsUtil.commonContainer(
                                bgColor: const Color(0xFF0E1840),
                                child: SizedBox(
                                  width: 3.w,
                                  height: 12.h,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              ByWidgetsUtil.commonText(
                                text: "绘图风格：",
                                fontWeight: FontWeight.w500,
                                textColor: const Color(0xFF0E1840),
                              ),
                            ]),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: ByWidgetsUtil.commonText(
                                text: _styleCases[_currentPage].model,
                                maxLines: 10,
                                textColor:
                                    const Color(0xFF0E1840).withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ByWidgetsUtil.commonContainer(
                                  bgColor: const Color(0xFF0E1840),
                                  child: SizedBox(
                                    width: 3.w,
                                    height: 12.h,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                ByWidgetsUtil.commonText(
                                  text: "图片比例：",
                                  fontWeight: FontWeight.w500,
                                  textColor: const Color(0xFF0E1840),
                                )
                              ],
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: ByWidgetsUtil.commonText(
                                text: _styleCases[_currentPage].ratio,
                                maxLines: 10,
                                textColor:
                                    const Color(0xFF0E1840).withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              ByWidgetsUtil.commonContainer(
                                bgColor: const Color(0xFF0E1840),
                                child: SizedBox(
                                  width: 3.w,
                                  height: 12.h,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              ByWidgetsUtil.commonText(
                                text: "画面描述：",
                                fontWeight: FontWeight.w500,
                                textColor: const Color(0xFF0E1840),
                              ),
                            ]),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: ByWidgetsUtil.commonText(
                                text: _styleCases[_currentPage].prompt,
                                maxLines: 10,
                                textColor:
                                    const Color(0xFF0E1840).withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
                SizedBox(height: 120.h), // 增加底部间距，避免内容被遮挡
              ],
            ),
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: ByColorUtil.WhiteColor,
                padding: EdgeInsets.only(
                  left: 12.w,
                  right: 12.w,
                  top: 10.h,
                  bottom: 8.h + ByScreenUtils.bottomSafeHeight,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIntegralVipView(),
                    SizedBox(
                      height: 50.h,
                      child: ByWidgetsUtil.commonBtn(
                        title: "一键同款",
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        onClick: () {
                          final provider = context.read<AiDrawProvider>();
                          final purchaseProvider =
                              context.read<PurchaseProvider>();

                          if (purchaseProvider.preLoginCheck(context) ==
                              false) {
                            return;
                          }

                          final integralVipController =
                              IntegralVipController.getOrPut();

                          ///不是会员并且无试用-付费弹窗
                          if (!chekVip() && integralVipController.isTest <= 0) {
                            final provider = context.read<AiSquareProvider>();
                            String mark = 'ai_draw';
                            provider.showModelPayDialog(context, mark);
                            return;
                          }

                          // 检查积分是否足够
                          if (!integralVipController.canContinueUse()) {
                            integralVipController.showIntegralPayDialog();
                            return;
                          }

                          provider.startSameStyleCreate(
                            caseBean: _styleCases[_currentPage],
                            onSuccess: (taskID) {
                              integralVipController.init(
                                requiredPoints: 0,
                                type: "ai_qiumi_paint",
                              );

                              /// 进入到进度查询页面
                              ByNavRouterUtils.push(
                                context,
                                ChangeNotifierProvider(
                                  create: (context) =>
                                      AiDrawWorkManagementProvider(),
                                  child: const AiDrawManagementPage(),
                                ),
                              );
                            },
                            onFailed: () {
                              BotToast.showText(text: "创作失败，请稍后再试");
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }

  bool chekVip() {
    final isVip = context.read<LaunchProvider>().launchInfo?.isVip ?? 0;
    return isVip == 1;
  }
}
