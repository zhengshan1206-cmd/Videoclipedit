import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/guid/add_material_guid_page.dart';
import 'package:video_clip_edit/modules/guid/clip/cloud_materials_guid_page.dart';
import 'package:video_clip_edit/modules/home/providers/show_recreate_provider.dart';
import 'package:video_clip_edit/modules/home/recreate/short_show_recreate_page.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/clipped/clipped_page.dart';
import 'package:video_clip_edit/modules/home/providers/clipped_provider.dart';

class MainFuncsView extends StatelessWidget {
  final List<MainFunctionBean> functions;
  const MainFuncsView({
    super.key,
    required this.functions,
  });

  @override
  Widget build(BuildContext context) {
    LaunchProvider provider = context.watch<LaunchProvider>();
    final bool showClipGuid = provider.shouldShowClipGuid();
    final bool showCreateGuid = provider.shouldShowCreateGuid();
    final height = 86.h;
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// 智能混剪
            GestureDetector(
              onTap: () {
                ByNavRouterUtils.push(
                  context,
                  showClipGuid == false
                      ? ChangeNotifierProvider<ClippedProvider>(
                          create: (ctx) => ClippedProvider(),
                          child: const ClippedPage<ClippedProvider>(),
                        )
                      : const CloudMaterialsGuidPage(),
                );

                if (showClipGuid) {
                  provider.checkClipGuid();
                }
              },
              child: Image.asset(
                functions[0].url,
                height: height,
                fit: BoxFit.fitHeight,
              ),
            ),

            /// 剪辑
            GestureDetector(
              onTap: () async {
                // await ChannelOperate.toVideoEdit(false).then((data) {
                //   if (data != null) {
                //     final String pathResult = data["edit_result"] ?? "";
                //     if (pathResult.isNotEmpty) {
                //       ByNavRouterUtils.push(
                //           context, VideoClipHyberPrevicew(pathResult));
                //     } else {
                //       BotToast.showText(text: "视频剪辑失败");
                //     }
                //   }
                // });
              },
              child: Image.asset(
                functions[1].url,
                height: height,
                fit: BoxFit.fitHeight,
              ),
            ),

            /// 短剧二创
            GestureDetector(
              onTap: () {
                ByNavRouterUtils.push(
                  context,
                  //  const AddMaterialGuidPage()
                  showCreateGuid == false
                      ? ChangeNotifierProvider<ShowRecreateProvider>(
                          create: (context) => ShowRecreateProvider(),
                          child: const ShortShowRecreatePage<
                              ShowRecreateProvider>(),
                        )
                      : const AddMaterialGuidPage(),
                );

                if (showCreateGuid) {
                  provider.checkCreateGuid();
                }
              },
              child: Image.asset(
                functions[2].url,
                height: height,
                fit: BoxFit.fitHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainFunctionBean {
  final String url;

  MainFunctionBean({
    required this.url,
  });
}
