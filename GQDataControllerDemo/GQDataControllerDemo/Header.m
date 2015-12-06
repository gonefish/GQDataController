//
//  Header.m
//  GQDataControllerDemo
//
//  Created by 钱国强 on 15/12/6.
//  Copyright © 2015年 Qian GuoQiang. All rights reserved.
//

#import "Header.h"

@implementation Header

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"userAgent": @"User-Agent",
             };
}

@end
