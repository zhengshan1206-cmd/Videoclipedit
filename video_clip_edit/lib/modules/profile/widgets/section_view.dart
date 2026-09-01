import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/common/widget/common_dialog.dart';
import 'package:video_clip_edit/modules/home/beans/setting_item_bean.dart';
import 'package:video_clip_edit/modules/main/controllers/main_controller.dart';
import 'package:video_clip_edit/modules/profile/personal_settings_page.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/providers/settings_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';

class SectionView extends StatelessWidget {
  final List<SettingItemBean> beans;
  const SectionView({
    super.key,
    required this.beans,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ByColorUtil.WhiteColor,
        borderRadius: BorderRadius.circular(12.w),
      ),
      margin: EdgeInsets.only(bottom: 12.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: beans
            .map(
              (e) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SectionCell(
                    itemBean: e,
                    onSelectedCallback: (bean) {
                      _handleSelect(bean, context);
                    },
                  ),
                  if (beans.indexOf(e) < beans.length - 1)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15.w),
                      width: double.infinity,
                      height: 0.5,
                      color: ByColorUtil.BlackColor.withOpacity(0.05),
                    )
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  _handleSelect(SettingItemBean itemBean, BuildContext context) {
    switch (itemBean.title) {
      case "个人信息设置":
        ByNavRouterUtils.push(
            context,
            PersonalSettingsPage(
              provider: Provider.of<SettingsProvider>(context, listen: false),
            ));
        break;
      case "注销账号":
        showDialog(
          context: context,
          builder: (c) {
            return CommonDialog(
              title: "注销须知",
              contents:
                  "1、账户一旦注销，该账户下的信息、数据、记录将全部删除，且无法恢复。\n2、注销后，账户下的全部权益均被清除:且无法恢复。\n3、注销后，该账户绑定的第三方账户将被解除绑定，您可重新使用并注册成为新用户。\n4、提交注销后将在三个工作日内完成数据清除",
              cancelBtnTitle: "继续注销",
              textAlign: TextAlign.start,
              confirmBtnTitle: "继续使用",
              maxLine: 100,
              reverse: true,
              confirmCallback: () {},
              cancelCallback: () {
                HttpUtils.post(
                  APIs.accountCancellations,
                  {},
                  showLoading: true,
                  success: (data) {
                    BotToast.showText(text: "注销成功");
                    context.read<LaunchProvider>().launch(
                      context,
                      onSuccess: (p0) {
                        ByNavRouterUtils.goBack(context);
                        Get.find<MainController>().tabChanged(0);
                      },
                    );
                  },
                  fail: (code, msg) {
                    BotToast.showText(text: msg);
                  },
                );
              },
            );
          },
        );
        break;
      default:
        if (itemBean.canCopy ?? false) {
          Clipboard.setData(ClipboardData(text: itemBean.desc ?? "")).then((_) {
            BotToast.showText(text: "复制成功");
          });
          return;
        }

        final url = itemBean.url;
        if (url.isEmpty) return;
        ByNavRouterUtils.jumpWebViewPage(context, itemBean.title, url);
        break;
    }
  }
}

class SectionCell extends StatelessWidget {
  final SettingItemBean itemBean;
  final void Function(SettingItemBean) onSelectedCallback;
  const SectionCell({
    super.key,
    required this.itemBean,
    required this.onSelectedCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 19),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          onSelectedCallback(itemBean);
        },
        child: Row(
          children: [
            ByWidgetsUtil.commonText(
              text: itemBean.title,
              textColor: ByColorUtil.CommonTextColor,
              fontSize: 14,
            ),
            const Spacer(),
            if (itemBean.desc != null)
              ByWidgetsUtil.commonText(
                text: itemBean.desc!,
                textColor: ByColorUtil.MainTextColor.withOpacity(0.6),
                fontSize: 14,
              ),
            if (itemBean.isAvatar ?? false)
              itemBean.imgUrl == null || itemBean.imgUrl!.isEmpty
                  ? Image.asset(
                      "assets/mine/mine_avarta.png",
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    )
                  : CachedNetworkImage(
                      imageUrl: itemBean.imgUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
            if (itemBean.canCopy ?? false) SizedBox(width: 4.w),
            if (itemBean.canCopy ?? false)
              Image.asset(
                "assets/mine/icon_copy.png",
                width: 15.w,
                height: 15.h,
                fit: BoxFit.contain,
              ),
            if (itemBean.interactive) SizedBox(width: 8.w),
            if (itemBean.interactive)
              Image.asset(
                "assets/mine/arrow_right.png",
                width: 7,
                height: 13,
              ),
          ],
        ),
      ),
    );
  }
}
