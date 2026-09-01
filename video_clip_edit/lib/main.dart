import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:video_clip_edit/flavors/channel.dart';
import 'package:video_clip_edit/routes/route_utils.dart';
import 'package:video_clip_edit/flavors/environment.dart';
import 'package:video_clip_edit/by_global_providers.dart';
import 'package:video_clip_edit/flavors/build_config.dart';
import 'package:video_clip_edit/core/base/app_binding.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_clip_edit/utils/comon/by_init_utils.dart';
import 'package:video_clip_edit/flavors/environment_config.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'flavors/app_values.dart';
import 'routes/app_pages.dart';
import 'package:video_clip_edit/utils/http/route_history_observer.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
final RouteHistoryObserver routeHistoryObserver = RouteHistoryObserver();

///App 入口main文件
void main() async {
  FlutterBugly.postCatchedException(
    () async {
      BuildConfig.instantiate(
        envType: Environment.PRODUCTION,
        envConfig: EnvironmentConfig(),
        channelType: ChannelType.harmony,
      );

      WidgetsFlutterBinding.ensureInitialized();
      SystemChrome.setPreferredOrientations([
        // 强制竖屏
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      await ScreenUtil.ensureScreenSize();
      await ByInitUtils.init();
      // 延迟initUserAgentData调用，等待用户同意隐私政策后再获取设备信息
      // await ConstKeys().initUserAgentData();

      runApp(
        const KeyboardDismissOnTap(
          // dismissOnCapturedTaps: true,
          child: MyApp(),
        ),
      );

      // 延迟FlutterBugly初始化，等待用户同意隐私政策后再初始化
      // FlutterBugly.init(
      //   androidAppId: "2b0c0df0ad",
      //   iOSAppId: "",
      // );
    },
    onException: (FlutterErrorDetails details) {
      byDebugPrint("检测到异常：\n${details.stack}");
    },
    debugUpload: true,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        child: GetMaterialApp(
          title: '妙笔工坊',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          theme: theme,
          supportedLocales: const [Locale('zh', 'CN')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: Get.deviceLocale,
          routes: RouteUtils.routeList,
          initialRoute: RouterUtil.initialRoute(),
          initialBinding: AppBinding(),
          getPages: AppPages.routes,
          popGesture: false,
          defaultTransition: Transition.fadeIn,
          builder: (context, child) {
            SystemChrome.setSystemUIOverlayStyle(
              const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
            );
            return EasyLoading.init()(context, BotToastInit()(context, child));
          },
          navigatorObservers: [
            BotToastNavigatorObserver(),
            routeObserver,
            routeHistoryObserver,
          ],
        ),
      ),
    );
  }
}
