//
//  VideoEditUtil.m
//  Runner
//
//  Created by frcc on 2024/9/12.
//

#import "VideoEditUtil.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface VideoEditUtil ()
@property (strong, nonatomic) AVAssetImageGenerator *imageGenerator;
@end

@implementation VideoEditUtil

+ (instancetype)sharedInstance {
    static VideoEditUtil *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

// 防止通过复制创建单例的副本
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

// 防止通过归档创建单例的副本
- (id)initWithCoder:(NSCoder *)coder {
    return self;
}

- (void)videoEdit {
    NSLog(@"开始视频编辑");
}

- (void)loadVideoSnapshots:(NSString *)videoFilePath completionHandler:(void (^)(NSMutableArray *))completionHandler {
    NSURL *videoURL = [NSURL fileURLWithPath:videoFilePath];
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    _imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    
    _imageGenerator.maximumSize = CGSizeMake(200, 100);  // 设置最大图像尺寸
//    _imageGenerator.appliesPreferredTrackTransform = YES;  // 应用视频的变换
    NSMutableArray *times = [NSMutableArray array];
    for (int i = 0; i < 30; i++) {
        [times addObject:[NSNumber valueWithCMTime:CMTimeMakeWithSeconds(0.05 * i, NSEC_PER_SEC)]];
    }
    
    NSMutableArray *imagesData = [NSMutableArray array];
    
    [_imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        UIImage *img = [[UIImage alloc] initWithCGImage:image];
        NSData *imageData = UIImagePNGRepresentation(img);
        [imagesData addObject:imageData];
        if (imagesData.count == times.count) {
            NSLog(@"imagesData:%@", imagesData);
            completionHandler(imagesData);
        }
    }];
}

@end
