import 'package:flutter/material.dart';

class ScaleTransitionWidget extends StatefulWidget {
  final Widget child;
  final double? min;
  final double? max;
  final int? period;
  const ScaleTransitionWidget({
    super.key,
    required this.child,
    this.min,
    this.max,
    this.period,
  });

  @override
  State<ScaleTransitionWidget> createState() => _ScaleTransitionWidgetState();
}

class _ScaleTransitionWidgetState extends State<ScaleTransitionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: widget.period ?? 800),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: widget.min ?? 0.9,
      end: widget.max ?? 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRect(
        clipBehavior: Clip.antiAlias,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform(
              transform: Matrix4.identity()..scale(_animation.value),
              alignment: Alignment.center,
              filterQuality: FilterQuality.high,
              child: child,
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// 心跳按钮组件，实现左右放大缩小和波纹效果
class HeartbeatButtonWidget extends StatefulWidget {
  final Widget child;
  final double? minScale;
  final double? maxScale;
  final int? period;
  final Color? rippleColor;
  final int rippleCount;
  final double rippleMaxRadius;

  const HeartbeatButtonWidget({
    super.key,
    required this.child,
    this.minScale,
    this.maxScale,
    this.period,
    this.rippleColor,
    this.rippleCount = 3,
    this.rippleMaxRadius = 100.0,
  });

  @override
  State<HeartbeatButtonWidget> createState() => _HeartbeatButtonWidgetState();
}

class _HeartbeatButtonWidgetState extends State<HeartbeatButtonWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rippleController;
  late Animation<double> _scaleAnimation;
  late List<Animation<double>> _rippleAnimations;

  @override
  void initState() {
    super.initState();

    // 缩放动画控制器
    _scaleController = AnimationController(
      duration: Duration(milliseconds: widget.period ?? 600),
      vsync: this,
    )..repeat(reverse: true);

    // 缩放动画 - 只在X轴方向缩放（左右放大缩小）
    _scaleAnimation = Tween<double>(
      begin: widget.minScale ?? 0.95,
      end: widget.maxScale ?? 1.05,
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );

    // 波纹动画控制器
    _rippleController = AnimationController(
      duration: Duration(milliseconds: (widget.period ?? 600) * 2),
      vsync: this,
    )..repeat();

    // 创建多个波纹动画，每个波纹延迟启动
    _rippleAnimations = List.generate(
      widget.rippleCount,
      (index) {
        return Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _rippleController,
            curve: Interval(
              index / widget.rippleCount,
              (index + 1) / widget.rippleCount,
              curve: Curves.easeOut,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 波纹效果层
          ..._rippleAnimations.map((rippleAnimation) {
            return AnimatedBuilder(
              animation: rippleAnimation,
              builder: (context, child) {
                if (rippleAnimation.value == 0.0) {
                  return const SizedBox.shrink();
                }
                return CustomPaint(
                  painter: RipplePainter(
                    progress: rippleAnimation.value,
                    color: widget.rippleColor ?? Colors.white.withOpacity(0.3),
                    maxRadius: widget.rippleMaxRadius,
                  ),
                );
              },
            );
          }),
          // 按钮内容层（带缩放效果）
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.identity()
                  ..scale(_scaleAnimation.value, 1.0), // 只在X轴缩放
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
                child: widget.child,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 波纹绘制器
class RipplePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double maxRadius;

  RipplePainter({
    required this.progress,
    required this.color,
    required this.maxRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity((1.0 - progress) * color.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final radius = progress * maxRadius;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      radius,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant RipplePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.maxRadius != maxRadius;
  }
}
