/*
 * @Author: duncy
 * @Date: 2025-11-21 15:37:47
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-11-28 15:03:55
 * @FilePath: /video_clip_edit/lib/v2/anime/pages/anime_page.dart
 * @Description: 
 */

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/anime/controllers/anime_controller.dart';
import 'package:video_clip_edit/widgets/common/multi_status_view.dart';

import 'anime_scroll_page.dart';

class AnimePage extends StatelessWidget {
  AnimePage({super.key});

  final AnimeController controller = Get.put(AnimeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset("assets/v2/home/home_page_bg_top.png"),
          SafeArea(
            child: Column(
              children: [
                const NavigationTitleView(title: 'AI漫剧'),
                Container(
                  constraints: BoxConstraints(
                    maxHeight:
                        MediaQuery.of(context).size.height -
                        AppBar().preferredSize.height -
                        MediaQuery.of(context).padding.top -
                        12,
                  ),
                  margin: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    bottom: 12,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFEAEEFF),
                    image: const DecorationImage(
                      alignment: Alignment.topCenter,
                      image: AssetImage(
                        'assets/v2/anime/anime_list_top_bg.png',
                      ),
                    ),
                  ),
                  child: Obx(
                    () => MultiStatusView(
                      backgroundColor: Colors.transparent,
                      emptyActionType: EmptyActionType.text,
                      currentStatus: controller.statusType.value,
                      // action: () => controller.fetchAnimeList,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 30.w,
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/v2/anime/anime_hot.png',
                                    width: 16,
                                    height: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  ByWidgetsUtil.commonText(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    text: '热门漫剧',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            GridView.count(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              crossAxisCount: 2, // 列数
                              mainAxisSpacing: 12.w,
                              crossAxisSpacing: 11.w,
                              childAspectRatio: 158 / 262, // 宽高比（控制项的尺寸）
                              children: controller.dataList.map((item) {
                                int index = controller.dataList.indexOf(item);
                                return GestureDetector(
                                  onTap: () {
                                    Get.to(
                                      () => AnimeScrollPage(
                                        dataList: controller.dataList,
                                        index: index,
                                      ),
                                    );
                                    // ByNavRouterUtils.push(context, AnimeDetailPage(bean: item,));
                                  },
                                  child: Column(
                                    children: [
                                      // 封面图（带播放按钮）
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.network(
                                              item.coverUrl!,
                                              fit: BoxFit.cover,
                                              width: 158.w, // 模拟不规则高度
                                              height: 232.w,
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              width: 32,
                                              height: 32,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.black54,
                                              ),
                                              child: const Icon(
                                                Icons.play_arrow,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // 标题
                                      Container(
                                        height: 24.w,
                                        margin: EdgeInsets.only(top: 6.w),
                                        alignment: Alignment.centerLeft,
                                        child: ByWidgetsUtil.commonText(
                                          fontWeight: FontWeight.w500,
                                          text: item.title ?? '',
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationTitleView extends StatelessWidget {
  const NavigationTitleView({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final double height = AppBar().preferredSize.height;
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Center(
            child: Text(
              title,
              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            left: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 56.w,
                height: height,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  "assets/home/icon_back.png",
                  width: 16.w,
                  height: 16.w,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
