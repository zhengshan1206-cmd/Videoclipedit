import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/toolBox/widgets/tool_box_banner_view.dart';
import 'package:video_clip_edit/v2/toolBox/widgets/sliver_type_list_view.dart';
import 'package:video_clip_edit/v2/toolBox/providers/new_tool_box_provider.dart';

class NewToolBoxPage extends StatefulWidget {
  const NewToolBoxPage({
    super.key,
  });

  @override
  State<NewToolBoxPage> createState() => _NewToolBoxPageState();
}

class _NewToolBoxPageState extends State<NewToolBoxPage> {
  final _controller = ScrollController();
  final ScrollController _categoryScrollController = ScrollController();
  final PageController _pageController = PageController();
  @override
  void initState() {
    _addListener();

    super.initState();
  }

  void _addListener() {
    _controller.addListener(() {
      final offset = _controller.offset;
      context.read<NewToolBoxProvider>().updateOffset(offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    byDebugPrint("-----build");
    return Scaffold(
      body: Stack(
        children: [
          Container(),
          _buildBanner(context),
          _buildContents(context),
        ],
      ),
    );
  }

  _buildBanner(BuildContext context) {
    return const ToolBoxBannerView();
  }

  _buildContents(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0), //12.w
      child: CustomScrollView(
        controller: _controller,
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 210.h,
              color: Colors.transparent,
              width: double.infinity,
            ),
          ),
          SliverTypeListView(
            categoryScrollController: _categoryScrollController,
            pageController: _pageController,
            onSize: (Size size, int index) {},
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            sliver: SliverGrid.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10.h,
                crossAxisSpacing: 10.w,
                childAspectRatio: 17 / 22,
              ),
              itemCount: 10,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16.w),
                  child: Stack(
                    children: [
                      Container(),
                      Positioned.fill(
                        child: Image.asset("assets/newToolBox/cell_bg.png"),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: Image.asset(
                          "assets/newToolBox/cell_top_bg.png",
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 100.h,
                        child: ByWidgetsUtil.gradientBgContainer(
                          borderRadius: 0,
                          gradient: ByColorUtil.lineareGradient(
                            colorStart: const Color(0xFFFFFFFF).withOpacity(0),
                            colorEnd: const Color(0xFFFFFFFF).withOpacity(0.5),
                            end: Alignment.bottomCenter,
                            begin: Alignment.topCenter,
                          ),
                          child: Container(),
                        ),
                      ),
                      Positioned.fill(
                          child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Column(
                          children: [
                            SizedBox(height: 15.h),
                            Row(
                              children: [
                                Image.asset(
                                  "assets/newToolBox/cell_logo_top.png",
                                  width: 18,
                                  height: 18,
                                ),
                                SizedBox(width: 4.w),
                                ByWidgetsUtil.commonText(
                                  fontSize: 16.sp,
                                  text: "小说推文视频",
                                  textColor: const Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.bold,
                                )
                              ],
                            ),
                            SizedBox(height: 5.h),
                            ByWidgetsUtil.commonText(
                              fontSize: 11.sp,
                              text: "复制小说内容，一键AI成片。",
                              fontWeight: FontWeight.normal,
                              textColor: const Color(0xFFFFFFFF),
                            ),
                            const Spacer(),
                            Container(
                              height: 36.h,
                              margin: EdgeInsets.symmetric(horizontal: 10.w),
                              child: ByWidgetsUtil.commonBtn(
                                fontSize: 14.sp,
                                title: "生成视频",
                                borderRadius: 20.h,
                                padding: EdgeInsets.zero,
                                fontWeight: FontWeight.bold,
                                onClick: () {},
                              ),
                            ),
                            SizedBox(height: 10.h),
                          ],
                        ),
                      ))
                    ],
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: ByScreenUtils.bottomSafeHeight + 15.h,
            ),
          )
        ],
      ),
    );
  }
}
