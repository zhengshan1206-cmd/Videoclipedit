/*
 * @Author: cold-x
 * @Date: 2025-05-14 17:45:42
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-05-16 15:02:17
 * @FilePath: /video_clip_edit/lib/v2/Me/AboutUs/pages/version_update_page.dart
 * @Description: 更新弹窗页面
 */


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import '../beans/version_update_bean.dart';
import '../controllers/version_update_controller.dart';


class CurrentVersionUpdatePage extends StatelessWidget {
  const CurrentVersionUpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 320.w,
        height: 261.w,
        child: Stack(
          children: [
            Positioned(
              top: 30.w,
              width: 320.w,
              height: 231.w,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 60.w),
                    ByWidgetsUtil.commonText(
                      text: "温馨提示",
                      fontSize: 16,
                      fontWeight: BYFontWeight.semiBold,
                      textColor: ByColorUtil.CommonTextColor,
                    ),
                    SizedBox(height: 20.w),
                    ByWidgetsUtil.commonText(
                      text: "您当前已是最新版本，无需更新",
                      fontSize: 14,
                      textColor: ByColorUtil.CommonTextColor,
                    ),
                    SizedBox(height: 49.w),
                    SizedBox(
                      width: 270.w,
                      height: 48.w,
                      child: ByWidgetsUtil.commonBtn(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                          title: "确认",
                          textColor: ByColorUtil.WhiteColor,
                          fontSize: 16,
                          borderRadius: 12,
                          fontWeight: BYFontWeight.semiBold,
                          onClick: () {
                            Get.back();
                          }),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 125.w,
              child: SizedBox(
                width: 70.w,
                height: 70.w,
                child: Image.asset(
                  "assets/mine/icon_version_update_ring.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class VersionUpdatePage extends StatefulWidget {
  const VersionUpdatePage({
    super.key,
    required this.bean,
  });

  final VersionUpdateBean bean;

  @override
  State<VersionUpdatePage> createState() => _VersionUpdatePageState();
}

/// 版本更新弹窗
class _VersionUpdatePageState extends State<VersionUpdatePage> {
  final VersionUpdateController controller = Get.put(VersionUpdateController());

  @override
  void dispose() {
    super.dispose();
    Get.delete<VersionUpdateController>();
  }

  @override
  Widget build(BuildContext context) {
    bool isForceUpdate = widget.bean.isForceUpdate ? true : false;
    return Center(
        child: SizedBox(
          width: 300.w,
          height: 400.w,
          child: Stack(
            children: [
              Positioned.fill(child: 
                Image.asset(
                  "assets/mine/icon_version_update_bg.png",
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 185.w,
                left: 20.w,
                right: 20.w,
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: ByWidgetsUtil.commonText(
                        text: "新版本升级",
                        fontSize: 14,
                        fontWeight: BYFontWeight.medium,
                        textColor: ByColorUtil.CommonTextColor,
                      ),
                    ),
                    SizedBox(height: 14.5.w),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 74.w,
                        maxHeight: 74.w,
                      ),
                      child: SingleChildScrollView(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: ByWidgetsUtil.commonText(
                            text: widget.bean.content,
                            fontSize: 14,
                            fontWeight: BYFontWeight.regular,
                            textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                            maxLines: 999,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isForceUpdate ? 40.w : 30.w),
                    SizedBox(
                      width: 250.w,
                      height: 48.w,
                      child: Obx(() => ByWidgetsUtil.commonBtn(
                        title:  controller.statusText.value, 
                        bgColor: ByColorUtil.LoginBtnBgColor,
                        textColor: ByColorUtil.WhiteColor,
                        fontSize: 16,
                        fontWeight: BYFontWeight.semiBold,
                        borderRadius: 24,
                        onClick: (){
                          
                      })
                      ),
                    ),
                    if (!isForceUpdate)
                      Container(
                      width: 250.w,
                      height: 30.w,
                      alignment: Alignment.center,
                      child: GestureDetector(
                                  onTap: () {
                                    Get.back();
                                  },
                                  child: ByWidgetsUtil.commonText(
                                    text: "稍后更新",
                                    fontSize: 12,
                                    fontWeight: BYFontWeight.regular,
                                    textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                                  ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  _downloadApp() {
    controller.startDownloadApp(widget.bean.url);
  }
}