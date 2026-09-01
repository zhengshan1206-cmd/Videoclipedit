import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';

class PurchaseSuccessDialog extends StatefulWidget {
  const PurchaseSuccessDialog({
    super.key,
    this.contents,
    this.btnTtle,
    this.webUrl,
  });

  final String? contents;
  final String? btnTtle;
  final String? webUrl;

  @override
  State<PurchaseSuccessDialog> createState() => _PurchaseSuccessDialogState();
}

class _PurchaseSuccessDialogState extends State<PurchaseSuccessDialog> {
  bool showCloseBtn = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        showCloseBtn = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(horizontal: 27.5),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showCloseBtn)
            GestureDetector(
              onTap: () {
                // ByNavRouterUtils.goBack(context);
                Navigator.of(context).pop(false);
              },
              child: Image.asset(
                "assets/purchase/dailog_bonus_close.png",
                width: 32,
                height: 32,
              ),
            ),
          if (!showCloseBtn)
            const SizedBox(
              width: 32,
              height: 32,
            ),
          Container(
            height: 307,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/purchase/purchase_success_bg.png"),
                fit: BoxFit.contain,
              ),
            ),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 31),
                  child: Text(
                    widget.contents ?? "您已成为尊贵的会员用户，畅享会员权益。",
                    style: TextStyle(
                      color: const Color(0xff4A1F00),
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => gotoWx(context),
                  child: Container(
                    height: 54.h,
                    width: 180.w,
                    margin: const EdgeInsets.only(bottom: 40),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(27),
                      color: const Color(0xffFF8902),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.btnTtle ?? "我知道了",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void gotoWx(BuildContext context) async {
    Navigator.of(context).pop(true);
    await openExternalUrl(context);
  }

  openExternalUrl(BuildContext context) async {
    String url = widget.webUrl ??
        (context.read<PurchaseProvider>().vipPageBean?.kfUrl ?? "");
    if (url.isEmpty) return;
    await launchUrl(Uri.parse(url));
    // if (await canLaunchUrl(Uri.parse(url))) {
    //   await launchUrl(Uri.parse(url));
    // } else {
    //   // BotToast.showText(text: "使用浏览器打开链接失败");
    //   throw 'Could not launch :$url';
    // }
  }
}
