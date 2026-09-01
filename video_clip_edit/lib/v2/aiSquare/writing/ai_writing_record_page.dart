import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_color_utils.dart';
import 'package:video_clip_edit/utils/comon/by_time_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/v2/aiSquare/writing/ai_writing_page.dart';
import 'package:video_clip_edit/modules/profile/widgets/no_data_view.dart';
import 'package:video_clip_edit/modules/home/providers/stroy_create_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/writing/provider/ai_writing_provider.dart';
import 'package:video_clip_edit/modules/home/story/assistant/assistant_record_detail_page.dart';
import 'package:video_clip_edit/modules/home/story/assistant/beans/assistant_record_item_bean.dart';

class AiWritingRecordPage extends StatefulWidget {
  const AiWritingRecordPage({
    super.key,
    this.showAppBar = true,
  });

  final bool showAppBar;
  @override
  State<AiWritingRecordPage> createState() => _AiWritingRecordPageState();
}

class _AiWritingRecordPageState extends State<AiWritingRecordPage> {
  late AiWritingProvider provider;

  @override
  void initState() {
    super.initState();
    provider = context.read<AiWritingProvider>();
    provider.loadAssistantRecord(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    provider = context.watch<AiWritingProvider>();
    return Scaffold(
      body: Container(
        color: ByColorUtils.hexColor('#F8FAFB'),
        child: Column(
          children: [
            _buildAppBarWidget(),
            if (widget.showAppBar)
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(top: 8, left: 12, right: 12),
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
                      "  文字在云端存储7天，过期无法恢复，请及时保存。",
                      style: TextStyle(
                          color: ByColorUtils.hexColor("#5A4BF7"),
                          fontSize: 12.sp),
                    )
                  ],
                ),
              ),
            Expanded(
                child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: provider.mAiWritingRecordBean.isEmpty
                        ? _buildNoData(context,
                            margin: EdgeInsets.only(
                                left: 12.w,
                                right: 12.w,
                                bottom: ByScreenUtils.bottomSafeHeight + 12.h))
                        : EasyRefresh(
                            controller: provider.assistantController,
                            onRefresh: () {
                              provider.loadAssistantRecord(reset: true);
                            },
                            onLoad: () {
                              provider.loadAssistantRecord(reset: false);
                            },
                            child: ListView.builder(
                              padding: EdgeInsets.only(left: 12.w, right: 12.w),
                              itemCount: provider.mAiWritingRecordBean.length,
                              itemBuilder: (context, index) {
                                final AssistantRecordItemBean bean =
                                    provider.mAiWritingRecordBean[index];
                                return _buildItemWidget(bean);
                              },
                            ),
                          ))),
            _buildBottomWidget(),
          ],
        ),
      ),
    );
  }

  _buildNoData(
    BuildContext context, {
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ByColorUtil.WhiteColor,
        borderRadius: BorderRadius.circular(15.h),
      ),
      alignment: Alignment.center,
      margin: margin ?? EdgeInsets.symmetric(vertical: 15.h),
      child: NoDataView(
        onTap: () {
          if (widget.showAppBar) {
            ByNavRouterUtils.goBack(context);
          } else {
            ByNavRouterUtils.push(
                context,
                ChangeNotifierProvider(
                  create: (context) => AiWritingProvider(),
                  child: const AiWritingPage(),
                ));
          }
        },
      ),
    );
  }

  _buildItemWidget(AssistantRecordItemBean bean) {
    final menus = ["复制", "删除"];
    return GestureDetector(
      onTap: () {
        // 上报点击埋点（文案只需要上报id，不需要封面图，使用token作为标识）
        ByNavigatorUtil.reportDataPoint(
          pageTag: "myworks_list_txt_extraction_works",
          operateType: "click",
          funcDetailTag: bean.token,
          funcDetailImg: "",
        );
        ByNavRouterUtils.push(
          context,
          AssistantRecordDetailPage(
            recordItemBean: bean,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(
          bottom: 5.h,
          left: 2.w,
          right: 2.w,
        ),
        padding: EdgeInsets.only(
          left: 12.w,
          top: 12.h,
          bottom: 12.h,
        ),
        decoration: BoxDecoration(
          color: ByColorUtil.WhiteColor,
          borderRadius: BorderRadius.circular(12.w),
          boxShadow: [
            BoxShadow(
              color: ByColorUtil.BlackColor.withOpacity(0.05),
              blurRadius: 2.w,
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ByWidgetsUtil.commonText(
                    text: bean.sketch,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                  SizedBox(height: 12.h),
                  ByWidgetsUtil.commonText(
                    text: bean.answer,
                    fontSize: 12.sp,
                    textColor: ByColorUtil.CommonTextColor.withOpacity(0.6),
                  ),
                  SizedBox(height: 12.h),
                  ByWidgetsUtil.commonText(
                    text: ByTimeUtils.dateTimeToTime(bean.createTime),
                    fontSize: 12.sp,
                    textColor: ByColorUtil.CommonTextColor.withOpacity(0.6),
                  ),
                ],
              ),
            ),
            CustomPopup(
              showArrow: false,
              contentPadding: EdgeInsets.zero,
              backgroundColor: const Color(0xFFe9eff1),
              barrierColor: ByColorUtil.BlackColor.withOpacity(0.5),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: menus.map((e) {
                  final showBorder = menus.indexOf(e) < menus.length - 1;
                  return GestureDetector(
                    onTap: () {
                      if (menus.indexOf(e) == 0) {
                        Clipboard.setData(ClipboardData(text: bean.answer));
                        BotToast.showText(text: "复制成功");
                      } else {
                        context
                            .read<StroyCreateProvider>()
                            .deleteAssistantMessage(msgID: bean.token);
                      }
                      ByNavRouterUtils.goBack(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.h, horizontal: 30.w),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: ByColorUtil.BlackColor.withOpacity(
                                showBorder ? 0.1 : 0),
                          ),
                        ),
                      ),
                      child: ByWidgetsUtil.commonText(text: e),
                    ),
                  );
                }).toList(),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
                child: Image.asset(
                  "assets/home/icon_more.png",
                  width: 10,
                  height: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildAppBarWidget() {
    if (widget.showAppBar == false) return Container();
    return Column(
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
            backgroundColor: Colors.white,
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
            title: Text("生成记录",
                style: TextStyle(
                    color: ByColorUtils.hexColor('#0B1843'),
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp)),
            centerTitle: true,
            actions: [
              Container(
                height: 30.h,
                margin: EdgeInsets.only(right: 12.w),
                child: GestureDetector(
                  onTap: () {
                    provider.setEdit(!provider.isEdit);
                  },
                  child: Visibility(
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
                                  width: 24.w,
                                  height: 24.h,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(width: 6.w),
                                // const SizedBox(),
                                Text(provider.isEditAll ? " 取消全选  " : " 全选  ",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 17.sp))
                              ],
                            ),
                          )
                        : Text("管理",
                            style: TextStyle(
                                color: Colors.black, fontSize: 16.sp)),
                  ),
                ),
              ),
              // Container(
              //   margin: EdgeInsets.only(right: 12),
              //   child:Text("管理" ,style: TextStyle( color: ByColorUtils.hexColor('#0B1843'),fontSize: 14.sp)),
              // )
            ],
          ),
        ),
      ],
    );
  }

  _buildBottomWidget() {
    return Visibility(
        visible: provider.isEdit ? true : false,
        child: Container(
          margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: Row(
            children: [
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  provider.setEdit(false);
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: ByColorUtils.hexColor('#A0A3AE'),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "取消",
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                ),
              )),
              Container(
                width: 10,
              ),
              Expanded(
                  child: GestureDetector(
                onTap: () {
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                        color: ByColorUtils.hexColor("#0B1843"),
                                      ),
                                    ),
                                  )),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      // provider.deleteSelect();
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
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
                                                    fontWeight: FontWeight.bold,
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
                child: Container(
                  alignment: Alignment.center,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: ByColorUtil.HomeHotAuthNumberColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "删除",
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                ),
              )),
              Container(
                width: 10,
              ),
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  _showBottomDialog();
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: ByColorUtils.hexColor('#5B4BF7'),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "导出",
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                ),
              ))
            ],
          ),
        ));
  }

  _showBottomDialog() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(18),
          ),
        ),
        builder: (BuildContext context) {
          //构建弹框中的内容
          return StatefulBuilder(builder: (c, setBottomSheetState) {
            return Container(
              height: 240.h,
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(),
                      Text(
                        "选择导出格式",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Image.asset(
                          "assets/login/login_dialog_close.png",
                          width: 12.9,
                          height: 12.7,
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Image.asset(
                        "assets/ai/aiduihua_dcword.png",
                        width: 170.w,
                        height: 170.h,
                      )),
                      Expanded(
                          child: Image.asset(
                        "assets/ai/aiduihua_dctxt.png",
                        width: 170.w,
                        height: 170.h,
                      ))
                    ],
                  )
                ],
              ),
            );
          });
        },
        context: context);
  }
}
