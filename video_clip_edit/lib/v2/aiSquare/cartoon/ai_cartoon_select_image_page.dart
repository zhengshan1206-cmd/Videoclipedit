import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_image_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/widgets/ai_cartoon_select_image_list_view.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_select_image_provider.dart';

class AiCartoonSelectImagePage extends StatefulWidget {
  const AiCartoonSelectImagePage({
    super.key,
    required this.isUpload,
    required this.imageBean,
    required this.pid,
    required this.onFinish,
  });

  final String pid;
  final bool isUpload;
  final AiCartoonImageBean imageBean;
  final void Function() onFinish;
  @override
  State<AiCartoonSelectImagePage> createState() =>
      _AiCartoonSelectImagePageState();
}

class _AiCartoonSelectImagePageState extends State<AiCartoonSelectImagePage> {
  final controller = EasyRefreshController();
  @override
  void initState() {
    super.initState();

    context.read<AiCartoonSelectImageProvider>().loadImages(
        pid: widget.pid,
        imgId: widget.imageBean.id,
        keyword: widget.imageBean.text);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AiCartoonProvider>();
    final selectedRatioId = provider.selectedRatioId;
    String ratio = selectedRatioId == -1
        ? "9:16"
        : provider.videoRatioBeans
            .firstWhere((e) => e.id == selectedRatioId)
            .scale;

    return Scaffold(
      appBar: ByWidgetsUtil.appBar(context: context, title: "选择图片"),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              children: [
                _buildSearch(),
                SizedBox(height: 10.h),
                Expanded(
                  child: AiCartoonSelectImageListView(
                    ratio: ratio,
                    pid: widget.pid,
                    imageBean: widget.imageBean,
                    controller: controller,
                  ),
                )
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 66.h,
            child: PhysicalModel(
              color: ByColorUtil.BlackColor,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: ByWidgetsUtil.commonBtn(
                  title: "确定",
                  borderRadius: 12.w,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  bgColor: ByColorUtil.LoginBtnBgColor.withOpacity(
                    context.select<AiCartoonSelectImageProvider, int>(
                                (p) => p.selectedImageIndex) !=
                            -1
                        ? 1
                        : 0.3,
                  ),
                  onClick: () {
                    final providerSelect =
                        context.read<AiCartoonSelectImageProvider>();
                    context.read<AiCartoonProvider>().regernateImage(
                          imgId: widget.imageBean.id,
                          isAi: 0,
                          imgUrl: providerSelect
                              .images[providerSelect.selectedImageIndex],
                          prompt: widget.imageBean.text,
                          onSuccess: () {
                            widget.onFinish();
                          },
                        );
                    ByNavRouterUtils.goBack(context);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildSearch() {
    return AiCartoonImageSearchView(
      pid: widget.pid,
      imageBean: widget.imageBean,
      controller: controller,
    );
  }
}

class AiCartoonImageSearchView extends StatefulWidget {
  const AiCartoonImageSearchView({
    super.key,
    required this.pid,
    required this.imageBean,
    required this.controller,
  });
  final String pid;
  final AiCartoonImageBean imageBean;
  final EasyRefreshController controller;

  @override
  State<AiCartoonImageSearchView> createState() =>
      _AiCartoonImageSearchViewState();
}

class _AiCartoonImageSearchViewState extends State<AiCartoonImageSearchView> {
  late TextEditingController controller;
  final FocusNode focusNode = FocusNode();
  static const int duration = 100;
  @override
  void dispose() {
    controller.removeListener(_textChanged);

    focusNode.removeListener(_focusNodeStatusChanged);
    super.dispose();
  }

  @override
  void initState() {
    controller = TextEditingController()..addListener(_textChanged);
    focusNode.addListener(_focusNodeStatusChanged);
    Future.microtask(() {
      FocusScope.of(context).unfocus();
    });
    super.initState();
  }

  /// 失去焦点时更新provider的描述信息
  _focusNodeStatusChanged() {
    final provider = context.read<AiCartoonSelectImageProvider>();
    provider.updateHasFocus(focusNode.hasFocus);
  }

  /// 更新字数
  _textChanged() {
    final provider = context.read<AiCartoonSelectImageProvider>();
    provider.updateKeywords(controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final hasFocus = context
        .select<AiCartoonSelectImageProvider, bool>((value) => value.hasFocus);
    return SizedBox(
      height: 44.h,
      child: ByWidgetsUtil.commonContainer(
        bgColor: const Color(0xFFF4F8F9),
        border: Border.all(
          color:
              hasFocus ? ByColorUtil.LoginBtnBgColor : const Color(0xFFF4F8F9),
        ),
        borerRadius: 8.w,
        child: Row(
          children: [
            AnimatedContainer(
              width: hasFocus ? 0 : 14.w,
              duration: const Duration(milliseconds: duration),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: duration),
              width: hasFocus ? 0 : 16,
              child: Image.asset(
                "assets/ai/ai_cartoon_picture_search.png",
                width: 16,
                height: 16,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: ExtendedTextField(
                maxLines: 1,
                controller: controller,
                focusNode: focusNode,
                autofocus: false,
                onChanged: (String value) {},
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  labelStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.normal,
                    color: ByColorUtil.CommonTextColor,
                  ),
                  hintText: "请输入相关词搜索图片",
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.normal,
                    color: ByColorUtil.CommonTextColor.withOpacity(0.3),
                  ),
                ),
                cursorColor: ByColorUtil.CommonTextColor,
              ),
            ),
            GestureDetector(
              onTap: () {
                if (controller.text.isEmpty) return;
                FocusScope.of(context).unfocus();
                widget.controller.callRefresh();
              },
              child: Container(
                width: 70.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: ByColorUtil.LoginBtnBgColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8.w),
                    bottomRight: Radius.circular(8.w),
                  ),
                ),
                alignment: Alignment.center,
                child: ByWidgetsUtil.commonText(
                  text: "搜索",
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  textColor: ByColorUtil.WhiteColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
