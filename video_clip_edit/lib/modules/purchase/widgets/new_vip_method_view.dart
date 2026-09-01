import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/purchase/beans/pay_method_bean.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class NewVipMethodView extends StatelessWidget {
  final void Function(PayMethodBean)? onSelected;
  final bool showCheckBox;
  final PayMethodBean payMethodBean;
  const NewVipMethodView({
    super.key,
    required this.payMethodBean,
    this.onSelected,
    this.showCheckBox = true,
  });

  @override
  Widget build(BuildContext context) {
    final PurchaseProvider provider = context.read<PurchaseProvider>();
    final selected = provider.payMethodBeans.indexOf(payMethodBean) ==
        provider.selectedPayMethodIndex;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onSelected?.call(payMethodBean);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            payMethodBean.icon,
            width: 18.w,
            height: 18.w,
          ),
          SizedBox(width: 5.w),
          ByWidgetsUtil.commonText(
            fontSize: 14.sp,
            fontWeight: FontWeight.normal,
            text: payMethodBean.payName,
            textColor: showCheckBox
                ? const Color(0xFF0E101F).withOpacity(0.6)
                : const Color(0xFF999999),
          ),
          SizedBox(width: (showCheckBox == true ? 5.w : 10.w)),
          if (showCheckBox)
            SizedBox(
              width: 12.w,
              height: 12.w,
              child: Image.asset(
                selected
                    ? "assets/purchase/icon_checkbox_selected.png"
                    : "assets/purchase/icon_checkbox_normal.png",
                color: const Color(0xFF0E101F),
                width: 12.w,
                height: 12.w,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
    );
  }
}
