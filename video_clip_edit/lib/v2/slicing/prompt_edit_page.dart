import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/input/normal_input_view.dart';
import 'package:video_clip_edit/v2/slicing/controller/slicing_home_controller.dart';

class PromptEditPage extends StatefulWidget {
  const PromptEditPage({super.key});

  @override
  State<PromptEditPage> createState() => _PromptEditPageState();
}

class _PromptEditPageState extends State<PromptEditPage> {
  final SlicingHomeController homeController =
      Get.find<SlicingHomeController>();
  RxInt wordsCount = 0.obs;

  @override
  void initState() {
    wordsCount.value = homeController.currentPrompt.value.length;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const SizedBox(
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Image.asset(
              "assets/v2/slicing/appbar_bg.png",
              fit: BoxFit.fitWidth,
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Column(
                children: [
                  SizedBox(height: 30.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ByWidgetsUtil.commonText(
                        text: "剧本内容：",
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        textColor: ByColorUtil.color0B1843,
                      ),
                      const Spacer(),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          Get.back();
                        },
                        child: Container(
                          width: 40.w,
                          height: 40.h,
                          alignment: Alignment.bottomRight,
                          child: Image.asset(
                            "assets/v2/slicing/icon_fold.png",
                            width: 12.w,
                            height: 12.w,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    height: 400.h,
                    child: Obx(() {
                      return NormalInputView(
                        key: UniqueKey(),
                        maxWords: 2000,
                        placeholder:
                            "您可点击上面的推荐灵感或自行输入故事概要也可以\n在此直接输入完整的故事、剧本、小说",
                        initialValue: homeController.currentPrompt.value,
                        onChanged: (val) {
                          wordsCount.value = val.length;
                        },
                        onFinished: (val) {
                          homeController.currentPrompt.value = val;
                        },
                        scrollToBottom: true,
                        toolBarBuilder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Obx(() {
                                return homeController.isGenerating.value
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                            top: 4.h, bottom: 4.h),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 12.w),
                                            ByWidgetsUtil.generatingBtn(),
                                            const Spacer(),
                                          ],
                                        ),
                                      )
                                    : Container();
                              }),
                              Row(
                                children: [
                                  SizedBox(width: 12.w),
                                  Obx(() {
                                    return ByWidgetsUtil.commonText(
                                      text: "${wordsCount.value}/2000",
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.normal,
                                      textColor: ByColorUtil.color0B1843
                                          .withOpacity(0.5),
                                    );
                                  }),
                                  Obx(() {
                                    return Offstage(
                                      offstage: homeController
                                          .currentPrompt.value.isEmpty,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          homeController.currentPrompt.value =
                                              '';
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5.w),
                                          child: ByWidgetsUtil.commonText(
                                            text: "清空",
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.normal,
                                            textColor: ByColorUtil.color0B1843
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  const Spacer(),
                                  Image.asset(
                                    "assets/v2/slicing/icon_random.png",
                                    width: 12.w,
                                    height: 12.w,
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(width: 5.w),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      homeController
                                          .fetchRandomPromptStreamData();
                                    },
                                    child: ByWidgetsUtil.commonText(
                                      text: "随机热门灵感",
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.normal,
                                      textColor: const Color(0xFF5B4BF7),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    }),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
