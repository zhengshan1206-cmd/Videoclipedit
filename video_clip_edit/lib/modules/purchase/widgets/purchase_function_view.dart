import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/purchase/beans/purchase_function_bean.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class PurchaseFunctionView extends StatelessWidget {
  final PurchaseFunctionBean functionBean;
  final void Function(PurchaseFunctionBean) onSelected;
  const PurchaseFunctionView({
    super.key,
    required this.functionBean,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onSelected(functionBean);
      },
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Offstage(
              offstage: !functionBean.isNew,
              child: _buidNewTag(),
            ),
          ),
          Column(
            children: [
              SizedBox(height: 8.h),
              Image.asset(
                functionBean.icon,
                height: 40.h,
                width: double.infinity,
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
              const Spacer(),
              ByWidgetsUtil.commonText(
                text: functionBean.name,
                fontSize: 12.sp,
                textColor: ByColorUtil.CommonTextColor,
              )
            ],
          )
        ],
      ),
    );
  }

  Container _buidNewTag() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsetsDirectional.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: ByColorUtil.PurchaseTagNewBgColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.h),
          topRight: Radius.circular(8.h),
          bottomRight: Radius.circular(8.h),
          bottomLeft: Radius.circular(4.h),
        ),
      ),
      child: ByWidgetsUtil.commonText(
        text: "New",
        fontSize: 10.sp,
        fontWeight: FontWeight.bold,
        textColor: ByColorUtil.WhiteColor,
      ),
    );
  }
}

class PurchaseFunctionViewDark extends StatelessWidget {
  final PurchaseFunctionBean functionBean;
  final void Function(PurchaseFunctionBean) onSelected;
  const PurchaseFunctionViewDark({
    super.key,
    required this.functionBean,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          onSelected(functionBean);
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xfF1E2022).withOpacity(0.6),
            borderRadius: BorderRadius.circular(12.w),
            border: Border.all(
                color: const Color(0xFF707478)
                    .withOpacity(functionBean.selected ? 1 : 0.3),
                width: 0.5),
          ),
          child: Column(
            children: [
              SizedBox(height: 15.h),
              Opacity(
                opacity: functionBean.selected ? 1 : 0.5,
                child: Image.asset(
                  functionBean.icon,
                  height: 24.h,
                  width: 24.w,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
              SizedBox(height: 11.h),
              ByWidgetsUtil.commonText(
                text: functionBean.name,
                fontSize: 10.sp,
                textColor: ByColorUtil.WhiteColor.withOpacity(
                  functionBean.selected ? 1 : 0.5,
                ),
              )
            ],
          ),
        ));
  }
}
