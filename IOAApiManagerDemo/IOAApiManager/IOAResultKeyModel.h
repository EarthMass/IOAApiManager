//
//  IOAResultKeyModel.h
//  IOANetManager
//
//  Created by guohx on 2019/6/5.
//  Copyright © 2019 ghx. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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

NS_ASSUME_NONNULL_END
