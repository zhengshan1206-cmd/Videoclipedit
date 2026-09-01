import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/providers/keyboard_visible_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_provider.dart';
import 'package:video_clip_edit/v2/hotReplica/widgets/replica_components.dart';
import 'package:video_clip_edit/v2/hotReplica/widgets/replica_font_select_view.dart';
import 'package:video_clip_edit/v2/hotReplica/widgets/replica_common_input_view.dart';
import 'package:video_clip_edit/v2/hotReplica/widgets/replica_common_input_field.dart';
import 'package:video_clip_edit/v2/hotReplica/providers/hot_case_replica_provider.dart';
import 'package:video_clip_edit/v2/hotReplica/widgets/replica_clip_material_select_view.dart';
import 'package:video_clip_edit/v2/hotReplica/widgets/replica_clip_material_opening_select_view.dart';

class HotCaseReplicaPage extends StatefulWidget {
  const HotCaseReplicaPage({super.key});

  @override
  State<HotCaseReplicaPage> createState() => _HotCaseReplicaPageState();
}

class _HotCaseReplicaPageState extends State<HotCaseReplicaPage> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(),
          _buildContents(context),
          _buildAppBar(context),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Positioned _buildContents(BuildContext context) {
    return Positioned.fill(
      child: CustomScrollView(
        controller: _controller,
        slivers: [
          SliverToBoxAdapter(
              child: Stack(
            children: [
              SizedBox(height: 490.h),
              _buildTopBgImg(),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 240.h,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: ReplicaCommonInputView<HotCaseReplicaProvider>(
                    maxWords: 500,
                    padding: EdgeInsets.zero,
                    onFoucusChanged: (hasFocus, value) {
                      context
                          .read<HotCaseReplicaProvider>()
                          .updateHasLinkFocus(hasFocus);
                    },
                  ),
                ),
              )
            ],
          )),
          _buildHeader(
            top: 20.h,
            bottom: 9.h,
            context: context,
            title: "请输入标题",
            icon: "assets/replica/replica_header_edit.svg",
          ),
          _buildTitleInputiew(context),
          SliverPadding(
            padding: EdgeInsets.only(top: 23.h),
            sliver: const ReplicaMoreSettingsHeader(),
          ),
          _builTips(context),
          const ReplicaClipMaterialSelectView(),
          const ReplicaClipMaterialOpeningSelectView(),
          const ReplicaFontSelectView(),
          SliverToBoxAdapter(
              child: SizedBox(
            height: 110.h + ByScreenUtils.bottomSafeHeight,
          ))
        ],
      ),
    );
  }

  _buildHeader({
    required BuildContext context,
    required String title,
    required String icon,
    required double top,
    required double bottom,
    Widget? rightWidget,
  }) {
    return SliverPadding(
      padding: EdgeInsets.only(
        top: top,
        bottom: bottom,
      ),
      sliver: SliverToBoxAdapter(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 12.w),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ByWidgetsUtil.svgAsset(
                  filePath: icon,
                  width: 16,
                  height: 16,
                ),
                SizedBox(width: 4.w),
                ByWidgetsUtil.commonText(
                  text: title,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            const Spacer(),
            rightWidget ?? Container(),
            SizedBox(width: 12.w),
          ],
        ),
      ),
    );
  }

  _buildAppBar(BuildContext context) {
    return const ReplicaAppBar();
  }

  Positioned _buildTopBgImg() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Image.asset(
        "assets/replica/hot_case_replica_banner.png",
        fit: BoxFit.fitWidth,
      ),
    );
  }

  _builTips(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(left: 12.w),
      sliver: SliverToBoxAdapter(
        child: ByWidgetsUtil.commonText(
          text: "*若不手动选择素材，系统自动智能匹配。",
          fontSize: 12.sp,
          textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
        ),
      ),
    );
  }

  _buildTitleInputiew(BuildContext context) {
    return SliverToBoxAdapter(
      child: ReplicaInputFiled(
        maxWords: 15,
        initText: context.read<HotCaseReplicaProvider>().title,
        onFoucusChanged: (hasFocus, value) {
          context.read<HotCaseReplicaProvider>().updateHasTitleFocus(hasFocus);
          if (!hasFocus) {
            context.read<HotCaseReplicaProvider>().updateTitle(value);
          }
        },
      ),
    );
  }

  _buildBottomBar(BuildContext context) {
    final keyboardVisible = context.select<KeyboardVisibleProvider, bool>(
        (value) => value.keyboardVisible);
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Offstage(
        offstage: keyboardVisible,
        child: const ReplicaBottomBar(),
      ),
    );
  }

  void _loadData() {
    final provider = context.read<AiClipProvider>();

    /// 视频比例
    provider.loadVideoRatios();

    /// 字幕样式
    provider.loadVideoFonts();
  }
}
