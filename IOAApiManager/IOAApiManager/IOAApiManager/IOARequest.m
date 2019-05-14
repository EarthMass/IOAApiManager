//
//  IOARequest.m
//  IOAMall
//
//  Created by Mac on 2018/1/31.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import "IOARequest.h"
#import "YTKNetworkConfig.h"



/**
 自定义 返回模型 特殊处理
 */
@interface IOAResultKeyModel : NSObject

@property (nonatomic, copy) NSString * successKey;
@property (nonatomic, copy) NSString * successValue; //成功的字符串 无就是bool
@property (nonatomic, copy) NSString * errorCodeKey;
@property (nonatomic, copy) NSString * errorMsgKey;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithSuccessKey:(NSString *)successKey
                      successValue:(NSString *)successValue
                        errorCodeKey:(NSString *)errorCodeKey
                        errorMsgKey:(NSString *)errorMsgKey;

@end

@implementation IOAResultKeyModel

- (instancetype)initWithSuccessKey:(NSString *)successKey
                      successValue:(NSString *)successValue
                      errorCodeKey:(NSString *)errorCodeKey
                       errorMsgKey:(NSString *)errorMsgKey {
    if (self = [super init]) {
        self.successKey = successKey;
        self.successValue = successValue;
        self.errorCodeKey = errorCodeKey;
        self.errorMsgKey = errorMsgKey;
    }
    return self;
}

@end


@interface IOARequest ()

@property (nonatomic, readwrite, assign) NSInteger serverResponseStatusCode;
@property (nonatomic, readwrite, assign) NSInteger requestResponseStatusCode;

@property (nonatomic, readwrite, copy) NSString *serverResponseMessage;
@property (nonatomic,strong) id requestModel;
@property (nonatomic,strong) NSDictionary *requestDic;

/**
 回调实体类名称，根据返回的数据格式定制 model
 */
@property (nonatomic, copy) NSString * respEntityName;

#pragma mark- CusDelegate Params
@property (nonatomic, weak, nullable) id<IOARequestDelegate> ioaDelegate;
@property (nonatomic, copy) NSString * respMethodStr;


#pragma mark- Block Params
@property (nonatomic, assign) YTKRequestMethod requestType;
@property (nonatomic, copy)  NSString * uri;
@property (nonatomic, assign) BOOL isBlockInit;

#pragma mark- 资源上传
//保存图片上传数据
//Key 图片上传的Key
//Value 图片对象（原始数据）
@property(nonatomic, strong) NSDictionary <NSString* , id>* imgDict;
//文件
@property(nonatomic, strong) NSDictionary <NSString* , NSData *>* dataDict;


@end

@implementation IOARequest

#pragma mark- 定制提示框 提示统一处理[便于快速切换库]
+ (void)showToast:(NSString *)msg {

    [HXProgress showToastWithMsg:msg];
}
+ (void)hideToast {

    [HXProgress dismissHUD];
}
+ (void)showLoading:(NSString *)msg {
    [HXProgress showWithStatus:@"加载中..."];
}
+ (void)hideLoading {

    [HXProgress dismissHUD];
}
#pragma mark-

- (void)dealloc {
    
}

- (YTKRequestSerializerType)requestSerializerType{
    return YTKRequestSerializerTypeJSON;
}

- (NSTimeInterval)requestTimeoutInterval {
    return 15.0;
}
- (YTKRequestMethod)requestMethod {
    
    if (self.isBlockInit) {
        return self.requestType;
    }
    
    return YTKRequestMethodPOST;
}

- (id)requestArgument {
    if (_requestModel) {
        return [self.requestModel mj_JSONObject];
        
    } else if (_requestDic) {
        return _requestDic;
    }
    return @{};
}

- (NSString *)requestUrl {
    if (self.isBlockInit) {
        NSAssert(self.uri.length, @"requestUrl 不能为空");
        return self.uri;
    }
    return nil;
}

#pragma mark-

- (instancetype)initWithModel:(id)model respEntityName:(NSString *)respEntityName {
    self = [super init];
    
    if (self) {
        self.requestModel = model;
        self.respEntityName = respEntityName;
    }
    return self;
}
- (instancetype)initWithDictionary:(NSDictionary*)dic respEntityName:(NSString *)respEntityName {
    
    self = [super init];
    
    if (self) {
        self.requestDic = dic;
        self.respEntityName = respEntityName;
    }
    return self;
}


