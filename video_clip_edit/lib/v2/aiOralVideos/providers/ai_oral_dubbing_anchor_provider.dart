import 'package:bot_toast/bot_toast.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_dubbing_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_input_mixin.dart';

class AiOralDubbingAnchorProvider extends AiInputMixin {
  /// 角色配音
  List<AiCartoonDubbingBean> dubbingBeans = [];

  updateDubbingBeans(List<AiCartoonDubbingBean> beans) {
    dubbingBeans = beans;
    notifyListeners();
  }

  /// 选中的配音角色id
  int selectedDubbingId = -1;
  updateSelectedDubbingId(int id) {
    selectedDubbingId = id;
    notifyListeners();
  }

  /// 正在试听的角色id
  int listeningDubbingId = -1;
  updateListeningDubbingId(int id) {
    listeningDubbingId = id;
    notifyListeners();
  }

  /// 获取角色配音
  loadDubbingList({
    bool showLoading = false,
    bool loadFirstSelected = true,
  }) {
    HttpUtils.post(
      APIs.aiSpeakerList,
      {
        "page": 1,
        "size": 999,
      },
      showLoading: showLoading,
      success: (data) {
        final List speakerList = data["data"]["items"] ?? [];
        List<AiCartoonDubbingBean> beans =
            speakerList.map((e) => AiCartoonDubbingBean.fromJson(e)).toList();
        if(loadFirstSelected){
          if (selectedDubbingId == -1 && beans.isNotEmpty) {
            selectedDubbingId = beans.first.id;
          }
        }
        updateDubbingBeans(beans);
        updateSelectMyCloneMusicIndex();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }


  ///选择AiMusic index
  int selectAiMusicIndex = -1;


  updateSelectMyCloneMusicIndex(){
    Get.log("更新我的AI声音index====> ${selectedDubbingId}  ${dubbingBeans.length}");
    if(selectedDubbingId!=-1&&dubbingBeans.isNotEmpty){
      for (var e in dubbingBeans) {
        if(e.id==selectedDubbingId){
          selectAiMusicIndex = dubbingBeans.indexOf(e);
          notifyListeners();
          return;
        }
      }
    }
  }

}
