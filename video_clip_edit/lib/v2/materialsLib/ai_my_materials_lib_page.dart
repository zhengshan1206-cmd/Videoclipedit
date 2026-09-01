import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'dart:ui' as ui;

class AiMyMaterialsLibPage extends StatefulWidget {
  const AiMyMaterialsLibPage({super.key});

  @override
  State<AiMyMaterialsLibPage> createState() => _AiMyMaterialsLibPageState();
}

class _AiMyMaterialsLibPageState extends State<AiMyMaterialsLibPage>
    with SingleTickerProviderStateMixin {
  final List<String> _categories = ["素材包", "唯美风景", "高清横屏"];

  late final TabController _controller = TabController(
    length: _categories.length,
    vsync: this,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Stack(
        children: [
          _buildContents(),
          _buildAppBar(context),
        ],
      ),
    );
  }

  _buildContents() {
    return Positioned.fill(
      child: Column(
        children: [
          SizedBox(height: ByScreenUtils.navigationBarHeight),
          AiMyMaterialLibTabbar(
              controller: _controller, categories: _categories),
        ],
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
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage("assets/ai/ai_app_bar_bg.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: ByWidgetsUtil.appBar(
          context: context,
          title: "素材库",
          showBottmLine: true,
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}

class AiMyMaterialLibTabbar extends StatefulWidget {
  const AiMyMaterialLibTabbar({
    super.key,
    required TabController controller,
    required List<String> categories,
  })  : _controller = controller,
        _categories = categories;

  final TabController _controller;
  final List<String> _categories;

  @override
  State<AiMyMaterialLibTabbar> createState() => _AiMyMaterialLibTabbarState();
}

class _AiMyMaterialLibTabbarState extends State<AiMyMaterialLibTabbar> {
  ui.Image? image;

  @override
  void initState() {
    super.initState();

    _loadImage();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      width: double.infinity,
      child: TabBar(
        controller: widget._controller,
        tabs: List.generate(
          widget._categories.length,
          (idx) {
            return Text(widget._categories[idx]);
          },
        ),
        labelStyle: TextStyle(
          color: const Color(0xFF020C2A),
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          color: const Color(0xFF020C2A),
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        indicator: image == null
            ? const BoxDecoration(color: Colors.transparent)
            : CustomTabIndicator(image: image!),
        indicatorWeight: 0,
        indicatorColor: Colors.transparent,
        isScrollable: true,
        dividerHeight: 0,
      ),
    );
  }

  void _loadImage() async {
    final data = await DefaultAssetBundle.of(context).load(
      'assets/ai/clip/ai_material_lib_tab_indicator.png',
    );
    final bytes = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();

    setState(() {
      image = frame.image;
    });
  }
}

class CustomTabIndicator extends Decoration {
  final ui.Image image;
  const CustomTabIndicator({required this.image});
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomBoxPainter(image: image);
  }
}

class _CustomBoxPainter extends BoxPainter {
  final ui.Image image;
  const _CustomBoxPainter({
    required this.image,
  });
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    // 检查 configuration.size 是否为 null，避免在切换时出现空值异常
    final size = configuration.size;
    if (size == null || size.width <= 0 || size.height <= 0) {
      return;
    }

    try {
      final Paint paint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      final indicatorW = 40.w;
      final indicatorH = 8.w;
      final width = size.width;
      final offsetX = offset.dx + (width - indicatorW) * 0.5;
      final offsetY = size.height - indicatorH;
      const scale = 0.5;
      final offsetReal = Offset(offsetX / scale, offsetY / scale);
      canvas.scale(scale);
      canvas.drawImage(image, offsetReal, paint);
    } catch (e) {
      // 捕获任何绘制异常，避免崩溃
      return;
    }
  }
}