#pragma mark- 数据回调
#pragma mark- Delegate 方式
- (void)startWithCompletionWithDelegate:(id<IOARequestDelegate>)delegate respMethodStr:(NSString *)respMethodStr {
    
    _ioaDelegate = delegate;
    self.respMethodStr = respMethodStr;

    __weak typeof(self) weakSelf = self;
    //请求 成功失败 回调
    if ([self requestWithLoadingView]) {
        [IOARequest showLoading:@"加载中..."];
    }

    if (![IOAApiManager isNetworkReachable] && [IOAApiManager getNetworkStatus] != AFNetworkReachabilityStatusUnknown) {
        self.responseStatusType = kResponseStatusTypeNoNetwork;
        self.serverResponseStatusCode = kResponseStatusTypeNoNetwork; // 没网络
        self.serverResponseMessage = [self.class responseMsgWithStatus:self.responseStatusType];

        [IOARequest hideLoading];
        [self delegateReturnWithRequest:self];
        
        return;
    }


    [self setCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {

         [IOARequest hideLoading];
        __block typeof(self) blockSelf = weakSelf;
         [blockSelf delegateReturnWithRequest:request];

    }  failure:^(__kindof YTKBaseRequest * _Nonnull request) {
         [IOARequest hideLoading];
        
        __block typeof(self) blockSelf = weakSelf;
        [blockSelf delegateReturnWithRequest:request];
    }];
    [self start];
}

- (void)delegateReturnWithRequest:(YTKBaseRequest *)request {
    
    if (self.ioaDelegate) {
        
        IOAResponse * response = [IOAResponse responseWithRequest:(IOARequest *)request];
        if (self.respMethodStr.length) {
            
            NSAssert([self.ioaDelegate respondsToSelector:NSSelectorFromString(self.respMethodStr)], @"无效的回调方法--%@",self.respMethodStr);
            
            if ([self.ioaDelegate respondsToSelector:NSSelectorFromString(self.respMethodStr)]) {
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

                 [self.ioaDelegate performSelector:NSSelectorFromString(self.respMethodStr) withObject:response];
                
#pragma clang diagnostic pop
            }
           
            
        } else {
            
        
             NSAssert([self.ioaDelegate respondsToSelector:@selector(ioaResult:)], @"未指定特定的回调方法，也未实现默认 --ioaResult--方法");
            
            if ([self.ioaDelegate respondsToSelector:@selector(ioaResult:)]) {
                [self.ioaDelegate ioaResult:response];
            }
            
        }
        
        if (!response.success) {
            [self failureOpWithResp:response];
        }
    }
    
}

#pragma mark- block 方式
- (void)startWithBlockWithResult:(IOAResponseResultBlock)resultBlock {

    
    //请求 成功失败 回调
    if ([self requestWithLoadingView]) {
        [IOARequest showLoading:@"加载中..."];
    }
    
    if (![IOAApiManager isNetworkReachable] && [IOAApiManager getNetworkStatus] != AFNetworkReachabilityStatusUnknown) {
        self.responseStatusType = kResponseStatusTypeNoNetwork; // 没网络
        self.serverResponseStatusCode = kResponseStatusTypeNoNetwork;
        self.serverResponseMessage = [self.class responseMsgWithStatus:self.responseStatusType];
        if (resultBlock) {
            [IOARequest hideLoading];
            [self failure:resultBlock];
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self setCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        
        [IOARequest hideLoading];
        __block typeof(self) blockSelf = weakSelf;
        [blockSelf success:resultBlock request:request];
        
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        
        [IOARequest hideLoading];
        if (resultBlock) {
            
            __block typeof(self) blockSelf = weakSelf;
            [blockSelf failure:resultBlock];

        }
    }];
    [self start];
}

#pragma mark- block直接实例化 方式
- (void)startInBlockWithType:(YTKRequestMethod)type params:(NSDictionary *)dic
                         uri:(NSString *)uri
       respEntityName:(NSString *)respEntityName
               result:(IOAResponseResultBlock)resultBlock {
    
    [self startWithType:type model:nil params:dic uri:uri respEntityName:respEntityName result:resultBlock];
    
}

- (void)startInBlockWithType:(YTKRequestMethod)type model:(id)model
                         uri:(NSString *)uri
       respEntityName:(NSString *)respEntityName
               result:(IOAResponseResultBlock)resultBlock {
    
     [self startWithType:type model:model params:nil uri:uri respEntityName:respEntityName result:resultBlock];
    
}

