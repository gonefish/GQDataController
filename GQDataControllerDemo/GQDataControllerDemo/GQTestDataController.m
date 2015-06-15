//
//  GQTestDataController.m
//  GQDataController
//
//  Created by 钱国强 on 14-7-31.
//  Copyright (c) 2014年 Qian GuoQiang. All rights reserved.
//

#import "GQTestDataController.h"
#import "IP.h"

@implementation GQTestDataController

- (NSArray *)requestURLStrings
{
    return @[@"http://httpbin.org/ip"];
}

//- (void)handleWithObject:(id)object
//{
//    self.ip = [object objectForKey:@"origin"];
//}

- (Class)mantleModelClass
{
    return [IP class];
}

//- (NSString *)localResponseFilename
//{
//    return @"ip.json";
//}

@end
