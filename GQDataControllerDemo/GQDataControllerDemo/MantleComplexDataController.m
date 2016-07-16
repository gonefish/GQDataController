//
//  MantleComplexDataController.m
//  GQDataControllerDemo
//
//  Created by 钱国强 on 15/12/6.
//  Copyright © 2015年 Qian GuoQiang. All rights reserved.
//

#import "MantleComplexDataController.h"

@implementation MantleComplexDataController

- (NSArray *)requestURLStrings
{
    return @[@"http://httpbin.org/headers"];
}

- (Class)objectModelClass
{
    return [Header class];
}

- (NSString *)modelObjectKeyPath
{
    return @"headers";
}

@end
