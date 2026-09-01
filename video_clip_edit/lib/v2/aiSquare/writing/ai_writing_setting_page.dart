import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_color_utils.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class AiWritingSettingPage extends StatefulWidget {
  const AiWritingSettingPage({super.key});

  @override
  State<AiWritingSettingPage> createState() => _AiWritingSettingPageState();
}

class _AiWritingSettingPageState extends State<AiWritingSettingPage> {
  String title = "";

  @override
  Widget build(BuildContext context) {
    title = ModalRoute.of(context)?.settings.arguments.toString() ?? "";
    return Scaffold(
      body: Column(
        children: [
          _buildAppBarWidget(),
          Expanded(
              child: Container(
                child: Column(children: [
                  Text("测评内容",
                      style: TextStyle(
                          color: ByColorUtils.hexColor('#0B1843'),
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp)),
                  // SizedBox(
                  //   height: 200.h,
                  //   child: Column(
                  //     children: [
                  //       Expanded(
                  //           flex: 1,
                  //           child: TextField(
                  //               maxLines: 10,
                  //               controller: provider.evaluationContentEditingController,
                  //               decoration: InputDecoration(
                  //                 counterText: "",
                  //                 border: InputBorder.none,
                  //                 hintText: provider.contentHindText,
                  //                 hintStyle: TextStyle(
                  //                   fontSize: 14.sp,
                  //                   color: ByColorUtils.hexColor('#C8CAD1'),
                  //                 ),
                  //               ))),
                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           GestureDetector(
                  //             onTap: () {
                  //               provider.musicAiLyrics(
                  //                   provider.aiSongContentController.text);
                  //             },
                  //             child: Row(
                  //               children: [
                  //                 Image.asset(
                  //                   width: 15.w,
                  //                   height: 15.h,
                  //                   "assets/ai/ai_app_bar_saizi.png",
                  //                 ),
                  //                 Text(
                  //                   " 试一试~",
                  //                   style: TextStyle(
                  //                       fontSize: 12.sp,
                  //                       color: ByColorUtil.TabTextColorSelected),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //           Row(
                  //             children: [
                  //               GestureDetector(
                  //                 onTap: () {
                  //                   _checkTitle();
                  //                 },
                  //                 child: Text('违禁词检测  ',
                  //                     style: TextStyle(
                  //                         fontSize: 12.sp,
                  //                         color: ByColorUtils.hexColor('#C8CAD1'))),
                  //               ),
                  //               GestureDetector(
                  //                 onTap: () async {
                  //                   ClipboardData? data =
                  //                   await Clipboard.getData('text/plain');
                  //                   provider.aiSongContentController.text =
                  //                       data?.text ?? "";
                  //                 },
                  //                 child: Text('粘贴',
                  //                     style: TextStyle(
                  //                         fontSize: 12.sp,
                  //                         color: ByColorUtils.hexColor('#C8CAD1'))),
                  //               ),
                  //               Text(' | ',
                  //                   style: TextStyle(
                  //                       fontSize: 12.sp,
                  //                       color: ByColorUtils.hexColor('#C8CAD1'))),
                  //               GestureDetector(
                  //                 onTap: () {
                  //                   provider.aiSongTitleController.clear();
                  //                   provider.aiSongContentController.clear();
                  //                   provider.notifyListeners();
                  //                 },
                  //                 child: Text('清空  ',
                  //                     style: TextStyle(
                  //                         fontSize: 12.sp,
                  //                         color: ByColorUtils.hexColor('#C8CAD1'))),
                  //               ),
                  //               Text(
                  //                   '${provider.contentFondSize}/${provider.aiSongContentControllerLength}',
                  //                   style: TextStyle(
                  //                       fontSize: 12.sp,
                  //                       color: ByColorUtils.hexColor('#C8CAD1')))
                  //             ],
                  //           ),
                  //         ],
                  //       )
                  //     ],
                  //   ),
                  // ),
                  Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: ByColorUtil.TabTextColorSelected,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "立即创作",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  )
                ],),
              color:Colors.white,
          )),
        ],
      ),
    );
  }

  _buildAppBarWidget() {
    return GestureDetector(
      onTap: () {
        ByNavRouterUtils.goBack(context);
      },
      child: Column(
        children: [
          Container(
            height: ByScreenUtils.navigationBarHeight,
            decoration: const BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage("assets/ai/ai_app_bar_bg.png"),
                fit: BoxFit.fill,
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              bottom: ByWidgetsUtil.appBarBottom(),
              elevation: 0,
              leading: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  ByNavRouterUtils.goBack(context);
                },
                child: Container(
                  width: 30.w,
                  height: 30.h,
                  alignment: Alignment.center,
                  child: Image.asset(
                    "assets/home/icon_back.png",
                    width: 16.w,
                    height: 16.h,
                  ),
                ),
              ),
              title: Text(title,
                  style: TextStyle(
                      color: ByColorUtils.hexColor('#0B1843'),
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp)),
              centerTitle: true,
              actions: [],
            ),
          ),
        ],
      ),
    );
  }
}
