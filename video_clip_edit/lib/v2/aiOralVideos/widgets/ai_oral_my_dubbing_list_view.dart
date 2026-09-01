import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiOralVideos/beans/ai_oral_clone_bean.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_videos_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/widgets/ai_oral_my_dubbing_list_cell.dart';

///我的克隆声音页面
class AiOralMyDubbingListView extends StatefulWidget {
  const AiOralMyDubbingListView({
    super.key,
  });

  @override
  State<AiOralMyDubbingListView> createState() =>
      _AiOralMyDubbingListViewState();
}

class _AiOralMyDubbingListViewState extends State<AiOralMyDubbingListView> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final provider = context.read<AiOralVideosProvider>();
    int selectMyCloneMusicIndex = provider.selectMyCloneMusicIndex;
    Get.log("===克隆声音index====> ${selectMyCloneMusicIndex}");
    if (selectMyCloneMusicIndex != -1) {
      if (selectMyCloneMusicIndex > 2) {
        double moveSpace = (selectMyCloneMusicIndex - 2) * 70;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          /// 此时视图已经完成构建，可以安全地调用animateTo()
          scrollController.animateTo(
            moveSpace.w,
            duration: const Duration(milliseconds: 500),
            curve: Curves.linear,
          );
          Get.log("执行自动滚动=== ${selectMyCloneMusicIndex}");
          if (mounted) {
            setState(() {});
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cloneBeans =
        context.select<AiOralVideosProvider, List<AiOralCloneBean>>(
      (value) => value.cloneBeans,
    );
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.only(
        bottom: 66.h + ByScreenUtils.bottomSafeHeight,
      ),
      itemCount: cloneBeans.length,
      itemBuilder: (context, index) {
        return AiOralMyDubbingListCell(
          index: index,
          bean: cloneBeans[index],
        );
      },
    );
  }
}

class AiOralDubbingListCell extends StatelessWidget {
  const AiOralDubbingListCell({
    super.key,
    required this.index,
    required this.content,
  });

  final int index;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ByWidgetsUtil.commonText(
            text: "$index".padLeft(2, '0'),
            fontSize: 14.sp,
            height: 1.4,
            fontWeight: FontWeight.bold,
            textColor: ByColorUtil.TabTextColorSelected,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ByWidgetsUtil.commonText(
              text: content,
              maxLines: 100,
              height: 1.2,
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
            ),
          )
        ],
      ),
    );
  }
}
