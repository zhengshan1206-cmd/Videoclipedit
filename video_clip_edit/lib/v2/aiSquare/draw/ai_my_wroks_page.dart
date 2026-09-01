import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/widgets/ai_my_work_cell.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/beans/ai_draw_img_details_bean.dart';

class AiMyWroksPage extends StatefulWidget {
  const AiMyWroksPage({super.key});

  @override
  State<AiMyWroksPage> createState() => _AiMyWroksPageState();
}

class _AiMyWroksPageState extends State<AiMyWroksPage> {
  List<AiDrawImgDetailsBean>? workBeans;
  int page = 1;
  int size = 10;
  @override
  void initState() {
    super.initState();

    _loadAllWorks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ByWidgetsUtil.appBar(
          context: context,
          title: '我的创作',
        ),
        backgroundColor: ByColorUtil.CommonPageBgColor,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Column(
            children: [
              SizedBox(height: 8.h),
              ByWidgetsUtil.commonTipsBar(
                "内容由AI生成仅供参考，禁止利用功能从事违法活动，只保 留7天请及时保存到相册。",
              ),
              SizedBox(height: 6.h),
              Expanded(
                child: EasyRefresh(
                  refreshOnStart: true,
                  onRefresh: () {
                    page = 1;
                    workBeans?.clear();
                    _loadAllWorks();
                  },
                  onLoad: _loadAllWorks,
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10.h,
                      crossAxisSpacing: 11.w,
                      childAspectRatio: 17 / 28,
                    ),
                    itemBuilder: (context, index) {
                      return AiMyWorkCell(bean: workBeans![index]);
                    },
                    itemCount: workBeans?.length ?? 0,
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void _loadAllWorks() {
    final provider = context.read<AiDrawProvider>();
    provider.loadAllPictures(
      page: page,
      size: size,
      onSuccess: (beans) {
        final allBeans = List<AiDrawImgDetailsBean>.from(workBeans ?? []);
        allBeans.addElementsByRemovingLast(
          beans,
          pageSize: size,
          currentPage: page,
        );
        setState(() {
          workBeans = allBeans;
        });
      },
      onFailed: () {},
    );
  }
}
