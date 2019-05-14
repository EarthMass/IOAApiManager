//
//  IOAResponse.m
//  IOAMall
//
//  Created by Mac on 2018/3/5.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import "IOAResponse.h"
#import "IOARequest.h"

@implementation IOAResponse

+ (IOAResponse *)responseWithRequest:(IOARequest *)request {
    
    if (!request) return nil;
    IOAResponse *response = [IOAResponse new];
    
    response.success = request.success;
    
    response.serverResponseStatusCode = request.serverResponseStatusCode;
    response.requestResponseStatusCode = request.requestResponseStatusCode;
    
    response.responseOriginObject = request.responseObject;
    
    if (request.respEntityName.length && NSClassFromString(request.respEntityName)) {
       Class respEntityCls = NSClassFromString(request.respEntityName);
        response.responseObject = [respEntityCls mj_objectWithKeyValues:request.responseObject];
        
    } else {
        
        response.responseObject = request.responseObject;
        
    }
  
    response.responseMessage = request.serverResponseMessage;
    
    
    return response;
}

@end
