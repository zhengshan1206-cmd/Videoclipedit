import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:video_clip_edit/modules/home/beans/cloud_video_bean.dart';
import 'package:video_clip_edit/v2/hotCreate/widgets/short_play_list_cell.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/short_play_create_provider.dart';

class SingleShortPlayListPage extends StatefulWidget {
  final String prePagePath;
  final String type;
  const SingleShortPlayListPage({
    super.key,
    this.prePagePath = "",
    this.type = "2",
  });

  @override
  State<SingleShortPlayListPage> createState() => _ShortPlayListPageState();
}

class _ShortPlayListPageState extends State<SingleShortPlayListPage>
    with AutomaticKeepAliveClientMixin {
  final EasyRefreshController _easyRefreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );
  bool _hasMore = true;

  @override
  bool get wantKeepAlive => true;
  @override
  initState() {
    super.initState();
    _refresh(context: context);
  }

  // 上拉加载更多
  Future<void> _loadMore({
    required BuildContext context,
  }) async {
    final provider = context.read<ShortPlayCreateProvider>();
    provider.loadCloudVideos(
      isRefresh: false,
      type: widget.type,
      onSuccess: (hasMore) {
        _hasMore = hasMore;
        _easyRefreshController.finishLoad(
            hasMore ? IndicatorResult.success : IndicatorResult.noMore, true);
        setState(() {});
      },
      onFail: () {
        _easyRefreshController.finishLoad(IndicatorResult.fail, false);
        setState(() {});
      },
    );
  }

  // 下拉刷新
  Future<void> _refresh({
    required BuildContext context,
  }) async {
    final provider = context.read<ShortPlayCreateProvider>();
    provider.loadCloudVideos(
      type: widget.type,
      isRefresh: false,
      onSuccess: (hasMore) {
        _hasMore = hasMore;
        _easyRefreshController.finishRefresh(IndicatorResult.success, false);
        if (hasMore) {
          _easyRefreshController.resetFooter();
        }
      },
      onFail: () {
        _easyRefreshController.finishRefresh(IndicatorResult.fail, false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final shortPlayBeans =
        context.select<ShortPlayCreateProvider, List<CloudVideoListBean>>(
      (value) => value.shortPlayBeans,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: EasyRefresh(
        // refreshOnStart: true,
        triggerAxis: Axis.vertical,
        controller: _easyRefreshController,
        onLoad: () => _loadMore(context: context),
        footer: null,
        onRefresh: () => _refresh(context: context),
        child: shortPlayBeans.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/home/nothing_bg.png',
                      width: 180,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '搜索无结果',
                      style: TextStyle(color: Color(0xFF999999), fontSize: 16),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: shortPlayBeans.length,
                itemBuilder: (context, index) {
                  if (index < 0 || index >= shortPlayBeans.length)
                    return const SizedBox();
                  return ShortPlayListCell(
                    fromPrompt: true,
                    shortPlayBean: shortPlayBeans[index],
                    index: index,
                    noMore: !_hasMore,
                    isLast: index == shortPlayBeans.length - 1,
                    prePagePath: widget.prePagePath,
                  );
                },
              ),
      ),
    );
  }
}
