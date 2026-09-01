import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/home/erase/beans/pen_size_bean.dart';
import 'package:video_clip_edit/modules/home/erase/picture_erase_result_page.dart';
import 'package:video_clip_edit/modules/home/providers/words_extract_provider.dart';
import 'package:video_clip_edit/modules/home/words/beans/upload_info_bean.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_download_util.dart';
import 'package:video_clip_edit/utils/comon/by_ffmpeg_util.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/home/erase/widgets/pen_size_view.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class PictureErasePage extends StatefulWidget {
  const PictureErasePage({
    super.key,
    required this.assets,
  });
  final List<AssetEntity> assets;

  @override
  State<PictureErasePage> createState() => _PictureErasePageState();
}

class _PictureErasePageState extends State<PictureErasePage> {
  @override
  void initState() {
    super.initState();
  }

  final GlobalKey _globalKey = GlobalKey();

  PenSizeBean? selectBean;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(context: context, title: "图片擦除"),
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Column(
        children: [
          /// 视频、图片预览
          _buildPreview(context),

          /// 笔触大小
          // _buildPenSize(context),

          /// 底部按钮
          _buildBottomBtn(context),
        ],
      ),
    );
  }

  Future<void> earaseImage(BuildContext context) async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        // 这里可以将pngBytes保存为图片或者上传等处理
        File? file = await widget.assets.first.file;
        final docPath = await getApplicationDocumentsDirectory();
        final savePath =
            "${docPath.path}${Platform.pathSeparator}img_${DateTime.now().millisecondsSinceEpoch}.png";
        File fileErease = File(savePath);
        fileErease.writeAsBytesSync(pngBytes);
        _uploadImage(
          file!,
          onSuccess: (url) {
            HttpUtils.post(
              APIs.imageErase,
              {
                "img_url": url,
              },
              showLoading: true,
              loadingText: "图片擦除中...",
              success: (data) async {
                byDebugPrint(data, tag: "一键擦除：");
                fileErease.delete();
                final String url = data["data"]["url"] ?? "";
                final navigator = Navigator.of(context);
                if (url.isNotEmpty) {
                  AssetEntity? asset = await ByDownloadUtil.downloadImage(url);
                  if (asset != null) {
                    navigator.push(
                      MaterialPageRoute(
                        builder: (context) =>
                            PictureEraseResultPage(asset: asset),
                      ),
                    );
                  }
                }
              },
              fail: (code, msg) {
                BotToast.showText(text: msg);
              },
            );
          },
        );
      }
    } catch (e) {
      byDebugPrint(e);
    }
  }

  _uploadImage(
    File file, {
    void Function(String)? onSuccess,
  }) {
    ByFfmpegUtil.loadUploadInfo(
      type: MediaType.picture,
      onSuccess: (UploadInfoBean infoBean) async {
        /// 上传
        ByFfmpegUtil.uploadFile(
          loadingText: "图片上传中",
          infoBean: infoBean,
          filePath: file.path,
          onSuccess: (resp) {
            ///增加鉴黄逻辑
            ByFfmpegUtil.contentsRisk(url: infoBean.objectUrl,onSuccess: (){
              onSuccess?.call(infoBean.objectUrl);
            });
          },
        );
      },
    );
  }

  /// 视频、图片预览
  Expanded _buildPreview(BuildContext context) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        child: RepaintBoundary(
          key: _globalKey,
          child: AspectRatio(
            aspectRatio: widget.assets.first.width / widget.assets.first.height,
            child: FutureBuilder<Widget>(
              future: widget.assets.first.originBytes.then((data) {
                if (data != null) {
                  return Image.memory(
                    data,
                    fit: BoxFit.cover,
                  );
                } else {
                  return Container(
                    color: Colors.grey,
                  );
                }
              }),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return snapshot.data!;
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
      ),
    );
  }

  /// 笔触大小
  _buildPenSize(BuildContext context) {
    return Container(
      color: ByColorUtil.CommonPageBgColor,
      height: 83.h,
      width: double.infinity,
      child: const PenSizeListView(),
    );
  }

  /// 底部按钮
  Container _buildBottomBtn(BuildContext context) {
    return Container(
      color: ByColorUtil.WhiteColor,
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 8.h,
        bottom: 8.h + ByScreenUtils.bottomSafeHeight,
      ),
      child: ByWidgetsUtil.commonBtn(
        title: "一键擦除",
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        borderRadius: 12.w,
        onClick: () async {
          earaseImage(context);

          // ByNavRouterUtils.push(
          //   context,
          //   ChangeNotifierProvider.value(
          //     value: context.read<VideoEraseProvider>(),
          //     child: const VideoHandlePage(type: VideoHandlePageType.picture),
          //   ),
          // );
        },
      ),
    );
  }
}
