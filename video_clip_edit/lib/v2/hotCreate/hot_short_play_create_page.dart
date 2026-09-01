import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/hotCreate/single_short_play_list_page.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/short_play_create_provider.dart';
import 'package:video_clip_edit/v2/hotCreate/widgets/short_play_sliver_pinned_header_view.dart';
import 'package:video_clip_edit/widgets/common/right_navigation_bar.dart';

import '../../modules/guid/providers/guide_pop_providers.dart';

class HotShortPlayCreatePage extends StatefulWidget {
  const HotShortPlayCreatePage(
      {super.key, this.type = "2", this.title = "短剧创作"});

  final String? type;
  final String? title;

  @override
  State<HotShortPlayCreatePage> createState() => _HotNovelCreatePageState();
}

class _HotNovelCreatePageState extends State<HotShortPlayCreatePage> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();

    _loadData();

    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final provider = context.read<ShortPlayCreateProvider>();
    final offset = _controller.offset;
    provider.updateOffset(offset);
  }

  void _loadData() {
    final provider = context.read<ShortPlayCreateProvider>();
    provider.loadBroadcast();
    provider.loadBroadcast();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      body: Stack(
        children: [
          _buildBody(context),
          _buildAppBar(context),
        ],
      ),
    );
  }

  _buildBody(BuildContext context) {
    return Positioned.fill(
      child: NestedScrollView(
        /// 限制 NestedScrollView 的滚动行为
        physics: const ClampingScrollPhysics(),
        controller: _controller,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            ShortPlaySliverPinnedHeaderView(
              type: widget.type ?? "2",
            ),
          ];
        },
        body: ChangeNotifierProvider.value(
          value: context.read<ShortPlayCreateProvider>(),
          child: SingleShortPlayListPage(
            prePagePath: "/hot_short_play_create_page",
            type: widget.type ?? "2",
          ),
        ),
      ),
    );
  }

  Positioned _buildAppBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: ByScreenUtils.navigationBarHeight,
        decoration: const BoxDecoration(
          color: Color(0xFFF4F7F8),
          image: DecorationImage(
            image: AssetImage("assets/ai/ai_app_bar_bg.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          bottom: ByWidgetsUtil.appBarBottom(),
          bottomOpacity: 0,
          elevation: 0,
          leading: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ByNavRouterUtils.goBack(context);
            },
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              child: Image.asset(
                "assets/home/icon_back.png",
                width: 16,
                height: 16,
              ),
            ),
          ),
          title: ByWidgetsUtil.commonText(
            text: "短剧创作",
            textColor: ByColorUtil.CommonTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          centerTitle: true,
          actions: const [
            Center(
              //短剧创作 short_play_create
              // child: RightNavigationBar(entranceType: 3),
              child: RightNavigationBar(
                  entranceType: GuideEntranceType.shortPlayCreate),
            )
          ],
        ),
      ),
    );
  }
}
