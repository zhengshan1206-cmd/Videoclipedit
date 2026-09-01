import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/novel_create_provider.dart';

import 'package:video_clip_edit/v2/promote/controllers/search_view_controller.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/short_play_create_provider.dart';

class SearchView extends StatefulWidget {
  final ShortPlayCreateProvider? shortPlayProvider;
  final NovelCreateProvider? novelCreateProvider;
  final bool showPlatform;
  SearchView(
      {super.key,
      this.shortPlayProvider,
      this.novelCreateProvider,
      this.showPlatform = true});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late final SearchViewController controller;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    // 创建临时控制器，页面销毁时会自动清理
    controller =
        Get.put(SearchViewController(), tag: 'search_view_${widget.hashCode}');

    // 设置ShortPlayCreateProvider引用
    if (widget.shortPlayProvider != null) {
      controller.setShortPlayProvider(widget.shortPlayProvider!);
    }
    if (widget.novelCreateProvider != null) {
      controller.setNovelCreateProvider(widget.novelCreateProvider!);
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    // 手动删除控制器
    Get.delete<SearchViewController>(tag: 'search_view_${widget.hashCode}');
    super.dispose();
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => _buildDropdownOverlay(),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildDropdownOverlay() {
    final c = controller;
    return Positioned(
      top: ByScreenUtils.navigationBarHeight + 60.h, // 导航栏高度 + 搜索框高度 + 偏移
      right: 12.w,
      child: Material(
        color: Colors.transparent,
        elevation: 8,
        child: Container(
          width: 100.w,
          padding: EdgeInsets.only(
            top: 10.h,
            left: 10.w,
            right: 10.w,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              c.platformList.length,
              (index) => GestureDetector(
                onTap: () {
                  c.selectPlatform(index);
                  c.closeDropdown();
                },
                child: Container(
                  width: double.infinity,
                  height: 36.h,
                  margin: EdgeInsets.only(bottom: 4.h),
                  decoration: BoxDecoration(
                    color: c.selectedPlatformIndex == index
                        ? const Color(0xFFEAEEFF)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  child: Center(
                    child: Text(
                      c.platformList[index].name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: c.selectedPlatformIndex == index
                            ? const Color(0xFF5B4BF7)
                            : const Color(0xFF0B1843),
                      ),
                    ),
                  ),
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
    return GetBuilder<SearchViewController>(
      tag: 'search_view_${widget.hashCode}',
      init: controller, // 保证controller已注册
      builder: (c) {
        // 处理下拉菜单显示
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (c.showDropdown) {
            _showOverlay();
          } else {
            _removeOverlay();
          }
        });

        final hasValue = c.keyword.isNotEmpty;
        final borderColor =
            (hasValue || c.hasFocus) ? const Color(0xFF5B4BF7) : Colors.white;
        final searchIcon = (hasValue || c.hasFocus)
            ? "assets/mine/search_icon_2.png"
            : "assets/mine/search_icon_1.png";
        final arrowIcon = "assets/mine/search_icon_3.png";

        return Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            left: 10.w,
            right: 10.w,
            top: 6.h,
            bottom: 10.h,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  // 搜索框
                  Expanded(
                    child: Container(
                      height: 44.h,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.w),
                        border: Border.all(
                          color: borderColor,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: double.infinity,
                              padding: EdgeInsets.only(
                                top: 5.h,
                              ),
                              child: TextField(
                                controller: c.textController,
                                focusNode: c.focusNode,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  hintText: c.isShortPlay ? "搜索短剧名称" : "搜索爆文名称",
                                  hintStyle: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF0B1843)
                                        .withOpacity(0.3),
                                  ),
                                ),
                                onSubmitted: (_) => c.doSearch(),
                              ),
                            ),
                          ),
                          // 清除按钮
                          if (hasValue)
                            GestureDetector(
                              onTap: () {
                                c.clearInput();
                              },
                              child: Padding(
                                padding: EdgeInsets.only(left: 6.w),
                                child: Image.asset(
                                  "assets/purchase/icon_close.png",
                                  width: 15.w,
                                  height: 15.h,
                                ),
                              ),
                            ),
                          SizedBox(width: 10.w),
                          // 搜索按钮
                          GestureDetector(
                            onTap: () {
                              c.doSearch();
                            },
                            child: Image.asset(
                              searchIcon,
                              width: 20.w,
                              height: 20.h,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  if (widget.showPlatform)
                    GestureDetector(
                      onTap: () {
                        c.toggleDropdown();
                      },
                      child: Container(
                        width: 74.w,
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              c.platformList.isNotEmpty &&
                                      c.selectedPlatformIndex <
                                          c.platformList.length
                                  ? c.platformList[c.selectedPlatformIndex].name
                                  : "全部",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF0B1843),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Transform.rotate(
                              angle: c.showDropdown ? 3.1415 : 0, // 旋转180度
                              child: Image.asset(
                                arrowIcon,
                                width: 12.w,
                                height: 12.h,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
