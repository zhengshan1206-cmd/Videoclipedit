import 'package:get/get.dart';
import 'package:video_clip_edit/core/util/extension.dart';
import 'package:video_clip_edit/data/model/aiCreate/ai_create_picture_style_bean.dart';
import 'package:video_clip_edit/data/model/aiCreate/ai_create_request.dart';

class FolkStoryCreateRequest extends AiCreateRequest {
  FolkStoryCreateRequest({
    Rx<AICreatePictureStyleBean?>? selectStyleBean,
  })  : selectStyleBean = selectStyleBean ?? Rx<AICreatePictureStyleBean?>(null),
        super();

  ///画面风格
  final Rx<AICreatePictureStyleBean?> selectStyleBean;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.setIfNotNull(value: selectStyleBean.value?.id, key: 'image_style_id');
    return data;
  }
}
