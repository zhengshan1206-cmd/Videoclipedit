import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/v2/slicing/slicing_home_page.dart';
import 'package:video_clip_edit/v2/aiSquare/chat/ai_chat_page.dart';
import 'package:video_clip_edit/v2/slicing/widget/title_tab_bar.dart';
import 'package:video_clip_edit/v2/slicing/controller/one_click_slicing_controller.dart';
import 'package:video_clip_edit/v2/slicing/controller/slicing_home_controller.dart';

class OneClickSlicingPage extends StatefulWidget {
  const OneClickSlicingPage({super.key});

  @override
  State<OneClickSlicingPage> createState() => _OneClickSlicingPageState();
}

class _OneClickSlicingPageState extends State<OneClickSlicingPage> {
  /// 当前选中的页面索引
  final RxInt _selectedIdx = 0.obs;
  final OneClickSlicingController controller =
      Get.find<OneClickSlicingController>();

  @override
  void initState() {
    super.initState();
  }

  /// 页面列表
  final List<Widget> pages = [const SlicingHomePage(), const AiChatPage()];
  UserController get userController => Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSlicingTab = _selectedIdx.value == 0;
      final isEditingPrompt = isSlicingTab &&
          Get.isRegistered<SlicingHomeController>() &&
          Get.find<SlicingHomeController>().manualEditing.value;
      return Scaffold(
        // 仅剧本编辑态自行按 viewInsets 避让，避免鸿蒙横屏把标题顶出屏外；
        // AI 对话仍走系统 resize，避免输入框被键盘挡住
        resizeToAvoidBottomInset: !isEditingPrompt,
        body: Column(
          children: [
            Obx(() {
              return controller.showAppBar.value ? _buildAppBar() : Container();
            }),
            Expanded(child: Obx(() => pages[_selectedIdx.value])),
          ],
        ),
      );
    });
  }

  Widget _buildAppBar() {
    final minBarH = math.max(
      88.h,
      MediaQuery.sizeOf(context).shortestSide * 0.14,
    );
    return Row(
      children: [
        SizedBox(
          height: minBarH,
          width: ByScreenUtils.screenWidth,
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Obx(() => Image.asset(
                      userController.isShowSpringStyle.value
                          ? "assets/springFestival/springFestival-1.png"
                          : "assets/v2/slicing/appbar_bg.png",
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    )),
              ),
              Positioned(
                bottom: 4.h,
                left: 12.w,
                right: 12.w,
                child: Row(
                  children: [
                    TitleTabBar(
                      tabs: const ['AI成片', 'AI对话'],
                      selectedImages: const [
                        'assets/home/ai_full_swing_tab_1.png',
                        'assets/home/ai_dialog_tab_1.png',
                      ],
                      unselectedImages: const [
                        'assets/home/ai_full_swing_tab_2.png',
                        'assets/home/ai_dialog_tab_2.png',
                      ],
                      tabHeight: math.min(40.h, minBarH * 0.42),
                      initialSelectedIndex: _selectedIdx.value,
                      onTabSelected: (index) {
                        _selectedIdx.value = index;
                      },
                    ),
                    const Spacer(),
                    Obx(() {
                      return (userController.user.value?.isVip ?? 0) == 0
                          ? GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                final purchaseProvider =
                                    context.read<PurchaseProvider>();
                                if (purchaseProvider.preLoginCheck(context) ==
                                    false) {
                                  return;
                                }

                                context.read<LaunchProvider>().gotoPay(
                                      context,
                                      closePay: true,
                                    );
                              },
                              child: Image.asset(
                                userController.isShowSpringStyle.value
                                    ? "assets/springFestival/springFestival-2.png"
                                    : "assets/ai/aiVideo/new_ai_video_app_bar_trailing.png",
                                height: math.min(36.h, minBarH * 0.48),
                                fit: BoxFit.fitHeight,
                              ),
                            )
                          : Container();
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
