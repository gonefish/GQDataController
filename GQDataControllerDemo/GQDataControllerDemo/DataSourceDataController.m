//
//  DataSourceDataController.m
//  GQDataControllerDemo
//
//  Created by 钱国强 on 15/12/6.
//  Copyright © 2015年 Qian GuoQiang. All rights reserved.
//

#import "DataSourceDataController.h"

@implementation DataSourceDataController

- (NSArray *)requestURLStrings
{
    return @[@"https://itunes.apple.com/search?term=keynote&entity=software&limit=10"];
}

- (Class)mantleModelClass
{
    return [AppInfo class];
}

- (NSString *)mantleObjectKeyPath
{
    return @"results";
}

@end
