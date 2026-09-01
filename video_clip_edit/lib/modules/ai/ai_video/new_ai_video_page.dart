import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/core/base/base_view.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/routes/route_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/widgets/common/right_navigation_bar.dart';
import '../../../controller/user_controller.dart';
import '../../../providers/launch_provider.dart';
import '../../../utils/comon/by_colors.dart';
import '../../../v2/aiVideo/models/ai_video_square_model.dart';
import '../../guid/providers/guide_pop_providers.dart';
import 'new_ai_video_controller.dart';
import 'new_ai_video_dialog_ex.dart';
import 'new_ai_video_list_view_page_ex.dart';
import 'package:video_clip_edit/widgets/common/integral_vip_view.dart';

///3.10.12 新增加的Ai视频页面
class NewAiVideoPage extends StatelessWidget {
  const NewAiVideoPage({super.key});

  ///用户user
  UserController get userController => Get.find<UserController>();

  ///new ai video controller
  NewAiVideoController get newAiVideoController =>
      Get.find<NewAiVideoController>();

  ///launch provider
  // LaunchProvider get launchProvider => Get.find<LaunchProvider>();

  ///热门同款
  Widget _hotProductView({required BuildContext context}) {
    return Container(
      width: 1.sw,
      height: 175.w,
      margin: EdgeInsets.only(left: 12.w, right: 12.w),
      padding: EdgeInsets.only(top: 15.w, left: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Column(
        children: [
          ///热门同款
          Row(
            children: [
              Image.asset(
                "assets/ai/aiVideo/new_ai_hot.png",
                width: 16.w,
                height: 16.w,
              ),
              SizedBox(width: 2.w),
              Text(
                "热门同款",
                style: TextStyle(
                  color: const Color(0XFF0B1843),
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(width: 2.w),
              Padding(
                padding: EdgeInsets.only(top: 5.w),
                child: Text(
                  "可用下列素材直接生成",
                  style: TextStyle(
                    color: const Color(0XFF0B1843).withOpacity(0.5),
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Get.to(
                    () => NewAiVideoListViewPageEx(
                      type: newAiVideoController.type == 1
                          ? AiVideoGenerationType.imageToVideo
                          : AiVideoGenerationType.embraceVideo,
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      "全部",
                      style: TextStyle(
                        color: const Color(0XFF0B1843).withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 15.w,
                      color: const Color(0XFF0B1843).withOpacity(0.7),
                    ),
                    SizedBox(width: 5.w),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.w),
          SizedBox(
            height: 110.h,
            child: GetBuilder<NewAiVideoController>(
              id: "hotVideos",
              builder: (controller) {
                return ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...controller.currentHotVideos.map(
                      (e) => GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (context) {
                              return NewAiVideoDialogEx(model: e);
                            },
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                          ).then((value) {
                            if (value != null) {
                              controller.useSame(models: value);
                            }
                          });
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 90.w,
                              height: 110.h,
                              margin: EdgeInsets.only(right: 10.w),
                              decoration: BoxDecoration(
                                // color: Colors.blue,
                                borderRadius: BorderRadius.circular(10.w),
                                image: DecorationImage(
                                  image: NetworkImage(e.coverUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Image.asset(
                                "assets/ai/aiVideo/new_ai_video_play_icon.png",
                                width: 23.w,
                                height: 23.w,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  ///上传图片
  Widget _uploadImageView({required BuildContext context}) {
    return GetBuilder<NewAiVideoController>(
      builder: (controller) {
        log("===type=== ${controller.imageUrl}");
        if (controller.type == 1) {
          return Stack(
            children: [
              GestureDetector(
                onTap: () {
                  if (controller.imageUrl.isEmpty) {
                    controller.updateImageUrl();
                  }
                },
                child: Container(
                  width: 1.sw,
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: const Color(0XFFEAEEFF),
                    borderRadius: BorderRadius.circular(10.w),
                    border: Border.all(color: const Color(0XFFEAEEFF)),
                  ),
                  alignment: Alignment.center,
                  child: controller.imageUrl.isNotEmpty
                      ? Stack(
                          // alignment: Alignment.center,
                          children: [
                            CachedNetworkImage(
                              height: 98.h,
                              imageUrl: controller.imageUrl,
                              fit: BoxFit.fitHeight,
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/ai/aiVideo/new_ai_upload_image_icon.png",
                              width: 28.w,
                              height: 28.w,
                            ),
                            Text(
                              "点我上传图片",
                              style: TextStyle(
                                color: Color(0XFF5B4BF7),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              if (controller.imageUrl.isNotEmpty)
                Positioned(
                  right: 5.w,
                  top: 5.w,
                  child: GestureDetector(
                    onTap: () {
                      controller.deleteImageUrlEvent();
                    },
                    child: Image.asset(
                      "assets/ai/aiVideo/new_ai_video_close_icon.png",
                      width: 15.w,
                      height: 15.w,
                    ),
                  ),
                ),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (controller.imageUrl2.isEmpty) {
                          controller.updateImageUrl(selectImageType: 2);
                        }
                      },
                      child: Container(
                        width: 1.sw,
                        height: 100.h,
                        decoration: BoxDecoration(
                          color: const Color(0XFFEAEEFF),
                          borderRadius: BorderRadius.circular(10.w),
                          border: Border.all(color: const Color(0XFFEAEEFF)),
                        ),
                        alignment: Alignment.center,
                        child: controller.imageUrl2.isNotEmpty
                            ? Stack(
                                // alignment: Alignment.center,
                                children: [
                                  CachedNetworkImage(
                                    height: 98.h,
                                    imageUrl: controller.imageUrl2,
                                    fit: BoxFit.fitHeight,
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/ai/aiVideo/new_ai_upload_image_icon.png",
                                    width: 28.w,
                                    height: 28.w,
                                  ),
                                  Text(
                                    "点我上传图片一",
                                    style: TextStyle(
                                      color: Color(0XFF5B4BF7),
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    if (controller.imageUrl2.isNotEmpty)
                      Positioned(
                        right: 5.w,
                        top: 5.w,
                        child: GestureDetector(
                          onTap: () {
                            controller.deleteImageUrlEvent(index1: 1);
                          },
                          child: Image.asset(
                            "assets/ai/aiVideo/new_ai_video_close_icon.png",
                            width: 15.w,
                            height: 15.w,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 7.w),
              Expanded(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (controller.imageUrl3.isEmpty) {
                          controller.updateImageUrl(selectImageType: 3);
                        }
                      },
                      child: Container(
                        width: 1.sw,
                        height: 100.h,
                        decoration: BoxDecoration(
                          color: const Color(0XFFEAEEFF),
                          borderRadius: BorderRadius.circular(10.w),
                          border: Border.all(color: const Color(0XFFEAEEFF)),
                        ),
                        alignment: Alignment.center,
                        child: controller.imageUrl3.isNotEmpty
                            ? Stack(
                                // alignment: Alignment.center,
                                children: [
                                  CachedNetworkImage(
                                    height: 98.h,
                                    imageUrl: controller.imageUrl3,
                                    fit: BoxFit.fitHeight,
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/ai/aiVideo/new_ai_upload_image_icon.png",
                                    width: 28.w,
                                    height: 28.w,
                                  ),
                                  Text(
                                    "点我上传图片二",
                                    style: TextStyle(
                                      color: Color(0XFF5B4BF7),
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    if (controller.imageUrl3.isNotEmpty)
                      Positioned(
                        right: 5.w,
                        top: 5.w,
                        child: GestureDetector(
                          onTap: () {
                            Get.log("===点击了===");
                            controller.deleteImageUrlEvent(index2: 2);
                          },
                          child: Image.asset(
                            "assets/ai/aiVideo/new_ai_video_close_icon.png",
                            width: 15.w,
                            height: 15.w,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }

  /// 灵感输入
  Widget _imagineHintTextView() {
    return GetBuilder<NewAiVideoController>(
      builder: (controller) {
        late TextEditingController editingController;
        late FocusNode focusNode;
        if (controller.type == 1) {
          editingController = controller.editingController1;
          focusNode = controller.focusNode1;
        } else {
          editingController = controller.editingController2;
          focusNode = controller.focusNode2;
        }
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 5.w),
              child: TextField(
                maxLength: 200,
                minLines: 1,
                maxLines: 3,
                expands: false,
                controller: editingController,
                focusNode: focusNode,
                autofocus: false,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  labelStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.normal,
                    color: ByColorUtil.CommonTextColor,
                  ),
                  hintText: "请输入文字，描述你想让图片如何变化，输入和图片相关的描述，效果更好",
                  counterText: "",
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.normal,
                    color: ByColorUtil.CommonTextColor.withOpacity(0.3),
                  ),
                ),
                cursorColor: ByColorUtil.CommonTextColor,
                style: TextStyle(fontSize: 14.sp, color: Color(0XFF0B1843)),
              ),
            ),
            Row(
              children: [
                SizedBox(width: 5.5.w),
                _textNumberView(),
                SizedBox(width: 7.w),
                GestureDetector(
                  onTap: () {
                    controller.deletePrompts();
                  },
                  child: Text(
                    "清空",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: ByColorUtil.CommonTextColor.withOpacity(0.3),
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    controller.randomPrompt();
                  },
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/ai/aiVideo/new_ai_refersh_icon.png",
                        width: 12.w,
                        height: 12.w,
                      ),
                      SizedBox(width: 5.5.w),
                      Text(
                        "随机热门灵感",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Color(0XFF5B4BF7),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 5.5.w),
              ],
            ),
            SizedBox(height: 4.w),
          ],
        );
      },
    );
  }

  ///描述提示词
  Widget _hintTextView() {
    return Column(
      children: [
        SizedBox(height: 15.w),
        Row(
          children: [
            Image.asset(
              "assets/ai/aiVideo/new_ai_hint_icon.png",
              width: 12.w,
              height: 12.w,
            ),
            SizedBox(width: 5.5.w),
            Text(
              "描述提示词",
              style: TextStyle(
                color: const Color(0XFF0B1843),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                newAiVideoController.loadAllPrompts();
              },
              child: Icon(Icons.refresh, color: Color(0XFF5B4BF7), size: 18.w),
            ),
          ],
        ),
        SizedBox(height: 10.w),
        SizedBox(
          height: 32.w,
          child: GetBuilder<NewAiVideoController>(
            builder: (controller) {
              List<dynamic> prompts = [];
              if (controller.type == 1) {
                prompts = controller.prompts1;
              } else {
                prompts = controller.prompts2;
              }
              return ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...prompts.map(
                    (e) => InkResponse(
                      onTap: () {
                        controller.changePrompts(text: "${e["prompt"]}");
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 8.w),
                        padding: EdgeInsets.only(left: 11.w, right: 11.w),
                        decoration: BoxDecoration(
                          color: const Color(0XFFF9FAFF),
                          borderRadius: BorderRadius.circular(14.w),
                          border: Border.all(color: const Color(0XFFEAEEFF)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${e["tag"]}",
                          style: TextStyle(
                            color: const Color(0XFF0B1843).withOpacity(0.5),
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: 10.w),
      ],
    );
  }

  ///背景音乐
  Widget _backgroundMusicView({required BuildContext context}) {
    return GetBuilder<NewAiVideoController>(
      builder: (controller) {
        String bgmTitle = "";
        if (controller.type == 1) {
          bgmTitle = controller.bgmTitle1;
        } else {
          bgmTitle = controller.bgmTitle2;
        }

        return InkResponse(
          onTap: () {
            controller.showBgmDialog();
          },
          child: Row(
            children: [
              Image.asset(
                "assets/ai/aiVideo/background_music.png",
                width: 12.w,
                height: 12.w,
              ),
              SizedBox(width: 5.5.w),
              Text(
                "背景音乐",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: ByColorUtil.CommonTextColor,
                ),
              ),
              const Spacer(),
              Text(
                bgmTitle.isEmpty ? "选择" : bgmTitle,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: ByColorUtil.CommonTextColor.withOpacity(0.8),
                ),
              ),
              SizedBox(width: 5.w),
              Image.asset(
                "assets/ai/ai_back_icon.png",
                width: 15.w,
                height: 15.w,
              ),
            ],
          ),
        );
      },
    );
  }

  ///字数显示
  Widget _textNumberView() {
    return GetBuilder<NewAiVideoController>(
      id: 'promptsTextNumber',
      builder: (controller) {
        int number = 0;
        if (controller.type == 1) {
          number = controller.promptsText1.length;
        } else {
          number = controller.promptsText2.length;
        }
        return Text(
          "${number}/200",
          style: TextStyle(
            fontSize: 12.sp,
            color: ByColorUtil.CommonTextColor.withOpacity(0.3),
          ),
        );
      },
    );
  }

  ///一键成片
  Widget _oneKeyBtn(BuildContext context) {
    return Obx(() {
      bool isEnabled = newAiVideoController.isButtonEnabled.value;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIntegralVipView(),
          SizedBox(
            height: 50.h,
            child: Row(
              children: [
                if (context.read<LaunchProvider>().launchInfo?.isVip == 1)
                  SizedBox(
                    height: 50.h,
                    child: FilledButton(
                      onPressed: () {
                        newAiVideoController.clickCreationRecordEvent();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF5B4BF7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.w),
                          side: const BorderSide(
                            color: Color(0xFF5B4BF7),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text("创作记录", style: TextStyle(fontSize: 16.sp)),
                    ),
                  ),
                if (context.read<LaunchProvider>().launchInfo?.isVip == 1)
                  SizedBox(width: 10.w),
                Expanded(
                  child: SizedBox(
                    height: 50.h,
                    child: FilledButton(
                      onPressed: () {
                        ///针对华为用户是否需要绑定手机号码
                        ByNavigatorUtil.checkLogin(
                          context: context,
                          nextStepEvent: () {
                            newAiVideoController.clickOneKeyEvent();
                          },
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: isEnabled
                            ? const Color(0xFF5B4BF7)
                            : const Color(0xFFB5B9C6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                      ),
                      child: Text(
                        "一键成片",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  // 积分-vip-次数-消耗模块-Ai视频
  Widget _buildIntegralVipView() {
    return const IntegralVipView(
      requiredPoints: 0,
      type: "ai_image2_video", // 通过这个type请求权益接口获取实际积分
    );
  }

  ///新的选择图片组件
  Widget _selectImageView() {
    return GetBuilder<NewAiVideoController>(
      builder: (controller) {
        log("===type=== ${controller.imageUrl}");
        return Container(
          width: 1.sw,
          decoration: BoxDecoration(
            color: const Color(0XFfF9FAFF),
            borderRadius: BorderRadius.circular(10.w),
            border: Border.all(color: const Color(0XFFEAEEFF)),
          ),
          padding: EdgeInsets.only(left: 10.w, top: 10.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.type == 1
                    ? "支持JPG/PNG格式，文件大小不超过10MB。"
                    : "上传两张图片，支持JPG/PNG格式，文件大小不超过10MB。",
                style: TextStyle(
                  color: const Color(0XFF0B1843).withOpacity(0.5),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              _uploadImageViewEx(newController: controller),

              ///文字输入区域
              _imagineHintTextView(),
            ],
          ),
        );
      },
    );
  }

  Widget _uploadImageViewEx({required NewAiVideoController newController}) {
    if (newController.type == 1) {
      if (newController.imageUrl.isNotEmpty) {
        return Stack(
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              margin: EdgeInsets.only(right: 10.w, top: 10.w),
              decoration: BoxDecoration(
                // color: Colors.blue,
                borderRadius: BorderRadius.circular(10.w),
                image: DecorationImage(
                  image: NetworkImage(newController.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 6.w,
              right: 4.w,
              child: GestureDetector(
                onTap: () {
                  newController.deleteImageUrlEvent();
                },
                child: Image.asset(
                  "assets/ai/aiVideo/new_ai_video_close_icon.png",
                  width: 15.w,
                  height: 15.w,
                ),
              ),
            ),
          ],
        );
      }
      return GestureDetector(
        onTap: () {
          newController.updateImageUrl(selectImageType: 1);
        },
        child: Container(
          width: 80.w,
          height: 80.w,
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 10.w),
          decoration: BoxDecoration(
            color: const Color(0XFfF9FAFF),
            borderRadius: BorderRadius.circular(10.w),
            border: Border.all(color: const Color(0XFF5B4BF7), width: 1),
          ),
          child: Image.asset(
            "assets/ai/aiVideo/new_add_image_icon.png",
            width: 25.w,
            height: 25.w,
          ),
        ),
      );
    } else {
      return Row(
        children: [
          newController.imageUrl2.isNotEmpty
              ? Stack(
                  children: [
                    Container(
                      width: 80.w,
                      height: 80.w,
                      margin: EdgeInsets.only(right: 10.w, top: 10.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.w),
                        image: DecorationImage(
                          image: NetworkImage(newController.imageUrl2),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6.w,
                      right: 4.w,
                      child: GestureDetector(
                        onTap: () {
                          newController.deleteImageUrlEvent(index1: 1);
                        },
                        child: Image.asset(
                          "assets/ai/aiVideo/new_ai_video_close_icon.png",
                          width: 15.w,
                          height: 15.w,
                        ),
                      ),
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: () {
                    newController.updateImageUrl(selectImageType: 2);
                  },
                  child: Container(
                    width: 80.w,
                    height: 80.w,
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(right: 15.w, top: 10.w),
                    decoration: BoxDecoration(
                      color: const Color(0XFfF9FAFF),
                      borderRadius: BorderRadius.circular(10.w),
                      border: Border.all(
                        color: const Color(0XFF5B4BF7),
                        width: 1,
                      ),
                    ),
                    child: Image.asset(
                      "assets/ai/aiVideo/new_add_image_icon.png",
                      width: 25.w,
                      height: 25.w,
                    ),
                  ),
                ),
          newController.imageUrl3.isNotEmpty
              ? Stack(
                  children: [
                    Container(
                      width: 80.w,
                      height: 80.w,
                      margin: EdgeInsets.only(right: 10.w, top: 10.w),
                      decoration: BoxDecoration(
                        // color: Colors.blue,
                        borderRadius: BorderRadius.circular(10.w),
                        image: DecorationImage(
                          image: NetworkImage(newController.imageUrl3),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6.w,
                      right: 4.w,
                      child: GestureDetector(
                        onTap: () {
                          newController.deleteImageUrlEvent(index2: 2);
                        },
                        child: Image.asset(
                          "assets/ai/aiVideo/new_ai_video_close_icon.png",
                          width: 15.w,
                          height: 15.w,
                        ),
                      ),
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: () {
                    newController.updateImageUrl(selectImageType: 3);
                  },
                  child: Container(
                    width: 80.w,
                    height: 80.w,
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 10.w),
                    decoration: BoxDecoration(
                      color: const Color(0XFfF9FAFF),
                      borderRadius: BorderRadius.circular(10.w),
                      border: Border.all(
                        color: const Color(0XFF5B4BF7),
                        width: 1,
                      ),
                    ),
                    child: Image.asset(
                      "assets/ai/aiVideo/new_add_image_icon.png",
                      width: 25.w,
                      height: 25.w,
                    ),
                  ),
                ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      hasAppBar: false,
      backgroundColor: const Color(0XFFF8FAFB),
      resizeToAvoidBottomInset: true,
      child: GestureDetector(
        onTap: () {
          newAiVideoController.cancelFocusNode();
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(width: 1.sw, height: 1.sh),
            Positioned(
              child: Container(
                width: 1.sw,
                height: 120.w,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/v2/home/home_page_bg_top.png"),
                    fit: BoxFit.fitWidth,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: 52.w,
                        left: 12.w,
                        right: 12.w,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {},
                            child: Image.asset(
                              "assets/ai/aiVideo/new_ai_video_logo.png",
                              height: 28.h,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                          const Spacer(),
                          GetBuilder<NewAiVideoController>(
                            builder: (controller) {
                              int type = controller.type;
                              if (type == 1) {
                                return const RightNavigationBar(
                                  entranceType:
                                      GuideEntranceType.aiImageToVideo,
                                  hasMultipilePage: true,
                                );
                              } else {
                                return const RightNavigationBar(
                                  entranceType:
                                      GuideEntranceType.aiEmbraceVideo,
                                  hasMultipilePage: true,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 100.w,
              left: 12.w,
              right: 12.w,
              child: Container(
                width: 1.sw,
                height: 44.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.w),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GetBuilder<NewAiVideoController>(
                        builder: (controller) {
                          int type = controller.type;
                          return InkResponse(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            splashFactory: NoSplash.splashFactory,
                            onTap: () {
                              if (type == 1) {
                                return;
                              }
                              controller.changeMode(modeValue: 1);
                            },
                            child: Container(
                              width: 0.5.sw,
                              alignment: Alignment.center,
                              decoration: type == 1
                                  ? BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0XFF5B4BF7),
                                        width: 1.5.w,
                                      ),
                                      borderRadius: BorderRadius.circular(12.w),
                                      color: const Color(0XFFEAEEFF),
                                    )
                                  : null,
                              child: Text(
                                "单图模式",
                                style: TextStyle(
                                  color: type == 1
                                      ? const Color(0Xff5B4BF7)
                                      : const Color(0XFF0B1843),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: GetBuilder<NewAiVideoController>(
                        builder: (controller) {
                          int type = controller.type;
                          return InkResponse(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            splashFactory: NoSplash.splashFactory,
                            onTap: () {
                              if (type == 2) {
                                return;
                              }
                              controller.changeMode(modeValue: 2);
                            },
                            child: Container(
                              width: 0.5.sw,
                              alignment: Alignment.center,
                              decoration: type == 2
                                  ? BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0XFF5B4BF7),
                                        width: 1.5.w,
                                      ),
                                      borderRadius: BorderRadius.circular(12.w),
                                      color: const Color(0XFFEAEEFF),
                                    )
                                  : null,
                              child: Text(
                                "双图模式",
                                style: TextStyle(
                                  color: type == 2
                                      ? const Color(0Xff5B4BF7)
                                      : const Color(0XFF0B1843),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 160.w,
              right: 0.w,
              left: 0.w,
              child: SizedBox(
                height: 1.sh - 180.w,
                child: ListView(
                  padding: EdgeInsets.zero,
                  controller: newAiVideoController.scrollController,
                  children: [
                    _hotProductView(context: context),

                    ///上传图片 热门灵感 描述提示词
                    Container(
                      width: 1.sw,
                      margin: EdgeInsets.only(
                        left: 12.w,
                        right: 12.w,
                        top: 10.w,
                      ),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.w),
                      ),
                      child: Column(
                        children: [
                          _selectImageView(),
                          _hintTextView(),
                          _backgroundMusicView(context: context),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 1.sw,
                      height: 300.w,
                      // color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                  left: 12.w,
                  right: 12.w,
                  top: 12.w,
                  bottom: 8.w,
                ),
                child: _oneKeyBtn(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
