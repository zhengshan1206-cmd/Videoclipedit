import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_color_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/v2/aiSquare/song/ai_song_view_page.dart';
import 'package:video_clip_edit/modules/profile/widgets/no_data_view.dart';
import 'package:video_clip_edit/v2/aiSquare/song/provider/ai_song_view_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/song/beans/ai_song_task_detail_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/song/provider/ai_song_tasks_provider.dart';

class AiSongTasksPage extends StatefulWidget {
  const AiSongTasksPage({super.key});

  @override
  State<AiSongTasksPage> createState() => _AiSongTasksPageState();
}

class _AiSongTasksPageState extends State<AiSongTasksPage> {
  late AiSongTasksProvider provider;

  @override
  void initState() {
    super.initState();
    provider = context.read<AiSongTasksProvider>();
    provider.getDetailList(true);
    // 上报页面进入埋点
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ByNavigatorUtil.reportDataPoint(
        pageTag: "myworks_list_ai_music_works",
        operateType: "view",
        funcDetailTag: "",
        funcDetailImg: "",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    provider = context.watch<AiSongTasksProvider>();
    return Scaffold(
      body: Column(
        children: [
          _buildAppBarWidget(),
          Expanded(
            child: provider.aiSongTasksBean.isEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.w),
                    child: Container(
                      margin: EdgeInsets.only(
                          bottom: ByScreenUtils.bottomSafeHeight + 12.h),
                      color: ByColorUtil.WhiteColor,
                      alignment: Alignment.center,
                      height: 300.h,
                      child: NoDataView(
                        onTap: () {
                          ByNavRouterUtils.goBack(context);
                        },
                      ),
                    ),
                  )
                : EasyRefresh(
                    onRefresh: () {
                      provider.getDetailList(true);
                    },
                    onLoad: () {
                      provider.getDetailList(false);
                    },
                    child: GridView.builder(
                        padding: const EdgeInsets.only(top: 1),
                        itemCount: provider.aiSongTasksBean.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1 / 1.2,
                        ),
                        itemBuilder: (_, position) {
                          AiSongTaskDetailBean aiSongTasksBean =
                              provider.aiSongTasksBean[position];
                          int status = aiSongTasksBean.status;
                          return GestureDetector(
                            onTap: () {
                              if (provider.isEdit) {
                                if (provider
                                    .checkIsSelect(aiSongTasksBean.status)) {
                                  aiSongTasksBean.isSelect =
                                      !aiSongTasksBean.isSelect;
                                  provider.notifyListeners();
                                }
                              } else if (status == 3) {
                                // 上报点击埋点
                                ByNavigatorUtil.reportDataPoint(
                                  pageTag: "myworks_list_ai_music_works",
                                  operateType: "click",
                                  funcDetailTag: aiSongTasksBean.id.toString(),
                                  funcDetailImg: aiSongTasksBean.coverUrl ?? "",
                                );
                                ByNavRouterUtils.pushNamedResult(
                                    context,
                                    ChangeNotifierProvider(
                                      create: (context) => AiSongViewProvder(),
                                      child: AiSongViewPage(
                                          provider.aiSongTasksBean,
                                          position,
                                          true),
                                    ), (data) {
                                  if (data != null) {
                                    ByNavRouterUtils.goBackWithParams(
                                        context, data);
                                  }
                                });
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(top: 10),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 170.h,
                                      width: 170.w,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          //状态:0待提交 1已提交 2生成中 3生成成功 4生成失败
                                          if (status == 0 ||
                                              status == 1 ||
                                              status == 2)
                                            Image.asset(
                                              height: 170.h,
                                              width: 170.w,
                                              fit: BoxFit.fill,
                                              "assets/mine/work_in_progress.png",
                                            ),

                                          if (status == 4)
                                            Image.asset(
                                              height: 170.h,
                                              width: 170.w,
                                              fit: BoxFit.fill,
                                              "assets/mine/work_failed_bg.png",
                                            ),
                                          if (status == 3)
                                            CachedNetworkImage(
                                              height: 170.h,
                                              width: 170.w,
                                              fit: BoxFit.fill,
                                              imageUrl:
                                                  aiSongTasksBean.coverUrl,
                                            ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              if (status == 3)
                                                Image.asset(
                                                  width: 40.w,
                                                  height: 40.h,
                                                  "assets/ai/ai_case_play.png",
                                                ),
                                              if (status == 4)
                                                Image.asset(
                                                  width: 70.w,
                                                  height: 70.h,
                                                  "assets/mine/work_failed.png",
                                                ),
                                              Visibility(
                                                  visible: status == 2 ||
                                                          status == 0 ||
                                                          status == 1
                                                      ? true
                                                      : false,
                                                  child: Column(
                                                    children: [
                                                      Center(
                                                        child: Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 30),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              ByWidgetsUtil
                                                                  .activityIndicator(
                                                                radius: 12,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top: 5),
                                                                child: Text(
                                                                  "生成中",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          16.sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 10),
                                                          child: Text(
                                                            "预估需要1-15分钟",
                                                            style: TextStyle(
                                                                color: ByColorUtils
                                                                    .hexColor(
                                                                        "#99A0B8"),
                                                                fontSize:
                                                                    10.sp),
                                                          )),
                                                      Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(top: 3),
                                                          child: Text(
                                                            "请耐心等待",
                                                            style: TextStyle(
                                                                color: ByColorUtils
                                                                    .hexColor(
                                                                        "#99A0B8"),
                                                                fontSize:
                                                                    10.sp),
                                                          ))
                                                    ],
                                                  )),
                                            ],
                                          ),
                                          Visibility(
                                            visible: provider.checkIsSelect(
                                                    aiSongTasksBean.status,
                                                    isShowMsg: false)
                                                ? (provider.isEdit
                                                    ? true
                                                    : false)
                                                : false,
                                            child: GestureDetector(
                                              onTap: () {
                                                if (provider.checkIsSelect(
                                                    aiSongTasksBean.status)) {
                                                  aiSongTasksBean.isSelect =
                                                      !aiSongTasksBean.isSelect;
                                                  provider.notifyListeners();
                                                }
                                              },
                                              child: Container(
                                                margin:
                                                    const EdgeInsets.all(10),
                                                alignment: Alignment.topRight,
                                                child: Image.asset(
                                                  height: 24.h,
                                                  width: 24.w,
                                                  fit: BoxFit.contain,
                                                  aiSongTasksBean.isSelect
                                                      ? "assets/home/mat_icon_selected.png"
                                                      : "assets/home/mat_icon_unselected.png",
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          aiSongTasksBean.createAt,
                                          style: TextStyle(
                                            color: ByColorUtils.hexColor(
                                                "#A0A3AE"),
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                        Text(
                                          aiSongTasksBean.title.isNotEmpty
                                              ? aiSongTasksBean.title
                                              : "",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        })),
          ),
          _buildBottomWidget(),
        ],
      ),
    );
  }

  _buildBottomWidget() {
    return Visibility(
      visible: provider.isEdit ? true : false,
      child: PhysicalModel(
        color: Colors.black,
        elevation: 10,
        child: Container(
          height: 66.h,
          width: double.infinity,
          color: ByColorUtil.WhiteColor,
          alignment: Alignment.center,
          child: SizedBox(
            height: 44.h,
            child: Row(
              children: [
                SizedBox(
                  width: 12.w,
                ),
                Expanded(
                  child: ByWidgetsUtil.commonBtn(
                    title: "取消",
                    fontSize: 16.sp,
                    borderRadius: 12.w,
                    fontWeight: FontWeight.w600,
                    bgColor: ByColorUtil.CommonTextColor.withOpacity(0.2),
                    textColor: ByColorUtil.WhiteColor,
                    onClick: () {
                      provider.setEdit(false);
                    },
                  ),
                ),
                SizedBox(
                  width: 12.w,
                ),
                Expanded(
                  child: ByWidgetsUtil.commonBtn(
                    title: "删除",
                    fontSize: 16.sp,
                    borderRadius: 12.w,
                    fontWeight: FontWeight.w600,
                    bgColor: const Color(0xFFFF5373),
                    textColor: ByColorUtil.WhiteColor,
                    onClick: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  height: 200.h,
                                  width: 300.w,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "提示",
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                          child: Container(
                                        margin: const EdgeInsets.only(top: 30),
                                        child: Text(
                                          "确定要删除选中的作品吗？删除后不可恢复",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: ByColorUtils.hexColor(
                                                "#0B1843"),
                                          ),
                                        ),
                                      )),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                          provider.deleteSelect();
                                        },
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    left: 10, right: 10),
                                                height: 44.h,
                                                decoration: BoxDecoration(
                                                  color: ByColorUtil
                                                      .TabTextColorSelected,
                                                  borderRadius:
                                                      BorderRadius.circular(22),
                                                ),
                                                alignment: Alignment.center,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "确定",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                        fontSize: 16.sp,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 20),
                                    child: Image.asset(
                                      "assets/home/icon_close.png",
                                      width: 24.w,
                                      height: 24.h,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 12.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column _buildAppBarWidget() {
    return Column(
      children: [
        SizedBox(
          height: ByScreenUtils.navigationBarHeight,
          // decoration: const BoxDecoration(
          //   color: Colors.white,
          //   image: DecorationImage(
          //     image: AssetImage("assets/ai/ai_app_bar_bg.png"),
          //     fit: BoxFit.fill,
          //   ),
          // ),
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
            title: Text(
              "最近任务",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              Center(
                child: Container(
                  height: 30.h,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(right: 12.w),
                  child: GestureDetector(
                    onTap: () {
                      provider.setEdit(!provider.isEdit);
                    },
                    child: Visibility(
                      visible: provider.aiSongTasksBean.isEmpty ? false : true,
                      child: provider.isEdit
                          ? GestureDetector(
                              onTap: () {
                                provider.setEditAll(!provider.isEditAll);
                              },
                              child: Row(
                                children: [
                                  Image.asset(
                                    provider.isEditAll
                                        ? "assets/login/checked.png"
                                        : "assets/login/uncheck_all.png",
                                    width: 16.w,
                                    height: 16.h,
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(width: 6.w),
                                  // const SizedBox(),
                                  Text(provider.isEditAll ? " 取消全选  " : " 全选  ",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 14.sp))
                                ],
                              ),
                            )
                          : Text("管理",
                              style: TextStyle(
                                  color: Colors.black, fontSize: 14.sp)),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(top: 8, left: 5, right: 5),
          decoration: BoxDecoration(
            color: ByColorUtils.hexColor("#E3E9FB"),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Image.asset(
                width: 12.w,
                height: 12.h,
                "assets/ai/ai_app_aisong_task_jinggao.png",
              ),
              Text(
                "  文件在云端存储7天，过期无法恢复，请及时保存。",
                style: TextStyle(
                    color: ByColorUtils.hexColor("#5A4BF7"), fontSize: 12.sp),
              )
            ],
          ),
        )
      ],
    );
  }
}
