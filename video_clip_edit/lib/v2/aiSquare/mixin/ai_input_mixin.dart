import 'package:video_clip_edit/providers/base_provider.dart';

abstract class AiInputMixin extends BaseProvider {
  String inputValue = "";
  updateInputValue(String txt) {
    inputValue = txt;
    notifyListeners();
  }
}
