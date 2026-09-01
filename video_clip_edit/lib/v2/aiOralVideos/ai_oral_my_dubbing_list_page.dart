import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_videos_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/widgets/ai_oral_my_Audio_list_view.dart';
import 'package:video_clip_edit/v2/aiOralVideos/beans/ai_oral_dubbing_clone_detail_bean.dart';

class AiOralMyDubbingListPage extends StatefulWidget {
  const AiOralMyDubbingListPage({
    super.key,
    this.showSelect = true,
  });

  final bool showSelect;

  @override
  State<AiOralMyDubbingListPage> createState() =>
      _AiOralMyDubbingListPageState();
}

class _AiOralMyDubbingListPageState extends State<AiOralMyDubbingListPage> {
  AiOralDubbingCloneDetailBean? detailBean;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final provider = context.read<AiOralVideosProvider>();
      provider.getUserAudioTTSList();
      provider.updateListeningDubbingId(-1);
      // 上报页面进入埋点
      ByNavigatorUtil.reportDataPoint(
        pageTag: "myworks_list_dub_works",
        operateType: "view",
        funcDetailTag: "",
        funcDetailImg: "",
      );
    });
  }

  @override
  void dispose() {
    ByAudioPlayer.sharedInstance.playerDispose();
    EasyLoading.dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dubbingBeanList = context
        .select<AiOralVideosProvider, List<AiOralDubbingCloneDetailBean>>(
            (value) => value.dubbingCloneDetailBeanList);

    bool hasDubbings = dubbingBeanList.isNotEmpty;
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(
        context: context,
        title: "我的音频",
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 12.w,
              right: 12.w,
            ),
            child: Column(
              children: [
                SizedBox(height: 10.h),
                Expanded(
                  child: hasDubbings
                      ? AiOralMyAudioListView(showSelect: widget.showSelect)
                      : _buildEmptyView(context),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return ByWidgetsUtil.commonListNoDataView(prompts: "暂无内容");
  }
}
