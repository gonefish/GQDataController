//
//  GQTestDataController.m
//  GQDataController
//
//  Created by 钱国强 on 14-7-31.
//  Copyright (c) 2014年 Qian GuoQiang. All rights reserved.
//

#import "GQTestDataController.h"

@implementation GQTestDataController

- (NSArray *)requestURL
{
    return @[@"http://ios.config.synacast.com/globalConfig?osv=7.1&deviceid=8380E58F-028D-4B6C-8BBE-E2F541783D42&channel=1002&platform=iphone&devicetype=iphone&sv=4.0.0"];
}

- (BOOL)parseContent:(NSString *)content
{
    return NO;
}

@end
