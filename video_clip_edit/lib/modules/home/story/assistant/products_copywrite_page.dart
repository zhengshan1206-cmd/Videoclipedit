import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class ProductsCopywritePage extends StatefulWidget {
  const ProductsCopywritePage({super.key});

  @override
  State<ProductsCopywritePage> createState() => _ProductsCopywritePageState();
}

class _ProductsCopywritePageState extends State<ProductsCopywritePage> {
  final TextEditingController productReviewController = TextEditingController();
  final TextEditingController productReviewFeatureController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(context: context, title: "商品测评文案"),
      backgroundColor: ByColorUtil.WhiteColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 5.h,
            color: const Color(0xFFF5F8F9),
          ),
          _buildSectionHeader(title: "测评内容："),
          _buildInputArea(context, productReviewController),
          SizedBox(height: 15.h),
          _buildSectionHeader(title: "评测产品的特点："),
          _buildInputArea(context, productReviewFeatureController),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: ByWidgetsUtil.commonBtn(
              title: "立即创作",
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              borderRadius: 12.w,
              onClick: () {},
            ),
          ),
        ],
      ),
    );
  }

  Container _buildInputArea(
      BuildContext context, TextEditingController controller) {
    return Container(
      color: ByColorUtil.WhiteColor,
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        // top: 15.h,
        bottom: 10.h,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.w),
        child: Stack(
          children: [
            /// 背景色
            Container(
              color: const Color(0xFFF5F8F9),
              height: 180.h,
            ),

            /// 输入框
            _buildTextArea(context, controller),

            /// 工具条
            _buildToolBar(context, controller),
          ],
        ),
      ),
    );
  }

  /// 输入框
  Positioned _buildTextArea(
    BuildContext context,
    TextEditingController controller,
  ) {
    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        child: TextField(
          maxLines: null,
          expands: false,
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelStyle: TextStyle(
              fontSize: 14.sp,
              color: ByColorUtil.CommonTextColor,
            ),
            hintText: "请输入文字内容...",
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: ByColorUtil.CommonTextColor.withOpacity(0.5),
            ),
          ),
          cursorColor: ByColorUtil.CommonTextColor,
          // cursorHeight: 15.sp,
        ),
      ),
    );
  }

  /// 工具条
  Positioned _buildToolBar(
    BuildContext context,
    TextEditingController controller,
  ) {
    return Positioned(
      bottom: 6.h,
      child: SizedBox(
        width: ByScreenUtils.screenWidth - 24.w,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Spacer(),
            GestureDetector(
              onTap: () async {
                ClipboardData? data = await Clipboard.getData('text/plain');
                controller.text = data?.text ?? "";
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 29.h,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: ByWidgetsUtil.commonText(
                  text: "粘贴",
                  fontSize: 12.sp,
                  textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                ),
              ),
            ),
            Container(
              height: 29.h,
              alignment: Alignment.center,
              child: ByWidgetsUtil.commonText(
                text: "|",
                fontSize: 12.sp,
              ),
            ),
            GestureDetector(
              onTap: () {
                controller.clear();
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 29.h,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: ByWidgetsUtil.commonText(
                  text: "清空",
                  fontSize: 12.sp,
                  textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildSectionHeader({required String title}) {
    return Container(
      color: ByColorUtil.WhiteColor,
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 15.h,
        bottom: 10.h,
      ),
      child: ByWidgetsUtil.commonText(
        text: title,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
