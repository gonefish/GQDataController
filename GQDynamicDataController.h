//
//  GQDynamicDataController.h
//  GQDataController
//
//  Created by 钱国强 on 16/3/21.
//  Copyright (c) 2014年 Qian GuoQiang. All rights reserved.
//

#import "GQDataController.h"

@interface GQDynamicDataController : GQDataController

+ (instancetype)dataControllerWithURLString:(NSString *)URLString;

+ (instancetype)dataControllerWithURLString:(NSString *)URLString requestMethod:(NSString *)method;

+ (instancetype)sharedDataController __attribute__((unavailable("Can't use singleton")));

+ (instancetype)new __attribute__((unavailable("Use dataControllerWithURLString: or dataControllerWithURLString:requestMethod: instead.")));

- (instancetype)init __attribute__((unavailable("Use dataControllerWithURLString: or dataControllerWithURLString:requestMethod: instead.")));

@end
