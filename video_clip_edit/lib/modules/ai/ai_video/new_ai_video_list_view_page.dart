import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import '../../../utils/http/apis.dart';
import '../../../utils/http/http_utils.dart';
import '../../../v2/aiVideo/models/ai_video_square_model.dart';
import 'new_ai_video_controller.dart';
import 'new_ai_video_dialog_ex.dart';

class NewAiVideoListViewPage extends StatefulWidget {
  final AiVideoGenerationType type;
  const NewAiVideoListViewPage({
    super.key,
    required this.type,
  });

  @override
  State<NewAiVideoListViewPage> createState() => _NewAiVideoListViewPageState();
}

class _NewAiVideoListViewPageState extends State<NewAiVideoListViewPage> {
  List<AiVideoSquareModel> listBeans = [];
  int page = 1;
  int size = 10;
  int loadTimes = 0;
  NewAiVideoController get newAiVideoController =>
      Get.find<NewAiVideoController>();

  final EasyRefreshController _easyRefreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  @override
  void initState() {
    super.initState();
  }

  resetPages() {
    page = 1;
    listBeans.clear();
  }

  void loadList({
    void Function(bool hasMore)? onSuccess,
    required void Function() onFailed,
    bool isRefresh = false,
  }) {
    if (isRefresh) {
      resetPages();
    }
    HttpUtils.get(
      APIs.aiVideoCategoryDetail,
      {
        "page": page,
        "pageSize": size,
        "category_id": widget.type.code,
      },
      success: (data) {
        loadTimes++;
        final success = data["status"] == 200;
        if (!success) {
          onFailed.call();
          return;
        }
        final List list = data["data"]["data"] ?? [];

        Get.log("====list====> ${list}");

        final beans = List<AiVideoSquareModel>.from(list.map(
          (ele) => AiVideoSquareModel.fromJson(ele),
        ));
        final results = List<AiVideoSquareModel>.from(listBeans);
        page = results.addElementsByRemovingLast(beans,
            pageSize: size, currentPage: page);

        Get.log("====page====> ${page}");

        listBeans = results;
        setState(() {});
        onSuccess?.call(beans.isNotEmpty && beans.length % 10 == 0);
      },
      fail: (code, msg) {
        onFailed.call();
        BotToast.showText(text: msg);
      },
    );
  }

  // 上拉加载更多
  Future<void> _loadMore({
    required BuildContext context,
  }) async {
    Get.log("执行加载更多");

    loadList(
      isRefresh: false,
      onFailed: () {
        _easyRefreshController.finishLoad(
          IndicatorResult.fail,
          false,
        );
        setState(() {});
      },
      onSuccess: (hasMore) {
        _easyRefreshController.finishLoad(
          hasMore ? IndicatorResult.success : IndicatorResult.noMore,
          true,
        );
        setState(() {});
      },
    );
  }

  // 下拉刷新
  Future<void> _refresh({
    required BuildContext context,
  }) async {
    loadList(
      isRefresh: true,
      onSuccess: (hasMore) {
        _easyRefreshController.finishRefresh(IndicatorResult.success, false);
        Get.log("===hasMore=== $hasMore");
        // if (hasMore) {
        //   _easyRefreshController.resetFooter();
        // }
        setState(() {});
      },
      onFailed: () {
        _easyRefreshController.finishRefresh(
          IndicatorResult.fail,
          false,
        );
        setState(() {});
      },
    );
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
              return NewAiVideoDialogEx(model: e);
            },
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            )).then((value) {
          if (value != null) {
            newAiVideoController.useSame(models: value);
            Get.back();
          }
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            // width: 90.w,
            height: 225.h,
            margin: EdgeInsets.only(right: 10.w),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.w),
                image: DecorationImage(
                    image: NetworkImage(e.coverUrl), fit: BoxFit.cover)),
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
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
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
            )),
        body: SizedBox(
          // height: 1.sh,
          child: EasyRefresh(
              // refreshOnStart: true,
              triggerAxis: Axis.vertical,
              controller: _easyRefreshController,
              onLoad: () => _loadMore(context: context),
              onRefresh: () => _refresh(context: context),


              // child: ListView.builder(itemBuilder: (context, index) {
              //   if (index > listBeans.length - 1) {
              //     return const SizedBox();
              //   }
              //   final bean = listBeans[index];
              //   return _viewItem(e: bean);
              // }),


              child: WaterfallFlow.builder(
                  gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 11.w,
                    mainAxisSpacing: 10.h,
                  ),
                  itemBuilder: (context, index) {
                    if (index > listBeans.length - 1) {
                      return const SizedBox();
                    }
                    final bean = listBeans[index];
                    return _viewItem(e: bean);
                  }),

              ),
        ));
  }
}
