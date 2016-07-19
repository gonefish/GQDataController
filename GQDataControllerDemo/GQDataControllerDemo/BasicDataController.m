//
//  GQTestDataController.m
//  GQDataController
//
//  Created by 钱国强 on 14-7-31.
//  Copyright (c) 2014年 Qian GuoQiang. All rights reserved.
//

#import "BasicDataController.h"

@implementation BasicDataController

- (NSArray *)requestURLStrings
{
    return @[@"http://httpbin.org/ip"];
}

- (NSString *)ip
{
    return [self.modelObject objectForKey:@"origin"];
}

@end
