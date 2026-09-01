import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_cases_list_view.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_cases_tweets_list_view.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_song_list_view.dart';
import 'package:video_clip_edit/v2/aiVideo/models/ai_video_square_model.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/v2/aiVideo/widgets/ai_cases_videos_list_view.dart';

class NewSameCaseSquarePage extends StatefulWidget {
  const NewSameCaseSquarePage({
    super.key,
    required this.sqid,
  });

  /// 1绘图 2数字人 3推文 4动态视频 5AI写歌 6推文-小说推文 7推文-混剪
  final String sqid;

  @override
  State<NewSameCaseSquarePage> createState() => _NewSameCaseSquarePageState();
}

class _NewSameCaseSquarePageState extends State<NewSameCaseSquarePage> {
  final EasyRefreshController _controller = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(
        context: context,
        title: _getTitle(),
        showBottmLine: true,
      ),
      body: EasyRefresh(
        refreshOnStart: true,
        controller: _controller,
        onLoad: () => _loadData(context: context, reset: false),
        onRefresh: () => _loadData(context: context, reset: true),
        child: CustomScrollView(
          slivers: [
            _getSquareList(),
          ],
        ),
      ),
    );
  }

  _loadData({
    required BuildContext context,
    bool reset = false,
  }) {
    final provider = context.read<AiSquareProvider>();
    switch (widget.sqid) {
      /// AI绘画
      case "1":
        provider.loadAiSquareData(
          reset: reset,
          onSuccess: (hasMore) {
            if (reset) {
              _controller.finishRefresh();
              _controller.resetFooter();
            } else {
              _controller.finishLoad(
                hasMore ? IndicatorResult.success : IndicatorResult.noMore,
              );
            }
          },
          onFailed: () {
            _controller.finishLoad(IndicatorResult.fail);
          },
        );
        break;

      /// AI推文
      case "3":
      case "6":
      case "7":
        String jumptype = widget.sqid;
        if (jumptype == "6") {
          jumptype = "1";
        }
        if (jumptype == "7") {
          jumptype = "2";
        }
        provider.loadTweetsSquareData(
          reset: reset,
          jumptype: jumptype,
          onSuccess: (hasMore) {
            if (reset) {
              _controller.finishRefresh();
              _controller.resetFooter();
            } else {
              _controller.finishLoad(
                hasMore ? IndicatorResult.success : IndicatorResult.noMore,
              );
            }
          },
          onFailed: () {
            _controller.finishLoad(IndicatorResult.fail);
          },
        );
        break;

      /// 动态视频
      case "4":
      case "8":
      case "9":
      case "10":
        final code = int.parse(widget.sqid);
        provider.loadVideosSquareData(
          type: code > 7 ? AiVideoGenerationType.fromJson(code - 7) : null,
          reset: reset,
          onSuccess: (hasMore) {
            if (reset) {
              _controller.finishRefresh();
              _controller.resetFooter();
            } else {
              _controller.finishLoad(
                hasMore ? IndicatorResult.success : IndicatorResult.noMore,
              );
            }
          },
          onFailed: () {
            _controller.finishLoad(IndicatorResult.fail);
          },
        );
        break;

      case "5":

        /// AI写歌
        provider.getSquareList(
          reset: reset,
          onSuccess: (hasMore) {
            if (reset) {
              _controller.finishRefresh();
              _controller.resetFooter();
            } else {
              _controller.finishLoad(
                hasMore ? IndicatorResult.success : IndicatorResult.noMore,
              );
            }
          },
          onFailed: () {
            _controller.finishLoad(IndicatorResult.fail);
          },
        );
        break;
    }
  }

  _getTitle() {
    switch (widget.sqid) {
      case "1":
        return "AI绘图广场";
      case "3":
        return "AI推文广场";
      case "6":
        return "AI推文广场";
      case "7":
        return "AI智能混剪广场";
      case "4":
      case "8":
      case "9":
      case "10":
        return "AI动态视频广场";
      case "5":
        return "AI音乐广场";
      default:
        return "";
    }
  }

  Widget _getSquareList() {
    switch (widget.sqid) {
      case "1":
        return const AiCasesListView();
      case "3":
      case "6":
      case "7":
        return const AiCasesTweetsListView();
      case "4":
      case "8":
      case "9":
      case "10":
        return const AiCasesVideosListView(prePagePath: "/same_case_square",);
      case "5":
        return const AiSongListView();
      default:
        return Container();
    }
  }
}
