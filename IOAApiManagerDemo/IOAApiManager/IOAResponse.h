//
//  IOAResponse.h
//  IOAMall
//
//  Created by Mac on 2018/3/5.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IOARequest;

/**
 数据处理
 */
@interface IOAResponse : NSObject

@property (nonatomic, assign) BOOL success;

@property (nonatomic, assign) NSInteger serverResponseStatusCode; // 服务端返回的status code
@property (nonatomic, assign) NSInteger requestResponseStatusCode; // 请求返回的status code

@property (nonatomic, strong) id responseObject; //转换过数据
@property (nonatomic, strong) id responseOriginObject; //原始数据

@property (nonatomic, copy) NSString *responseMessage;

+ (IOAResponse *)responseWithRequest:(IOARequest *)request;


@end
