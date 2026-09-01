import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/profile/beans/mine_score_record_bean.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_scores_provider.dart';

class MineScoreRecordsPage extends StatefulWidget {
  const MineScoreRecordsPage({super.key});

  @override
  State<MineScoreRecordsPage> createState() => _MineScoreRecordsPageState();
}

class _MineScoreRecordsPageState extends State<MineScoreRecordsPage> {
  final EasyRefreshController _controller = EasyRefreshController(
      controlFinishRefresh: true, controlFinishLoad: true);
  @override
  void initState() {
    super.initState();

    _reset();
  }

  @override
  Widget build(BuildContext context) {
    final scoreBeans =
        context.select<MineScoresProvider, List<MineScoreRecordBean>>(
      (value) => value.scoreBeans,
    );
    final isEmpty = scoreBeans.isEmpty;
    // final scoreRequestCount =
    //     context.read<MineScoresProvider>().scoreRequestCount;
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(
        context: context,
        title: "积分记录",
      ),
      body: EasyRefresh(
        refreshOnStart: true,
        controller: _controller,
        onRefresh: () {
          _loadRecords(context, reset: true, controller: _controller);
        },
        onLoad: () {
          _loadRecords(context, reset: false, controller: _controller);
        },
        child: isEmpty
            ? ByWidgetsUtil.commonListNoDataView(prompts: "暂无积分记录")
            // scoreRequestCount > 0
            //     ? ByWidgetsUtil.commonListNoDataView(prompts: "暂无积分记录")
            //     : Container()
            : ListView.builder(
                itemCount: scoreBeans.length,
                itemBuilder: (context, index) => MineScoreRecordsCell(
                  index: index,
                  bean: scoreBeans[index],
                ),
              ),
      ),
    );
  }

  void _loadRecords(
    BuildContext context, {
    bool reset = false,
    required EasyRefreshController controller,
  }) {
    byDebugPrint("----_loadRecords");
    final provider = context.read<MineScoresProvider>();
    provider.loadScoresRecords(
      reset: reset,
      controller: controller,
    );
  }

  void _reset() {
    byDebugPrint("----reset");
    final provider = context.read<MineScoresProvider>();
    provider.scoreRequestCount = 0;
  }
}

class MineScoreRecordsCell extends StatelessWidget {
  const MineScoreRecordsCell({
    super.key,
    required this.index,
    required this.bean,
  });

  final int index;
  final MineScoreRecordBean bean;

  @override
  Widget build(BuildContext context) {
    final selected = bean.integral > 0;
    const selectedColor = Color(0xFFF9A200);
    const normalColor = ByColorUtil.CommonTextColor;
    return SizedBox(
      height: 60.h,
      child: ByWidgetsUtil.commonContainer(
          margin: EdgeInsets.symmetric(
            vertical: 5.h,
            horizontal: 12.w,
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          border: Border.all(
            color: const Color(0xFFFFFFFF), //selected ? selectedColor :
          ),
          boxShadow: [
            BoxShadow(
              color: ByColorUtil.BlackColor.withOpacity(0.05),
              blurRadius: 4.w,
            )
          ],
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ByWidgetsUtil.commonText(
                      text: bean.des,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      textColor: selected ? selectedColor : normalColor,
                    ),
                    const SizedBox(height: 4),
                    ByWidgetsUtil.commonText(
                      text: bean.createdAt,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.normal,
                      textColor: selected
                          ? selectedColor
                          : normalColor.withOpacity(0.6),
                    ),
                  ],
                ),
              ),
              ByWidgetsUtil.commonText(
                text: "${bean.integral}",
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                textColor: selected ? selectedColor : normalColor,
              )
            ],
          )),
    );
  }
}
