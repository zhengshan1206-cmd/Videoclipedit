import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_color_utils.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/novelwriting/beans/ai_novel_singelchoice_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/novelwriting/providers/ai_novel_writing_providers.dart';
import 'package:video_clip_edit/widgets/common/right_navigation_bar.dart';

import '../../../utils/comon/by_nav_router_utils.dart';

class AiNovelWriting extends StatefulWidget {
  const AiNovelWriting({super.key});

  @override
  State<AiNovelWriting> createState() => _AiNovelWritingState();
}

class _AiNovelWritingState extends State<AiNovelWriting> {
  late AiNovelWritingProviders provider;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    provider = context.read<AiNovelWritingProviders>();
  }

  @override
  Widget build(BuildContext context) {
    provider = context.watch<AiNovelWritingProviders>();
    return Scaffold(
        body: Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        _buildAppBarWidget(),
        Expanded(
            child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ListView(
                  children: [
                    _buildContentCreateWidget(),
                  ],
                ))),
      ],
    ));
  }

  ///内容创作
  _buildContentCreateWidget() {
    return Container(
      margin: EdgeInsets.only(left: 12, right: 12, top: 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    "assets/ai/aichuangzuo_nrcz.png",
                    width: 18.w,
                    height: 18.h,
                  ),
                  Text(
                    "  内容创作",
                    style: TextStyle(
                        color: ByColorUtils.hexColor('#0B1843'),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  Image.asset(
                    "assets/ai/aichuangzuo_sjcz.png",
                    width: 18.w,
                    height: 18.h,
                  ),
                  Text(
                    "  随机AI生成",
                    style: TextStyle(
                      color: ByColorUtils.hexColor('#5B4BF7'),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildInputBodyWidget(),
          _buildSingleChoiceWidget("目标读者", provider.targetAudienceData),
          _buildSingleChoiceWidget("篇幅", provider.lengthData),
          _buildSingleChoiceWidget("故事视角", provider.storyPerspectiveData),
        ],
      ),
    );
  }

  Container _buildInputBodyWidget() {
    return Container(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 8),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        // border: Border.all(width: 1.0, color: ByColorUtil.TabTextColorSelected),
        color: ByColorUtils.hexColor('#F5F8F9'),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Column(
                children: [
                  TextField(
                      controller: provider.titleCreateEditingController,
                      decoration: InputDecoration(
                        hintText: "请输小说名字",
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 16.sp,
                          color: ByColorUtils.hexColor('#A2A5B0'),
                        ),
                      )),
                ],
              )),
            ],
          ),
          Container(
            color: ByColorUtils.hexColor('#EEEFF0'),
            height: 1,
          ),
          SizedBox(
            height: 200.h,
            child: Column(
              children: [
                Expanded(
                    flex: 1,
                    child: TextField(
                        maxLines: 10,
                        controller: provider.contentCreateEditingController,
                        decoration: InputDecoration(
                          counterText: "",
                          border: InputBorder.none,
                          hintText:
                              "题材：军事； 风格：科幻言情； 男主人设：骚气； 女主人设：疯批美人实则中二萌妹； 情节：逆天改命、穿书成反派后自救； 时空背",
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: ByColorUtils.hexColor('#C8CAD1'),
                          ),
                        ))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            ClipboardData? data =
                                await Clipboard.getData('text/plain');
                            provider.contentCreateEditingController.text =
                                data?.text ?? "";
                          },
                          child: Text('粘贴',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: ByColorUtils.hexColor('#C8CAD1'))),
                        ),
                        Text(' | ',
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: ByColorUtils.hexColor('#C8CAD1'))),
                        GestureDetector(
                          onTap: () {
                            provider.contentCreateEditingController.clear();
                            provider.contentCreateEditingController.clear();
                            provider.notifyListeners();
                          },
                          child: Text('清空  ',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: ByColorUtils.hexColor('#C8CAD1'))),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  _buildAppBarWidget() {
    return GestureDetector(
      onTap: () {
        ByNavRouterUtils.goBack(context);
      },
      child: Column(
        children: [
          Container(
            height: ByScreenUtils.navigationBarHeight,
            decoration: const BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage("assets/ai/ai_app_bar_bg.png"),
                fit: BoxFit.fill,
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              bottom: ByWidgetsUtil.appBarBottom(),
              elevation: 0,
              leading: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  ByNavRouterUtils.goBack(context);
                },
                child: Container(
                  width: 30.w,
                  height: 30.h,
                  alignment: Alignment.center,
                  child: Image.asset(
                    "assets/home/icon_back.png",
                    width: 16.w,
                    height: 16.h,
                  ),
                ),
              ),
              title: Image.asset(
                height: 19.h,
                fit: BoxFit.fitHeight,
                "assets/ai/xiaoshuochuangzuotitle.png",
              ),
              centerTitle: true,
              actions: const [
                Center(

                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildSingleChoiceWidget(String txt, List<AiNovelSingelchoiceBean> data) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              txt,
              style: TextStyle(
                  color: ByColorUtils.hexColor('#0B1843'),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "(单选)",
              style: TextStyle(
                color: ByColorUtils.hexColor('#0B1843'),
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
        GridView.builder(
            padding: const EdgeInsets.only(top: 10),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 5,
                crossAxisSpacing: 10,
                childAspectRatio: 80 / 36),
            itemBuilder: (_, position) {
              AiNovelSingelchoiceBean item = data[position];
              return GestureDetector(
                onTap: () {
                  for (int i = 0; i < data.length; i++) {
                    data[i].isSelect = false;
                  }
                  item.isSelect = true;
                  provider.notifyListeners();
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: item.isSelect
                        ? ByColorUtils.hexColor('#5B4BF7')
                        : ByColorUtils.hexColor('#F8FAFB'),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        item.txt,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: item.isSelect ? Colors.white : Colors.black,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            })
      ],
    );
  }
}
