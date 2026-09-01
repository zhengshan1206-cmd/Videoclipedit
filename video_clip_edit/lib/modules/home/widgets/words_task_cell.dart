import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/beans/words_task_cell_bean.dart';
import 'package:video_clip_edit/modules/home/providers/words_extract_provider.dart';
import 'package:video_clip_edit/modules/home/words/words_extraction_result_page.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/comon/by_time_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:flutter_popup/flutter_popup.dart';

class WordsTaskCell extends StatelessWidget {
  final Color? bgColor;
  final bool showBottomMargin;
  final WordsTaskCellBean taskCellBean;

  const WordsTaskCell({
    super.key,
    required this.showBottomMargin,
    required this.taskCellBean,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final menus = ["复制", "删除"];
    return Container(
      margin: EdgeInsets.only(
        bottom: showBottomMargin ? 12.h : 0,
      ),
      padding: EdgeInsets.only(
        left: 11.w,
        top: 12.h,
        bottom: 12.h,
      ),
      decoration: BoxDecoration(
        color: bgColor ?? ByColorUtil.WhiteColor,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // 上报点击埋点（文案只需要上报id，不需要封面图）
          ByNavigatorUtil.reportDataPoint(
            pageTag: "myworks_list_txt_extraction_works",
            operateType: "click",
            funcDetailTag: taskCellBean.id.toString(),
            funcDetailImg: "",
          );
          ByNavRouterUtils.push(
            context,
            WordsExtractionResultPage(contents: _parseContents()),
          );
        },
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ByWidgetsUtil.commonText(
                    text: taskCellBean.content.isEmpty
                        ? "暂无内容"
                        : _parseContents(),
                  ),
                  SizedBox(height: 5.h),
                  ByWidgetsUtil.commonText(
                    text: ByTimeUtils.dateTimeToTime(taskCellBean.createdAt),
                    textColor: ByColorUtil.BlackColor.withOpacity(0.4),
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
                  final index = menus.indexOf(e);
                  final showBorder = index < menus.length - 1;
                  return GestureDetector(
                    onTap: () {
                      if (kDebugMode) {
                        print("onselecte $e");
                      }
                      ByNavRouterUtils.goBack(context);
                      if (index == 0) {
                        if (taskCellBean.content.isNotEmpty) {
                          Clipboard.setData(
                            ClipboardData(text: _parseContents()),
                          );
                          BotToast.showText(text: "复制成功");
                        }
                      } else {
                        /// 删除记录
                        context.read<WordsExtractProvider>().deleteRecords(
                          ["${taskCellBean.id}"],
                        );
                      }
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
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(right: 10.w),
                child: Image.asset(
                  "assets/home/icon_more.png",
                  width: 20.w,
                  height: 20.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _parseContents() {
    final fileType = taskCellBean.fileType;
    if (fileType == 4) {
      return taskCellBean.content;
    }
    final List contents = taskCellBean.content.prettyDecode() ?? [];
    if (contents.isEmpty) {
      return "未识别到文本内容";
    }
    String res = "";
    for (var e in contents) {
      final String text = e["text"] ?? "";
      if (text.isNotEmpty) {
        res += "$text\n";
      }
    }

    return res;
  }
}