- (void)startWithType:(YTKRequestMethod)type model:(id)model
               params:(NSDictionary *)dic
                  uri:(NSString *)uri
               respEntityName:(NSString *)respEntityName
                       result:(IOAResponseResultBlock)resultBlock {
    
    self.isBlockInit = YES;
    self.requestType = type;
    self.requestDic = dic;
    self.requestModel = model;
    self.respEntityName = respEntityName;
    self.uri = uri;
    
    //请求 成功失败 回调
    if ([self requestWithLoadingView]) {
        [IOARequest showLoading:@"加载中..."];
    }
    
    if (![IOAApiManager isNetworkReachable] && [IOAApiManager getNetworkStatus] != AFNetworkReachabilityStatusUnknown) {
        
        self.responseStatusType = kResponseStatusTypeNoNetwork; // 没网络
        self.serverResponseStatusCode = kResponseStatusTypeNoNetwork;
        self.serverResponseMessage = [self.class responseMsgWithStatus:self.responseStatusType];
        if (resultBlock) {
            [IOARequest hideLoading];
            [self failure:resultBlock];
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self setCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        
        [IOARequest hideLoading];
        __block typeof(self) blockSelf = weakSelf;
        [blockSelf success:resultBlock request:request];
        
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        
        [IOARequest hideLoading];
        if (resultBlock) {
            
            __block typeof(self) blockSelf = weakSelf;
            [blockSelf failure:resultBlock];
            
        }
    }];
    [self start];
}

#pragma mark- 成功 失败处理，【code的特定 统一处理，提示等】
- (void)success:(IOAResponseResultBlock)successBlock request:(YTKBaseRequest *)request {
    
    [IOARequest hideLoading];
    
    IOAResponse * response = [IOAResponse responseWithRequest:(IOARequest *)self];
    if (response.success) {

        if (successBlock) {
            IOALog(@"%@", response.responseOriginObject);
            successBlock(response);
        }
        return;
    }

    response.success = NO;

    IOALog(@"%@", response.responseOriginObject);
    //统一处理 错误 toast
    if (response.responseMessage.length) {
        [IOARequest showToast:response.responseMessage];
    }
    

    if (successBlock) {
        successBlock(response);
    }
}

- (void)failure:(IOAResponseResultBlock)failureBlock {
    
    IOAResponse * response = [IOAResponse responseWithRequest:(IOARequest *)self];
    response.success = NO;

    if (failureBlock) {
        failureBlock(response);
    }
    
    [self failureOpWithResp:response];
}


#pragma mark 对指定的code 特殊处理 can override
- (void)failureOpWithResp:(IOAResponse *)response {
    
    return;
//    if (response.serverResponseStatusCode == 21000) {
//        //用户不存在
//
//    }
//    else if (response.serverResponseStatusCode == 401) {
//
//
//        //token失效,alert 重新登录
//        IOARequest * currRequest = (IOARequest *)self;
//        if (![currRequest needAuthorization]) {
//            return;
//        }
//    }
//    else {
//        //统一处理 错误 toast
//        if (response.responseMessage.length) {
//
//            ShowToast(response.responseMessage);
//        }
//    }
}

#pragma mark- 资源上传
- (void)uploadImageDic:(NSDictionary <NSString* , UIImage *>* )imgDict {
    
    self.imgDict = imgDict;
    
    
}
- (void)uploadImageDataDic:(NSDictionary <NSString* , NSData *>* )imgDataDict {
     self.imgDict = imgDataDict;
}
- (void)uploadDataDic:(NSDictionary <NSString* , NSData *>*)dataDic{
    
    self.dataDict = dataDic;
}

/*!
 *  @brief 多图上传
 *
 *  @return ""
 */
