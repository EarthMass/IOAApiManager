//
//  IOANetworkManager.m
//  IOAMall
//
//  Created by Mac on 2018/1/31.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import "IOANetworkManager.h"
#import "IOARequest.h"

@implementation IOANetworkManager

+ (void)load {
    /**
     * 注册通知
     */
    __block id observer =
    [[NSNotificationCenter defaultCenter]
     addObserverForName:UIApplicationDidFinishLaunchingNotification
     object:nil
     queue:nil
     usingBlock:^(NSNotification *note) {
         /**
          初始化操作
          */
         //开启 网络监控， 有监控时间 请求 需要 隔一小段时间才能正常
         [IOAApiHelper startNetworkMonitoring:^{
             //完成相关操作，注销通知
             [[NSNotificationCenter defaultCenter] removeObserver:observer];
         }];

     }];
}

+ (void)startNetworkMonitoring {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

+ (void)stopNetworkMonitoring {
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

+ (BOOL)isReachable {
    return [AFNetworkReachabilityManager sharedManager].isReachable;
}
+ (AFNetworkReachabilityStatus)getNetworkStatus {
    return [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
}
+ (void)checkNet:(void(^)(BOOL isReachable))block {
    if ([self isReachable]) {
        block(YES);
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [IOARequest showToast:@"网络连接失败,请检查网络"];
        });

    }
}

@end
