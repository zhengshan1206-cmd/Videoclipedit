import 'package:provider/provider.dart';
import 'package:video_clip_edit/providers/ios_purchase_provider.dart';
import 'package:video_clip_edit/providers/login_provider.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/providers/ai_chat_providers.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/providers/mine_page_provider.dart';
import 'package:video_clip_edit/providers/keyboard_visible_provider.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/v2/toolBox/providers/new_tool_box_provider.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_scores_provider.dart';

var providers = [
  ChangeNotifierProvider<MineScoresProvider>(
      create: (context) => MineScoresProvider()),

  ChangeNotifierProvider<NewToolBoxProvider>(
      create: (context) => NewToolBoxProvider()),

  ChangeNotifierProvider<LoginProvider>(create: (context) => LoginProvider()),

  ChangeNotifierProvider<MinePageProvider>(
      create: (context) => MinePageProvider()),

  ChangeNotifierProvider<PurchaseProvider>(
      create: (context) => PurchaseProvider()),

  ChangeNotifierProvider<LaunchProvider>(create: (context) => LaunchProvider()),

  ChangeNotifierProvider<AiSquareProvider>(
      create: (context) => AiSquareProvider()),

  ChangeNotifierProvider<AiChatProviders>(
      create: (context) => AiChatProviders()),

  ChangeNotifierProvider<KeyboardVisibleProvider>(
      create: (context) => KeyboardVisibleProvider()),

  // ChangeNotifierProvider<PromotionProvider>(
  //     create: (context) => PromotionProvider()),

  ChangeNotifierProvider<IosPurchaseProvider>(
      create: (context) => IosPurchaseProvider()),

];
