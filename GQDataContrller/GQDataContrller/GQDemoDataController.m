//
//  GQTestDataController.m
//  GQDataContrller
//
//  Created by 钱国强 on 12-12-29.
//  Copyright (c) 2012年 Qian GuoQiang. All rights reserved.
//

#import "GQDemoDataController.h"

@implementation GQDemoDataController

#pragma mark - Subclass implementation



- (NSArray *)requestBaseURL
{
    return @[[NSURL URLWithString:@"http://gonefish.info"]];
}

- (NSString *)requestPath
{
    return @"/test.php";
}

@end
