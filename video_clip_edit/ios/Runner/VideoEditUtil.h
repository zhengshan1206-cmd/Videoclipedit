//
//  VideoEditUtil.h
//  Runner
//
//  Created by frcc on 2024/9/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoEditUtil : NSObject
/**
 获取单例对象
 */
+ (instancetype)sharedInstance;
/**
 视频编辑
 */
- (void)videoEdit;
/**
 获取视频截图
 */
- (void)loadVideoSnapshots:(NSString *)videoFilePath  completionHandler:(void (^)(NSMutableArray *))completionHandler;
@end

NS_ASSUME_NONNULL_END
