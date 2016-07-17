//
//  DataSourceDataController.m
//  GQDataControllerDemo
//
//  Created by 钱国强 on 15/12/6.
//  Copyright © 2015年 Qian GuoQiang. All rights reserved.
//

#import "DataSourceDataController.h"
#import <GQDataController/GQMantleAdapter.h>

@implementation DataSourceDataController

- (NSArray *)requestURLStrings
{
    return @[@"https://itunes.apple.com/search?term=keynote&entity=software&limit=10"];
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
