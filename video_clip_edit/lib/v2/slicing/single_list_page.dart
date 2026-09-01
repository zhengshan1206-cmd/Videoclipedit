import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/data/model/slicing/prompt_item_bean.dart';
import 'package:video_clip_edit/data/model/slicing/slicing_item_bean.dart';
import 'package:video_clip_edit/v2/slicing/controller/single_list_controller.dart';
import 'package:video_clip_edit/v2/slicing/controller/slicing_home_controller.dart';

class SingleListPage extends StatefulWidget {
  const SingleListPage({
    super.key,
    required this.categoryBean,
  });

  final SlicingItemBean categoryBean;

  @override
  State<SingleListPage> createState() => _SingleListPageState();
}

class _SingleListPageState extends State<SingleListPage>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late final SingleListController controller;
  final SlicingHomeController homeController =
      Get.find<SlicingHomeController>();
  StreamSubscription? _tabRefreshSubscription;

  @override
  void initState() {
    /// 避免重复创建controller
    controller =
        Get.put(SingleListController(), tag: widget.categoryBean.id.toString());

    /// 加载提示词列表
    controller.loadPromptList(widget.categoryBean.id);

    /// 添加观察者
    WidgetsBinding.instance.addObserver(this);

    /// 订阅标签页切换事件
    _subscribeToTabChanges();

    super.initState();
  }

  /// 订阅标签页切换事件
  void _subscribeToTabChanges() {
    _tabRefreshSubscription =
        homeController.tabRefreshStream.listen((tabIndex) {
      // 获取当前页面在标签页中的索引
      final pageIndex = _getPageIndex();

      // 如果当前切换到了这个页面，刷新数据
      if (tabIndex == pageIndex) {
        controller.loadPromptList(widget.categoryBean.id);
      }
    });
  }

  /// 获取当前页面在标签栏中的索引
  int _getPageIndex() {
    // 通过categoryBean的id在列表中查找索引
    final index = homeController.categoryBeans
        .indexWhere((category) => category.id == widget.categoryBean.id);
    return index;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      controller.loadPromptList(widget.categoryBean.id);
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    // 取消标签页切换事件订阅
    _tabRefreshSubscription?.cancel();

    // 移除观察者
    WidgetsBinding.instance.removeObserver(this);
    // 移除controller删除，保持状态
    Get.delete<SingleListController>(tag: widget.categoryBean.id.toString());

    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用
    return Scaffold(
      body: Obx(() => ListView.builder(
            padding: EdgeInsets.only(
              bottom: homeController.bottomViewHeight,
            ),
            itemCount: controller.promptItemBeans.isNotEmpty
                ? controller.promptItemBeans.length + 1
                : controller.promptItemBeans.length,
            itemBuilder: (context, index) {
              if (index == controller.promptItemBeans.length) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    homeController.fetchRandomPromptStreamData();
                  },
                  child: Container(
                    padding: EdgeInsets.only(top: 5.h, bottom: 12.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                            homeController.fetchRandomPromptStreamData();
                          },
                          child: ByWidgetsUtil.commonText(
                            text: "都不满意？点击随机生成",
                            fontSize: 12.sp,
                            fontWeight: FontWeight.normal,
                            textColor: const Color(0xFF5B4BF7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return PromptListCell(
                index: index,
                promptItemBean: controller.promptItemBeans[index],
                onTap: (bean) {
                  homeController.currentPrompt.value = bean.prompt;
                },
              );
            },
          )),
    );
  }
}

class PromptListCell extends StatelessWidget {
  const PromptListCell({
    super.key,
    required this.index,
    required this.onTap,
    required this.promptItemBean,
  });

  final int index;
  final PromptItemBean promptItemBean;
  final Function(PromptItemBean) onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onTap(promptItemBean);
      },
      child: ByWidgetsUtil.commonContainer(
        borerRadius: 12.w,
        bgColor: ByColorUtil.colorF8FAFB,
        padding: EdgeInsets.symmetric(
          horizontal: 13.w,
          vertical: 15.h,
        ),
        margin: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 4.h,
        ),
        child: ByWidgetsUtil.commonText(
          text: promptItemBean.prompt,
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
          textColor: ByColorUtil.color0B1843,
          maxLines: 100000,
        ),
      ),
    );
  }
}
