# HXNetUtil
Easy to use network operate,网络请求框架对 YTKNetwork二次封装，使用方式多样，简单。

# 特点
* 使用  特点 
* 四种使用  直接调用，block, delegate，以及YTKNetwork单接口一个一个写
* 统一管理错误提示，以及alert弹出框
* 可配置单接口是否显示提示alert
* 可配置 单个接口 是否 token
* 接收的数据直接转成模型model
* 参数支持 dic, 以及 model传值
* 支持图片以及文件的上传处理
* 提示alert 可自己配置配置 使用不同的库
* 使用时 针对不同的 url, 继承一个IOARequest类出来处理

#使用[详情看demo]
```
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

```


