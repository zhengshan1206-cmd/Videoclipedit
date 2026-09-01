import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiOralVideos/ai_oral_dubbing_anchor_page.dart';
import 'package:video_clip_edit/v2/aiOralVideos/ai_oral_dubbing_remake_page.dart';
import 'package:video_clip_edit/v2/aiOralVideos/beans/ai_oral_audio_bean.dart';
import 'package:video_clip_edit/v2/aiOralVideos/beans/ai_oral_dubbing_clone_detail_bean.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_dubbing_anchor_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_dubbing_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_videos_provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class AiOralDubbingListView extends StatelessWidget {
  const AiOralDubbingListView({
    super.key,
    this.onSelect,
  });

  final void Function(String filePah)? onSelect;

  @override
  Widget build(BuildContext context) {
    final selectedCloneDetailBean =
        context.select<AiOralVideosProvider, AiOralDubbingCloneDetailBean?>(
      (value) => value.dubbingCloneDetailBean,
    );

    final audioBeans =
        context.select<AiOralVideosProvider, List<AiOralAudioBean>>(
      (value) => value.audioBeans,
    );
    if (selectedCloneDetailBean != null) {
      return SliverToBoxAdapter(child: Container());
    }

    ///2025.4.2 暂时屏蔽我的音频文件选择
    return SliverGrid.builder(
      itemCount: audioBeans.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 10.w,
          childAspectRatio: 1.5),
      itemBuilder: (context, index) {
        final bean = audioBeans[index];
        return AiOralDubbingCell(bean: bean, index: index, onSelect: onSelect);
      },
    );
  }
}

class AiOralDubbingCell extends StatelessWidget {
  const AiOralDubbingCell({
    super.key,
    required this.bean,
    required this.index,
    this.onSelect,
  });

  final AiOralAudioBean bean;
  final int index;
  final void Function(String filePah)? onSelect;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final purchaseProvider = context.read<PurchaseProvider>();
        if (purchaseProvider.preLoginCheck(context) == false) {
          return;
        }
        switch (index) {
          case 0:
            ByNavRouterUtils.push(
              context,
              MultiProvider(
                providers: [
                  ChangeNotifierProvider.value(
                    value: context.read<AiOralVideosProvider>(),
                  ),
                  ChangeNotifierProvider(
                    create: (context) => AiOralDubbingProvider(),
                  ),
                  ChangeNotifierProvider.value(
                    value: ByAudioPlayer.sharedInstance.statusProvider,
                  ),
                ],
                child: const AiOralDubbingRemakePage(),
              ),
            );
            break;
          case 1:
            ByNavRouterUtils.push(
              context,
              MultiProvider(
                providers: [
                  ChangeNotifierProvider.value(
                    value: AiOralDubbingAnchorProvider(),
                  ),
                  ChangeNotifierProvider(
                    create: (context) => AiOralDubbingProvider(),
                  ),
                  ChangeNotifierProvider.value(
                    value: context.read<AiOralVideosProvider>(),
                  ),
                  ChangeNotifierProvider.value(
                    value: ByAudioPlayer.sharedInstance.statusProvider,
                  ),
                ],
                child: const AiOralDubbingAnchorPage(),
              ),
            );
            break;
          case 2:
            final List<AssetEntity> result = await ByCommonUtils.pickAudio(
              context,
              maxCount: 1,
              durationLimitMin: 15,
              durationLimit: 120,
            );
            if (result.isEmpty) return;
            AssetEntity asset = result.first;
            final file = await asset.file;
            if (file == null) {
              BotToast.showText(text: "选择文件时出错，请重新选择");
              return;
            }
            onSelect?.call(file.path);
            break;
          default:
        }
      },
      child: ByWidgetsUtil.commonContainer(
        boxShadow: [
          BoxShadow(
            color: ByColorUtil.BlackColor.withOpacity(0.05),
            blurRadius: 4.w,
          )
        ],
        child: Column(
          children: [
            const Spacer(),
            ClipOval(
              child: Container(
                color: const Color(0xFFF8FAFB),
                width: 56.w,
                height: 56.w,
                alignment: Alignment.center,
                child: ByWidgetsUtil.svgAsset(
                  filePath: bean.icon,
                  width: 32,
                  height: 32,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            ByWidgetsUtil.commonText(
              fontSize: 12.sp,
              text: bean.title,
              fontWeight: FontWeight.normal,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
