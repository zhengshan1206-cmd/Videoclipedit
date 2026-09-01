/*
  top_tool_bar.dart
  顶部工具栏
  Created by duncy on 25/4/23.
*/

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../modules/guid/providers/guide_pop_providers.dart';
import '../../../widgets/common/right_navigation_bar.dart';

class TopToolBar extends StatelessWidget {
  const TopToolBar({
    super.key,
    required this.guideType});

  final GuideEntranceType guideType;

  @override
  Widget build(BuildContext context) {
    return _buildTopToolBar();
  }

  //初始化上方工具按钮
  Positioned _buildTopToolBar() {
    return Positioned(
      top: 50.w,
      left: 17.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TopToolBackBar(),
          SizedBox(
            width: 230.w,
          ),
          //民间故事  爆文创作 novel_create	flutter
          RightNavigationBar(entranceType: guideType),
          SizedBox(
            width: 17.w,
          )
        ],
      ),
    );      
  }
}

class TopToolBackBar extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Image.asset(
                "assets/home/icon_back.png",
                color: Colors.white,
                width: 16,
                height: 16,
              ),
            ),
          );
  }
}