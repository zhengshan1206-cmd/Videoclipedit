import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/purchase/beans/pay_method_bean.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class PayMethodView extends StatelessWidget {
  final void Function(PayMethodBean)? onSelected;
  final bool showCheckBox;
  final PayMethodBean payMethodBean;
  const PayMethodView({
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
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              payMethodBean.icon,
              width: 18.w,
              height: 18.w,
            ),
            const SizedBox(width: 5),
            ByWidgetsUtil.commonText(
              fontSize: 14.sp,
              text: payMethodBean.payName,
              textColor: showCheckBox
                  ? const Color(0xFF666666)
                  : const Color(0xFF999999),
            ),
            SizedBox(width: (showCheckBox == true ? 5.w : 10.w)),
            if (showCheckBox)
              SizedBox(
                width: 15.w,
                height: 15.w,
                child: Image.asset(
                  selected
                      ? "assets/purchase/icon_checkbox_selected.png"
                      : "assets/purchase/icon_checkbox_normal.png",
                  width: 18.w,
                  height: 18.w,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
