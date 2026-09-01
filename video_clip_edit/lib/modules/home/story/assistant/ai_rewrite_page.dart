import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/home/providers/stroy_create_provider.dart';
import 'package:video_clip_edit/modules/home/story/assistant/ai_rewrite_details_page.dart';
import 'package:video_clip_edit/modules/home/story/assistant/beans/assistant_page_info_bean.dart';
import 'package:video_clip_edit/modules/home/story/assistant/beans/creator_bean.dart';
import 'package:video_clip_edit/modules/home/story/assistant/widgets/assistant_info_widget.dart';
import 'package:video_clip_edit/modules/purchase/widgets/dailog_bonus_lowest_price.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_settings_mixin.dart';

class AiRewritePage<T extends AiSettingsMixin> extends StatefulWidget {
  const AiRewritePage({
    super.key,
    required this.bean,
    required this.contents,
  });

  final CreatorBean bean;
  final String contents;

  @override
  State<AiRewritePage> createState() => _AiRewritePageState<T>();
}

class _AiRewritePageState<T extends AiSettingsMixin>
    extends State<AiRewritePage<T>> {
  @override
  void initState() {
    super.initState();

    _resetValues();

    /// 加载页面配置
    _loadPageConifg();
  }

  @override
  Widget build(BuildContext context) {
    final pageInfoBean =
        context.select<StroyCreateProvider, AssitantPageInfoBean?>(
            (p) => p.pageInfoBean);
    final title = widget.bean.title;

    return Scaffold(
      appBar: ByWidgetsUtil.appBar(
        context: context,
        showBottmLine: true,
        title: title.isEmpty ? (pageInfoBean?.templateName ?? "") : title,
      ),
      backgroundColor: ByColorUtil.WhiteColor,
      body: pageInfoBean == null
          ? Center(
              child: CupertinoActivityIndicator(
                color: ByColorUtil.CommonTextColor,
                radius: 12.w,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 15.h,
                    bottom: 10.h,
                    left: 12.w,
                    right: 12.w,
                  ),
                  child: ByWidgetsUtil.commonText(
                    text: "主要内容：",
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(
                  height: 300.h,
                  child: ByWidgetsUtil.commonContainer(
                    borerRadius: 12.w,
                    bgColor: const Color(0xFFF5F8F9),
                    margin: EdgeInsets.symmetric(horizontal: 12.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        ByWidgetsUtil.commonText(
                          text: widget.contents,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.normal,
                          textColor: ByColorUtil.CommonTextColor,
                          maxLines: 1000000,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 20.h,
                    bottom: 5.h,
                    left: 12.w,
                    right: 12.w,
                  ),
                  child: ByWidgetsUtil.commonText(
                    text: "风格：",
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
                _buildStyels(context, pageInfoBean),
                const Spacer(),
                ByWidgetsUtil.physicalModel(
                  color: ByColorUtil.WhiteColor,
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 12.w,
                      right: 12.w,
                      top: 8.h,
                      bottom: 8.h + context.byBottomSafeHeight,
                    ),
                    height: 66.h + context.byBottomSafeHeight,
                    child: ByWidgetsUtil.commonBtn(
                      title: "立即创作",
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      borderRadius: 12.w,
                      onClick: () {
                        final provider = context.read<StroyCreateProvider>();

                        String? canContinue = provider.pageInfoBean?.validate();
                        if (canContinue != null) {
                          BotToast.showText(text: canContinue);
                          return;
                        }
                        provider.creatorMessage(
                          creatorID: widget.bean.id,
                          values: pageInfoBean.editInfo(),
                          onSuccess: (infoBean) {
                            bool needMoney = infoBean.isMoney == 1;
                            if (needMoney) {
                              context.read<PurchaseProvider>().loadVIPItems(
                                onSuccess: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const DailogBonusLowestPrice();
                                    },
                                  );
                                },
                              );

                              return;
                            }
                            provider.pid = infoBean.token;
                            provider.questionInfoBean = infoBean;
                            // final providerS =
                            //     context.read<StroyCreateProvider>();
                            ByNavRouterUtils.push(
                              context,
                              MultiProvider(
                                providers: [
                                  ChangeNotifierProvider.value(value: provider),
                                  ChangeNotifierProvider.value(
                                      value: context.read<T>()),
                                ],
                                child: AiRewriteDetailsPage<T>(
                                  showBottomFunctions: false,
                                  isCreator: false,
                                  fromAi: true,
                                  provider: provider,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Container _buildStyels(
      BuildContext context, AssitantPageInfoBean pageInfoBean) {
    if (pageInfoBean.items.length < 2) return Container();

    final styleItem = pageInfoBean.items[1];
    final styles = styleItem.items ?? [];
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      width: double.infinity,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
            childAspectRatio: 20 / 9.0),
        itemCount: styles.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          return MenuCountCell(
            item: styleItem,
            index: index,
          );
        },
      ),
    );
  }

  void _loadPageConifg({
    void Function(AssitantPageInfoBean)? onSuccess,
  }) {
    final provider = context.read<StroyCreateProvider>();
    provider.loadPageConfig(
      creatorID: widget.bean.id,
      onSuccess: (bean) {
        if (bean.items.isNotEmpty) {
          final first = bean.items.first;
          final itemMaxSize = first.itemMaxSize ?? 0;
          final value =
              (itemMaxSize > 0 && widget.contents.length > itemMaxSize)
                  ? widget.contents.substring(0, itemMaxSize)
                  : widget.contents;
          first.value = value;
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            provider.updateAssitantPageInfoBean(bean);
          });
        }
      },
    );
  }

  void _resetValues() {
    /// 重置默认值
    context.read<StroyCreateProvider>().pageInfoBean = null;
  }
}
