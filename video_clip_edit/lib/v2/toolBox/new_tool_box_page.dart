import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/v2/toolBox/widgets/tool_box_page_view.dart';
import 'package:video_clip_edit/v2/toolBox/widgets/sliver_type_list_view.dart';
import 'package:video_clip_edit/v2/toolBox/providers/new_tool_box_provider.dart';

class NewToolBoxPage extends StatefulWidget {
  const NewToolBoxPage({
    super.key,
  });

  @override
  State<NewToolBoxPage> createState() => _NewToolBoxPageState();
}

class _NewToolBoxPageState extends State<NewToolBoxPage> {
  final _controller = ScrollController();
  final PageController _pageController = PageController();
  final ScrollController _categoryScrollController = ScrollController();
  final Map<int, double> _itemWidths = {};

  @override
  void initState() {
    context.read<NewToolBoxProvider>().currentOffset = 0;
    context.read<NewToolBoxProvider>().selectedIndex = 0;
    context.read<NewToolBoxProvider>().loadBannerData();

    _addListener();

    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();

    _controller.removeListener(_onControllerOffsetChanged);
    _controller.dispose();
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
      body: NestedScrollView(
        physics: const ClampingScrollPhysics(), // 限制 NestedScrollView 的滚动行为
        controller: _controller,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverTypeListView(
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
                    .read<NewToolBoxProvider>()
                    .updateSelectedIndex(currentPage);
              }
            }
            return false;
          },
          child: ToolBoxPageView(
            pageController: _pageController,
            onPageChanged: (int index) {
              _onPageChanged(index, context);
            },
          ),
        ),
      ),
    );
  }

  void _addListener() {
    _controller.addListener(_onControllerOffsetChanged);
  }

  _onControllerOffsetChanged() {
    final offset = _controller.offset;
    context.read<NewToolBoxProvider>().updateOffset(offset);
  }
}
