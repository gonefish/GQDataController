//
//  GQDynamicDataController.m
//  GQDataController
//
//  Created by 钱国强 on 16/3/21.
//  Copyright (c) 2014年 Qian GuoQiang. All rights reserved.
//

#import "GQDynamicDataController.h"

@interface GQDynamicDataController ()

@property (nonatomic, copy) NSString *dynamicURLString;

@property (nonatomic, copy) NSString *dynamicRequestMethod;

@end

@implementation GQDynamicDataController

- (instancetype)privateInit
{
    return [super init];
}

+ (instancetype)dataControllerWithURLString:(NSString *)URLString
{
    return [self dataControllerWithURLString:URLString requestMethod:@"GET"];
}

+ (instancetype)dataControllerWithURLString:(NSString *)URLString requestMethod:(NSString *)method
{
    NSParameterAssert([URLString isKindOfClass:[NSString class]]);
    NSParameterAssert([method isKindOfClass:[NSString class]]);
    
    GQDynamicDataController *newInstance = [[GQDynamicDataController alloc] privateInit];
    newInstance.dynamicURLString = URLString;
    newInstance.dynamicRequestMethod = method;
    
    return newInstance;
}

- (NSString *)requestMethod
{
    return self.dynamicRequestMethod;
}

- (NSArray<NSString *> *)requestURLStrings
{
    return @[self.dynamicURLString];
}

@end
