import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/main/controllers/main_controller.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_video_player.dart';
import 'package:video_clip_edit/v2/aiVideo/pages/ai_dynamic_video_page.dart';

import '../../../providers/ai_chat_providers.dart';
import '../../../routes/route_utils.dart';
import '../../../utils/comon/by_nav_router_utils.dart';
import '../../aiVideo/models/ai_video_square_model.dart';
import '../../aiVideo/pages/new_ai_video_page.dart';
import '../../aiVideo/provider/ai_video_provider.dart';
import '../chat/ai_chat_page.dart';
import '../draw/ai_draw_page.dart';
import '../draw/providers/ai_draw_provider.dart';
import '../song/ai_song_page.dart';
import '../song/provider/ai_song_provider.dart';
import 'home_page_scroll_list_view.dart';

class HomePageScrollListCell extends StatelessWidget {
  final int id;
  final String text;
  const HomePageScrollListCell({
    super.key,
    required this.id,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 7.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipOval(
            child: Container(
              width: 8.w,
              height: 8.w,
              alignment: Alignment.center,
              color: ByColorUtil.LoginBtnBgColor.withOpacity(0.2),
              child: Container(
                width: 4.w,
                height: 4.w,
                decoration: BoxDecoration(
                  color: ByColorUtil.LoginBtnBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SizedBox(width: 5.w),
          Expanded(
            child: ByWidgetsUtil.commonText(
              text: text,
            ),
          )
        ],
      ),
    );
  }
}

///
class Marquee extends StatefulWidget {
  final List<String> texts;
  final Duration scrollDuration;
  final double textSize;
  final Color textColor;
  final Color highlightedColor;
  final int id;

  const Marquee({
    Key? key,
    required this.texts,
    this.scrollDuration = const Duration(seconds: 2),
    this.textSize = 14.0,
    this.textColor = Colors.white,
    this.highlightedColor = Colors.yellow,
    required this.id,
  }) : super(key: key);

  @override
  _MarqueeState createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> {
  ScrollController _scrollController = ScrollController();
  Timer? _timer;
  int _currentIndex = 0;
  double _scrollOffset = 0.0;
  bool couldAnimate = true;
  final GlobalKey _listViewKey = GlobalKey();
  int _outOfViewCount = 0;

  ///滑出视图外的item count数量
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScroll();
      _scrollController.addListener(_onScroll);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  _startScroll() async {
    // await Future.delayed(const Duration(seconds: 2));
    _timer = Timer.periodic(widget.scrollDuration, (_) {
      if (widget.texts.isEmpty && !couldAnimate) {
        return;
      }
      _currentIndex = (_currentIndex + 1) % widget.texts.length;
      _scrollOffset = _currentIndex * (widget.textSize.sp + 15.h); // 10 为行间距
      // log("scroller ${_scrollController.positions.length}");
      if (_scrollController.hasClients) {
        try {
          _scrollController.animateTo(
            _scrollOffset,
            duration: widget.scrollDuration,
            curve: Curves.linear,
          );
        } catch (e) {
          log("滚动异常========${e.toString()}");
        }
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _handleTapDown(Offset globalPosition) {
    log("id======> ${widget.id}");
    final RenderBox box =
        _listViewKey.currentContext!.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(globalPosition);
    double itemHeight = 31.w;
    int index = (localOffset.dy / itemHeight).floor();
    log("index===> $index");
    if (_outOfViewCount > 0) {
      index += _outOfViewCount;
    }
    if (index >= 0 && index < widget.texts.length) {
      int id = widget.id;
      String text = widget.texts[index];
      if (id == 1) {
        final provider = AiDrawProvider();
        provider.desc = text;
        ByNavRouterUtils.push(
          context,
          ChangeNotifierProvider(
            create: (context) => provider,
            child: const AiDrawPage(),
          ),
        );
      } else if (id == 2) {
        Get.find<MainController>().tabChanged(1);
        final provider2 = context.read<AiChatProviders>();
        provider2.firstDesQuestion = text;
        eventBus.fire(const ClickAiChatPageEvent());
      } else if (id == 4) {
        final provider = AiVideoProvider();
        // ByNavRouterUtils.push(
        //   context,
        //   ChangeNotifierProvider(
        //     create: (context) => provider,
        //     child: NewAiVideoPage(
        //       initType: AiVideoGenerationType.textToVideo,
        //       prompt: text,
        //     ),
        //   ),
        // );
        ByNavRouterUtils.push(
          context,
          AIDynamicVideoPage(
            initType: AiVideoGenerationType.textToVideo,
            prompt: text,
          ),
        );
      } else if (id == 5) {
        final provider = AiSongProvider();
        provider.aiMusicHintText = text;
        ByNavRouterUtils.push(
          context,
          ChangeNotifierProvider(
            create: (context) => provider,
            child: AiSongPage(),
          ),
        );
      }
      print('Clicked item index: $index');
    }
  }

  void _onScroll() {
    double offsetHeight = 8.h;
    if (_outOfViewCount > 0) {
      offsetHeight = 18.h;
    }
    _outOfViewCount =
        (_scrollController.offset ~/ (widget.textSize.sp + offsetHeight))
            .clamp(0, widget.texts.length);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // key: _listViewKey,
      onTapDown: (TapDownDetails details) {
        _handleTapDown(details.globalPosition);
      },
      child: ListView.builder(
        // shrinkWrap: true,
        // physics: const NeverScrollableScrollPhysics(),
        key: _listViewKey,
        physics: const AlwaysScrollableScrollPhysics(), // 确保可以滚动
        padding: EdgeInsets.zero,
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        itemCount: widget.texts.length,
        itemBuilder: (context, index) {
          return InkWell(
            child: SizedBox(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 7.5.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    index == _currentIndex
                        ? ClipOval(
                            child: Container(
                              width: 8.w,
                              height: 8.w,
                              alignment: Alignment.center,
                              color:
                                  ByColorUtil.LoginBtnBgColor.withOpacity(0.2),
                              child: Container(
                                width: 4.w,
                                height: 4.w,
                                decoration: BoxDecoration(
                                  color: ByColorUtil.LoginBtnBgColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(
                            width: 8,
                          ),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: ByWidgetsUtil.commonText(
                          fontSize: widget.textSize.sp,
                          text: widget.texts[index],
                          textColor: index == _currentIndex
                              ? const Color(0XFF5B4BF7)
                              : const Color(0XFF0B1843)),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
