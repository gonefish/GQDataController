//
//  PageDataController.m
//  GQDataControllerDemo
//
//  Created by 钱国强 on 15/12/8.
//  Copyright © 2015年 Qian GuoQiang. All rights reserved.
//

#import "PageDataController.h"
#import <GQDataController/GQMantleAdapter.h>

@implementation PageDataController


- (NSArray *)requestURLStrings
{
    return @[@"https://itunes.apple.com/search?term=keynote&entity=software&limit=1"];
}

- (Class)objectModelClass
{
    return [AppInfo class];
}

- (NSString *)modelObjectKeyPath
{
    return @"results";
}

- (Class)modelAdapterClass
{
    return [GQMantleAdapter class];
}

@end
