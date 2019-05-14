//
//  IOARequest.h
//  IOAMall
//
//  Created by Mac on 2018/1/31.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import <YTKNetwork/YTKNetwork.h>
#import "IOAApiManager.h"
#import "IOAResponse.h"

//pod 'MJExtension' ##数据解析
//pod 'YTKNetwork'  ##网络
//pod 'HXProgressHUD'
#import <HXProgressHUD/HXProgress.h>
#import <MJExtension/MJExtension.h>

#ifdef DEBUG
#define IOALog(...) NSLog(__VA_ARGS__)
#else
#define IOALog(...)
#endif

@class IOARequest;
@class IOAResultKeyModel;
typedef void(^IOAResponseResultBlock)(IOAResponse * resp);
//typedef void(^IOAUploadProgressBlock)(IOARequest *currentApi, NSProgress * progress);


typedef NS_ENUM(NSInteger, ResponseStatusType) {
    kResponseStatusTypeRequestError = 0, // 服务后台问题
    kResponseStatusTypeNoNetwork = 1, // 没有网络
    kResponseStatusTypeSuccess = 200,
    kResponseStatusTypeNoNeedRefresh = 304, //不需要刷新
    kResponseStatusTypeExpiryToken = 401, //token失败 多端登录
    kResponseStatusTypeTimeout = 408, //请求超时
    kResponseStatusTypeServerServiceError = 500,
    //    kResponseStatustypeServiceExist = 501,
    kResponseStatusTypeDataNull = 502,
    kResponseStatusTypeNotLogin = 600,
};
#pragma mark-

@protocol IOARequestDelegate <NSObject>

- (void)ioaResult:(IOAResponse *)result;
@end

@interface IOARequest : YTKRequest


//请求服务端返回的code
@property (nonatomic, readonly, assign) NSInteger serverResponseStatusCode;
//返回请求状态码 请求返回的status code
@property (nonatomic, readonly, assign) NSInteger requestResponseStatusCode;

@property (nonatomic, assign) ResponseStatusType responseStatusType;
// 返回的提示信息
@property (nonatomic, readonly, copy) NSString *serverResponseMessage;

@property (nonatomic, assign) BOOL success;

/**
 回调实体类名称，根据返回的数据格式定制 model
 */
@property (nonatomic,readonly, copy) NSString * respEntityName;

#pragma mark- 定制提示框 提示统一处理[便于快速切换提示库] 一般不需要重写
+ (void)showToast:(NSString *)msg;
+ (void)hideToast;
+ (void)showLoading:(NSString *)msg;
+ (void)hideLoading;
#pragma mark-

#pragma mark- 定制错误码[便于快速定制 错误 以及 验证条件] 一般不需要重写
+ (NSString *)responseMsgWithStatus:(ResponseStatusType)respStatusType;
//状态码是以 请求返回的code值来判断，还是通过 回传的参数某个值来判断 ---->>response code judge<<-----
- (NSArray <IOAResultKeyModel *> *)responseSuccessKeyAndErrorKeys;
//对请求的结果进行校验,以及处理赋值 responseStatusType serverResponseMessage
- (BOOL)statusCodeValidator;
#pragma mark-


#pragma mark- ******需要定义独立Api类 方式【YTKNetwork原版使用，一个接口一个类】*********
#pragma mark 参数设置
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;


/**
 初始化 请求参数 模型，以及 取到的数据模型

 @param model 模型
 @param respEntityName 数据模型
 @return 实例
 */
- (instancetype)initWithModel:(id)model respEntityName:(NSString *)respEntityName;
/**
 初始化 请求参数【字典】，以及 取到的数据模型
 
 @param dic 字典参数
 @param respEntityName 数据模型
 @return 实例
 */
- (instancetype)initWithDictionary:(NSDictionary*)dic respEntityName:(NSString *)respEntityName;


//屏蔽原本的请求
- (void)startWithCompletionBlockWithSuccess:(YTKRequestCompletionBlock)success
                                    failure:(YTKRequestCompletionBlock)failure NS_UNAVAILABLE;

#pragma mark Block 方式

// 如果没有网络 failure同步方式返回
- (void)startWithBlockWithResult:(IOAResponseResultBlock)resultBlock;

#pragma mark delegate 方式

/**
 协议调用
 指定 respMethodStr 回调方法， 指定方法， 否则默认
 @param delegate 协议

 @param respMethodStr 回调方法名 如果为nil, 采用默认的方法 ioaResult， 不为空 无效 断言提示
 */
- (void)startWithCompletionWithDelegate:(id<IOARequestDelegate>)delegate respMethodStr:(NSString *)respMethodStr;


#pragma mark- ******独立使用 block直接实例化 方式*********

/*
【Block不需要 重写子类，不依赖 ItemApi, 要注意 继承IOARequest的类，这两个方法，最好不写】
 这个两个属性是用于 快捷初始化使用的，
    比如子类  重写requestWithLoadingView 方法，子类优先级更高, needShowHud 属性无效
    比如子类  重写needAuthorization 方法，子类优先级更高, needAuthor 属性无效

 */

/**
 请求是否显示加载 便于block快捷设置
 */
@property (nonatomic, assign) NSNumber * needShowHud;
/**
 请求是否需要 验签 便于block快捷设置
 */
@property (nonatomic, assign) NSNumber * needAuthor;

- (void)startInBlockWithType:(YTKRequestMethod)type params:(NSDictionary *)dic
                         uri:(NSString *)uri
       respEntityName:(NSString *)respEntityName
               result:(IOAResponseResultBlock)resultBlock;

- (void)startInBlockWithType:(YTKRequestMethod)type model:(id)model
                         uri:(NSString *)uri
       respEntityName:(NSString *)respEntityName
               result:(IOAResponseResultBlock)resultBlock;


#pragma mark- 资源上传 可与 上面几种方式混合使用
- (void)uploadImageDic:(NSDictionary <NSString* , UIImage *>* )imgDict;
- (void)uploadImageDataDic:(NSDictionary <NSString* , NSData *>* )imgDataDict;
- (void)uploadDataDic:(NSDictionary <NSString* , NSData *>*)dataDic;


- (BOOL)needAuthorization;

@end








