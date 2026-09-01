import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/modules/home/beans/setting_item_bean.dart';
import 'package:video_clip_edit/modules/profile/beans/user_info_bean.dart';
import 'package:video_clip_edit/modules/profile/widgets/section_view.dart';
import 'package:video_clip_edit/providers/settings_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  UserController get userController => Get.find<UserController>();

  UserInfoBean? get userInfo => userController.user.value;

  @override
  void initState() {
    super.initState();
    context.read<SettingsProvider>().loadSettingItems();
    // PackageInfo packageInfo = await getPackageInfo();
    // packageInfo.version
  }

  @override
  Widget build(BuildContext context) {
    final List<List<SettingItemBean>> itemBeans =
        context.select<SettingsProvider, List<List<SettingItemBean>>>(
            (provider) => provider.sectionBeans);
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(context: context, title: "设置"),
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        children: [
          ...itemBeans.map((e) => SectionView(beans: e)),
          SizedBox(height: 25.h),
          loginOutBtn(),

          // Container(
          //   margin: EdgeInsets.only(top: 20),
          //   alignment: Alignment.center,
          //   child: Text("v5.0.4",style: TextStyle(color: Colors.grey),),),
        ],
      ),
    );
  }

  Widget loginOutBtn() {
    bool isLogin = userInfo?.isFormal == 1;
    debugPrint("isLogin:$isLogin");
    return isLogin
        ? ByWidgetsUtil.commonBtn(
            title: "退出登录",
            onClick: () {
              Get.find<UserController>().logout();
            },
            bgColor: ByColorUtil.WhiteColor,
            textColor: ByColorUtil.CommonTextColor,
          )
        : Container();
  }
}
