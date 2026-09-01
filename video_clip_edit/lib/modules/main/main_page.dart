import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/core/util/app_util.dart';
import 'package:video_clip_edit/core/base/base_view.dart';
import 'package:video_clip_edit/modules/main/controllers/new_user_benefits_controller.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/modules/main/controllers/main_controller.dart';
import 'package:video_clip_edit/v2/business/new_user_benefits_page.dart';
import 'package:video_clip_edit/v2/minorMode/controllers/minor_mode_controller.dart';

import '../../controller/user_controller.dart';

class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  /// 图标区域高度（与普通图标一致），推广图标底边与此对齐并向上超出
  static const double _kIconAreaHeight = 28.0;
  static const double _kNormalIconSize = 28.0;
  static const double _kPromoteIconSize = 46.0;

  Widget _buildCustomBottomBar(MainController controller) {
    final list = [
      ('首页', Assets.tabTabHome, Assets.tabTabHomeSelected),
      ('AI成片', Assets.tabTabChat, Assets.tabTabChatSelected),
      ('推广', Assets.tabTabPromote, Assets.tabTabPromoteSelected),
      ('AI视频', Assets.tabAiVideo, Assets.tabAiVideoSelected),
      ('我的', Assets.tabTabMine, Assets.tabTabMineSelected),
    ];
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 4.h, bottom: 4.h),
          child: Row(
            children: List.generate(list.length, (index) {
              final selected = controller.currentIndex == index;
              final isPromote = index == 2;
              return Expanded(
                child: InkWell(
                  onTap: () => controller.tabChanged(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: _kIconAreaHeight,
                        child: isPromote
                            ? Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Image.asset(
                                        Assets.tabTabCenter,
                                        width: _kPromoteIconSize,
                                        height: _kPromoteIconSize,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Center(
                                child: Image.asset(
                                  selected ? list[index].$3 : list[index].$2,
                                  width: _kNormalIconSize,
                                  height: _kNormalIconSize,
                                  fit: BoxFit.contain,
                                ),
                              ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        list[index].$1,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: selected
                              ? ByColorUtil.TabTextColorSelected
                              : ByColorUtil.MainTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (GetPlatform.isAndroid) {
      return WillPopScope(
        child: _bodyView(context),
        onWillPop: AppUtil.exitApp,
      );
    } else {
      return _bodyView(context);
    }
  }

  _bodyView(BuildContext context) {
    return GetBuilder<MainController>(
      builder: (controller) {
        return BaseView(
          hasAppBar: false,
          bottomNavigationBar: Obx(
            () {
              if (MinorModeController.to.isMinorModeEnabled) {
                return const SizedBox.shrink();
              }
              return _buildCustomBottomBar(controller);
            },
          ),
          child: Stack(
            children: [
              ...controller.tabBarPages.map((e) {
                return Offstage(
                  offstage:
                      controller.currentIndex !=
                      controller.tabBarPages.indexOf(e),
                  child: e,
                );
              }),
              Obx(() {
                if (MinorModeController.to.isMinorModeEnabled) {
                  return const SizedBox();
                }
                bool isIntegralVipController =
                    Get.isRegistered<NewUserBenefitsController>();
                if (!isIntegralVipController) {
                  Get.put(NewUserBenefitsController());
                }
                NewUserBenefitsController newUserBenefitsController =
                    Get.find<NewUserBenefitsController>();
                final UserController userController =
                    Get.find<UserController>();

                ///用户是vip不展示福利
                if (userController.user.value?.isVip == 1) {
                  return const SizedBox();
                }
                if (controller.currentIndex != 0) {
                  return const SizedBox();
                }
                if (newUserBenefitsController.showType.value == 1) {
                  return Positioned(
                    bottom: 0.h,
                    child: Column(
                      children: [
                        const NewUserBenefitsWidget(),
                        SizedBox(height: 5.h),
                      ],
                    ),
                  );
                } else if (newUserBenefitsController.showType.value == 3) {
                  return Positioned(
                    bottom: 0.h,
                    child: Column(
                      children: [
                        const BenefitsForCreatorWidget(),
                        SizedBox(height: 5.h),
                      ],
                    ),
                  );
                } else if (newUserBenefitsController.showType.value == 2) {
                  return Positioned(
                    bottom: 0.h,
                    child: Column(
                      children: [
                        const RedEnvelopeNoticeWidget(),
                        SizedBox(height: 5.h),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              }),
            ],
          ),
        );
      },
    );
  }
}
