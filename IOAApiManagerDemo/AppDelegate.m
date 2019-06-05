//
//  AppDelegate.m
//  HXNetUtil
//
//  Created by guohx on 2019/1/18.
//  Copyright © 2019年 ghx. All rights reserved.
//

#import "AppDelegate.h"

#import "IOAApiManager/IOAApiManager.h"

#import "TestApi.h"
#import "UploadApi.h"

@interface AppDelegate ()<IOARequestDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    //https 配置，token 验证，需要先保存[saveToken]。
    
    //配置 网络地址
    [IOAApiHelper configNetworkWithBaseUrl:@"xxxxx"];
    

#pragma mark- 三种方式 请求，前两需要继承自IOARequest 最后项 直接 调用
        TestApiRequestEntity * requestEntity = [[TestApiRequestEntity alloc] init];
        requestEntity.appId = @"35C49FCB-F472-4B41-AD73-1EA3F4778380";
        requestEntity.phone = @"xxxxx";
        requestEntity.code = @"00000";

        //测试请求 block
        TestApi * api = [[TestApi alloc] initWithModel:requestEntity respEntityName:@"TestApiRespEntity"];
        [api startWithBlockWithResult:^(IOAResponse *resp) {

            NSLog(@"data %@",resp.responseObject);
            UIAlertView * alertV = [[UIAlertView alloc] initWithTitle:@"提示" message:[resp.responseObject mj_JSONString] delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            [alertV show];
        }];

        /*
         测试请求 delegate ,
         有指定 respMethodStr 回调为 respMethodStr
         未指定默认为ioaResult
         */
        TestApi * apiDelegate = [[TestApi alloc] initWithModel:nil respEntityName:@"TestApiRespEntity"];
        [apiDelegate startWithCompletionWithDelegate:self respMethodStr:@"getTestApi:"];
//         [api startWithCompletionWithDelegate:self respMethodStr:nil];


        //block快捷方式
        IOARequest * apiBlock = [IOARequest new];
        apiBlock.needShowHud = @0; //是否显示hud
        apiBlock.needAuthor = @0; //是否 需要验签
        [apiBlock startInBlockWithType:YTKRequestMethodPOST model:requestEntity  uri:@"ecloud/api/v1/app_login/code" respEntityName:@"TestApiRespEntity" result:^(IOAResponse *resp) {

            NSLog(@"data %@",resp.responseObject);
        }];

        //资源上传
        UploadApi * uploadApi = [[UploadApi alloc] initWithModel:nil respEntityName:nil];
        [uploadApi uploadImageDic:@{@"11":[UIImage imageNamed:@"666.jpg"]}];

        [uploadApi startWithBlockWithResult:^(IOAResponse *resp) {

            NSLog(@"");
        }];
    
    return YES;
}

//未指定 默认回调方法
- (void)ioaResult:(IOAResponse *)result {
    
    NSLog(@"data");

}

//指定 回调方法
- (void)getTestApi:(IOAResponse *)result {
    
    NSLog(@"data");
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
