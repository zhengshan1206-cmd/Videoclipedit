import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/providers/words_extract_provider.dart';
import 'package:video_clip_edit/modules/tool_box/beans/link_extraction_bean.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_download_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';

class ShortVideoLinkView extends StatefulWidget {
  const ShortVideoLinkView({
    super.key,
    this.onSuccess,
  });
  final void Function(String filePath)? onSuccess;
  @override
  State<ShortVideoLinkView> createState() => _ShortVideoLinkViewState();
}

class _ShortVideoLinkViewState extends State<ShortVideoLinkView> {
  final FocusNode _linkNode = FocusNode();
  final controller = TextEditingController();
  String platforms = "";
  @override
  void initState() {
    _loadPlatforms();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: ByColorUtil.BlackColor.withOpacity(0.5),
      body: Column(
        children: [
          const Spacer(),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: 12.w,
              right: 12.w,
              top: 20.h,
              bottom: 40.h + context.byBottomSafeHeight,
            ),
            decoration: BoxDecoration(
                color: ByColorUtil.WhiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.w),
                  topRight: Radius.circular(16.w),
                )),
            child: Material(
              color: ByColorUtil.WhiteColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          ByNavRouterUtils.goBack(context);
                        },
                        child: Container(
                          width: 20.w,
                          height: 12.w,
                          margin: EdgeInsets.only(right: 4.w),
                          alignment: Alignment.center,
                          child: Image.asset(
                            "assets/login/login_dialog_close.png",
                            width: 12.w,
                            height: 12.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Stack(
                    children: [
                      Container(
                        height: 120.h,
                        padding: EdgeInsets.only(bottom: 15.h),
                        decoration: BoxDecoration(
                            color: const Color(0xffF5F8F9),
                            borderRadius: BorderRadius.circular(12.w)),
                        child: TextField(
                          controller: controller,
                          focusNode: _linkNode,
                          maxLengthEnforcement: null,
                          maxLines: 5,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                            hintText: "粘贴链接到这里",
                            fillColor: Colors.transparent,
                            filled: true,
                            border: InputBorder.none,
                            labelStyle: TextStyle(
                              color: const Color(0xff0B1843).withOpacity(0.5),
                              fontSize: 12.sp,
                            ),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 12,
                        child: GestureDetector(
                          onTap: () {
                            getClipData();
                          },
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/toolbox/icon_link.png",
                                width: 10.5.w,
                                height: 10.5.h,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "粘贴链接",
                                style: TextStyle(
                                  color: const Color(0xff0B1843),
                                  fontSize: 12.sp,
                                ),
                              ),
                              Container(
                                height: 29.h,
                                alignment: Alignment.center,
                                child: ByWidgetsUtil.commonText(
                                  text: "  |  ",
                                  fontSize: 12.sp,
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  controller.text = "";
                                },
                                child: ByWidgetsUtil.commonText(
                                  text: "清空",
                                  fontSize: 12.sp,
                                  textColor: const Color(0xff0B1843),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      ByDownloadUtil.parseShareUrl(
                        controller.text,
                        onSuccess: (data) {
                          LinkExtractionBean bean =
                              LinkExtractionBean.fromJson(data);
                          // 跳转至视频下载页面
                          byDebugPrint(bean.videoUrl, tag: "视频下载地址：");
                          if (bean.videoUrl.isEmpty) {
                            BotToast.showText(text: "获取视频链接失败，请重试");
                            return;
                          }

                          ByNavRouterUtils.goBack(context);
                          widget.onSuccess?.call(bean.videoUrl);
                        },
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: ByColorUtil.TabTextColorSelected,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "一键提取",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  ByWidgetsUtil.commonText(text: "温馨提示：", fontSize: 14.sp),
                  SizedBox(height: 10.h),
                  ByWidgetsUtil.commonText(
                    text: platforms,
                    fontSize: 12.sp,
                    textColor: ByColorUtil.CommonTextColor.withOpacity(0.6),
                  ),
                  // SizedBox(height: 3.h),
                  // ByWidgetsUtil.commonText(
                  //   text: "2、支持抖音、快手、小红书等平台链接。",
                  //   fontSize: 12.sp,
                  //   textColor: ByColorUtil.CommonTextColor.withOpacity(0.6),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  getClipData() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      controller.text = data.text ?? "";
    }
  }

  void _loadPlatforms() {
    context.read<WordsExtractProvider>().loadSurpportedPlatforms(
          onSuccess: (plat) {
            setState(() {
              platforms = plat;
            });
          },
          onFailed: () {},
        );
  }
}
