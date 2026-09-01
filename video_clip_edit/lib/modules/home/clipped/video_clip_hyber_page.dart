import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/download/providers/download_provider.dart';
import 'package:video_clip_edit/modules/home/recreate/provdier/video_recreate_dubbing_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/hyber_clip_content_view.dart';

// ignore: must_be_immutable
class VideoClipHyberPage<T extends MaterialBaseProvider>
    extends StatefulWidget {
  int type;

  VideoClipHyberPage({
    super.key,
    this.showCommentary = true,
    this.type = 1,
  });

  ///  是否显示顶部的解说列表
  final bool showCommentary;

  @override
  State<VideoClipHyberPage> createState() => _VideoClipHyberPageState<T>();
}

class _VideoClipHyberPageState<T extends MaterialBaseProvider>
    extends State<VideoClipHyberPage<T>> {
  @override
  Widget build(BuildContext context) {
    final bool isClip = MaterialProviderTypeExt.providerTypeFromType(T) ==
        MaterialProviderType.clip;
    return Scaffold(
        appBar: ByWidgetsUtil.appBar(
            context: context, title: isClip ? "视频混剪" : "短剧二创"),
        backgroundColor: ByColorUtil.CommonPageBgColor,
        // body: HyberClipContentView<T>(
        //   showCommentary: widget.showCommentary,
        //   type: isClip,
        // )
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: context.read<T>()),
          ChangeNotifierProvider(
              create: (context) => VideoRecreateDubbingProvider()),
          ChangeNotifierProvider(
              create: (context) => DownloadProvider()),
        ],
        child:HyberClipContentView<T>(showCommentary: widget.showCommentary,type: isClip,),
      ),

    );
  }
}
