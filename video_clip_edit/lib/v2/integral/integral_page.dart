import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/integral/integral_controller.dart';
import 'package:video_clip_edit/v2/integral/integral_pay_dialog.dart';
import 'package:video_clip_edit/v2/integral/integral_describe_dialog.dart';

class IntegralPage extends StatefulWidget {
  const IntegralPage({super.key});

  @override
  State<IntegralPage> createState() => _IntegralPageState();
}

class _IntegralPageState extends State<IntegralPage> {
  /// 我的积分（使用安全获取，避免未注册报错）
  IntegralController get controller => IntegralController.getOrPut();

  @override
  void initState() {
    super.initState();
    // 页面初始化时刷新数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.onRefresh();
    });
  }

  @override
  void dispose() {
    // 页面销毁时清理数据
    controller.integralRecords.clear();
    controller.page.value = 1;
    super.dispose();
  }

  // 当前积分
  Widget _remainingIntegralView() {
    return Positioned(
      top: 107.h,
      left: 32.w,
      right: 32.w,
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "当前剩余积分：",
              style: TextStyle(
                color: const Color(0XFF56310E),
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              controller.currentIntegral.value.toString(),
              style: TextStyle(
                color: const Color(0XFF56310E),
                fontSize: 48.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //tab
  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.only(top: 20.h, bottom: 12.h),
      child: Row(
        children: List.generate(3, (index) {
          return Obx(() {
            bool isSelected = index == controller.selectedTabIndex.value;
            return Expanded(
              child: InkWell(
                onTap: () {
                  controller.tabBarTap(index);
                },
                child: Container(
                  height: 34.h,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 0),
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: isSelected
                              ? const Color(0XFF0B1843)
                              : const Color.fromRGBO(11, 24, 67, 0.5),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        child: Text(controller.tabs[index]),
                      ),
                      SizedBox(height: 6.h),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 0),
                        curve: Curves.easeInOut,
                        height: 3.h,
                        width: 18.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: isSelected
                              ? const Color(0XFFFBD870)
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        }),
      ),
    );
  }

  //item 列表
  Widget _itemListView() {
    return Obx(() {
      final records = controller.selectedTabIndex.value == 0
          ? controller.integralRecords
          : controller.selectedTabIndex.value == 1
          ? controller.integralRecords
                .where((item) => item.integral > 0)
                .toList()
          : controller.integralRecords
                .where((item) => item.integral < 0)
                .toList();

      if (records.isEmpty) {
        return _buildNoDataView();
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: records.length,
        itemBuilder: (context, index) {
          final item = records[index];
          return Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.only(
              top: 14.h,
              bottom: 14.h,
              left: 12.w,
              right: 12.w,
            ),
            decoration: BoxDecoration(
              color: const Color(0XFFF8FAFB),
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //des
                      Text(
                        item.des,
                        style: TextStyle(
                          color: const Color(0XFF0B1843),
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        item.createdAt.toString().substring(0, 16),
                        style: TextStyle(
                          color: const Color.fromRGBO(11, 24, 67, 0.6),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${item.integral}",
                        style: TextStyle(
                          color: const Color(0XFF0B1843),
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "剩余${item.userIntegral}积分",
                        style: TextStyle(
                          color: const Color.fromRGBO(11, 24, 67, 0.6),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  //暂无内容
  Widget _buildNoDataView() {
    return Padding(
      padding: EdgeInsets.only(top: 100.h, bottom: 100.h),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/mine/mine_no_data.png",
              width: 180.w,
              height: 100.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 16.h),
            Text(
              "暂无数据",
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0XFF0B1843).withOpacity(0.3),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 主体内容
  Widget _mainView() {
    return Positioned(
      top: 200.h,
      left: 0.w,
      right: 0.w,
      bottom: 90.h,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.w),
            topRight: Radius.circular(24.w),
          ),
        ),
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: EasyRefresh(
                controller: controller.refreshController,
                onRefresh: controller.onRefresh,
                onLoad: controller.onLoadMore,
                child: Obx(() {
                  if (controller.isRefreshing.value) {
                    return const SizedBox.shrink();
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: _itemListView(),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 底部按钮
  Widget _remainingBtnView() {
    return Positioned(
      bottom: 10.h,
      left: 27.w,
      right: 27.w,
      child: ScaleTransitionWidget(
        child: GestureDetector(
          onTap: () => {
            showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return const IntegralPayDialog();
              },
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
            ).then((value) {
              // 刷新积分信息
              controller.onRefresh();
            }),
          },
          child: Container(
            height: 70.h,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/mine/integral-btn.png"),
                fit: BoxFit.fill,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 16.h, left: 120.w),
              child: Text(
                "购买积分",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 顶部背景
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: 1.sw,
              height: 250.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0XFFFBDD75), Color(0XFFFEB536)],
                ),
              ),
              child: Stack(
                children: [
                  // 辅助背景图片
                  Positioned(
                    top: 88.h,
                    right: 50.w,
                    child: Image.asset(
                      "assets/mine/integral-label.png",
                      width: 200.w,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 顶部导航栏
          Positioned(
            top: topPadding + 12.h,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Stack(
                children: [
                  // 返回按钮
                  Positioned(
                    left: 0,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                        size: 20.w,
                      ),
                    ),
                  ),
                  // 标题居中
                  Center(
                    child: Text(
                      "我的积分",
                      style: TextStyle(
                        color: const Color(0XFF0B1843),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // 积分说明按钮暂时屏蔽
                  Positioned(
                    right: 0,
                    child: Container(),

                    // GestureDetector(
                    //   onTap: () => {
                    //     showModalBottomSheet(
                    //         isScrollControlled: true,
                    //         context: context,
                    //         builder: (context) {
                    //           return const IntegralDescribeDialog();
                    //         },
                    //         shape: const RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.vertical(
                    //             top: Radius.circular(18),
                    //           ),
                    //         ))
                    //   },
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       Image.asset(
                    //         "assets/mine/integral-tips.png",
                    //         width: 12.w,
                    //         height: 12.w,
                    //       ),
                    //       SizedBox(width: 3.w),
                    //       Text(
                    //         "积分说明",
                    //         style: TextStyle(
                    //           color: const Color(0XFF0B1843),
                    //           fontSize: 12.sp,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ),
                ],
              ),
            ),
          ),

          _remainingIntegralView(),
          _mainView(),
          _remainingBtnView(),
        ],
      ),
    );
  }
}
