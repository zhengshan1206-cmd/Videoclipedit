import 'dart:async';
import 'dart:io';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_video_player.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

///ios 支付工具
class IosBuyEngin {
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  late InAppPurchase _inAppPurchase;
  List<ProductDetails> _products = [];

  ///内购的商品对象集合

  late StreamSubscription _iosBuyStreamSubscription;

  bool buyIosProductSuccess = false;

  //初始化购买组件
  void initializeInAppPurchase() {
    /// 初始化in_app_purchase插件
    _inAppPurchase = InAppPurchase.instance;

    //监听购买的事件
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      error.printError();
      Get.log("===购买失败了");
    });

    _iosBuyStreamSubscription =
        eventBus.on<IosProductBuySuccessEvent>().listen((e) {
      buyIosProductSuccess = true;
    });
  }

  void resumePurchase() {
    _inAppPurchase.restorePurchases();
  }

  /// 加载全部的商品
  Future loadProductDataAndBuy(
    String productId,
    String orderId,
  ) async {
    EasyLoading.show();
    Get.log("===请求商品id $productId");
    List<String> outProducts = [productId];
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      Get.log("===无法连接到商店");
      return;
    }

    ///开始购买
    Get.log("===连接成功-开始查询全部商品");
    List<String> kIds = outProducts;
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(kIds.toSet());
    Get.log("===商品获取结果${response.productDetails}");
    if (response.notFoundIDs.isNotEmpty) {
      Get.log("===无法找到指定的商品");
      return;
    }

    /// 处理查询到的商品列表
    List<ProductDetails> products = response.productDetails;
    Get.log("====products  ${products.length}");
    if (products.isNotEmpty) {
      ///赋值内购商品集合
      _products = products;
    }
    Get.log("===全部商品加载完成了，可以启动购买了,总共商品数量为：${products.first.title}");
    startPurchase(productId, orderId);
  }

  ///调用此函数以启动购买过程
  void startPurchase(
    String productId,
    String orderId,
  ) async {
    Get.log("===购买的商品id为$productId");
    if (_products.isNotEmpty) {
      try {
        ProductDetails productDetails = _getProduct(productId);
        Get.log(
            "===一切正常，开始购买,信息如下：title: ${productDetails.title}  desc:${productDetails.description} "
            "price:${productDetails.price}  currencyCode:${productDetails.currencyCode}  currencySymbol:${productDetails.currencySymbol}");

        await clearPendingPurchases();

        await _inAppPurchase.buyNonConsumable(
            purchaseParam: PurchaseParam(
          productDetails: productDetails,
          // applicationUserName: orderId,
        ));
      } catch (e) {
        e.printError();
        Get.log("===购买失败了");
      }
    } else {
      Get.log("===当前没有商品无法调用购买逻辑");
    }
  }

  ///根据产品ID获取产品信息
  ProductDetails _getProduct(String productId) {
    return _products.firstWhere((product) => product.id == productId);
  }

  /// 内购的购买更新监听
  void _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (PurchaseDetails purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.pending) {
        /// 等待支付完成
        _handlePending();
      } else if (purchase.status == PurchaseStatus.canceled) {
        /// 取消支付
        _handleCancel(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        /// 购买失败
        _handleError(purchase.error);
      } else if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        ///todo 完成购买, 到服务器验证
        if (Platform.isAndroid) {
          // var googleDetail = purchase as GooglePlayPurchaseDetails;
          // checkAndroidPayInfo(googleDetail);
        } else if (Platform.isIOS) {
          var appstoreDetail = purchase as AppStorePurchaseDetails;
          if (purchase.status == PurchaseStatus.purchased) {
            eventBus.fire(QueryIosOrderEvent(
                serverVerificationData:
                    appstoreDetail.verificationData.serverVerificationData));
          }
          EasyLoading.dismiss();
          await checkApplePayInfo(appstoreDetail);
        }
      }
    }
  }

  /// 购买失败
  void _handleError(IAPError? iapError) {
    EasyLoading.dismiss();
    Get.log("===购买失败");
    // ToastUtil.showToast("${DataConfig.getShowName("Purchase_Failed")}：${iapError?.code} message${iapError?.message}");
  }

  /// 等待支付
  void _handlePending() {
    EasyLoading.show();
    Get.log("===等待支付===");
  }

  /// 取消支付
  void _handleCancel(PurchaseDetails purchase) {
    EasyLoading.dismiss();
    Get.log("===取消支付===");
    _inAppPurchase.completePurchase(purchase);
  }

  /// Android支付成功的校验
  // void checkAndroidPayInfo(GooglePlayPurchaseDetails googleDetail) async {
  //   _inAppPurchase.completePurchase(googleDetail);
  //    print("安卓支付交易ID为" + googleDetail.purchaseID);
  //    print("安卓支付验证收据为" + googleDetail.verificationData.serverVerificationData);
  // }

  /// Apple支付成功的校验
  checkApplePayInfo(AppStorePurchaseDetails appstoreDetail) async {
    Get.log(
        "serverVerificationData===> ${appstoreDetail.verificationData.serverVerificationData}"
        "source===>${appstoreDetail.verificationData.source}"
        "localVerificationData====>${appstoreDetail.verificationData.localVerificationData}"
        "");
    SpUtil.putString("ios_last_server_verification",
        appstoreDetail.verificationData.serverVerificationData);
    if (buyIosProductSuccess) {
      await _inAppPurchase.completePurchase(appstoreDetail);
    }
    Get.log("===Apple支付交易ID为${appstoreDetail.purchaseID}");
    Get.log(
        "===Apple支付验证收据为${appstoreDetail.verificationData.serverVerificationData}");
  }

  void onClose() {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
  }

  ///清除其他交易记录
  Future<void> clearPendingPurchases() async {
    try {
      final transactions = await SKPaymentQueueWrapper().transactions();
      for (final transaction in transactions) {
        try {
          await SKPaymentQueueWrapper().finishTransaction(transaction);
        } catch (e) {
          debugPrint("Error clearing pending purchases::in::loop");
          debugPrint(e.toString());
          rethrow;
        }
      }
    } catch (e) {
      debugPrint("Error clearing pending purchases");
      debugPrint(e.toString());
      rethrow;
    }
  }
}

///查询苹果订单状态事件
class QueryIosOrderEvent {
  final String serverVerificationData;
  const QueryIosOrderEvent({required this.serverVerificationData});
}

class IosProductBuySuccessEvent {
  const IosProductBuySuccessEvent();
}

///购买成功事件
class BuySuccessEvent {
  const BuySuccessEvent();
}
