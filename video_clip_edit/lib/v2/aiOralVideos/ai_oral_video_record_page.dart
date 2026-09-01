import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_time_utils.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_permission_utils.dart';

class AiOralVideoRecordPage extends StatefulWidget {
  const AiOralVideoRecordPage({
    super.key,
    required this.onRecordFinished,
  });

  final void Function(String videoPath, bool isFromCamera) onRecordFinished;

  @override
  State<AiOralVideoRecordPage> createState() => _AiOralVideoRecordPageState();
}

class _AiOralVideoRecordPageState extends State<AiOralVideoRecordPage> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;

  /// 当前摄像头索引（前置/后置）偶数为前置 奇数为后置
  int _currentCameraIndex = 2;

  /// 相机初始化完成
  bool _isInitialized = false;

  /// 是否正在录制视频
  bool _isRecording = false;

  /// 保存录制视频路径
  String? _videoPath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      // 查找前置摄像头
      CameraDescription frontCamera = _cameras.firstWhere(
        (camera) => _currentCameraIndex.isEven
            ? camera.lensDirection == CameraLensDirection.front
            : camera.lensDirection == CameraLensDirection.back,
      );
      _cameraController = CameraController(
        frontCamera,
        fps: 30,
        ResolutionPreset.veryHigh,
        videoBitrate: 3000000,
      );
      await _cameraController?.initialize();
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      byDebugPrint("初始化相机失败: $e");
      BotToast.showText(text: "初始化相机失败");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // 开始录制视频
  Future<void> _startRecording() async {
    if (await ByPermissionUtils.videos() == false) return;
    if (!_cameraController!.value.isInitialized) return;
    if (_cameraController!.value.isRecordingVideo) return;

    try {
      // 获取文件存储路径
      final directory = await getTemporaryDirectory();
      final videoPath = '${directory.path}/${DateTime.now()}.mp4';

      await _cameraController?.startVideoRecording();

      setState(() {
        _isRecording = true;
        _videoPath = videoPath;
      });
    } catch (e) {
      byDebugPrint("录制视频时出错：$e");
      BotToast.showText(text: "录制视频出错");
    }
  }

  // 停止录制视频
  Future<void> _stopRecording() async {
    if (!_cameraController!.value.isRecordingVideo) return;

    try {
      final XFile? file = await _cameraController?.stopVideoRecording();

      setState(() {
        _isRecording = false;
        _videoPath = file?.path;
      });

      if (file != null && await file.length() > 0) {
        final fileT = File(file.path);

        // 使用 VideoPlayerController 加载视频
        final videoPlayerController = VideoPlayerController.file(fileT);
        await videoPlayerController.initialize(); // 初始化视频控制器
        final seconds = videoPlayerController.value.duration.inSeconds;
        if (seconds < 15 || seconds > 120) {
          BotToast.showText(text: "请控制视频时长在15~120秒之间");
          return;
        }
        ByNavRouterUtils.goBack(context);
        widget.onRecordFinished.call(_videoPath!, true);
      }
    } catch (e) {
      byDebugPrint("停止录制时出错：$e");
      BotToast.showText(text: "视频保存出错");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColorUtil.BlackColor,
      body: Column(
        children: [
          SizedBox(
              height: ByScreenUtils.topSafeHeight + kToolbarHeight * 0.5 - 15),
          Row(
            children: [
              SizedBox(width: 12.w),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  ByNavRouterUtils.goBack(context);
                },
                child: ByWidgetsUtil.svgAsset(
                  filePath:
                      "assets/ai/oralVideos/ai_oral_videos_record_back.svg",
                  width: 30,
                  height: 30,
                ),
              )
            ],
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: _isInitialized
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10.w),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(),
                        Positioned.fill(
                            child: CameraPreview(_cameraController!)),
                        Positioned.fill(
                          child: Column(
                            children: [
                              const Spacer(),
                              ByWidgetsUtil.svgAsset(
                                filePath:
                                    "assets/ai/oralVideos/ai_oral_camera_area.svg",
                                width: 331.w,
                                height: 402.h,
                              ),
                              SizedBox(height: 11.h),
                              GestureDetector(
                                onTap: () {
                                  if (_isRecording) {
                                    _stopRecording();
                                  } else {
                                    _startRecording();
                                  }
                                },
                                child: ByWidgetsUtil.svgAsset(
                                  filePath:
                                      "assets/ai/oralVideos/ai_oral_camera_btn_record.svg",
                                  width: 84.w,
                                  height: 84.w,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Counter(
                                key: UniqueKey(),
                                isStart: _isRecording,
                              ),
                              SizedBox(height: 25.h),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
          SizedBox(
            height: 74.h,
            child: Row(
              children: [
                SizedBox(width: 12.w),
                _buildBottomBarItem(
                  "assets/ai/oralVideos/ai_oral_camera_album.svg",
                  context,
                  () async {
                    final assets = await ByCommonUtils.pickVideos(
                      context,
                      maxCount: 1,
                      durationLimit: 120,
                      durationLimitMin: 15,
                    );
                    if (assets.isEmpty) return;
                    final file = await assets.first.file;
                    final existsSync = file?.existsSync() ?? false;
                    if (existsSync == false) return;
                    widget.onRecordFinished.call(file!.path, false);
                    ByNavRouterUtils.goBack(context);
                  },
                ),
                const Spacer(),
                _buildBottomBarItem(
                  "assets/ai/oralVideos/ai_oral_camera_exchange.svg",
                  context,
                  () {
                    if (_cameras.isEmpty) {
                      return;
                    }
                    _currentCameraIndex +=1;
                    _initializeCamera();
                  },
                ),
                SizedBox(width: 12.w),
              ],
            ),
          ),
          SizedBox(height: ByScreenUtils.bottomSafeHeight),
        ],
      ),
    );
  }

  Widget _buildBottomBarItem(
    String icon,
    BuildContext context,
    GestureTapCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44.w,
        height: 44.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.w),
          color: Colors.white.withOpacity(0.2),
        ),
        child: ByWidgetsUtil.svgAsset(
          filePath: icon,
          width: 32,
          height: 32,
        ),
      ),
    );
  }
}

class Counter extends StatefulWidget {
  const Counter({
    super.key,
    required this.isStart,
  });
  final bool isStart;

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  Timer? _timer;
  double _seconds = 0;

  _resetTimer() {
    _seconds = 0;
    _timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    _resetTimer();
    if (widget.isStart && mounted) {
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          if (mounted) {
            setState(() {
              _seconds += 1;
            });
          }
        },
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ByWidgetsUtil.commonText(
      text: widget.isStart ? ByTimeUtils.formatWithSeconds(_seconds) : "录制",
      fontSize: 14.sp,
      textColor: Colors.white,
      fontWeight: FontWeight.w500,
    );
  }
}
