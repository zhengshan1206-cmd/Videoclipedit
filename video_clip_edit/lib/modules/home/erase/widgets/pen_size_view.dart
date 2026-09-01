import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/home/erase/beans/pen_size_bean.dart';
import 'package:video_clip_edit/modules/home/providers/video_erase_provider.dart';

class PenSizeListView extends StatefulWidget {
  const PenSizeListView({super.key});

  @override
  State<PenSizeListView> createState() => _PenSizeListViewState();
}

class _PenSizeListViewState extends State<PenSizeListView> {
  PenSizeBean? selectBean;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _buildChildren(context),
    );
  }

  List<Widget> _buildChildren(BuildContext context) {
    final VideoEraseProvider eraseProvider =
        context.watch<VideoEraseProvider>();
    final penSizeBeans = eraseProvider.penSizeBeans;
    final length = penSizeBeans.length;
    List<Widget> res = [const Spacer()];
    for (var e in penSizeBeans.asMap().entries) {
      int idx = e.key;
      PenSizeBean bean = e.value;
      bean.selected;
      bean;
      res.add(
        GestureDetector(
          onTap: () {
            eraseProvider.updatePensize(bean);
            if (mounted) {
              setState(() {
                selectBean = bean;
              });
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: bean.radius + 10,
            height: double.infinity,
            alignment: Alignment.center,
            child: Container(
              width: bean.radius,
              height: bean.radius,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100.w),
                border: Border.all(
                  width: 3.w,
                  color: selectBean == bean
                      ? ByColorUtil.TabTextColorSelected
                      : const Color(0xFF0E1840).withOpacity(0.6),
                ),
              ),
            ),
          ),
        ),
      );

      if (idx < length - 1) {
        res.add(SizedBox(width: 15.w));
      }
    }
    res.add(const Spacer());
    return res;
  }
}