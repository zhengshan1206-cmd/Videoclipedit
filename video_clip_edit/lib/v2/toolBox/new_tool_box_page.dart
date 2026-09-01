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
    _categoryScrollController.dispose();

    _controller.removeListener(_onControllerOffsetChanged);
    _controller.dispose();
    super.dispose();
  }

  /// 仅随 PageView 页面切换滚动顶部分类条（须在 ScrollController 已 attach 后调用）
  void _syncCategoryTabScroll(int index) {
    if (!_categoryScrollController.hasClients) return;
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
      // 独立工具箱页：根节点垫底部安全区，避免 NestedScrollView + PageView 内 MediaQuery 拿不到手势条 inset 导致列表贴底
      body: SafeArea(
        bottom: true,
        top: false,
        left: false,
        right: false,
        child: NestedScrollView(
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
          body: ToolBoxPageView(
            pageController: _pageController,
            onPageChanged: (int index) {
              // 只用 PageView 的 onPageChanged 同步索引，避免 NestedScrollView 多次 ScrollEnd 与 postFrame 叠加导致进出页面奇偶次错乱
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                final p = context.read<NewToolBoxProvider>();
                if (p.selectedIndex != index) {
                  p.updateSelectedIndex(index);
                }
                _syncCategoryTabScroll(index);
              });
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
