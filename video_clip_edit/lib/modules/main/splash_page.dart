import 'package:flutter/material.dart';
import 'package:video_clip_edit/modules/main/launch_page.dart';
import 'package:video_clip_edit/modules/main/permission_confirm_page.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_storage_utils.dart';
import 'package:video_clip_edit/utils/consts/const.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    checkAgreement();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(),
          Positioned.fill(
            child: Image.asset(
              "assets/launch/launch_bg.png",
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  void checkAgreement() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final checked =
            ByStorageUtils.getBool(Consts.kAgreementChecked) ?? false;
        if (checked) {
          Future.delayed(const Duration(seconds: 1), () {
            ByNavRouterUtils.pushReplacement(
              context,
              const LaunchPage(),
            );
          });
          return;
        }

        ByNavRouterUtils.pushReplacement(
          context,
          PermissionConfirmPage(
            onConfirm: () {},
          ),
        );
      },
    );
  }
}
