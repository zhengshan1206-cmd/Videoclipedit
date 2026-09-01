import 'package:video_clip_edit/providers/base_provider.dart';

class AiCartoonImportProvider extends BaseProvider {
  final List<String> tabs = ["小说创作", "写作"];
  String selectedTab = "小说创作";
  updateSelectedTab(String tab) {
    selectedTab = tab;
    notifyListeners();
  }
}
