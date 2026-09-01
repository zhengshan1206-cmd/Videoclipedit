import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
// import 'package:chewie/chewie.dart'; // HarmonyOS 不支持 chewie
import 'package:video_player/video_player.dart';
import '../../../utils/comon/by_colors.dart';
import '../../../utils/comon/by_navigator_util.dart';
import '../beans/anime_bean.dart';
import 'anime_detail_setting_page.dart';

class AnimeScrollPage extends StatefulWidget {
  const AnimeScrollPage({
    super.key,
    required this.dataList,
    required this.index,
  });
  final List<AnimeBean> dataList;
  final int index;

  @override
  State<AnimeScrollPage> createState() => _AnimeScrollPageState();
}

class _AnimeScrollPageState extends State<AnimeScrollPage> {
  late final PageController _pageController;
  int _currentPage = 0;

  final Map<int, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.index);
    _currentPage = widget.index;
    _initController(_currentPage);
    _initController(_currentPage + 1);
    _initController(_currentPage - 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _playCurrentVideo();
      });
    });
  }

  @override
  void dispose() {
    for (final c in _videoControllers.values) {
      c.dispose();
    }
    _videoControllers.clear();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initController(int pageIndex) async {
    if (_videoControllers.containsKey(pageIndex) || pageIndex < 0) return;

    final int realIndex = pageIndex % widget.dataList.length;
    final AnimeBean video = widget.dataList[realIndex];

    final VideoPlayerController videoController =
        VideoPlayerController.networkUrl(Uri.parse(video.videoUrl!));

    await videoController.initialize();
    await videoController.setLooping(true);

    setState(() {
      _videoControllers[pageIndex] = videoController;
    });
  }

  void _disposeController(int pageIndex) {
    _videoControllers[pageIndex]?.dispose();
    _videoControllers.remove(pageIndex);
  }

  void _playCurrentVideo() {
    _videoControllers[_currentPage]?.play();

    _videoControllers.forEach((index, controller) {
      if (index != _currentPage) controller.pause();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) {
      final c = _videoControllers[_currentPage];
      if (c != null && c.value.isPlaying) {
        c.pause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                /// [SafeArea] 已预留底部系统区域，此处只需为「做同款」按钮留出视觉间距。
                bottom: 60.h,
              ),
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: 1000,
                onPageChanged: (int page) {
                  setState(() => _currentPage = page);

                  _initController(page + 1);
                  _initController(page - 1);
                  _disposeController(page + 3);
                  _disposeController(page - 3);

                  _playCurrentVideo();
                },
                itemBuilder: (context, index) {
                  final int realIndex = index % widget.dataList.length;
                  final AnimeBean video = widget.dataList[realIndex];

                  return _buildVideoCard(video, index);
                },
              ),
            ),

            Positioned(
              left: 12,
              right: 12,
              bottom: 10.h,
              child: SizedBox(
                height: 50,
                child: ByWidgetsUtil.commonBtn(
                  borderRadius: 12,
                  fontSize: 16.sp,
                  title: "做同款",
                  onClick: () {
                    ByNavigatorUtil.checkLogin(
                      context: context,
                      nextStepEvent: () {
                        final int realIndex =
                            _currentPage % widget.dataList.length;
                        final AnimeBean video = widget.dataList[realIndex];
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: false,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.viewInsetsOf(ctx).bottom,
                              ),
                              child: AnimeDetailSettingPage(bean: video),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            Positioned(
              left: 5,
              top: 10,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 56,
                  height: AppBar().preferredSize.height,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    "assets/home/icon_back_white.png",
                    width: 16,
                    height: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCard(AnimeBean video, int pageIndex) {
    final controller = _videoControllers[pageIndex];
    return GestureDetector(
      onTap: () {
        if (controller == null) return;
        controller.value.isPlaying ? controller.pause() : controller.play();
        setState(() {});
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (controller != null && controller.value.isInitialized)
            LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                final ratio = controller.value.aspectRatio;
                if (ratio <= 0) {
                  return Center(child: VideoPlayer(controller));
                }
                double width;
                double height;
                if (ratio > w / h) {
                  width = w;
                  height = w / ratio;
                } else {
                  height = h;
                  width = h * ratio;
                }
                return Center(
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: VideoPlayer(controller),
                  ),
                );
              },
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          // 标题叠在底部
          Positioned(
            left: 20,
            right: 20,
            bottom: 10,
            child: ByWidgetsUtil.commonText(
              text: video.title ?? '',
              fontSize: 20.sp,
              textColor: ByColorUtil.WhiteColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
