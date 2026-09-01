import 'package:video_clip_edit/modules/home/beans/function_item_bean.dart';
import 'package:video_clip_edit/providers/base_provider.dart';

class VideoDeduplicationProvider extends BaseProvider {
  List<FunctionItemBean> homeFunctions = [
    FunctionItemBean.fromJson({
      "icon": "assets/home/watermark_video.png",
      "title": "本地上传",
      "desc": "上传本地图片、视频文件"
    })
  ];

  List<E> updateMultiSelectableElements<E>(E ele, List<E> source) {
    if (source.contains(ele)) {
      source.remove(ele);
    } else {
      source.add(ele);
    }
    return source;
  }

  /// 模式
  final modes = [
    "扫光",
    "反光开幕",
    "下降开幕",
    "书单模式",
    "横版三屏",
    "溶图模式",
    "影视",
    "短剧",
    "探店",
    "好物"
  ];
  late String selectedMode = modes[0];
  void updateSelectedModes(String e) {
    selectedMode = e;
    notifyListeners();
  }

  /// 特效
  final speciaEffects = [
    "基础去重",
    "修改MD5",
    "智能抽帧",
    "智能调色",
    "掐头去尾",
    "画面锐化",
    "智能镜像",
    "随机翻转",
    "随机移动",
    "随机加速",
  ];
  late List<String> selectedSpeciaEffect = [speciaEffects[0]];
  void updateSelectedSpeciaEffect(String e) {
    updateMultiSelectableElements(e, selectedSpeciaEffect);
    notifyListeners();
  }

  /// 背景音乐
  final bgms = [
    "智能配乐",
    "本地上传",
  ];
  String? selectedBgm;
  void updateSelectedBgm(String e) {
    selectedBgm = e;
    notifyListeners();
  }

  /// 是否移除视频原声
  bool removeVideoAudio = false;
  updateRemoveVideoAudioStatus(bool status) {
    removeVideoAudio = status;
    notifyListeners();
  }
}
