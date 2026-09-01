import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class KeyboardVisibleProvider extends BaseProvider {
  KeyboardVisibleProvider() {
    KeyboardVisibilityController().onChange.listen((bool visible) {
      byDebugPrint("zzz------initStateKeyboardVisibility:$visible");
      changeKeyboardVisible(visible);
    });
  }

  bool keyboardVisible = false;
  void changeKeyboardVisible(bool visible) {
    keyboardVisible = visible;
    notifyListeners();
  }
}
