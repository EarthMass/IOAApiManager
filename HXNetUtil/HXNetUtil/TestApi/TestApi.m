//
//  TestApi.m
//  HXNetUtil
//
//  Created by guohx on 2019/1/22.
//  Copyright © 2019年 ghx. All rights reserved.
//

#import "TestApi.h"

@implementation TestApiRespEntity

@end
@implementation domain

@end
@implementation data

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"domain":[domain class]};
}

@end

@implementation TestApiRequestEntity


@end


@implementation TestApi

- (NSString *)requestUrl {
    return @"xxxx";
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}


@end
