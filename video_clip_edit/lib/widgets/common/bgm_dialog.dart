import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../modules/home/providers/by_audio_player.dart';
import '../../modules/home/widgets/svga_player.dart';
import '../../utils/comon/by_common_utils.dart';
import '../../utils/comon/by_widgets_util.dart';
import '../../utils/http/apis.dart';
import '../../utils/http/http_utils.dart';
import '../../v2/aiSquare/cartoon/beans/ai_cartoon_bgm_bean.dart';
import '../toast_util.dart';

///背景音乐选择弹窗 后续
class BgmDialog extends StatefulWidget {
  final String? id;
  final int? type;
  const BgmDialog({
    super.key,
    this.id,
    this.type,
  });

  @override
  State<BgmDialog> createState() => _BgmDialogState();
}

class _BgmDialogState extends State<BgmDialog> {
  ///背景音乐数据
  List<AiCartoonBgmBean> beans = [];

  ///选中的背景音乐id
  int? selectBgmId;

  ///初始化
  bool noUseBgm = false;

  ///音乐播放状态
  bool isPlay = false;

  ///播放器
  final ByAudioPlayer audioPlayer = ByAudioPlayer.sharedInstance;

  @override
  void initState() {
    super.initState();
    loadBgmList();
  }

  ///加载背景音乐
  loadBgmList() {
    HttpUtils.get(
      APIs.bgmListNew,
      {
        "page": 1,
        "pageSize": 200,
        "type": widget.type,
        // "cate": 1,
        // "useScenes": 4,
      },
      showLoading: false,
      success: (data) {
        byDebugPrint(data["data"]["items"], tag: "bgm列表:");
        final List bgmData = data["data"]["items"] ?? [];
        beans = bgmData.map((e) {
          final bean = AiCartoonBgmBean.fromJson(e);
          if (widget.id != null) {
            if (widget.id == bean.id.toString()) {
              selectBgmId = bean.id;
            }
          }
          return bean;
        }).toList();
        setState(() {});
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );

    log("selectBgmId====> $selectBgmId");
  }

  ///标题
  Widget _buildTitle({
    required BuildContext context,
  }) {
    return Container(
      margin: EdgeInsets.only(top: 20.w, right: 15.w),
      child: Row(
        children: [
          SizedBox(
            width: 18.w,
            height: 14.h,
          ),
          const Spacer(),
          ByWidgetsUtil.commonText(
            text: "背景音乐",
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).pop();
            },
            child: SizedBox(
              width: 18.w,
              height: 18.h,
              child: Image.asset(
                "assets/home/icon_close_dark.png",
                width: 14.w,
                height: 14.h,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
    );
  }

  ///不需要背景音乐按钮
  Widget _noMusicBtn({required BuildContext context}) {
    return GestureDetector(
      onTap: () {
        if (noUseBgm == false) {
          noUseBgm = true;
          selectBgmId = null;
          isPlay = false;
          audioPlayer.pause();
        } else {
          noUseBgm = false;
        }
        setState(() {});
      },
      child: Container(
        padding: EdgeInsets.only(top: 11.w, bottom: 11.w),
        margin: EdgeInsets.only(top: 20.w, left: 12.w, right: 12.w),
        decoration: BoxDecoration(
          color: noUseBgm ? const Color(0XFFF4F6FF) : const Color(0XFFF4F8F9),
          borderRadius: BorderRadius.circular(10.w),
          border: noUseBgm ? Border.all(color: const Color(0XFF5B4BF7)) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          "不需要背景音乐",
          style: TextStyle(
              color:
                  noUseBgm ? const Color(0XFF5B4BF7) : const Color(0XFF0B1843),
              fontSize: 14.sp,
              fontWeight: FontWeight.normal),
        ),
      ),
    );
  }

  ///音乐条目
  Widget _musicItem({
    required AiCartoonBgmBean musicBean,
  }) {
    return GestureDetector(
      onTap: () {
        if (selectBgmId != musicBean.id) {
          selectBgmId = musicBean.id;
          noUseBgm = false;
          isPlay = true;
        } else if (selectBgmId == musicBean.id) {
          isPlay = !isPlay;
        }
        if (isPlay) {
          audioPlayer.play(musicBean.url);
        } else {
          audioPlayer.pause();
        }
        setState(() {});
      },
      child: Container(
        padding:
            EdgeInsets.only(left: 12.w, right: 12.w, top: 8.w, bottom: 8.w),
        margin: EdgeInsets.only(top: 10.w, right: 12.w, left: 12.w),
        decoration: BoxDecoration(
            color: (selectBgmId == musicBean.id && !noUseBgm)
                ? const Color(0XFFF4F6FF)
                : Colors.white,
            border: (selectBgmId == musicBean.id && !noUseBgm)
                ? Border.all(color: const Color(0XFF5B4BF7), width: 2.w)
                : null,
            borderRadius: (selectBgmId == musicBean.id && !noUseBgm)
                ? BorderRadius.circular(12.w)
                : BorderRadius.circular(0)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.w),
              child: CachedNetworkImage(
                width: 44.w,
                height: 44.w,
                errorWidget: (context, url, error) =>
                    Image.asset("assets/ai/bgm_default.png"),
                imageUrl: musicBean.icon,
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(
              width: 13.5.w,
            ),
            Expanded(
              child: Text(
                musicBean.title,
                style: TextStyle(
                  color: (isPlay == true && selectBgmId == musicBean.id)
                      ? const Color(0XFF5B4BF7)
                      : const Color(0XFF0B1843),
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.clip,
                ),
                maxLines: 1,
              ),
            ),
            SizedBox(
              width: 8.w,
            ),
            if (selectBgmId == musicBean.id && !noUseBgm && isPlay)
              SizedBox(
                width: 15.w,
                height: 15.h,
                child: const SvgaPlayer(url: "assets/ai/ai_music_play.svga"),
              ),
            if (selectBgmId == musicBean.id && !noUseBgm) const Spacer(),
            if (selectBgmId == musicBean.id && !noUseBgm && isPlay)
              Image.asset(
                "assets/home/voice_pause_icon.png",
                width: 18.w,
                height: 18.w,
              ),
            if (selectBgmId == musicBean.id && !noUseBgm && !isPlay)
              Image.asset(
                "assets/home/new_play_icon.png",
                width: 18.w,
                height: 18.w,
              ),
          ],
        ),
      ),
    );
  }

  ///确定按钮
  Widget _confirmBtn() {
    return InkResponse(
      onTap: () {
        String selectUrl = "";
        String selectBgmTitle = "";
        String selectId = "";
        if (selectBgmId != null && beans.isNotEmpty) {
          for (var e in beans) {
            if (e.id == selectBgmId) {
              selectUrl = e.url;
              selectBgmTitle = e.title;
              selectId = e.id.toString();
            }
          }
        }
        Get.back(result: [selectUrl, selectBgmTitle, selectId]);
      },
      child: Container(
        alignment: Alignment.center,
        width: 1.sw,
        padding: EdgeInsets.only(top: 15.w, bottom: 15.w),
        margin: EdgeInsets.only(left: 12.w, right: 12.w),
        decoration: BoxDecoration(
            color: const Color(0XFF5B4BF7),
            borderRadius: BorderRadius.circular(12.w)),
        child: Text(
          "确定",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Expanded(
          child: SizedBox(),
        ),
        Container(
          width: double.infinity,
          // height: 0.7.sh,
          // margin: EdgeInsets.only(top: 0.35.sh),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.w),
                topRight: Radius.circular(18.w),
              )),
          child: Column(
            children: [
              _buildTitle(context: context),
              _noMusicBtn(context: context),
              SizedBox(
                height: 0.42.sh,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ...beans.map((e) => _musicItem(
                          musicBean: e,
                        ))
                  ],
                ),
              ),
              // const Spacer(),
              _confirmBtn(),
              SizedBox(
                height: 20.h,
              )
            ],
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    audioPlayer.pause();
    super.dispose();
  }
}