- (AFConstructingBlock)constructingBodyBlock {
    
    __weak typeof(self) weakSelf = self;
    if (self.imgDict.allKeys.count) {
        
        return ^(id<AFMultipartFormData> formData) {
            
            for (NSInteger idx = 0 ; idx <weakSelf.imgDict.allKeys.count; idx ++) {
                
                NSString* key = weakSelf.imgDict.allKeys[idx];
                UIImage* upload = weakSelf.imgDict[key];
                if ([upload isKindOfClass:UIImage.class]) {
                    //进行图片压缩
//                    upload = [upload compress];
                    NSData *data = UIImageJPEGRepresentation(upload, 0.9f);
                    
                    NSString *name = [NSString stringWithFormat:@"%@.jpeg",key];
                    NSString *type = @"image/jpeg"; // @"png/jpeg/jpg";
                    if (data) {
                        [formData appendPartWithFileData:data name:key fileName:name mimeType:type];
                    }
                } else if ([upload isKindOfClass:NSData.class]) {

                    NSString *name = [NSString stringWithFormat:@"%@.jpeg",key];
                    NSString *type = @"image/jpeg"; // @"png/jpeg/jpg";
                    if (upload) {
                        [formData appendPartWithFileData:(NSData *)upload name:key fileName:name mimeType:type];
                    }
                }
                
            }
            
            weakSelf.imgDict = nil;
        };
        return nil;
    }
    if(self.dataDict.allKeys.count){
        return ^(id<AFMultipartFormData> formData) {
            
            for (NSInteger idx = 0 ; idx <weakSelf.dataDict.allKeys.count; idx ++) {
                
                NSString* key = weakSelf.dataDict.allKeys[idx];
                NSData* upload = weakSelf.dataDict[key];
                if (upload) {
                    
//                    NSString *name = [NSString stringWithFormat:@"%@.mp4",key];
//                    NSString *type = @"video/mpeg";
                    NSString *name = key;
                    NSString *type = @"application/octet-stream";
                    [formData appendPartWithFileData:upload name:key fileName:name mimeType:type];
                }
                
            }
            
            weakSelf.dataDict = nil;
        };
        return nil;
    }
    
    return nil;
}

#pragma mark- Override beign 可重写 Override
//是否需要显示加载提示
- (BOOL)requestWithLoadingView {
    return self.needShowHud?[self.needShowHud boolValue]:YES;
}

//自定义是否需要 token
- (BOOL)needAuthorization {
    return self.needAuthor?[self.needAuthor boolValue]:YES;
}

#pragma mark 状态码是以 请求返回的code值来判断，还是通过 回传的参数某个值来判断 ---->>response code judge<<-----
- (NSArray <IOAResultKeyModel *> *)responseSuccessKeyAndErrorKeys {
    //多层级直接使用 . 连接
//    IOAResultKeyModel * resultMapModel = [[IOAResultKeyModel alloc] initWithSuccessKey:@"success" successValue:nil errorCodeKey:@"error.errorCode" errorMsgKey:@"error.errorName"];
//
//    return @[resultMapModel];
    return nil;
}



#pragma mark- 头部参数  can override
- (NSDictionary *)requestHeaderFieldValueDictionary {
    
    if ([self needAuthorization]) {

        NSString *token = [IOAApiManager getToken];
        
    
        if (token.length == 0) {
            return nil;
        }
        token = [NSString stringWithFormat:@"%@",token];
        return @{
                 @"Authorization": token
                 };
    }
    return nil;
 
}

