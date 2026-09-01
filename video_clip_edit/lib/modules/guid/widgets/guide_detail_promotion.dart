/*
  guide_detail_promotion.dart
  攻略弹窗详情页
  该页面用于展示使用教程的详情页
  增加推广按钮功能

  暂时废弃
  Created by duncy on 25/4/17.
*/

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_permission_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/widgets/ai_videos_downoad_dialog.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/widgets/video_player_widget.dart';

import '../beans/guide_pop_beans.dart';

class GuidePromotionPage extends StatefulWidget {
  final String videoUrl;
  final GuidePopBean guidePopBean;

  const GuidePromotionPage({
    super.key,
    required this.videoUrl,
    required this.guidePopBean,
  });

  @override
  State<GuidePromotionPage> createState() => _GuidePromotionPageState();
}

class _GuidePromotionPageState extends State<GuidePromotionPage>
    with RouteAware {
  _GuidePromotionPageState();
  final GlobalKey<VideoPlayerWidgetState> _playerKey =
      GlobalKey<VideoPlayerWidgetState>();

  bool deleteSuccess = false;

  @override
  void dispose() {
    _stopPlayer();
    super.dispose();
  }

  ///快手推广教程 常见问题view
  Widget helpView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Image.asset(
            "assets/toolbox/icon_guide_pop_page_des.png",
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 8),
          ByWidgetsUtil.commonText(
            text: widget.guidePopBean.promotionType == 2
                ? "快手授权推广教程"
                : "抖音授权推广教程",
            fontSize: 20,
            fontWeight: FontWeight.w600,
            textColor: const Color(0xFF5B4BF7),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(
        context: context,
        title: "视频详情",
      ),
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Positioned.fill(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: ByWidgetsUtil.commonTipsBar("内容由AI生成仅供参考，禁止利用功能从事违法活动。"),
              ),
            ),
            SliverToBoxAdapter(
              child: helpView(context),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: VideoPlayerWidget(
                    key: _playerKey,
                    url: widget.videoUrl,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: _bottomSettingWidget(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: _buildBottomQuestionView(),
              ),
            ),

            // 添加 SliverList
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  // 获取当前问题
                  final question =
                      widget.guidePopBean.questions?[index]["ask"] ?? "";
                  // 获取当前问题
                  final answer =
                      widget.guidePopBean.questions?[index]["answer"] ?? "";
                  // 返回空的 ListTile
                  return ListTile(
                    title: _buildQuestionDialogView(context, question, answer),
                  );
                },
                childCount: widget.guidePopBean.questions?.length ?? 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomSettingWidget(BuildContext context) {
    return Column(
      children: [
        ByWidgetsUtil.btnWithIcon(
          height: 50.h,
          boxDecoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF461AC),
                  Color(0xFF824EFA),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )),
          title:
              widget.guidePopBean.promotionType == 2 ? "快手一键授权推广" : "抖音授权推广教程",
          iconPath: "assets/toolbox/icon_guide_pop_page_des.png",
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          onClick: () async {},
        ),
        SizedBox(height: 12.h),
        Container(
          height: 50.h,
          child: ByWidgetsUtil.commonBtn(
            title: "保存到本地",
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            textColor: const Color(0xFF5B4BF7),
            bgColor: const Color(0xFFEAEEFF),
            // height: 50.h,
            onClick: () async {
              if (await ByPermissionUtils.storage() == false) return;
              final videoUrl = widget.videoUrl;
              showDialog(
                context: context,
                builder: (c) {
                  return AiVideosDownoadDialog(
                    contents: "",
                    maxLine: 10,
                    cancelBtnTitle: "取消",
                    confirmBtnTitle: "确定",
                    confirmCallback: () {},
                    videoUrls: [videoUrl],
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }

  ///常见问题view
  Widget _buildBottomQuestionView() {
    return Column(
      children: [
        Row(
          children: [
            Image.asset(
              "assets/toolbox/icon_guide_question.png",
              width: 18,
              height: 18,
            ),
            SizedBox(width: 8.w),
            ByWidgetsUtil.commonText(
              text: "常见问题",
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              textColor: Colors.black,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionDialogView(
      BuildContext context, String question, String answer) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        children: [
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ByWidgetsUtil.commonText(
              text: question,
              maxLines: 0,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              textColor: Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: ByWidgetsUtil.commonText(
              maxLines: 0,
              text: answer,
              fontSize: 14.sp,
              fontWeight: FontWeight.w300,
              textColor: const Color(0xFF0B1843),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  void _stopPlayer() {
    _playerKey.currentState?.stopPlay();
  }
}
