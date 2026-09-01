
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../utils/http/apis.dart';
import '../../../utils/http/http_utils.dart';
import '../../../v2/aiVideo/models/ai_video_square_model.dart';
import 'new_ai_video_controller.dart';
import 'new_ai_video_dialog_ex.dart';

class NewAiVideoListViewPageEx extends StatefulWidget {
  final AiVideoGenerationType type;

  ///当前类型
  final int? currentIndex;
  const NewAiVideoListViewPageEx({
    super.key,
    required this.type,
    this.currentIndex,
  });

  @override
  State<NewAiVideoListViewPageEx> createState() =>
      _NewAiVideoListViewPageState();
}

class _NewAiVideoListViewPageState extends State<NewAiVideoListViewPageEx> {

  List<AiVideoSquareModel> listBeans = [];
  int page = 1;
  int size = 10;
  NewAiVideoController get newAiVideoController =>
      Get.find<NewAiVideoController>();
  late EasyRefreshController _controller;
  bool couldLoadMore = true;

  bool showShimmer = true;

  @override
  void initState() {
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    _refresh();
    super.initState();
  }

  Widget _viewItem({
    required AiVideoSquareModel e,
  }) {
    return GestureDetector(
        onTap: () {
          showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return NewAiVideoDialogEx(model: e,type: widget.currentIndex,);
              },
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              )).then((value) {
            if (value != null) {
              newAiVideoController.useSame(models: value);
              Get.back(result: value);
            }
          });
        },
        child:Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: Container(
                height: 315.h,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.w),
                    image: DecorationImage(
                        image: NetworkImage(e.coverUrl), fit: BoxFit.cover)),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                "assets/ai/aiVideo/new_ai_video_play_icon.png",
                width: 23.w,
                height: 23.w,
              ),
            )
          ],
        ),);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    page =1;
    HttpUtils.get(
      APIs.aiVideoCategoryDetail,
      {
        "page": page,
        "pageSize": size,
        "category_id": widget.type.code,
      },
      success: (data) {
        if (showShimmer == true) {
          showShimmer = false;
          if (mounted == true) {
            setState(() {});
          }
        }
        final success = data["status"] == 200;
        if (!success) {
          return;
        }
        final List list = data["data"]["data"] ?? [];
        int? lastPage = data["data"]["last_page"];
        Get.log("====list====> ${data["data"]}");
        final beans = List<AiVideoSquareModel>.from(list.map(
          (ele) => AiVideoSquareModel.fromJson(ele),
        ));
        if(lastPage!=null){
          Get.log("====最后一页====> ${lastPage}");
          if(page<lastPage){
            couldLoadMore = true;
          }else{
            couldLoadMore = false;
          }
        }

        listBeans = beans;
        Get.log("====page====> ${page}  beans==> ${listBeans.length}");
        _controller.finishRefresh();
        _controller.resetFooter();
        setState(() {});
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  Future<void> _loadMore() async {
    if(!couldLoadMore){
      _controller.finishLoad();
      _controller.resetFooter();
      setState(() {
      });
      return;
    }
    page++;
    HttpUtils.get(
      APIs.aiVideoCategoryDetail,
      {
        "page": page,
        "pageSize": size,
        "category_id": widget.type.code,
      },
      success: (data) {
        final success = data["status"] == 200;
        if (!success) {
          return;
        }
        final List list = data["data"]["data"] ?? [];
        int? lastPage = data["data"]["last_page"];
        Get.log("====list====> ${list}");

        if(lastPage!=null){
          Get.log("====最后一页====> ${lastPage}");
          if(page<lastPage){
            page++;
            couldLoadMore = true;
          }else{
            couldLoadMore = false;
          }
        }


        final beans = List<AiVideoSquareModel>.from(list.map(
          (ele) => AiVideoSquareModel.fromJson(ele),
        ));
        listBeans.addAll(beans);
        Get.log("====page====> ${page}  beans===>${listBeans.length}");
        _controller.finishLoad();
        _controller.resetFooter();
        setState(() {});
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFF8FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "热门同款",
          style: TextStyle(
              color: const Color(0XFF0B1843),
              fontSize: 16.sp,
              fontWeight: FontWeight.bold),
        ),
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20.w,
          ),
        ),
      ),
      body: showShimmer
          ? SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: _buildShimmer(),
            )
          : EasyRefresh(
              controller: _controller,
              onRefresh: _refresh,
              onLoad: _loadMore,
              child: GridView.count(
                crossAxisSpacing: 11.w,
                mainAxisSpacing: 10.w,
                childAspectRatio: 3 / 4,
                padding: EdgeInsets.only(left: 12.w, right: 12.w),
                crossAxisCount: 2,
                children: [
                  ...listBeans.map((e) => _viewItem(e: e)),
                ],
              ),
            ),
    );
  }

  Widget _buildShimmer() {
    return GridView.count(
      crossAxisSpacing: 11.w,
      mainAxisSpacing: 10.w,
      childAspectRatio: 3 / 4,
      padding: EdgeInsets.only(left: 12.w, right: 12.w),
      crossAxisCount: 2,
      children: [
        _buildShimmerItem(),
        _buildShimmerItem(),
        _buildShimmerItem(),
        _buildShimmerItem(),
        _buildShimmerItem(),
        _buildShimmerItem(),
      ],
    );
  }

  Widget _buildShimmerItem() {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: SizedBox(
        height: 315.h,
        child: Shimmer.fromColors(
          baseColor: Colors.grey.withOpacity(.2),
          highlightColor: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10.w),
            ),
          ),
        ),
      ),
    );
  }
}
