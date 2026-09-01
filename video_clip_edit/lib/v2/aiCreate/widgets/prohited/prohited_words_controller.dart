import 'package:get/get.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/prohited/prohited_words_detect_mixin.dart';

class ProhitedWordsController extends GetxController
    with ProhitedWordsDetectMixin {
  ProhitedWordsController({
    required String initialValue,
  }) {
    inputValue.value = initialValue;
  }

  /// 输入框内容
  RxString inputValue = "".obs;

  replaceWord(String word, Function call) {
    final contents = inputValue.value.replaceAll(selectedBandedWord, word);
    byDebugPrint(contents);
    final bandedWordsCopy = List<String>.from(bandedWords);
    bandedWordsCopy.removeWhere((item) => item == selectedBandedWord.value);
    bandedWords.value = bandedWordsCopy;
    inputValue.value = contents;
    call();
  }

  replaceWithInitialLetterOfPinyin() {
    String content = inputValue.value;
    for (var e in bandedWords) {
      content = content.replaceAll(e, e.getFirstLetters());
    }
    return content;
  }
}
