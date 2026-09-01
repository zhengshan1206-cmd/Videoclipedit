import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiClip/ai_clip_materials_page.dart';
import 'package:video_clip_edit/v2/aiClip/ai_clip_mine_material_page.dart';
import 'package:video_clip_edit/v2/aiClip/ai_clip_materials_shows_page.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_material_provider.dart';
import 'package:video_clip_edit/v2/aiClip/widgets/ai_clip_material_tab_view.dart';

class AiMaterialSelectPage extends StatefulWidget {
  const AiMaterialSelectPage({
    super.key,
    this.isHotReplica = false,
    this.shareUrl = "",
  });

  final bool isHotReplica;
  final String shareUrl;
  @override
  State<AiMaterialSelectPage> createState() => _AiMaterialSelectPageState();
}

class _AiMaterialSelectPageState extends State<AiMaterialSelectPage> {
  late final PageController _controller;
  @override
  void initState() {
    final provider = context.read<AiMaterialProvider>();
    _controller =
        PageController(initialPage: provider.currentType.rawValue - 1);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(
        context: context,
        title: "选择混剪素材",
      ),
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Column(
        children: [
          Offstage(
            offstage: context.select<AiMaterialProvider, AiMaterialType>(
                    (value) => value.currentType) ==
                AiMaterialType.show,
            child: Container(
              color: ByColorUtil.WhiteColor,
              padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 8.h),
              height: 38.h,
              child: ByWidgetsUtil.commonTipsBar("请选择1-5个素材片段，如不选择将随机使用素材。",
                  padding: EdgeInsets.symmetric(horizontal: 10.w)),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 9.h),
            color: Colors.white,
            child: AiClipMaterialTabView(
              controller: _controller,
              items: /*widget.isHotReplica
                  ? */["剪辑素材", "我的素材"]
                  /*: const ["剪辑素材", "短剧素材", "我的素材"],*/
            ),
          ),
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (value) {
                // if (widget.isHotReplica) {
                  context.read<AiMaterialProvider>().updateMaterialType(
                      AiMaterialTypeExt.typeFromRawValue(
                          value == 0 ? value + 1 : value + 2));
                // } else {
                //   context.read<AiMaterialProvider>().updateMaterialType(
                //       AiMaterialTypeExt.typeFromRawValue(value + 1));
                // }
              },
              children: widget.isHotReplica
                  ? [
                      AiClipMaterialsPage(
                        isHotReplica: widget.isHotReplica,
                        shareUrl: widget.shareUrl,
                      ),
                      const AiClipMineMaterialPage(),
                    ]
                  : [
                      AiClipMaterialsPage(
                        isHotReplica: widget.isHotReplica,
                        shareUrl: widget.shareUrl,
                      ),
                      // const AiClipMaterialsShowsPage(),
                      const AiClipMineMaterialPage(),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}
