import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_color_utils.dart';
import 'package:video_clip_edit/providers/ai_chat_providers.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';

class AiChatAppBar extends StatelessWidget {

  UserController get userController => Get.find<UserController>();

  const AiChatAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AiChatProviders>();
    final selectedModelIndex = context.select<AiChatProviders, int>(
      (value) => value.selectedModelIndex,
    );
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
        leadingWidth: 120.w,
        backgroundColor: Colors.transparent,
        // AppBar 背景透明
        elevation: 0,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            provider.setShowModel(!provider.showModelList);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 12),
                alignment: Alignment.center,
                height: 30.h,
                decoration: BoxDecoration(
                  color: ByColorUtils.hexColor("#EAEEFF"),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      selectedModelIndex == -1
                          ? "选择模型"
                          : provider
                              .aiChatModelListBeans[selectedModelIndex].title,
                      style: TextStyle(
                          color: ByColorUtils.hexColor("#5E4AFF"),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp),
                    ),
                    SizedBox(
                      width: 5.w,
                    ),
                    Image.asset(
                      "assets/ai/aiduihuajiansd.png",
                      width: 7.w,
                      height: 7.h,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        title: Image.asset(
          "assets/ai/aiduihua_title.png",
          height: 17,
          fit: BoxFit.fitHeight,
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            return (userController.user.value?.isVip ?? 0) == 0
                ? GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                context.read<LaunchProvider>().gotoPay(context, closePay: true);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Image.asset(
                  "assets/home/home_vip.png",
                  width: 30.w,
                  height: 30.h,
                ),
              ),
            )
                : Container();
          })
        ],
      ),
    );
  }
}
