/*
  guide_pop_page.dart
  使用攻略弹窗
  该页面用于展示使用教程的弹窗
  该页面的设计思路是使用一个弹窗来展示教程内容
  弹窗的内容包括教程视频和链接url
  Created by duncy on 25/4/16.
*/

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/widgets/video_player_widget.dart';

 showGuidePopDialog(BuildContext context, String url,{ String topHintText ="",}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black.withOpacity(0.3),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return GuidePopPage(url: url, topHintText: topHintText,);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // 遮罩层透明度渐入渐出动画
      final maskFadeAnimation = Tween<double>(begin: 0, end: 0.3).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
      );

      // 对话框缩放动画
      final scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
      );

      // 对话框移动动画
      final slideAnimation = Tween<Offset>(
        begin: const Offset(0.35, -0.44),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
      );

      return Stack(
        children: [
          // 遮罩层
          FadeTransition(
            opacity: maskFadeAnimation,
            child: Container(
              color: Colors.black.withOpacity(0.3),
              // width: double.infinity,
              // height: double.infinity,
            ),
          ),
          // 对话框
          Center(
            child: SlideTransition(
              position: slideAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            ),
          ),
        ],
      );
    },
  );
}

class GuidePopPage extends StatelessWidget {
  final String url;
  final String topHintText;
  const GuidePopPage({super.key, required this.url, this.topHintText = ""});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(top: 75, left: 12, right: 12, bottom: 69),
        //初始化最小高度
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 300,
          ),
          //自适应高度
          child: IntrinsicHeight(
            child: Container(
              padding: const EdgeInsets.only(top: 13.5, left: 4, right: 4, bottom: 4),
              decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
              child: Column(
                children: [
                  SizedBox(
                    height: 4.h,
                  ),
                  _buildTopTip(context),
                  SizedBox(
                    height: 12.h,
                  ),
                  Expanded(
                    child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          clipBehavior: Clip.hardEdge,
                          child: VideoPlayerWidget(
                            url: url,
                            autoPlay: true,
                          ),
                      ),
                  ),
                ],
              ),
            ),
          ),
        )
        ),
    );
  }

  //顶部提示说明组件
  Widget _buildTopTip(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 10, right: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/toolbox/icon_guide_pop_page_des.png",
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 8),
          Text(
            topHintText.isEmpty? "短剧推广教程":topHintText,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5B4BF7),
            ),
          ),
          const Spacer(),
          //关闭按钮
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop(false);
            },
            child: Image.asset(
              "assets/toolbox/icon_guide_pop_page_close.png",
              width: 14,
              height: 24.5,
            ),
          ),
        ],
      ),
    );
  }

}
