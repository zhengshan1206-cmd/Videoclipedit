import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';

enum AiCartoonAudioStatus { playing, pause, resume, stop, complete }

class AiCartoonAudioStatusProvider extends BaseProvider {
  AiCartoonAudioStatus currentStatus = AiCartoonAudioStatus.stop;
  changeAudioStatus(AiCartoonAudioStatus status) {
    currentStatus = status;
    byDebugPrint("changeAudioStatus=====================$currentStatus");
    notifyListeners();
  }
}
