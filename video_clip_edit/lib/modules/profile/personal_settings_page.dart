import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/modules/profile/beans/user_info_bean.dart';
import 'package:video_clip_edit/modules/profile/widgets/section_view.dart';
import 'package:video_clip_edit/providers/settings_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class PersonalSettingsPage extends StatefulWidget {
  final SettingsProvider provider;
  const PersonalSettingsPage({super.key, required this.provider});

  @override
  State<PersonalSettingsPage> createState() => _PersonalSettingsPageState();
}

class _PersonalSettingsPageState extends State<PersonalSettingsPage> {
  UserController get userController => Get.find<UserController>();

  UserInfoBean? get userInfo => userController.user.value;

  @override
  void initState() {
    super.initState();
    widget.provider.assemblePersonalSettingBeans(
      avatar: userInfo?.avatar ?? "",
      userID: "${userInfo?.userId ?? 0}",
      nickName: userInfo?.nickName ?? "",
      phoneNO: userInfo?.phone ?? "",
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.provider,
      child: Scaffold(
        appBar: ByWidgetsUtil.appBar(context: context, title: "个人信息"),
        backgroundColor: ByColorUtil.CommonPageBgColor,
        body: Consumer<SettingsProvider>(builder: (context, provider, child) {
          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            children: [
              ...provider.personalSectionBeans.map(
                (e) => SectionView(
                  beans: e,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