#pragma mark- 对请求的结果进行校验  can override
- (BOOL)statusCodeValidator {
    
//    BOOL isOk = [super statusCodeValidator];
////    NSInteger statusCode = [self responseStatusCode];
//    //    return (statusCode >= 200 && statusCode <= 299);
//    if (!isOk) {
////@"网络请求错误"
//        return isOk;
//    }
//    if (!self.responseObject) {
////@"后台服务错误"
//        self.serverResponseStatusCode = 0;
//        return NO;
//    }
//    return YES;
 

  

    NSInteger statusCode = [self responseStatusCode];
    self.serverResponseStatusCode = statusCode;
    
    
    self.success = NO;

    if (statusCode > 200 && statusCode < 300) {
        self.responseStatusType = kResponseStatusTypeRequestError;
        self.serverResponseMessage = [self.class responseMsgWithStatus:self.responseStatusType];
        return NO;
    }
    else {
        if (statusCode == 304) { // 数据不需要刷新
            self.responseStatusType = kResponseStatusTypeNoNeedRefresh;
//            self.serverResponseMessage = IOARequestMsg(self.responseStatusType);
            self.success = YES;
            return YES;
        }
        if (statusCode == 0) { // 后台服务错误
            if (self.serverResponseMessage.length) {
                self.serverResponseMessage = self.serverResponseMessage;
            }
            self.responseStatusType = kResponseStatusTypeRequestError;
            self.serverResponseMessage = [self.class responseMsgWithStatus:self.responseStatusType];
            return NO;
        }

        if (statusCode == 1) { // 没有网络

            self.responseStatusType = kResponseStatusTypeNoNetwork;
            self.serverResponseMessage = [self.class responseMsgWithStatus:self.responseStatusType];
            return NO;
        }

        if (statusCode == 200) {

            
           __block BOOL isSuccess = YES;
            __block NSInteger errorCode = 0;
            __block NSString * errorMsg = @"";
            NSArray <IOAResultKeyModel *> * successKeyAndErrorKeyArr = [self responseSuccessKeyAndErrorKeys];
            if (successKeyAndErrorKeyArr.count) {
                
                [successKeyAndErrorKeyArr enumerateObjectsUsingBlock:^(IOAResultKeyModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    id successStatus =  [self.responseObject valueForKeyPath:obj.successKey];
                    
                    if (successStatus && ![successStatus isKindOfClass:[NSArray class]]) {
                        
                        if (obj.successValue.length) {
                            
                            if ([successStatus isEqualToString:obj.successValue]) {
                                isSuccess = YES;
                            } else {
                                isSuccess = NO;
                            }
                        } else {
                            isSuccess = [successStatus boolValue];
                        }
                        
                        if (!isSuccess) {
                            errorCode = [[self.responseObject valueForKeyPath:obj.errorCodeKey] integerValue];
                            errorMsg = [self.responseObject valueForKeyPath:obj.errorMsgKey];
                        }
                        * stop = YES;
                    }
                }];
            
                
            }
            
            self.serverResponseStatusCode = errorCode;
            self.responseStatusType = kResponseStatusTypeSuccess;
            self.serverResponseMessage = (isSuccess)?@"":errorMsg;
            self.success = isSuccess;
            return YES;
        }
        if (statusCode == 400) {
            self.responseStatusType = kResponseStatusTypeRequestError;
            self.serverResponseMessage = [self.class responseMsgWithStatus:self.responseStatusType];
            return NO;
        }
        if (statusCode == 408) {
            self.responseStatusType = kResponseStatusTypeTimeout;
            self.serverResponseMessage = [self.class responseMsgWithStatus:self.responseStatusType];
            return NO;
        }
        if (statusCode > 400 && statusCode < 500) {

            if (self.serverResponseStatusCode == 401) {
                self.responseStatusType = kResponseStatusTypeExpiryToken;
                self.serverResponseMessage = [self.class responseMsgWithStatus:self.responseStatusType];
            }

            return NO;
        }

        if (statusCode == 500) {
            self.responseStatusType = kResponseStatusTypeServerServiceError;
            self.serverResponseMessage = [self.class responseMsgWithStatus:self.responseStatusType];
            return NO;
        }

        if (statusCode == 501) {
            self.responseStatusType = kResponseStatusTypeServerServiceError;
            self.serverResponseMessage = [self.class responseMsgWithStatus:self.responseStatusType];
            return NO;
        }

        if (statusCode == 502) {
            self.responseStatusType = kResponseStatusTypeDataNull;
            self.serverResponseMessage = [self.class responseMsgWithStatus:self.responseStatusType];
            return NO;
        }

        if (statusCode == 600) {
            self.responseStatusType = kResponseStatusTypeNotLogin;
            self.serverResponseMessage = [self.class responseMsgWithStatus:self.responseStatusType];
            return NO;
        }

    }
    return NO;
}


/**
 错误 与 提示内容 一一对应

 @param respStatusType type
 @return 错误string
 */
+ (NSString *)responseMsgWithStatus:(ResponseStatusType)respStatusType {
    switch (respStatusType) {
        case kResponseStatusTypeRequestError:
            return @"服务器开小差，请稍后重试";
            break;
        case kResponseStatusTypeNoNetwork:
            return @"网络连接异常，请检查网络设置";
            break;
        case kResponseStatusTypeNoNeedRefresh:
            return @"已是最新数据";
            break;
        case kResponseStatusTypeExpiryToken:
            return @"设备在别的地方登录";
            break;
        case kResponseStatusTypeTimeout:
            return @"服务器忙，请稍后重试";
            break;
        case kResponseStatusTypeServerServiceError:
            return @"服务器异常，请稍后重试";
            break;
        case kResponseStatusTypeDataNull:
            return @"没有请求到数据，请稍后重试";
            break;
        case kResponseStatusTypeNotLogin:
            return @"用户未登陆,请先登录";
            break;

            //其他
        default:
            return @"未知错误，请稍后重试";
            break;
    }
}

@end
