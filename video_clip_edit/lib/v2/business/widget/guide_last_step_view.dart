import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FingerScaleAnimateView extends StatefulWidget {
  const FingerScaleAnimateView({super.key});

  @override
  State<FingerScaleAnimateView> createState() => _FingerScaleAnimateViewState();
}

class _FingerScaleAnimateViewState extends State<FingerScaleAnimateView>
    with SingleTickerProviderStateMixin {
  late AnimationController _aniController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器（时长 500ms，控制动画速度）
    _aniController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 2. 缩放动画：从 1.0（原尺寸）→ maxScale（放大后尺寸）
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _aniController,
        curve: Curves.linear,
      ), // 动画曲线（自然过渡）
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _aniController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _aniController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform.translate(
            offset: Offset(-32.5.w, -22.5.w),
            child: const ExpandedAnimateView()),
        Transform.translate(
            offset: Offset(-10.w, 10.w),
            child: SizedBox(
              width: 69.w,
              height: 69.w,
              child: AnimatedBuilder(
                animation: _aniController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    origin: Offset(-32.w, -10.w),
                    child: Image.asset(
                      'assets/v2/promote/promote-5.png',
                      width: 69.w,
                      height: 69.w,
                    ),
                  );
                },
              ),
            )),
      ],
    );
  }
}

class ExpandedAnimateView extends StatefulWidget {
  const ExpandedAnimateView({super.key});

  @override
  State<ExpandedAnimateView> createState() => _ExpandedAnimateViewState();
}

