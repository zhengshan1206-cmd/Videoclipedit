import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiClip/ai_clip_cloud_material_page.dart';
import 'package:video_clip_edit/v2/aiClip/ai_clip_mine_material_page.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_opening_provider.dart';
import 'package:video_clip_edit/v2/aiClip/widgets/ai_clip_material_opening_tab_view.dart';

class AiClipMaterialOpeningPage extends StatefulWidget {
  const AiClipMaterialOpeningPage({
    super.key,
  });

  @override
  State<AiClipMaterialOpeningPage> createState() =>
      _AiClipMaterialOpeningPageState();
}

class _AiClipMaterialOpeningPageState extends State<AiClipMaterialOpeningPage> {
  late final PageController _controller;

  @override
  void initState() {
    _controller = PageController(
        initialPage:
            context.read<AiClipOpeningProvider>().currentType.rawValue);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(
        context: context,
        title: "选择片头素材",
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 9.h, bottom: 19.h),
            color: Colors.white,
            child: AiClipMaterialOpeningTabView(
              controller: _controller,
              items: const ["云端片头素材", "我的素材"],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (value) {
                context.read<AiClipOpeningProvider>().updateMaterialType(
                    AiMaterialOpeningTypeExt.typeFromRawValue(value));
              },
              children: const [
                AiClipCloudMaterialPage(),
                AiClipMineMaterialPage(paddingTop: 0, isOpening: true)
              ],
            ),
          )
        ],
      ),
    );
  }
}
