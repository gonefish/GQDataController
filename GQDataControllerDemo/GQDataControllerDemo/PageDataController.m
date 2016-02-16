//
//  PageDataController.m
//  GQDataControllerDemo
//
//  Created by 钱国强 on 15/12/8.
//  Copyright © 2015年 Qian GuoQiang. All rights reserved.
//

#import "PageDataController.h"

@implementation PageDataController


- (NSArray *)requestURLStrings
{
    return @[@"https://itunes.apple.com/search?term=keynote&entity=software&limit=1"];
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
