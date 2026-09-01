import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/providers/stroy_create_provider.dart';
import 'package:video_clip_edit/modules/home/story/assistant/assistant_record_detail_page.dart';
import 'package:video_clip_edit/modules/home/story/assistant/beans/assistant_record_item_bean.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_time_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class RecordItemWidget extends StatelessWidget {
  final AssistantRecordItemBean recordItemBean;
  final int index;
  final bool isAiPage;
  const RecordItemWidget({
    super.key,
    required this.index,
    required this.recordItemBean,
    this.isAiPage = false,
  });

  @override
  Widget build(BuildContext context) {
    final menus = ["复制", "删除"];

    final isEditing = context.select<StroyCreateProvider, bool>(
      (value) => value.recordsEditing,
    );

    final selectedVideoIdxs = context.select<StroyCreateProvider, List<int>>(
        (value) => value.selectedVideoIdxs);
    final selected = selectedVideoIdxs.contains(index);

    return GestureDetector(
      onTap: () {
        if (isEditing) {
          context
              .read<StroyCreateProvider>()
              .updateSelectedVideoIdxsWithIndex(index);
          return;
        }
        ByNavRouterUtils.push(
          context,
          AssistantRecordDetailPage(
            recordItemBean: recordItemBean,
            fromAi: isAiPage,
            provider: context.read<StroyCreateProvider>(),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(
          bottom: 5.h,
          left: 2.w,
          right: 2.w,
        ),
        padding: EdgeInsets.only(
          left: 12.w,
          top: 12.h,
          bottom: 12.h,
        ),
        decoration: BoxDecoration(
          color: ByColorUtil.WhiteColor,
          borderRadius: BorderRadius.circular(12.w),
          boxShadow: [
            BoxShadow(
              color: ByColorUtil.BlackColor.withOpacity(0.05),
              blurRadius: 2.w,
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ByWidgetsUtil.commonText(
                    text: recordItemBean.sketch,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                  SizedBox(height: 12.h),
                  ByWidgetsUtil.commonText(
                    text: recordItemBean.answer,
                    fontSize: 12.sp,
                    textColor: ByColorUtil.CommonTextColor.withOpacity(0.6),
                  ),
                  SizedBox(height: 12.h),
                  ByWidgetsUtil.commonText(
                    text: ByTimeUtils.dateTimeToTime(recordItemBean.createTime),
                    fontSize: 12.sp,
                    textColor: ByColorUtil.CommonTextColor.withOpacity(0.6),
                  ),
                ],
              ),
            ),
            if (!isEditing)
              CustomPopup(
                showArrow: false,
                contentPadding: EdgeInsets.zero,
                backgroundColor: const Color(0xFFe9eff1),
                barrierColor: ByColorUtil.BlackColor.withOpacity(0.5),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: menus.map((e) {
                    final showBorder = menus.indexOf(e) < menus.length - 1;
                    return GestureDetector(
                      onTap: () {
                        if (menus.indexOf(e) == 0) {
                          Clipboard.setData(
                              ClipboardData(text: recordItemBean.answer));
                          BotToast.showText(text: "复制成功");
                        } else {
                          context
                              .read<StroyCreateProvider>()
                              .deleteAssistantMessage(
                                  msgID: recordItemBean.token);
                        }
                        ByNavRouterUtils.goBack(context);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.h, horizontal: 30.w),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: ByColorUtil.BlackColor.withOpacity(
                                  showBorder ? 0.1 : 0),
                            ),
                          ),
                        ),
                        child: ByWidgetsUtil.commonText(text: e),
                      ),
                    );
                  }).toList(),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  child: Image.asset(
                    "assets/home/icon_more.png",
                    width: 10,
                    height: 10,
                  ),
                ),
              ),
            if (isEditing)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Image.asset(
                  "assets/login/mywork_cell_${selected ? "selected" : "ai_unselected"}.png",
                  width: 24.w,
                  height: 24.h,
                  fit: BoxFit.contain,
                ),
              )
            else
              Container(),
          ],
        ),
      ),
    );
  }
}
