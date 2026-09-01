import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/providers/stroy_create_provider.dart';
import 'package:video_clip_edit/modules/home/story/assistant/beans/creator_bean.dart';
import 'package:video_clip_edit/modules/home/story/assistant/assistant_info_page.dart';
import 'package:video_clip_edit/v2/aiSquare/writing/provider/ai_writing_provider.dart';
import 'package:video_clip_edit/modules/home/story/assistant/assistant_record_page.dart';


///AI写作页面
class AiWritingPage extends StatefulWidget {
  const AiWritingPage({super.key});

  @override
  State<AiWritingPage> createState() => _AiWritingPageState();
}

class _AiWritingPageState extends State<AiWritingPage> {
  late AiWritingProvider provider;
  @override
  void initState() {
    super.initState();
    provider = context.read<AiWritingProvider>();
    provider.loadaiWritingListData();
  }

  @override
  Widget build(BuildContext context) {
    // provider = context.watch<AiWritingProvider>();
    final mAiWritingListBean =
        context.select<AiWritingProvider, List<CreatorBean>>(
      (value) => value.mAiWritingListBean,
    );
    return Scaffold(
        body: Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        _buildAppBarWidget(),
        Expanded(
            child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                left: 12.w,
                right: 12.w,
                top: 10.h,
              ),
              sliver: SliverGrid.builder(
                itemCount: mAiWritingListBean.length > 2
                    ? 2
                    : mAiWritingListBean.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemBuilder: (c, index) {
                  return AiWrittingCellLarge(
                    index: index,
                    bean: mAiWritingListBean[index],
                  );
                },
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                left: 12.w,
                right: 12.w,
                top: 10.h,
                bottom: ByScreenUtils.bottomSafeHeight + 10.h,
              ),
              sliver: SliverGrid.builder(
                itemCount: mAiWritingListBean.length > 2
                    ? provider.mAiWritingListBean.length - 2
                    : 0,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 170 / 90,
                ),
                itemBuilder: (c, index) {
                  return AiWrittingCell(
                    index: index,
                    bean: provider.mAiWritingListBean[index + 2],
                  );
                },
              ),
            )
          ],
        ))
      ],
    ));
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
                "assets/ai/aixiezuo_title_img.png",
              ),
              centerTitle: true,
              actions: [
                Center(
                  child: Container(
                    height: 30.h,
                    margin: const EdgeInsets.only(right: 12),
                    child: ByWidgetsUtil.btnWithIcon(
                      iconH: 12.h,
                      iconW: 12.w,
                      fontSize: 12.sp,
                      title: "生成记录",
                      borderRadius: 100.w,
                      padding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 10.w),
                      bgColor: ByColorUtil.WhiteColor,
                      iconPath: "assets/ai/ai_draw_records.png",
                      textColor: ByColorUtil.CommonTextColor,
                      onClick: () {
                        ByNavRouterUtils.push(
                          context,
                          ChangeNotifierProvider.value(
                            value: StroyCreateProvider(),
                            child: AssistantRecordPage(isAiPage: true),
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AiWrittingCell extends StatelessWidget {
  const AiWrittingCell({
    super.key,
    required this.bean,
    required this.index,
  });

  final CreatorBean bean;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ByNavRouterUtils.push(
          context,
          ChangeNotifierProvider.value(
            value: StroyCreateProvider(),
            child: AssistantInfoPage(bean: bean),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image:
                  AssetImage("assets/home/bg_assistant_${index % 4 + 1}.png")),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),
              ByWidgetsUtil.commonText(
                fontSize: 16.sp,
                text: bean.title,
                fontWeight: FontWeight.bold,
                textColor: ByColorUtil.WhiteColor,
              ),
              SizedBox(height: 5.h),
              ByWidgetsUtil.commonText(
                fontSize: 12.sp,
                text:
                    "热度值：${bean.hotNum > 10000 ? "${(bean.hotNum / 10000).toStringAsFixed(2)}w" : bean.hotNum}",
                textColor: ByColorUtil.WhiteColor,
              ),
              SizedBox(height: 5.h),
              Image.asset(
                "assets/home/icon_assistant_more.png",
                width: 20.w,
                height: 20.h,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AiWrittingCellLarge extends StatelessWidget {
  const AiWrittingCellLarge({
    super.key,
    required this.bean,
    required this.index,
  });

  final CreatorBean bean;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ByNavRouterUtils.push(
          context,
          ChangeNotifierProvider.value(
            value: StroyCreateProvider(),
            child: AssistantInfoPage(bean: bean),
          ),
        );
      },
      child: Stack(
        children: [
          Positioned.fill(
              child: CachedNetworkImage(
            imageUrl: bean.icon,
          )),
          // ignore: avoid_unnecessary_containers
          Container(
            // decoration: BoxDecoration(
            //   image: DecorationImage(
            //       image:
            //           AssetImage("assets/home/bg_assistant_${index % 4 + 1}.png"),
            //       fit: BoxFit.cover),
            // ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  ByWidgetsUtil.commonText(
                    fontSize: 18.sp,
                    text: bean.title,
                    fontWeight: FontWeight.bold,
                    textColor: ByColorUtil.WhiteColor,
                  ),
                  SizedBox(height: 5.h),
                  ByWidgetsUtil.commonText(
                    fontSize: 12.sp,
                    text: bean.des,
                    textColor: ByColorUtil.WhiteColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
