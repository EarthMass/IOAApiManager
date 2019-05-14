# 网络请求框架 YTKNetwork 二次封装
## 注意点 使用时 最好是 继承 IOARequest 再做操作


## 优点

* [x]包含三种请求写法
* [x]支持资源上传
* [x]可统一处理 错误操作
* [x]对不同的返回值定制处理
* [x]使用简单，定制性强


## 使用引入
### pod内容
```
pod 'MJExtension' ##数据解析
pod 'YTKNetwork','2.0.4'  ##网络
pod 'HXProgressHUD' ##提示
```
### 封装的代码
直接拷贝工程中的IOAApiManager 文件夹到工程中

## 使用方法，详情见 Demo

## 功能内容介绍
### 支持三种不同的写法， block delegate block快捷写法
```objc
 #import "IOAApiManager/IOAApiManager.h"

#import "TestApi.h"
#import "UploadApi.h"

@interface AppDelegate ()<IOARequestDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    //https 配置，token 验证，需要先保存[saveToken]。
    
    //配置 网络地址
    [IOAApiManager configNetworkWithBaseUrl:@"xxxxx"];
    
    //开启 网络监控， 有监控时间 请求 需要 隔一小段时间才能正常
    [IOAApiManager startNetworkMonitoring:^{
    
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
        [[IOARequest alloc] initAndStartWithType:YTKRequestMethodPOST model:requestEntity  uri:@"ecloud/api/v1/app_login/code" respEntityName:@"TestApiRespEntity" result:^(IOAResponse *resp) {

            NSLog(@"data %@",resp.responseObject);
        }];
        
        
        //资源上传
        UploadApi * uploadApi = [[UploadApi alloc] initWithModel:nil respEntityName:nil];
        [uploadApi uploadImageDic:@{@"image":[UIImage imageNamed:@"666.jpg"]}];

        [uploadApi startWithBlockWithResult:^(IOAResponse *resp) {

            NSLog(@"");

        }];

        
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
```



