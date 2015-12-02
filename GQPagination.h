//
//  GQPagination.h
//  GQDataControllerDemo
//
//  Created by 钱国强 on 15/12/2.
//  Copyright © 2015年 Qian GuoQiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GQPaginationMode) {
    GQPaginationModeReplace,
    GQPaginationModeInsert
};

@interface GQPagination : NSObject

@property (nonatomic, copy) NSString *pageIndexName;

@property (nullable, nonatomic, copy) NSString *pageSizeName;

/**
 *  默认是10
 */
@property (nonatomic, assign) NSUInteger pageSize;

@property (nonatomic, assign) NSUInteger currentPageIndex;

@property (nonatomic, assign) GQPaginationMode paginationMode;

+ (instancetype _Nullable)paginationWithPageIndexName:(NSString *)pageIndexName pageSizeName:(NSString * _Nullable)pageSizeName;

@end

NS_ASSUME_NONNULL_END
