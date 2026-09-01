import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/profile/beans/mine_videos_select_all_notification.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_video_management_page.dart';
import 'package:video_clip_edit/modules/profile/widgets/mine_videos_managment_page_view.dart';
import 'package:video_clip_edit/modules/profile/widgets/mine_videos_sliver_type_list_view.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_videos_management_provider.dart';

class MineVideosManagementPage extends StatefulWidget {
  const MineVideosManagementPage({
    super.key,
    this.type = AiCartoonVideoManagementPageType.normal,
  });
  final AiCartoonVideoManagementPageType? type;
  @override
  State<MineVideosManagementPage> createState() =>
      _MineVideosManagementPageState();
}

class _MineVideosManagementPageState extends State<MineVideosManagementPage> {
  final tips = "文件在云端存储7天，过期无法恢复，请及时保存。";
  final PageController _pageController = PageController();
  final ScrollController _categoryScrollController = ScrollController();
  final Map<int, double> _itemWidths = {};
// 创建 EventBus 实例
  final EventBus eventBus = EventBus();
  @override
  void initState() {
    context.read<MineVideosManagementProvider>().selectedCategory = 0;

    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index, BuildContext context) {
    double offset = 0;
    for (var i = 0; i < index; i++) {
      offset += _itemWidths[i] ?? 0;
    }

    offset = offset -
        (ByScreenUtils.screenWidth - 24.w) / 2 +
        (_itemWidths[index] != null ? (_itemWidths[index]! - 8) : 0) / 2;

    _categoryScrollController.animateTo(
      offset.clamp(
        0.0,
        _categoryScrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, eventBus),
      backgroundColor: ByColorUtil.WhiteColor,
      body: Stack(
        children: [
          NestedScrollView(
            physics: const ClampingScrollPhysics(), // 限制 NestedScrollView 的滚动行为
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 8.h,
                      left: 12.w,
                      right: 12.w,
                    ),
                    child: ByWidgetsUtil.commonTipsBar(tips),
                  ),
                ),
                MineVideosSliverTypeListView(
                  categoryScrollController: _categoryScrollController,
                  pageController: _pageController,
                  onSize: (Size size, int index) {
                    _itemWidths[index] = size.width;
                  },
                ),
              ];
            },
            body: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is ScrollEndNotification) {
                  final metrics = notification.metrics;
                  if (metrics is PageMetrics) {
                    int currentPage = metrics.page!.round();
                    context
                        .read<MineVideosManagementProvider>()
                        .updateSelectedCategory(currentPage);
                  }
                }
                return false;
              },
              child: MineVideosManagmentPageView(
                pageController: _pageController,
                onPageChanged: (int index) {
                  _onPageChanged(index, context);
                },
                eventBus: eventBus,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildAppBar(BuildContext context, EventBus eventBus) {
    return ByWidgetsUtil.appBar(
      context: context,
      title: "我的视频",
      actions: _buildActions(context),
      backgroundColor: Colors.white,
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final provider = context.read<MineVideosManagementProvider>();
    final worksEditing = context
        .select<MineVideosManagementProvider, bool>((p) => p.videosEditing);
    final selectAll =
        context.select<MineVideosManagementProvider, bool>((p) => p.selectAll);
    if (worksEditing) {
      return [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            final status = !selectAll;
            provider.updateSelectAllStatus(status);
            eventBus.fire(MineVideosSelectAllNotification(status));
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                selectAll
                    ? "assets/home/mat_icon_selected.png"
                    : "assets/home/mat_icon_unselected.png",
                width: 16.w,
                height: 16.h,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 6.w),
              ByWidgetsUtil.commonText(
                text: selectAll ? "取消全选" : "全选",
                fontSize: 14.sp,
              ),
              SizedBox(width: 12.w),
            ],
          ),
        )
      ];
    }

    /// 管理按钮
    return [
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          /// 更新编辑状态
          provider.updateWorksEditingState(true);
        },
        child: Container(
          height: 40.h,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: ByWidgetsUtil.commonText(
            text: "管理",
            fontSize: 14.sp,
          ),
        ),
      )
    ];
  }
}
