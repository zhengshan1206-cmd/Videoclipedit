import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/common/widget/common_dialog.dart';
import 'package:video_clip_edit/modules/profile/beans/my_work_bean.dart';
import 'package:video_clip_edit/modules/profile/widgets/mine_work_cell.dart';
import 'package:video_clip_edit/modules/profile/widgets/no_data_view.dart';
import 'package:video_clip_edit/providers/mine_page_provider.dart';
import 'package:video_clip_edit/routes/route_utils.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class MyWorksPage extends StatefulWidget {
  const MyWorksPage({super.key});

  @override
  State<MyWorksPage> createState() => _MyWorksPageState();
}

class _MyWorksPageState extends State<MyWorksPage> {
  late EasyRefreshController _controller = _controller = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  MinePageProvider? provider;
  @override
  void initState() {
    super.initState();
    provider = context.read<MinePageProvider>();
    Future.microtask(() {
      provider?.unselectAllWorks();
    });
    _loadRecords();
  }

  @override
  void dispose() {
    _controller.dispose();
    provider?.resetSelectedWorkBeans();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final worksEditing = context.watch<MinePageProvider>().worksEditing;
    return Scaffold(
      backgroundColor: ByColorUtil.CommonPageBgColor,
      appBar: ByWidgetsUtil.appBar(
        context: context,
        title: "我的创作",
        actions: _buildActions(context),
      ),
      body: Padding(
        padding: EdgeInsets.only(
            top: 8.w,
            left: 12.w,
            right: 12.w,
            bottom: worksEditing ? 0 : context.byBottomSafeHeight),
        child: Column(
          children: [
            _buildTipsbar(),
            SizedBox(height: 10.h),
            _buildWorkList(context),
          ],
        ),
      ),
      bottomNavigationBar: worksEditing
          ? SafeArea(
              top: false,
              child: Material(
                elevation: 8,
                color: ByColorUtil.WhiteColor,
                child: _worksEditBottomBar(context),
              ),
            )
          : null,
    );
  }

  _buildTipsbar() {
    return ByWidgetsUtil.commonTipsBar("文件在云端存储7天,过期无法恢复,请及时保存。");
  }

  _buildWorkList(BuildContext context) {
    final provider = context.watch<MinePageProvider>();
    final List<MyWorkBean> myWorkBeans = provider.myWorkBeans;
    final canSelect = provider.worksEditing;
    return Expanded(
      child: myWorkBeans.isEmpty
          ? _buildNoContents()
          : EasyRefresh(
              onRefresh: () {
                provider.resetPages();
                provider.loadWorkList(status: ["2", "3"].join(","));
              },
              onLoad: () {
                provider.loadWorkList(status: ["2", "3"].join(","));
              },
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10.w,
                  crossAxisSpacing: 10.w,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  return MineWorkCell(
                    myWorkBean: myWorkBeans[index],
                    canSelect: canSelect,
                  );
                },
                itemCount: myWorkBeans.length,
              ),
            ),
    );
  }

  _buildNoContents() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.w),
      child: Container(
        margin: EdgeInsets.only(bottom: ByScreenUtils.bottomSafeHeight + 12.h),
        color: ByColorUtil.WhiteColor,
        alignment: Alignment.center,
        height: 300.h,
        child: NoDataView(
          onTap: () {
            RouteUtils.gotoPage(context, "/home");
          },
        ),
      ),
    );
  }

  void _loadRecords() {
    final provider = context.read<MinePageProvider>();
    provider.resetPages();
    provider.loadWorkList(status: ["2", "3"].join(","));
  }

  _buildActions(BuildContext context) {
    final minePageProvider = context.read<MinePageProvider>();
    final worksEditing =
        context.select<MinePageProvider, bool>((p) => p.worksEditing);
    final selectAll =
        context.select<MinePageProvider, bool>((p) => p.selectAll);
    if (worksEditing) {
      return [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            provider!.updateSelectAllStatus(!selectAll);
            if (selectAll) {
              provider!.unselectAllWorks();
            } else {
              provider!.selectAllWorks();
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                selectAll
                    ? "assets/login/checked.png"
                    : "assets/login/uncheck_all.png",
                width: 15.w,
                height: 15.h,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 6.w),
              ByWidgetsUtil.commonText(
                text: selectAll ? "取消全选" : "全选",
                fontSize: 14.sp,
              ),
              SizedBox(width: 12.w),
            ],
          ),
        )
      ];
    }

    /// 管理按钮
    return [
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          /// 更新编辑状态
          minePageProvider.updateWorksEditingState(true);
        },
        child: Container(
          height: 40.h,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: ByWidgetsUtil.commonText(
            text: "管理",
            fontSize: 14.sp,
          ),
        ),
      )
    ];
  }

  /// 管理态底栏：放入 [Scaffold.bottomNavigationBar]，避免横屏矮区内与列表挤高导致按钮被裁切。
  Widget _worksEditBottomBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
      child: Row(
        children: [
          Expanded(
            child: ByWidgetsUtil.commonBtn(
              title: "取消",
              fontSize: 16.sp,
              borderRadius: 12.w,
              fontWeight: FontWeight.w600,
              bgColor: ByColorUtil.CommonTextColor.withOpacity(0.2),
              textColor: ByColorUtil.WhiteColor,
              onClick: () {
                if (provider?.worksEditing ?? false) {
                  provider?.resetSelectCnfigsWithoutNotify();
                  provider?.unselectAllWorks();
                }
              },
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: ByWidgetsUtil.commonBtn(
              title: "删除",
              fontSize: 16.sp,
              borderRadius: 12.w,
              fontWeight: FontWeight.w600,
              bgColor: const Color(0xFFFF5373),
              textColor: ByColorUtil.WhiteColor,
              onClick: () {
                final ids = provider!.getSelectedWorkIds();
                if (ids.isEmpty) {
                  BotToast.showText(text: "请选择要删除的组品");
                  return;
                }
                showDialog(
                  context: context,
                  builder: (ctx) {
                    return CommonDialog(
                      reverse: false,
                      maxLine: 10,
                      contents: "请确认是否删除，删除后将不可回恢复，请谨慎操作",
                      confirmBtnTitle: "删除",
                      confirmCallback: () {
                        final p = context.read<MinePageProvider>();
                        p.removeRecord(
                          workId: ids,
                          onSuccess: () {
                            p.resetSelectCnfigsWithoutNotify();
                            p.resetPages();
                            p.updateSelectAllStatus(false);
                            p.loadWorkList(status: ["2", "3"].join(","));
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
