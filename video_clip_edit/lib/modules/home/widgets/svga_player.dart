import 'package:flutter/material.dart';
import 'package:svgaplayer_flutter_rhr/svgaplayer_flutter.dart';

class SvgaPlayer extends StatefulWidget {
  final String url;
  const SvgaPlayer({
    super.key,
    required this.url,
  });

  @override
  State<SvgaPlayer> createState() => _SvgaPlayerState();
}

class _SvgaPlayerState extends State<SvgaPlayer>
    with SingleTickerProviderStateMixin {
  SVGAAnimationController? animationController;

  @override
  void initState() {
    animationController = SVGAAnimationController(vsync: this);
    _loadAnimation();
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  void _loadAnimation() async {
    final videoItem = await SVGAParser.shared.decodeFromAssets(widget.url);

    ///防止离开当前页面后依然执行代码造成报错
    if (animationController == null) return;
    animationController?.videoItem = videoItem;
    animationController
        ?.repeat()
        .whenComplete(() => animationController?.videoItem = null);
  }

  @override
  Widget build(BuildContext context) {
    if (animationController == null) return Container();
    return SVGAImage(
      animationController!,
      fit: BoxFit.fill,
      clearsAfterStop: false,
      allowDrawingOverflow: false,
    );
  }
}

// class SvgaPlayer extends StatefulWidget {
//   final String url;
//   const SvgaPlayer({
//     super.key,
//     required this.url,
//   });

//   @override
//   State<SvgaPlayer> createState() => _SvgaPlayerState();
// }

// class _SvgaPlayerState extends State<SvgaPlayer>
//     with SingleTickerProviderStateMixin {
//   SVGAAnimationController? animationController;

//   @override
//   void initState() {
//     animationController = SVGAAnimationController(vsync: this);
//     _loadAnimation();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     animationController?.dispose();
//     super.dispose();
//   }

//   void _loadAnimation() async {
//     final videoItem = await SVGAParser.shared.decodeFromAssets(widget.url);
//     animationController?.videoItem = videoItem;
//     animationController
//         ?.repeat()
//         .whenComplete(() => animationController?.videoItem = null);
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (animationController == null) return Container();
//     return SVGAImage(animationController!);
//   }
// }
