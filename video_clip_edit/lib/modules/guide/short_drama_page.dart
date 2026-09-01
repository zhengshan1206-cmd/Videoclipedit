import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/modules/home/beans/cloud_video_bean.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:bot_toast/bot_toast.dart';

class ShortDramaPage extends StatelessWidget {
  const ShortDramaPage({super.key});

  /// 处理按钮点击事件
  void _handleButtonClick() {
    // 跳转到推广页热门短剧的列表的第一个短剧详情
    // 先获取热门短剧列表
    HttpUtils.get(
      APIs.cloudVideosList,
      {
        "type": "2",
        "page": "1",
        "pageSize": "1", // 只需要第一个
      },
      showLoading: true,
      success: (data) {
        List listData = data["data"]["data"] ?? [];
        if (listData.isNotEmpty) {
          // 获取第一个短剧
          CloudVideoListBean firstShortPlay =
              CloudVideoListBean.fromJson(listData.first);
          Get.find<UserController>().showShortDramaGuide(true);

          ByNavigatorUtil.reportDataPoint(
            pageTag: "promotion_page_0fans_dialog_unlock_btn",
            operateType: "click",
            funcDetailTag: "0",
            funcDetailImg: Get.find<UserController>().shortDramaGuideImage,
          );

          Get.offNamed(
            Routes.newShortPlayListPage,
            arguments: {
              "fromPrompt": true,
              "videoListBean": firstShortPlay,
              "prePagePath": "/promote_hot_short_play_page",
              "fromShortDramaGuide": true,
            },
          );
        } else {
          BotToast.showText(text: "暂无热门短剧数据");
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final shortDramaGuideImage =
        Get.find<UserController>().shortDramaGuideImage;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
      },
      child: Container(
        width: 1.sw,
        decoration: const BoxDecoration(
          color: Color(0xFF8693EE),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 可滚动的主背景图片区域
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 74.h, // 为底部按钮预留空间
              child: SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    // child: shortDramaGuideImage.isNotEmpty
                    //     ? Image.network(shortDramaGuideImage)
                    //     : Image.asset(
                    //         "assets/v2/promote/promote-17.png",
                    //         width: 1.sw,
                    //         fit: BoxFit.fitWidth,
                    //       ),
                    child: Image.network(shortDramaGuideImage)),
              ),
            ),
            // 固定在底部的按钮区域
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                margin: EdgeInsets.only(bottom: 12.w),
                width: 1.sw,
                // 增加高度以容纳手指定位图片，避免被裁剪
                height: 100.h,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 按钮背景图片，添加点击事件
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _handleButtonClick,
                        child: Image.asset(
                          "assets/v2/promote/promote-18.png",
                          width: 1.sw,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    // 手指定位图片，允许超出容器范围，不被裁剪，添加点击事件
                    Positioned(
                      right: 77.w,
                      bottom: -20.h, // 从底部向上定位
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _handleButtonClick,
                        child: ScaleTransitionWidget(
                          period: 150,
                          child: Image.asset(
                            "assets/v2/promote/promote-19.png",
                            width: 70.w,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
