import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/purchase/beans/count_down_config.dart';
import 'package:video_clip_edit/modules/purchase/widgets/count_down_view.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/providers/ios_purchase_provider.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/utils/comon/by_package_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';

class RetentionVipDailog extends StatelessWidget {
  final String markUrl;
  final VoidCallback? onOpenBtnTap;
  final VoidCallback? onCloseBtnTap;

  const RetentionVipDailog({
    super.key,
    this.markUrl = "assets/purchase/dailog_bonus_bg_new_2.png",
    this.onOpenBtnTap,
    this.onCloseBtnTap,
  });

  // 判断是否是网络图片
  bool get isNetworkImage => markUrl.startsWith('http');

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: 300,
                height: 400,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  image: DecorationImage(
                    image: isNetworkImage
                        ? NetworkImage(markUrl)
                        : AssetImage(markUrl) as ImageProvider,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Positioned(
              //   bottom: 290.h,
              //   left: 0,
              //   right: 0,
              //   child: Center(
              //     child: CountDownView(
              //       config: CountDownConfig(
              //         dateTime: DateTime(
              //           DateTime.now().year,
              //           DateTime.now().month,
              //           DateTime.now().day,
              //           DateTime.now().hour + 5,
              //           DateTime.now().minute + 59,
              //           DateTime.now().second + 59,
              //         ),
              //         timeItemWidh: 30,
              //         timeItemBorderRadius: 8,
              //         textColor: const Color(0xFFFEFBF8),
              //         separatorPadding: 9,
              //         separatorFontSize: 16,
              //         separatorTextColor: const Color(0xFF7A4502),
              //         fontSize: 16,
              //         timeItemBgColor: const Color(0xFFF98C55),
              //       ),
              //     ),
              //   ),
              // ),
              Positioned(
                bottom: 0.h,
                left: 10.w,
                right: 10.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: CountDownView(
                        config: CountDownConfig(
                          dateTime: DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            DateTime.now().hour + 5,
                            DateTime.now().minute + 59,
                            DateTime.now().second + 59,
                          ),
                          timeItemWidh: 30,
                          timeItemBorderRadius: 8,
                          textColor: const Color(0xFFFEFBF8),
                          separatorPadding: 9,
                          separatorFontSize: 16,
                          separatorTextColor: const Color(0xFF7A4502),
                          fontSize: 16,
                          timeItemBgColor: const Color(0xFFF98C55),
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    ScaleTransitionWidget(
                      child: GestureDetector(
                        onTap: () {
                          // 调用开通按钮回调
                          onOpenBtnTap?.call();
                          if (Navigator.canPop(context)) {
                            ByNavRouterUtils.goBack(context);
                          } else {
                            Get.offNamed(Routes.main);
                          }
                          if (Platform.isIOS) {
                            context.read<IosPurchaseProvider>().createIosOrder(
                                  onSuccess: (payOrderBean) {},
                                  context: context,
                                  retentionPop: true,
                                );
                          } else if (Platform.isAndroid || ByPackageUtils.isOhos) {
                            context.read<PurchaseProvider>().createOrder(
                                  onSuccess: (payOrderBean) {},
                                  context: context,
                                  retentionPop: true,
                                );
                          }
                        },
                        child: Stack(
                          children: [
                            Container(
                              height: 76.h,
                              width: 280.w,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      "assets/purchase/dailog_obtain_btn2.png"),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 30,
                              child: Image.asset(
                                "assets/purchase/icon_pointer.png",
                                width: 52,
                                height: 45,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // 调用关闭按钮回调
              onCloseBtnTap?.call();
              Navigator.pop(context, true);
              if (Navigator.canPop(context)) {
                Navigator.pop(context, true);
              } else {
                Get.offNamed(Routes.main);
              }
            },
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              child: Image.asset(
                "assets/purchase/dailog_bonus_close.png",
                width: 32,
                height: 32,
              ),
            ),
          )
        ],
      ),
    );
  }
}
