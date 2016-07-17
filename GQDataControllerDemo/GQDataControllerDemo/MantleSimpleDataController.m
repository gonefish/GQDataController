//
//  MantleDataController.m
//  GQDataControllerDemo
//
//  Created by 钱国强 on 15/12/6.
//  Copyright © 2015年 Qian GuoQiang. All rights reserved.
//

#import "MantleSimpleDataController.h"
#import <GQDataController/GQMantleAdapter.h>

@implementation MantleSimpleDataController

- (NSArray *)requestURLStrings
{
    return @[@"http://httpbin.org/ip"];
}

- (Class)objectModelClass
{
    return [IP class];
}

- (Class)modelAdapterClass
{
    return [GQMantleAdapter class];
}

@end
