import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/widgets/common_button.dart';

class PaySuccessDialog extends StatelessWidget {
  const PaySuccessDialog({
    super.key,
    this.title,
    this.isFromIntegral = false,
    this.onAddBtnTap,
    this.onCloseBtnTap,
  });

  final String? title;
  final bool isFromIntegral;
  final VoidCallback? onAddBtnTap;
  final VoidCallback? onCloseBtnTap;

  @override
  Widget build(BuildContext context) {
    final imageHeight = 320.w * 307 / 320;
    final paddingBottom = imageHeight * 30 / 320;
    final spacingH1 = imageHeight * 25.5 / 320;
    final spacingH2 = imageHeight * 34.5 / 320;
    final bottonH = imageHeight * 54 / 320;
    return Center(
      child: Stack(
        children: [
          Image.asset(
            Assets.newIconPaySuccessBg,
            width: 320.w,
            height: imageHeight,
            fit: BoxFit.contain,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.only(bottom: paddingBottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BYText.instance(title ?? '支付成功！', 24.sp,
                      color: ByColorUtil.color4A1F00,
                      fontWeight: BYFontWeight.bold),
                  SizedBox(height: spacingH1),
                  BYText.instance('使用问题可在我的页面联系人工客服。', 14.sp,
                      color: ByColorUtil.color4A1F00,
                      fontWeight: BYFontWeight.medium),
                  SizedBox(height: spacingH2),
                  CommonButton(
                    minSize: 0,
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(bottonH / 2),
                    color: ByColorUtil.colorFF8902,
                    onPressed: () {
                      // 调用立即添加按钮回调
                      onAddBtnTap?.call();
                      if (isFromIntegral) {
                        // 如果是积分弹窗，关闭当前弹窗和积分弹窗
                        Navigator.of(context).pop(); // 关闭 PaySuccessDialog
                        Navigator.of(context).pop(); // 关闭 IntegralPayDialog
                      } else {
                        // 保持原有逻辑
                        Get.back();
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 180.w,
                      height: bottonH,
                      child: BYText.instance('立即创作', 18.sp,
                          color: ByColorUtil.WhiteColor,
                          fontWeight: BYFontWeight.semiBold),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
