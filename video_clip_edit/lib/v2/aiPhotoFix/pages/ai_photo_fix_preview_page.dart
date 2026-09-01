// ignore_for_file: use_build_context_synchronously
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/main/controllers/main_controller.dart';
import 'package:video_clip_edit/modules/main/main_page.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_permission_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiPhotoFix/provider/ai_photo_fix_management_provider.dart';

import '../../../modules/common/widget/common_dialog.dart';
import '../../aiSquare/draw/widgets/ai_imgs_downoad_dialog.dart';
import '../models/ai_photo_fix_task_model.dart';
import '../widgets/before_after/src/before_after.dart';

class AiPhotoFixPreviewPage extends StatefulWidget {
  final AiPhotoFixTaskModel taskModel;
  final bool backToHme;

  const AiPhotoFixPreviewPage({
    super.key,
    this.backToHme = false,
    required this.taskModel,
  });

  @override
  State<AiPhotoFixPreviewPage> createState() => _AiPhotoFixPreviewPageState();
}

class _AiPhotoFixPreviewPageState extends State<AiPhotoFixPreviewPage>
    with RouteAware {
  _AiPhotoFixPreviewPageState();

  var showMode = "compare"; // before/after
  var _compareValue = 0.5;

  void download() async {
    if (await ByPermissionUtils.storage() == false) return;
    showDialog(
      context: context,
      builder: (c) {
        return AiImgsDownoadDialog(
          contents: "",
          maxLine: 10,
          cancelBtnTitle: "取消",
          confirmBtnTitle: "确定",
          confirmCallback: () {},
          imgUrls: [widget.taskModel.imageUrl!],
        );
      },
    );
  }

  void delete() {
    final provider = context.read<AiPhotoFixManagementProvider>();
    showDialog(
      context: context,
      builder: (ctx) {
        return CommonDialog(
          reverse: false,
          maxLine: 10,
          contents: "请确认是否删除，删除后将不可回恢复，请谨慎操作",
          confirmBtnTitle: "删除",
          confirmCallback: () {
            provider.deleteVideos(
              [widget.taskModel.id],
              onSuccess: () {
                provider.resetPages();
                provider.updateSelectAllStatus(false);
                provider.loadVideoList(type: widget.taskModel.type);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(
        context: context,
        title: "图片详情",
        onPop: () {
          if (widget.backToHme) {
            Get.find<MainController>().backToMain();
          } else {
            ByNavRouterUtils.goBack(context);
          }
        },
        actions: [
          GestureDetector(
            onTap: delete,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                "删除",
                style: TextStyle(
                  color: const Color(0xFF0B1843),
                  fontSize: 14.sp,
                ),
              ),
            ),
          )
        ],
      ),
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showMode == "compare")
              Container(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.w),
                      child: BeforeAfter(
                        width: 350.w,
                        height: 400.h,
                        value: _compareValue,
                        before: CachedNetworkImage(
                            imageUrl: widget.taskModel.refImageUrl,
                            fit: BoxFit.cover),
                        after: CachedNetworkImage(
                            imageUrl: widget.taskModel.imageUrl!,
                            fit: BoxFit.cover),
                        onValueChanged: (value) {
                          setState(() => _compareValue = value);
                        },
                      ),
                    ),
                    Positioned(
                        left: 10.w,
                        top: 10.h,
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 9.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF000000),
                              borderRadius: BorderRadius.circular(12.w),
                              border: Border.all(
                                  color: const Color(0xFFB0B1A3), width: 0.5.w),
                            ),
                            child: Text(
                              "修复前",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  height: 1.0),
                            ))),
                    Positioned(
                        right: 10.w,
                        top: 10.h,
                        child: Container(
                            padding: EdgeInsets.fromLTRB(5.5.w, 6.h, 9.w, 6.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF000000),
                              borderRadius: BorderRadius.circular(12.w),
                              border: Border.all(
                                  color: const Color(0xFFB0B1A3), width: 0.5.w),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                    "assets/ai/aiPhotoFix/fix_star@2x.png",
                                    scale: 2),
                                SizedBox(width: 2.w),
                                Text(
                                  "修复后",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      height: 1.0),
                                ),
                              ],
                            )))
                  ],
                ),
              ),
            if (showMode == "before")
              Container(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.w),
                      child: SizedBox(
                        width: 350.w,
                        height: 400.h,
                        child: CachedNetworkImage(
                            imageUrl: widget.taskModel.refImageUrl,
                            fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                        left: 10.w,
                        top: 10.h,
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 9.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF000000),
                              borderRadius: BorderRadius.circular(12.w),
                              border: Border.all(
                                  color: const Color(0xFFB0B1A3), width: 0.5.w),
                            ),
                            child: Text(
                              "修复前",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  height: 1.0),
                            ))),
                  ],
                ),
              ),
            if (showMode == "after")
              Container(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.w),
                      child: SizedBox(
                        width: 350.w,
                        height: 400.h,
                        child: CachedNetworkImage(
                            imageUrl: widget.taskModel.imageUrl!,
                            fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                        right: 10.w,
                        top: 10.h,
                        child: Container(
                            padding: EdgeInsets.fromLTRB(5.5.w, 6.h, 9.w, 6.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF000000),
                              borderRadius: BorderRadius.circular(12.w),
                              border: Border.all(
                                  color: const Color(0xFFB0B1A3), width: 0.5.w),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                    "assets/ai/aiPhotoFix/fix_star@2x.png",
                                    scale: 2),
                                SizedBox(width: 2.w),
                                Text(
                                  "修复后",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      height: 1.0),
                                ),
                              ],
                            )))
                  ],
                ),
              ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildButton(
                  icon: "assets/ai/aiPhotoFix/img@2x.png",
                  title: "原图",
                  checked: showMode == "before",
                  onTap: () => setState(() => showMode = "before"),
                ),
                SizedBox(width: 25.w),
                buildButton(
                  icon: "assets/ai/aiPhotoFix/compare@2x.png",
                  title: "对比",
                  checked: showMode == "compare",
                  onTap: () => setState(() => showMode = "compare"),
                ),
                SizedBox(width: 25.w),
                buildButton(
                  icon: "assets/ai/aiPhotoFix/jd@2x.png",
                  title: "处理后",
                  checked: showMode == "after",
                  onTap: () => setState(() => showMode = "after"),
                ),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(60.w, 0, 60.w, 40.h),
        child: SizedBox(
          height: 60.h,
          child: FilledButton(
              onPressed: download,
              style: FilledButton.styleFrom(
                backgroundBuilder: (context, states, child) {
                  return Container(
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFF4BB1FF),
                            Color(0xFFE7F1FB),
                            Color(0xFFFAB1FF),
                          ],
                        )),
                    child: child,
                  );
                },
              ),
              child: Text("保存",
                  style: TextStyle(
                    color: const Color(0xFF1F2B52),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ))),
        ),
      ),
    );
  }

  Widget buildButton({
    required String icon,
    required String title,
    required bool checked,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90.w,
        height: 90.w,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(12),
          ),
          gradient: checked
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF4BB1FF),
                    Color(0xFFE7F1FB),
                    Color(0xFFFAB1FF),
                  ],
                )
              : null,
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                icon,
                scale: 2,
              ),
              SizedBox(height: 10.h),
              Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF1F2B52),
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
