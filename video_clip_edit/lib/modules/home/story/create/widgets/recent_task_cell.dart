import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/providers/stroy_create_provider.dart';
import 'package:video_clip_edit/modules/home/story/create/beans/ai_create_bean.dart';
import 'package:video_clip_edit/modules/home/story/create/message_details_page.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_time_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';

class RecentTaskCell extends StatelessWidget {
  final Color? bgColor;
  final bool showBottomMargin;
  final AiCreateBean taskCellBean;

  const RecentTaskCell({
    super.key,
    required this.showBottomMargin,
    required this.taskCellBean,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final menus = ["复制", "删除"];
    return GestureDetector(
      onTap: () {
        ByNavRouterUtils.push(
            context,
            ChangeNotifierProvider.value(
                value: context.read<StroyCreateProvider>(),
                child: MessageDetailsPage(bean: taskCellBean)));
      },
      child: Container(
        margin: EdgeInsets.only(
          bottom: showBottomMargin ? 12.h : 0,
        ),
        padding: EdgeInsets.only(
          left: 12.w,
          top: 12.h,
          bottom: 12.h,
        ),
        decoration: BoxDecoration(
          color: bgColor ?? ByColorUtil.WhiteColor,
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ByWidgetsUtil.commonText(
                    text: taskCellBean.sketch,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                  SizedBox(height: 12.h),
                  ByWidgetsUtil.commonText(
                    text: taskCellBean.ask,
                    fontSize: 12.sp,
                    textColor: ByColorUtil.CommonTextColor.withOpacity(0.6),
                  ),
                  SizedBox(height: 12.h),
                  ByWidgetsUtil.commonText(
                    text: ByTimeUtils.dateTimeToTime(taskCellBean.createTime),
                    fontSize: 12.sp,
                    textColor: ByColorUtil.CommonTextColor.withOpacity(0.6),
                  ),
                ],
              ),
            ),
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
                      if (kDebugMode) {
                        debugPrint("onSelect:$e");
                      }
                      if (menus.indexOf(e) == 0) {
                        Clipboard.setData(
                            ClipboardData(text: taskCellBean.answer));
                        BotToast.showText(text: "复制成功");
                      } else {
                        context
                            .read<StroyCreateProvider>()
                            .deleteMessage(msgID: taskCellBean.token);
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
          ],
        ),
      ),
    );
  }
}
