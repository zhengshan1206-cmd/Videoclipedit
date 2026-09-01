
#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import "VideoEditUtil.h"
#import <Flutter/FlutterViewController.h>
#import "UmengPushSdkPlugin.h"
#import <UserNotifications/UNNotification.h>
#import "UMCommon/UMCommon.h"
#import "UmengCommonSdkPlugin.h"
#import <UMPush/UMessage.h>
#import <UserNotifications/UNNotificationTrigger.h>
#import <UserNotifications/UNNotificationContent.h>
#import <UserNotifications/UNNotificationRequest.h>

//const NSString *channelIdentifier = @"com.by.ve.bridge";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"com.by.ve.bridge"
                                     binaryMessenger:controller.binaryMessenger];
    
    [channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        if ([@"videoEdit" isEqualToString:call.method]) {
            [[VideoEditUtil sharedInstance] videoEdit];
        } else if ([@"videoScreenshots" isEqualToString:call.method]) {
            [[VideoEditUtil sharedInstance] loadVideoSnapshots:call.arguments[@"videoFilePath"] completionHandler:^(NSMutableArray * _Nonnull imagesData) {
                NSMutableArray *res = [NSMutableArray array];
                for (NSData *image in imagesData) {
                    [res addObject:[FlutterStandardTypedData typedDataWithBytes:image]];
                }
                result(res);
            }];
        } else if ([@"exitApp" isEqualToString:call.method]) {
            exit(0);
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
    [UNUserNotificationCenter currentNotificationCenter].delegate=self;
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {

    NSDictionary * userInfo = notification.request.content.userInfo;
    
    NSLog(@"前台推送：收到推送消息");

    [UmengPushSdkPlugin didReceiveUMessage:userInfo];
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [UMessage setAutoAlert:NO];
        //应用处于前台时的远程推送接收
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
    } else {
        //应用处于前台时的本地推送接收
    }

    // 控制推送消息是否直接在前台显示
   completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    NSDictionary * userInfo = response.notification.request.content.userInfo;
        //应用后台或者关闭时收到消息，回调flutter层onNotificationOpen方法
    
    NSLog(@"后台推送：收到推送消息");
    [UmengPushSdkPlugin didOpenUMessage:userInfo];

    if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于后台时的远程推送接收
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
    } else {
        //应用处于后台时的本地推送接收
    }
}

@end
