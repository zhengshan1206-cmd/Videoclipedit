import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class AiCartoonNovelCreatePage extends StatefulWidget {
  const AiCartoonNovelCreatePage({super.key});

  @override
  State<AiCartoonNovelCreatePage> createState() =>
      _AiCartoonNovelCreatePageState();
}

class _AiCartoonNovelCreatePageState extends State<AiCartoonNovelCreatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
        child: Column(
          children: [
            ..._buildNoDataView(),
            // Expanded(
            //   child: _buildListView(),
            // ),
          ],
        ),
      ),
    );
  }

  ListView _buildListView() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return ByWidgetsUtil.commonContainer(
          borerRadius: 12.w,
          bgColor: ByColorUtil.CommonPageBgColor,
          padding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 5.h,
          ),
          margin: EdgeInsets.symmetric(vertical: 5.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ByWidgetsUtil.commonText(
                text: "重生到大明到皇帝",
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: 12.h),
              ByWidgetsUtil.commonText(
                text: "重生到大明当皇帝：重生到大明当皇帝重生到大明当皇帝重生重生到大明当皇帝：重生到大明当皇帝重生到大明当皇帝重生",
                fontSize: 12.sp,
                fontWeight: FontWeight.normal,
                textColor: ByColorUtil.CommonTextColor.withOpacity(0.6),
              ),
            ],
          ),
        );
      },
    );
  }

  _buildNoDataView() {
    return [
      SizedBox(
        height: 85.h,
        width: double.infinity,
      ),
      Image.asset(
        "assets/mine/mine_no_data.png",
        width: 180.w,
        height: 100.h,
        fit: BoxFit.contain,
      ),
      SizedBox(height: 30.h),
      ByWidgetsUtil.commonText(
        fontSize: 14.sp,
        text: "暂无数据",
        fontWeight: FontWeight.normal,
        textColor: ByColorUtil.CommonTextColor.withOpacity(0.3),
      ),
    ];
  }
}
