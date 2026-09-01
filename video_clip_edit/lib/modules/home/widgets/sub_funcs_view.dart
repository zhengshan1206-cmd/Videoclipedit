import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:video_clip_edit/utils/comon/by_color_utils.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/widgets/common/common_tab_bar.dart';

import '../../../controller/user_controller.dart';
import '../../../utils/comon/by_navigator_util.dart';
import '../../profile/beans/user_info_bean.dart';

class SubFuncsView extends StatelessWidget {
  final List<SubFunction> functions;

  const SubFuncsView({super.key, required this.functions});

  ///点击事件
  void itemClickEvent({
    required BuildContext context,
    required SubFunction e,
  }) async {
    ByNavigatorUtil.itemClickEvent(context: context, e: e);

    // final UserController controller = Get.find<UserController>();
    // UserInfoBean? userInfo = controller.user.value;
    // if ((userInfo?.isFormal ?? 0) == 1) {
    //   ByCommonUtils.subFunctionCase(context, e);
    // } else {
    //   controller.login().then((value) {
    //     userInfo = controller.user.value;
    //     if ((userInfo?.isFormal ?? 0) == 1) {
    //       ByCommonUtils.subFunctionCase(context, e);
    //     }
    //   });
    // }
  }

  Widget _itemView(SubFunction function, BuildContext context, double cellW) {
    return GestureDetector(
      onTap: () {
        ByNavigatorUtil.reportDataPoint(
          pageTag: "home_showcase",
          operateType: "click",
          funcDetailTag: function.id.toString(),
          funcDetailImg: function.imgUrl,
        );
        ByNavigatorUtil.checkLogin(
          context: context,
          nextStepEvent: () {
            ByCommonUtils.subFunctionCase(context, function);
          },
        );
        // itemClickEvent(context: context, e: function);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: cellW,
        decoration: BoxDecoration(
          color: const Color(0XFFF6FAFE),
          borderRadius: BorderRadius.circular(12.w),
          // border: Border.all(color: const Color(0XFFEDECFE))
        ),
        alignment: Alignment.center,
        // margin: EdgeInsets.only(right:8.w ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 11.5.w),
            CachedNetworkImage(
              imageUrl: function.imgUrl,
              width: 32.w,
              height: 32.w,
              fit: BoxFit.contain,
            ),
            const Spacer(),
            ByWidgetsUtil.commonText(
              text: function.title,
              fontSize: 12.sp,
              fontWeight: FontWeight.normal,
            ),
            SizedBox(height: 12.5.w),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cellW = (ByScreenUtils.screenWidth - 24.w) / 4.5;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
      child: SizedBox(
        height: 80.w,
        child: functions.length == 4
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ...functions.map((e) => _itemView(e, context, cellW)),
                ],
              )
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: functions.length,
                itemBuilder: (context, index) {
                  final function = functions[index];
                  return GestureDetector(
                    onTap: () {
                      ByNavigatorUtil.reportDataPoint(
                        pageTag: "home_showcase",
                        operateType: "click",
                        funcDetailTag: function.id.toString(),
                        funcDetailImg: function.imgUrl,
                      );
                      ByNavigatorUtil.checkLogin(
                        context: context,
                        nextStepEvent: () {
                          ByCommonUtils.subFunctionCase(context, function);
                        },
                      );
                      // itemClickEvent(context: context, e: function);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            (function.backgroundColor != null &&
                                function.backgroundColor!.isNotEmpty)
                            ? ByColorUtils.hexColor(function.backgroundColor!)
                            : const Color(0XFFF6FAFE),
                        borderRadius: BorderRadius.circular(12.w),
                        // border: Border.all(color: const Color(0XFFEDECFE))
                      ),
                      alignment: Alignment.center,
                      width: cellW,
                      margin: EdgeInsets.only(right: 8.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 11.5.w),
                          CachedNetworkImage(
                            imageUrl: function.imgUrl,
                            width: 32.w,
                            height: 32.w,
                            fit: BoxFit.contain,
                          ),
                          const Spacer(),
                          ByWidgetsUtil.commonText(
                            text: function.title,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.normal,
                          ),
                          SizedBox(height: 12.5.w),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// To parse this JSON data, do
//
//     final subFunction = subFunctionFromJson(jsonString);

SubFunction subFunctionFromJson(String str) =>
    SubFunction.fromJson(json.decode(str));

String subFunctionToJson(SubFunction data) => json.encode(data.toJson());

class SubFunction implements TabBarItem {
  int id;
  String title;
  String imgUrl;
  String jumpUrl;
  dynamic jumpParam;
  String? backgroundColor;

  /// 1 || 2:app路由 3:直接播放视频 4:打开一个url
  int type;
  String des;
  bool? isNew;
  String? banner;
  String? icon;
  bool? fromChat;

  SubFunction({
    required this.id,
    required this.title,
    required this.imgUrl,
    required this.jumpUrl,
    required this.jumpParam,
    required this.type,
    required this.des,
    this.isNew = false,
    this.banner,
    this.icon,
    this.fromChat = false,
    this.backgroundColor,
  });

  factory SubFunction.fromJson(Map<String, dynamic> json) => SubFunction(
    id: json["id"],
    title: json["title"],
    imgUrl: json["img_url"],
    jumpUrl: json["jump_url"],
    jumpParam: json["jump_param"],
    type: json["type"],
    des: json["des"],
    isNew: json["isNew"],
    banner: json["banner"] ?? "",
    icon: json["icon"] ?? "",
    fromChat: json["fromChat"] ?? false,
    backgroundColor: json["background_color"] ?? "",
  );

  factory SubFunction.fromPromotionJson(Map<String, dynamic> json) =>
      SubFunction(
        id: json["id"],
        title: json["title"],
        imgUrl: json["img_url"] ?? "",
        jumpUrl: json["jump_url"],
        jumpParam: json["jump_param"],
        type: int.parse(json["jump_type"].toString()),
        des: json["des"] ?? "",
        isNew: json["isNew"],
        banner: json["banner"] ?? "",
        icon: json["icon"] ?? "",
        fromChat: json["fromChat"] ?? false,
        backgroundColor: json["background_color"] ?? "",
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "img_url": imgUrl,
    "jump_url": jumpUrl,
    "jump_param": jumpParam,
    "type": type,
    "des": des,
    "isNew": isNew,
    "banner": banner,
    "icon": icon,
    "fromChat": fromChat,
    "background_color": backgroundColor,
  };

  @override
  String get tabText {
    return title;
  }

  @override
  String? get tabIcon {
    return icon;
  }

  @override
  String? get markIcon {
    return null;
  }
}
