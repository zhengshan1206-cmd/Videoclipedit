/*
 * @Author: duncy
 * @Date: 2025-11-21 15:37:47
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-11-28 14:21:45
 * @FilePath: /video_clip_edit/lib/v2/anime/pages/anime_detail_page.dart
 * @Description: 
 */



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/anime/pages/anime_detail_setting_page.dart';

import '../../../utils/comon/by_navigator_util.dart';
import '../../aiSquare/widgets/ai_video_player.dart';
import '../beans/anime_bean.dart';

class AnimeDetailPage extends StatelessWidget {
  const AnimeDetailPage({super.key, required this.bean});

  final AnimeBean bean;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            child: Column(
              children: [
                AiVideoPlayer(
                          autoPlay: true,
                          videoUrl: bean.videoUrl!),
                SizedBox(height: ByScreenUtils.bottomSafeHeight + 10,),
              ],
            ),
          ),
          ///做同款
          Positioned(
            left: 12,
            right: 12,
            bottom: ByScreenUtils.bottomSafeHeight + 10,
            child: SizedBox(
              height: 50.w,
              child: ByWidgetsUtil.commonBtn(
                borderRadius: 12,
                fontSize: 16.sp,
                title: "做同款", onClick: () {
                  ByNavigatorUtil.checkLogin(
                            context: context,
                            nextStepEvent: () {
                              showModalBottomSheet(context: context, builder: (context) {
                                return AnimeDetailSettingPage(bean: bean,);
                              });
                            });
              }),
            )
          ),
          ///标题
          Positioned(
            left: 12,
            right: 12,
            bottom: ByScreenUtils.bottomSafeHeight + 30 + 50.w,
            child: SizedBox(
              height: 30.w,
              child: ByWidgetsUtil.commonText(
                text: bean.title ?? '',
                fontSize: 20.sp,
                textColor: ByColorUtil.WhiteColor,
                fontWeight: FontWeight.bold)
            )
          ),
          ///关闭遮罩
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              height: 80.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [const Color(0xFF000000), const Color(0xFF000000).withOpacity(0)])
              ),
            )
          ),
          ///关闭
          Positioned(
              left: 0,
              top: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 56.w,
                  height: AppBar().preferredSize.height,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    "assets/home/icon_back_white.png",
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
