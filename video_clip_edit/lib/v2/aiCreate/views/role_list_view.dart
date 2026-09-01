import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/data/model/folk/story_role_bean.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/role_info_edit_controller.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/step_two_controller.dart';
import 'package:video_clip_edit/v2/aiCreate/views/role_regenerate_page.dart';
import 'package:video_clip_edit/widgets/image/by_image_view.dart';

class RoleListView extends StatelessWidget {
  const RoleListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final StepTwoController controller = Get.find<StepTwoController>();
    return Obx(() {
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        itemCount: controller.roleBeans.length,
        itemBuilder: (BuildContext context, int index) {
          final role = controller.roleBeans[index];
          return StoryRoleListCell(role: role, index: index);
        },
      );
    });
  }
}

class StoryRoleListCell extends StatelessWidget {
  const StoryRoleListCell({
    super.key,
    required this.role,
    required this.index,
  });

  final int index;
  final StoryRoleBean role;

  @override
  Widget build(BuildContext context) {
    final contentsH = 131.h;
    return ByWidgetsUtil.commonContainer(
      margin: EdgeInsets.symmetric(vertical: 5.h),
      padding: EdgeInsets.symmetric(
        vertical: 12.h,
        horizontal: 12.w,
      ),
      border: Border.all(
        width: 0.5,
        color: const Color(0xFFEAEEFF),
      ),
      child: SizedBox(
        height: contentsH,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: ByWidgetsUtil.commonContainer(
                borerRadius: 0,
                border: Border.all(
                  width: 0.5,
                  color: const Color(0xFFEAEEFF),
                ),
                child: BYImageView.normal(
                  width: 100.w,
                  height: contentsH,
                  imageUrl: role.url,

                  ///"https://img0.baidu.com/it/u=2191392668,814349101&fm=253&fmt=auto&app=138&f=JPEG?w=800&h=1399", //role.url
                ),
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ByWidgetsUtil.commonText(
                    text: role.name,

                    ///"李乘风", //role.name
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: 7.h),
                  ByWidgetsUtil.commonText(
                    text: role.desc,

                    ///"一位古老山村的青年，他的爷爷是十里 八乡有名的风水师，耳濡目染下，从小 就对奇门风水有着很大的兴趣。 ", //role.desc
                    maxLines: 3,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    textColor: ByColorUtil.CommonTextColor.withOpacity(0.6),
                  ),
                  const Spacer(),
                  Container(
                    height: 32.h,
                    width: 100.w,
                    alignment: Alignment.centerLeft,
                    child: ByWidgetsUtil.commonBtn(
                      padding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 22.w,
                      ),
                      bgColor: const Color(0xFFEAEEFF),
                      textColor: ByColorUtil.LoginBtnBgColor,
                      title: "重新生成",
                      fontSize: 14.sp,
                      borderRadius: 100,
                      fontWeight: FontWeight.normal,
                      onClick: () async {
                        final StepTwoController controller =
                            Get.find<StepTwoController>();

                        final result =
                            await Get.to(RoleRegeneratePage(role: role));
                        byDebugPrint(">>>>>result: $result");
                        if (result) {
                          controller.loadRoleList();
                        }
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
