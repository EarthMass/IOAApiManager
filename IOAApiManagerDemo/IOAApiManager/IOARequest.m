//
//  IOARequest.m
//  IOAMall
//
//  Created by Mac on 2018/1/31.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import "IOARequest.h"
#import "YTKNetworkConfig.h"


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
//Value 图片对象（原始数据） 当个如果闯入多个@{key: value, key: value}无法保证顺序
@property(nonatomic, strong) NSDictionary <NSString* , id>* imgDict;
//文件
@property(nonatomic, strong) NSDictionary <NSString* , NSData *>* dataDict;

@property(nonatomic, strong) NSArray <NSDictionary <NSString* , id>*> * imgDictArr;
//文件
@property(nonatomic, strong) NSArray <NSDictionary <NSString* , NSData *>*> * dataDictArr;


@end

@implementation IOARequest
#pragma mark- Get Value
- (BOOL)isBlockInit {
    return _isBlockInit;
}
- (NSInteger)serverResponseStatusCode {
    return _serverResponseStatusCode;
}
- (NSInteger)requestResponseStatusCode {
    return _requestResponseStatusCode;
}
- (NSString *)serverResponseMessage {
    return _serverResponseMessage;
}
- (id)requestModel {
    return _requestModel;
}
- (NSDictionary *)requestDic {
    return _requestDic;
}

- (NSDictionary *)imgDict {
    return _imgDict;
}

- (NSDictionary *)dataDict {
    return _dataDict;
}

- (NSArray <NSDictionary <NSString* , id>*> *)imgDictArr {
    return _imgDictArr;
}
- (NSArray <NSDictionary <NSString* , NSData *>*> *)dataDictArr {
    return _dataDictArr;
}

- (YTKRequestMethod)requestType {
    return _requestType;
}
- (NSString *)uri {
    return _uri;
}

