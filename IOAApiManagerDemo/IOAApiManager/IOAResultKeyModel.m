//
//  IOAResultKeyModel.m
//  IOANetManager
//
//  Created by guohx on 2019/6/5.
//  Copyright © 2019 ghx. All rights reserved.
//

#import "IOAResultKeyModel.h"

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
