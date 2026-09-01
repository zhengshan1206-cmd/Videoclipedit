import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marquee_text/marquee_text.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/data/model/common/common_notice_bean.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';

class CommonNoticeView extends StatelessWidget {
  const CommonNoticeView({
    super.key,
    required this.noticeList,
    this.padding,
  });

  final EdgeInsetsGeometry? padding;
  final List<CommonNoticeBean> noticeList;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
      child: Row(
        children: [
          Image.asset(
            Assets.commonIconNotice,
            width: 16.w,
            height: 16.w,
          ),
          SizedBox(width: 8.w),
          Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: BYText.instance('【公告】', 12.sp),
          ),
          Expanded(
            child: MarqueeText(
              text: TextSpan(
                children: _parseBroadcastbeans(),
              ),
              style: const TextStyle(
                fontSize: 12,
                color: ByColorUtil.MainTextColor,
              ),
              speed: 30,
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _parseBroadcastbeans() {
    return noticeList.map((noticeBean) {
      return TextSpan(text: noticeBean.content, style: const TextStyle(
        fontSize: 12,
        color: ByColorUtil.TabTextColorMarquee,
      ));
    }).toList();
  }
}
