import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../utils/comon/by_colors.dart';
import '../../../utils/comon/by_navigator_util.dart';
import '../../../utils/comon/by_screen_utils.dart';
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

  // 存储视频控制器，避免重复创建
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, ChewieController> _chewieControllers = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.index);
    _currentPage = widget.index;
    // 预加载初始页面及相邻页面的控制器
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
    // 释放所有控制器资源
    _videoControllers.forEach((_, controller) => controller.dispose());
    _chewieControllers.forEach((_, controller) => controller.dispose());
    _pageController.dispose();
    super.dispose();
  }

  // 初始化视频控制器
  Future<void> _initController(int pageIndex) async {
    if (_videoControllers.containsKey(pageIndex) || pageIndex < 0) return;

    final int realIndex = pageIndex % widget.dataList.length;
    final AnimeBean video = widget.dataList[realIndex];

    // 创建视频控制器
    final VideoPlayerController videoController =
        VideoPlayerController.networkUrl(Uri.parse(video.videoUrl!));

    await videoController.initialize();

    // 创建Chewie控制器（封装播放UI）
    final ChewieController chewieController = ChewieController(
      videoPlayerController: videoController,
      autoPlay: false,
      looping: true, // 视频循环播放
      showControls: true, // 隐藏默认控制栏
      allowFullScreen: false,
      subtitle: Subtitles([
        Subtitle(
          index: 0,
          start: Duration.zero,
          end: const Duration(seconds: 300),
          text: video.title ?? '',
        ),
      ]),
      subtitleBuilder: (context, subtitle) {
        return Container(
          height: 35.w,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20, bottom: 10),
          child: ByWidgetsUtil.commonText(
            text: video.title ?? '',
            fontSize: 20.sp,
            textColor: ByColorUtil.WhiteColor,
            fontWeight: FontWeight.bold,
          ),
        );
      },
      // customControls: Container(),
      optionsTranslation: OptionsTranslation(
        playbackSpeedButtonText: '倍速',
        cancelButtonText: '取消',
      ),
      materialProgressColors: ChewieProgressColors(playedColor: Colors.white),
      cupertinoProgressColors: ChewieProgressColors(playedColor: Colors.white),
      showControlsOnInitialize: false,
    );

    setState(() {
      _videoControllers[pageIndex] = videoController;
      _chewieControllers[pageIndex] = chewieController;
    });
  }

  // 释放指定页面的控制器
  void _disposeController(int pageIndex) {
    _videoControllers[pageIndex]?.dispose();
    _chewieControllers[pageIndex]?.dispose();
    _videoControllers.remove(pageIndex);
    _chewieControllers.remove(pageIndex);
  }

  // 播放当前页面视频，暂停其他视频
  void _playCurrentVideo() {
    // 播放当前视频
    _chewieControllers[_currentPage]?.play();

    // 暂停其他页面视频
    _chewieControllers.forEach((index, controller) {
      if (index != _currentPage) controller.pause();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 检查当前页面是否在最前面，如果不是则暂停
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) {
      if (_chewieControllers[_currentPage] != null &&
          _chewieControllers[_currentPage]!.isPlaying) {
        _chewieControllers[_currentPage]!.pause();
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
                bottom: ByScreenUtils.bottomSafeHeight + 60,
              ),
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical, // 垂直滑动
                itemCount: 1000, // 大数模拟无限循环
                onPageChanged: (int page) {
                  setState(() => _currentPage = page);

                  // 预加载相邻页面，释放过远页面
                  _initController(page + 1);
                  _initController(page - 1);
                  _disposeController(page + 3);
                  _disposeController(page - 3);

                  // 播放当前视频
                  _playCurrentVideo();
                },
                itemBuilder: (context, index) {
                  final int realIndex = index % widget.dataList.length;
                  final AnimeBean video = widget.dataList[realIndex];

                  return _buildVideoCard(video, index);
                },
              ),
            ),

            ///做同款
            Positioned(
              left: 12,
              right: 12,
              bottom: ByScreenUtils.bottomSafeHeight + 10,
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
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return AnimeDetailSettingPage(bean: video);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            // ///关闭遮罩
            // Positioned(
            //   left: 0,
            //   right: 0,
            //   top: 0,
            //   child: Container(
            //     height: 80,
            //     decoration: BoxDecoration(
            //       gradient: LinearGradient(
            //         begin: Alignment.topCenter,
            //         end: Alignment.bottomCenter,
            //         colors: [const Color(0xFF000000), const Color(0xFF000000).withOpacity(0)])
            //     ),
            //   )
            // ),

            ///关闭
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

  // 构建单个视频卡片
  Widget _buildVideoCard(AnimeBean video, int pageIndex) {
    return GestureDetector(
      onTap: () {
        // 点击切换播放/暂停
        final controller = _chewieControllers[pageIndex];
        if (controller != null) {
          controller.isPlaying ? controller.pause() : controller.play();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 视频播放器或封面图
          _chewieControllers[pageIndex] != null
              ? Chewie(controller: _chewieControllers[pageIndex]!)
              : const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
        ],
      ),
    );
  }
}