#pragma mark- 定制提示框 提示统一处理[便于快速切换库]
+ (void)showToast:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [HXProgress showToastWithMsg:msg];
    });
}
+ (void)hideToast {
    dispatch_async(dispatch_get_main_queue(), ^{
        [HXProgress dismissHUD];
    });

}
+ (void)showLoading:(NSString *)msg {

    dispatch_async(dispatch_get_main_queue(), ^{
        [HXProgress showWithStatus:msg];
    });
}
+ (void)hideLoading {

    dispatch_async(dispatch_get_main_queue(), ^{
        [HXProgress dismissHUD];
    });
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

    if (![IOAApiHelper isNetworkReachable] && [IOAApiHelper getNetworkStatus] != AFNetworkReachabilityStatusUnknown) {
        self.responseStatusType = kResponseStatusTypeNoNetwork;
        self.serverResponseStatusCode = kResponseStatusTypeNoNetwork; // 没网络
        self.serverResponseMessage = [self.class responseMsgWithStatus:self.responseStatusType];


        if ([self requestWithLoadingView]) [IOARequest hideLoading];
        [self delegateReturnWithRequest:self];
        
        return;
    }


    [self setCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {

        if ([weakSelf requestWithLoadingView]) [IOARequest hideLoading];
        __block typeof(self) blockSelf = weakSelf;
         [blockSelf delegateReturnWithRequest:request];

    }  failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        if ([weakSelf requestWithLoadingView]) [IOARequest hideLoading];
        
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
    
    if (![IOAApiHelper isNetworkReachable] && [IOAApiHelper getNetworkStatus] != AFNetworkReachabilityStatusUnknown) {
        self.responseStatusType = kResponseStatusTypeNoNetwork; // 没网络
        self.serverResponseStatusCode = kResponseStatusTypeNoNetwork;
        self.serverResponseMessage = [self.class responseMsgWithStatus:self.responseStatusType];
        if (resultBlock) {
           if ([self requestWithLoadingView]) [IOARequest hideLoading];
            [self failure:resultBlock];
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self setCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        
       if ([weakSelf requestWithLoadingView]) [IOARequest hideLoading];
        __block typeof(self) blockSelf = weakSelf;
        [blockSelf success:resultBlock request:request];
        
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        
       if ([weakSelf requestWithLoadingView]) [IOARequest hideLoading];
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
    
    if (![IOAApiHelper isNetworkReachable] && [IOAApiHelper getNetworkStatus] != AFNetworkReachabilityStatusUnknown) {
        
        self.responseStatusType = kResponseStatusTypeNoNetwork; // 没网络
        self.serverResponseStatusCode = kResponseStatusTypeNoNetwork;
        self.serverResponseMessage = [self.class responseMsgWithStatus:self.responseStatusType];
        if (resultBlock) {
           if ([self requestWithLoadingView]) [IOARequest hideLoading];
            [self failure:resultBlock];
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self setCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        
       if ([weakSelf requestWithLoadingView]) [IOARequest hideLoading];
        __block typeof(self) blockSelf = weakSelf;
        [blockSelf success:resultBlock request:request];
        
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        
       if ([weakSelf requestWithLoadingView]) [IOARequest hideLoading];
        if (resultBlock) {
            
            __block typeof(self) blockSelf = weakSelf;
            [blockSelf failure:resultBlock];
            
        }
    }];
    [self start];
}

#pragma mark- 成功 失败处理，【code的特定 统一处理，提示等】
- (void)success:(IOAResponseResultBlock)successBlock request:(YTKBaseRequest *)request {
    
   if ([self requestWithLoadingView]) [IOARequest hideLoading];
    
    IOAResponse * response = [IOAResponse responseWithRequest:(IOARequest *)self];
    if (response.success) {

        if (successBlock) {
            if([IOAApiHelper requestLogEnable]) IOALog(@"%@", [self getRequestInfoToStringWithResponse:response]);
            successBlock(response);
        }
        return;
    }

    response.success = NO;

    IOALog(@"%@", response.responseOriginObject);
    //统一处理 错误 toast
    if (response.responseMessage.length) {

        if ([self requestWithToastView]) [IOARequest showToast:response.responseMessage];
    }

    if (successBlock) {
       if([IOAApiHelper requestLogEnable]) IOALog(@"%@", [self getRequestInfoToStringWithResponse:response]);
        successBlock(response);
    }
}

- (void)failure:(IOAResponseResultBlock)failureBlock {
    
    IOAResponse * response = [IOAResponse responseWithRequest:(IOARequest *)self];
    response.success = NO;

    if (failureBlock) {
        if ([self requestWithToastView] && response.responseMessage.length) {
            [IOARequest showToast:response.responseMessage];
        }
       if([IOAApiHelper requestLogEnable]) IOALog(@"%@", [self getRequestInfoToStringWithResponse:response]);
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


- (void)uploadImageDicArr:(NSArray <NSDictionary <NSString* , UIImage *>* >*)imgDictArr {
    self.imgDictArr = imgDictArr;
}
- (void)uploadDataDicArr:(NSArray <NSDictionary <NSString* , NSData *>* >*)dataDicArr {
    self.dataDictArr = dataDicArr;
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
                    NSData *data = UIImageJPEGRepresentation(upload, 0.6f);
                    
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
            

        };

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
            
        };

    }
    if (self.imgDictArr.count) {

        return ^(id<AFMultipartFormData> formData) {

            for (NSInteger idx = 0 ; idx < weakSelf.imgDictArr.count; idx ++) {

                NSDictionary <NSString* , id>* tmp = weakSelf.imgDictArr[idx];
                for (NSInteger jdx = 0 ; jdx < tmp.allKeys.count; jdx ++) {

                    NSString* key = tmp.allKeys[jdx];
                    UIImage* upload = tmp[key];

                    if ([upload isKindOfClass:UIImage.class]) {
                        //进行图片压缩
                        //                    upload = [upload compress];
                        NSData *data = UIImageJPEGRepresentation(upload, 0.6f);

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
            }

        };
    }
    if (self.dataDictArr.count) {

        return ^(id<AFMultipartFormData> formData) {

            for (NSInteger idx = 0 ; idx < weakSelf.dataDictArr.count; idx ++) {

                NSDictionary <NSString* , NSData *>* tmp = weakSelf.imgDictArr[idx];

                for (NSInteger jdx = 0 ; jdx < tmp.allKeys.count; jdx ++) {

                    NSString * key = tmp.allKeys[jdx];
                    NSData * upload = tmp[key];
                    if (upload) {

                        NSString *name = key;
                        NSString *type = @"application/octet-stream";
                        [formData appendPartWithFileData:upload name:key fileName:name mimeType:type];
                    }

                }
            }

        };

    }
    


    return nil;
}

#pragma mark- Override beign 可重写 Override
//是否需要显示加载提示
- (BOOL)requestWithLoadingView {
    return self.needShowHud?[self.needShowHud boolValue]:YES;
}

- (BOOL)requestWithToastView {
    return self.needShowToast?[self.needShowToast boolValue]:YES;
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

        NSString *token = [IOAApiHelper getToken];
        
    
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
            return @"您的账号在其他设备登录，请重新登录";
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

#pragma mark- Other Log
- (NSString *)getRequestInfoToStringWithResponse:(IOAResponse *)resp {

    NSString * requestInfoStr = @"";

    NSString * resouce = nil;
    NSString * uri = nil;
    if (self.uri) {
        uri = self.uri;
    } else {
        uri = [self requestUrl];
    }



    if (self.baseUrl.length && ![self.uri hasPrefix:@"http"]) {
        resouce = [self.baseUrl stringByAppendingPathComponent:uri];
    } else {
        NSString * baseUrl = self.baseUrl.length?self.baseUrl:[YTKNetworkConfig sharedConfig].baseUrl;
        if (![self.uri hasPrefix:@"http"]) {
            resouce = [baseUrl stringByAppendingPathComponent:uri];
        } else {
            resouce = uri;
        }

    }
    NSMutableDictionary * requestInfo = [NSMutableDictionary dictionary];

    if (self.requestArgument) {
        if ([self.requestArgument isKindOfClass:[NSDictionary class]]) {
            requestInfo = [NSMutableDictionary dictionaryWithDictionary:self.requestArgument];

        } else {

            NSArray * arr = self.requestArgument;

            if (arr.count) {
                requestInfo = [NSMutableDictionary dictionaryWithDictionary:@{@"paramDic":[arr mj_JSONString]}];
            }
        }

    } else {
        requestInfo = [NSMutableDictionary dictionaryWithDictionary:self.requestDic?self.requestDic:[self.requestModel mj_JSONObject]];;
    }

    if (self.imgDict.allKeys.count) {
        for (NSString * fileKey in self.imgDict.allKeys) {
            [requestInfo setObject:@"maybe [file part]" forKey:fileKey?:@"file"];
        }
    }
    if (self.dataDict.allKeys.count) {
        for (NSString * fileKey in self.dataDict.allKeys) {
            [requestInfo setObject:@"maybe [file part]" forKey:fileKey?:@"file"];
        }
    }
    if (self.dataDictArr.count ) {
        for (NSDictionary <NSString *,NSData *> * dic in _dataDictArr) {
            if (dic.allKeys.count) {
                for (NSString * fileKey in dic.allKeys) {
                    [requestInfo setObject:@"maybe [file part]" forKey:fileKey?:@"file"];
                }
            }
        }

    }
    if (self.imgDictArr.count ) {
        for (NSDictionary <NSString *,NSData *> * dic in _imgDictArr) {
            if (dic.allKeys.count) {
                for (NSString * fileKey in dic.allKeys) {
                    [requestInfo setObject:@"maybe [file part]" forKey:fileKey?:@"file"];
                }
            }
        }

    }

   requestInfoStr = [requestInfoStr stringByAppendingString:[NSString stringWithFormat:@"requestUrl:%@ \n",resouce]];
   requestInfoStr = [requestInfoStr stringByAppendingString:[NSString stringWithFormat:@"requestHead:%@ \n",[self requestHeaderFieldValueDictionary]]];
   requestInfoStr = [requestInfoStr stringByAppendingString:[NSString stringWithFormat:@"requestInfo:%@ \n",requestInfo]];
   requestInfoStr = [requestInfoStr stringByAppendingString:[NSString stringWithFormat:@"responseInfo:%@ \n",[resp.responseOriginObject mj_JSONString]]];


    return requestInfoStr;
}

@end
