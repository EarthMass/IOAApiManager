//
//  IOARequest.m
//  ECloudCommonUtil
//
//  Created by guohx on 2019/6/5.
//  Copyright © 2019 istrong. All rights reserved.
//

#import "IOARequestCus.h"

@interface IOARequestCus ()

@property (nonatomic, readwrite, assign) NSInteger serverResponseStatusCode;
@property (nonatomic, readwrite, assign) NSInteger requestResponseStatusCode;

@property (nonatomic, readwrite, copy) NSString *serverResponseMessage;

@end

@implementation IOARequestCus
@synthesize serverResponseStatusCode = _serverResponseStatusCode;
@synthesize requestResponseStatusCode = _requestResponseStatusCode;
@synthesize serverResponseMessage = _serverResponseMessage;


//+ (void)showToast:(NSString *)msg {
//
//    [QMUITips showWithText:msg];
//}
//+ (void)hideToast {
//
//    [QMUITips hideAllTips];
//}
//+ (void)showLoading:(NSString *)msg {
//    [QMUITips showLoading:msg inView:CurrVC().view];
//}
//+ (void)hideLoading {
//
//    [QMUITips hideAllTips];
//}

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

#pragma mark- 对请求回来的数据 数据组装
- (NSArray <IOAResultKeyModel *> *)responseSuccessKeyAndErrorKeys {
    //多层级直接使用 . 连接
        IOAResultKeyModel * resultMapModel = [[IOAResultKeyModel alloc] initWithSuccessKey:@"success" successValue:nil errorCodeKey:@"error.errorCode" errorMsgKey:@"error.errorName"];

        return @[resultMapModel];
}

#pragma mark- 对请求的结果进行校验  can override
- (BOOL)statusCodeValidator {

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

#pragma mark 对指定的code 特殊处理 can override
- (void)failureOpWithResp:(IOAResponse *)response {


    if (response.serverResponseStatusCode == 21000) {
        //用户不存在
//        ShowAlertUserNoPermission();

    }
    else if (response.serverResponseStatusCode == 401) {


//        id tmp = CurrVC();
//
//        if ( [NSStringFromClass([tmp class]) isEqualToString:@"UIViewController"]
//            || [NSStringFromClass([tmp class]) isEqualToString:@"LoginVC"]
//            || [NSStringFromClass([tmp class]) isEqualToString:@"OrganizationListVC"]
//            || [NSStringFromClass([tmp class])  isEqualToString:@"QMUIModalPresentationViewController"] //已有弹窗
//            ) {
//
//            //启动页不显示 提示
//            return;
//        }
//
//
//        QMUIAlertController * alertV = [[QMUIAlertController alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@",response.responseMessage] preferredStyle:QMUIAlertControllerStyleAlert];
//        alertV.alertCancelButtonAttributes = @{NSForegroundColorAttributeName:COLOR_MAIN};
//        alertV.alertButtonAttributes = @{NSForegroundColorAttributeName:COLOR_MAIN};
//
//        QMUIAlertAction * ensureAction = [QMUIAlertAction actionWithTitle:@"重新登录" style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
//
//
//            QMUICommonViewController * vc = GetVcWithRouterStr(@"ModuleLoginServiceProtocol/getLoginVC", nil);
//            QMUINavigationController * nav = [[QMUINavigationController alloc] initWithRootViewController:vc];
//            [CurrVC() presentViewController:nav animated:YES completion:nil];
//
//
//        }];
//
//        [alertV addAction:ensureAction];
//
//        [alertV showWithAnimated:YES];

    }
    else {
        //统一处理 错误 toast
        if (response.responseMessage.length) {

           [self.class showToast:response.responseMessage];
        }
    }
}

- (NSDictionary *)requestHeaderFieldValueDictionary {

    if ([self needAuthorization]) {

        NSString *token = [IOAApiHelper getToken];


        if (token.length == 0) {
            return nil;
        }
        token = [NSString stringWithFormat:@"Bearer %@",token];
        return @{
                 @"Authorization": token,
                 @"User-Agent":@"iOS"
                 };
        //         return @{@"useragent":@"iOS"};
    }
    return nil;

}

@end