class _ExpandedAnimateViewState extends State<ExpandedAnimateView>
    with SingleTickerProviderStateMixin {
  late AnimationController _aniController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器（时长 300ms，控制动画速度）
    _aniController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // 2. 缩放动画：从 1.0（原尺寸）→ maxScale（放大后尺寸）
    _scaleAnimation = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(
        parent: _aniController,
        curve: Curves.linear,
      ), // 动画曲线（自然过渡）
    );

    // 3. 透明度动画：从 1.0（完全显示）→ 0.0（完全消失）
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _aniController,
        curve: Curves.linear,
      ), // 与缩放动画用同一曲线
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _aniController.repeat();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 75.w,
      height: 75.w,
      child: Stack(
        children: [
          _bulildSingleView(0, 4),
          _bulildSingleView(1, 4),
          _bulildSingleView(2, 4),
          _bulildSingleView(3, 4),
        ],
      ),
    );
  }

  Widget _bulildSingleView(int index, int count) {
    double avg = 1 / count;
    return Center(
      child: AnimatedBuilder(
        animation: _aniController,
        builder: (context, child) {
          double op = _opacityAnimation.value + avg * index >= 1
              ? _opacityAnimation.value - avg * (count - index)
              : _opacityAnimation.value + avg * index;
          double sc = _scaleAnimation.value + avg * (count - index) > 1.0
              ? _scaleAnimation.value - avg * index
              : _scaleAnimation.value + avg * (count - index);
          return Opacity(
            opacity: op,
            child: Transform.scale(
              scale: sc,
              child: Container(
                width: 75.w,
                height: 75.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(37.5.w),
                    // color: Color(0xFF53EC27),
                    color: op > 0.5
                        ? Color(0xFFFFFFFF).withOpacity(0.6)
                        : Colors.transparent,
                    border: Border.all(
                        width: 3, color: Color(0xFFFFFFFF).withOpacity(0.6))),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _aniController.dispose();
    super.dispose();
  }
}

/// 扫光效果组件（从左上到右下）
///
/// 可用于任何 Widget 的扫光动画效果
///
/// 使用示例：
/// ```dart
/// DiagonalShimmerWidget(
///   child: Image.asset('assets/image.png'),
///   duration: Duration(milliseconds: 1500),
///   shimmerColor: Colors.white,
///   shimmerOpacity: 0.6,
///   autoPlay: true,
///   loop: false, // 设置为 true 可循环播放
/// )
/// ```
class DiagonalShimmerWidget extends StatefulWidget {
  /// 需要添加扫光效果的子组件
  final Widget child;

  /// 动画持续时间，默认 1500ms
  final Duration duration;

  /// 扫光条宽度比例，默认 0.3（相对于对角线长度）
  final double shimmerWidthRatio;

  /// 扫光颜色，默认白色
  final Color shimmerColor;

  /// 扫光透明度，默认 0.6
  final double shimmerOpacity;

  /// 是否自动播放，默认 true
  final bool autoPlay;

  /// 动画曲线，默认 easeInOut
  final Curve curve;

  /// 混合模式，默认 overlay
  final BlendMode blendMode;

  /// 是否循环播放，默认 false（只播放一次）
  final bool loop;

  /// 扫光次数，默认 2 次
  final int repeatCount;

  /// 每次扫光时长，默认 500ms
  final Duration shimmerDuration;

  /// 每次扫光后的延迟时间，默认 500ms
  final Duration delayDuration;

  const DiagonalShimmerWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.shimmerWidthRatio = 0.3,
    this.shimmerColor = Colors.white,
    this.shimmerOpacity = 0.6,
    this.autoPlay = true,
    this.curve = Curves.easeInOut,
    this.blendMode = BlendMode.overlay,
    this.loop = false,
    this.repeatCount = 2,
    this.shimmerDuration = const Duration(milliseconds: 1500),
    this.delayDuration = const Duration(milliseconds: 500),
  });

  @override
  State<DiagonalShimmerWidget> createState() => _DiagonalShimmerWidgetState();
}

class _DiagonalShimmerWidgetState extends State<DiagonalShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  int _currentRepeatCount = 0;
  Timer? _delayTimer;
  bool _showShimmer = true; // 控制是否显示扫光效果

  @override
  void initState() {
    super.initState();
    // 使用 shimmerDuration 作为单次扫光时长
    _shimmerController = AnimationController(
      vsync: this,
      duration: widget.shimmerDuration,
    );
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: widget.curve,
      ),
    );

    // 监听动画完成事件
    _shimmerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onShimmerComplete();
      }
    });

    // 如果自动播放，启动扫光动画
    if (widget.autoPlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.loop) {
          _shimmerController.repeat();
        } else {
          _startShimmerSequence();
        }
      });
    }
  }

  /// 开始扫光序列
  void _startShimmerSequence() {
    _currentRepeatCount = 0;
    _showShimmer = true;
    _playNextShimmer();
  }

  /// 播放下一次扫光
  void _playNextShimmer() {
    if (_currentRepeatCount < widget.repeatCount) {
      _shimmerController.reset();
      _shimmerController.forward();
      _currentRepeatCount++;
    }
  }

  /// 扫光完成回调
  void _onShimmerComplete() {
    if (_currentRepeatCount < widget.repeatCount) {
      // 延迟后播放下一次扫光
      _delayTimer?.cancel();
      _delayTimer = Timer(widget.delayDuration, () {
        if (mounted) {
          _playNextShimmer();
        }
      });
    } else {
      // 所有扫光完成后，清除扫光效果
      if (mounted) {
        setState(() {
          _showShimmer = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _shimmerController.dispose();
    super.dispose();
  }

  /// 手动触发扫光动画
  void play() {
    if (widget.loop) {
      _shimmerController.repeat();
    } else {
      _startShimmerSequence();
    }
  }

  /// 停止动画
  void stop() {
    _shimmerController.stop();
  }

  /// 重置动画
  void reset() {
    _shimmerController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          widget.child,
          // 扫光效果遮罩层（只在需要时显示）
          if (_showShimmer)
            AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return Positioned.fill(
                  child: CustomPaint(
                    painter: DiagonalShimmerPainter(
                      progress: _shimmerAnimation.value,
                      shimmerWidthRatio: widget.shimmerWidthRatio,
                      shimmerColor: widget.shimmerColor,
                      shimmerOpacity: widget.shimmerOpacity,
                      blendMode: widget.blendMode,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// 水平扫光效果绘制器（从左到右）
class DiagonalShimmerPainter extends CustomPainter {
  final double progress;
  final double shimmerWidthRatio;
  final Color shimmerColor;
  final double shimmerOpacity;
  final BlendMode blendMode;

  DiagonalShimmerPainter({
    required this.progress,
    this.shimmerWidthRatio = 0.3,
    this.shimmerColor = Colors.white,
    this.shimmerOpacity = 0.8,
    this.blendMode = BlendMode.overlay,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress < -1.0 || progress > 1.0) {
      return; // 动画未开始或已结束时不绘制
    }

    // 先裁剪到容器边界，确保不超出
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // 计算对角线长度（从左上到右下）
    final double diagonalLength =
        math.sqrt(size.width * size.width + size.height * size.height);

    // 扫光条的宽度 = 对角线长度 * 比例
    final double shimmerWidth = diagonalLength * shimmerWidthRatio;

    // progress 从 -1.0 到 1.0，计算扫光条中心在对角线上的位置
    // -1.0 对应左上角外，1.0 对应右下角外
    final double centerProgress = (progress + 1.0) / 2.0; // 转换为 0.0 到 1.0
    final double centerDistance = centerProgress * diagonalLength;

    // 对角线的角度
    final double angle = math.atan(size.height / size.width);

    // 对角线的单位向量
    final double dx = size.width / diagonalLength;
    final double dy = size.height / diagonalLength;

    // 计算扫光条的中心点坐标（在对角线上）
    final double centerX = centerDistance * dx;
    final double centerY = centerDistance * dy;

    // 保存画布状态
    canvas.save();

    // 将画布旋转到对角线方向
    canvas.translate(centerX, centerY);
    canvas.rotate(angle);
    canvas.translate(-centerX, -centerY);

    // 计算扫光条的边界（在对角线坐标系中）
    final double halfWidth = shimmerWidth / 2;

    // 创建一个足够大的矩形来绘制扫光条
    // 矩形的宽度是扫光条宽度，高度要足够大以覆盖整个区域
    final double rectHeight = diagonalLength * 2;

    final Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          shimmerColor.withOpacity(0.0),
          shimmerColor.withOpacity(0.0),
          shimmerColor.withOpacity(shimmerOpacity * 0.3),
          shimmerColor.withOpacity(shimmerOpacity * 0.7),
          shimmerColor.withOpacity(shimmerOpacity),
          shimmerColor.withOpacity(shimmerOpacity * 0.7),
          shimmerColor.withOpacity(shimmerOpacity * 0.3),
          shimmerColor.withOpacity(0.0),
          shimmerColor.withOpacity(0.0),
        ],
        stops: const [0.0, 0.15, 0.3, 0.4, 0.5, 0.6, 0.7, 0.85, 1.0],
      ).createShader(
        Rect.fromLTWH(
          centerDistance - halfWidth,
          -rectHeight / 2,
          shimmerWidth,
          rectHeight,
        ),
      )
      ..blendMode = blendMode;

    // 在对角线坐标系中绘制扫光条
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerDistance, 0),
        width: shimmerWidth,
        height: rectHeight,
      ),
      paint,
    );

    // 恢复画布状态
    canvas.restore();
  }

  @override
  bool shouldRepaint(DiagonalShimmerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.shimmerWidthRatio != shimmerWidthRatio ||
        oldDelegate.shimmerColor != shimmerColor ||
        oldDelegate.shimmerOpacity != shimmerOpacity ||
        oldDelegate.blendMode != blendMode;
  }
}
