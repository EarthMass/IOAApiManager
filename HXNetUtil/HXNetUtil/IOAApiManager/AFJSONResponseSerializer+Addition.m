//
//  AFJSONResponseSerializer+Addition.m
//  ECloud
//
//  Created by guohx on 2019/3/12.
//  Copyright © 2019年 istrong. All rights reserved.
//

#import "AFJSONResponseSerializer+Addition.h"

@implementation AFJSONResponseSerializer (Addition)

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/plain", nil];
    
    return self;
}

@end
