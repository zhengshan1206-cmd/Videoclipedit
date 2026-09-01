import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_provider.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_bgm_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_item_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/widgets/ai_cartoon_bgm_dialog.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/widgets/ai_cartoon_video_fonts_dialog.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/widgets/ai_cartoon_video_ratio_dialog.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/widgets/ai_cartoon_video_voice_dialog.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/widgets/ai_cartoon_more_settings_dialog.dart';

class AiClipItemView extends StatelessWidget {
  const AiClipItemView({
    super.key,
    required this.itemBean,
  });

  final AiCartoonItemBean itemBean;

  @override
  Widget build(BuildContext context) {
    final hasValue = itemBean.hasValue();
    return SizedBox(
      height: 50.h,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          _handleTap(context);
        },
        behavior: HitTestBehavior.opaque,
        child: ByWidgetsUtil.commonContainer(
            bgColor: ByColorUtil.CommonPageBgColor,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            borerRadius: 10.w,
            border: Border.all(
              width: 0.5.w,
              color: const Color(0xFFF3F5F9),
            ),
            child: Row(
              children: [
                _buildLeading(),
                Expanded(
                  child: ByWidgetsUtil.commonText(
                    text: hasValue ? itemBean.value! : itemBean.placeholder,
                    textColor: ByColorUtil.CommonTextColor.withOpacity(
                      hasValue ? 1 : 0.5,
                    ),
                    fontWeight: itemBean.shouldBold!
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                Offstage(
                  offstage: itemBean.interactive == false,
                  child: Image.asset(
                    "assets/ai/ai_cartoon_item_more.png",
                    width: 12.w,
                    height: 12.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            )),
      ),
    );
  }

  _buildLeading() {
    final type = itemBean.type;
    switch (type) {
      case AiCartoonItemBeanType.settings:
        return Padding(
          padding: EdgeInsets.only(right: 5.w),
          child: Image.asset(
            itemBean.imgPath,
            width: 15.w,
            height: 15.h,
            fit: BoxFit.contain,
          ),
        );
      default:
        return Container();
    }
  }

  void _handleTap(BuildContext context) {
    if (itemBean.interactive == false) return;

    final type = itemBean.type;
    switch (type) {
      case AiCartoonItemBeanType.bgm:
        _showBgmDialog(context);
        break;
      case AiCartoonItemBeanType.voice:
        _showVoiceDialog(context);
        break;
      case AiCartoonItemBeanType.ratio:
        _showRatioDialog(context);
        break;
      case AiCartoonItemBeanType.font:
        _showFontDialog(context);
        break;
      case AiCartoonItemBeanType.settings:
        _showSettingsDialog(context);
        break;
      default:
        break;
    }
  }

  void _showVoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: context.read<AiClipProvider>(),
            ),
            ChangeNotifierProvider.value(
              value: ByAudioPlayer.sharedInstance.statusProvider,
            ),
          ],
          child: AiCartoonVideoVoiceDialog<AiClipProvider>(itemBean: itemBean),
        );
      },
    );
  }

  void _showBgmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final clipProvider = context.read<AiClipProvider>();
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: clipProvider),
            ChangeNotifierProvider(
              create: (context) =>
                  AiClipBgmProvider(bgmUrlInitial: clipProvider.selectedBgmUrl),
            ),
            ChangeNotifierProvider.value(
              value: ByAudioPlayer.sharedInstance.statusProvider,
            ),
          ],
          child: AiCartoonBgmDialog<AiClipProvider, AiClipBgmProvider>(
              itemBean: itemBean),
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return ChangeNotifierProvider.value(
          value: context.read<AiClipProvider>(),
          child: const AiCartoonMoreSettingsDialog<AiClipProvider>(),
        );
      },
    );
  }

  void _showRatioDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: context.read<AiClipProvider>()),
          ],
          child: AiCartoonVideoRatioDialog<AiClipProvider>(itemBean: itemBean),
        );
      },
    );
  }

  void _showFontDialog(BuildContext context) {
    log("字体itemBean====>");

    showDialog(
      context: context,
      builder: (ctx) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: context.read<AiClipProvider>()),
          ],
          child: AiCartoonVideoFontsDialog<AiClipProvider>(
            itemBean: itemBean,
          ),
        );
      },
    );
  }
}
