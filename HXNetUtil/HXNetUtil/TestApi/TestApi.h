//
//  TestApi.h
//  HXNetUtil
//
//  Created by guohx on 2019/1/22.
//  Copyright © 2019年 ghx. All rights reserved.
//

#import "IOARequest.h"


@interface domain :NSObject
@property (nonatomic , copy) NSString              * userId;
@property (nonatomic , copy) NSString              * uposts;
@property (nonatomic , copy) NSString              * realName;
@property (nonatomic , copy) NSString              * sysId;
@property (nonatomic , copy) NSString              * sysName;
@property (nonatomic , copy) NSString              * depId;
@property (nonatomic , copy) NSString              * depName;
@property (nonatomic , copy) NSString              * sex;

@end

@interface data :NSObject
@property (nonatomic , copy) NSString              * token;
@property (nonatomic , strong) NSArray              * domain;

@end

@interface TestApiRespEntity :NSObject
@property (nonatomic , strong) NSNumber              * success;
@property (nonatomic , copy) NSString              * message;
@property (nonatomic , strong) data              * data;
@property (nonatomic , copy) NSString              * schema;
@property (nonatomic , copy) NSString              * paging;

@end


@interface TestApiRequestEntity : NSObject

@property (nonatomic, copy) NSString * appId;
@property (nonatomic, copy) NSString * phone;
@property (nonatomic, copy) NSString * code;


@end


@interface TestApi : IOARequest

@end
