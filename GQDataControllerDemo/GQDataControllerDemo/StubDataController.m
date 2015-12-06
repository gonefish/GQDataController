//
//  StubDataController.m
//  GQDataControllerDemo
//
//  Created by 钱国强 on 15/12/7.
//  Copyright © 2015年 Qian GuoQiang. All rights reserved.
//

#import "StubDataController.h"

@implementation StubDataController

- (NSArray *)requestURLStrings
{
    return @[@"http://httpbin.org/ip"];
}

- (void)handleWithObject:(id)object
{
    self.ip = [object objectForKey:@"origin"];
}

@end
