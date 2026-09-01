import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/widgets/video_player_widget.dart';

class VideoMaterialEditPage<T> extends StatefulWidget {
  const VideoMaterialEditPage({
    super.key,
    required this.assetEntity,
  });

  final AssetEntity assetEntity;

  @override
  State<VideoMaterialEditPage<T>> createState() =>
      _VideoMaterialEditPageState<T>();
}

class _VideoMaterialEditPageState<T> extends State<VideoMaterialEditPage<T>> {
  List<Uint8List>? images;
  @override
  void initState() {
    super.initState();

    _loadVideoSnapshots();
  }

  void _loadVideoSnapshots() async {
    // final file = await widget.assetEntity.file;

    // if (file != null) {
    //   await ChannelOperate.toVideoEdit(false,
    //       videoLocalFilePathParameter: [file.path]).then((data) {
    //     // final List<Uint8List> imgs = e.cast<Uint8List>();
    //     byDebugPrint(data, tag: "获取到原生结果：${data.toString()}");
    //     setState(() {
    //       // images = imgs;
    //     });
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(context: context, title: "素材编辑"),
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                alignment: Alignment.center,
                child: FutureBuilder(
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(); // 等待时显示的加载指示器
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}"); // 错误时显示的内容
                    } else {
                      return VideoPlayerWidget(
                        url: snapshot.data?.path ?? "",
                        autoPlay: false,
                      ); // 成功获取数据时显示的内容
                    }
                  },
                  future: widget.assetEntity.file,
                ),
              ),
            ),
            Container(
              height: 80.h,
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 5.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.w),
                color: ByColorUtil.WhiteColor,
              ),
              child: images == null
                  ? const CupertinoActivityIndicator()
                  : Row(
                      children: [
                        Container(
                          height: 20.h,
                          width: 5.w,
                          margin: EdgeInsets.symmetric(horizontal: 8.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E2F34).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(3.w),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: images!.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  byDebugPrint("点击了$index");
                                },
                                child: Image.memory(
                                  images![index],
                                  fit: BoxFit.fitHeight,
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          height: 20.h,
                          width: 5.w,
                          margin: EdgeInsets.symmetric(horizontal: 8.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E2F34).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(3.w),
                          ),
                        ),
                      ],
                    ),
            ),
            SizedBox(
              height: ByScreenUtils.bottomSafeHeight,
            )
          ],
        ),
      ),
    );
  }
}
