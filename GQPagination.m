//
//  GQPagination.m
//  GQDataControllerDemo
//
//  Created by 钱国强 on 15/12/2.
//  Copyright © 2015年 Qian GuoQiang. All rights reserved.
//

#import "GQPagination.h"

@implementation GQPagination

+ (instancetype)paginationWithPageIndexName:(NSString *)pageIndexName pageSizeName:(NSString *)pageSizeName
{
    GQPagination *instance = [self init];
    
    if (instance) {
        instance.pageIndexName = pageIndexName;
        instance.pageSizeName = pageSizeName;
    }
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pageIndexName = @"page";
        self.pageSize = 10;
    }
    return self;
}

@end
