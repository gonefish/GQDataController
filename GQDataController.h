//
//  GQDataController.h
//  GQDataController
//
//  Created by 钱国强 on 14-5-25.
//  Copyright (c) 2014年 Qian GuoQiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GQDataControllerDelegate.h"

typedef void (^GQTableViewCellConfigureBlock)(UITableViewCell *cell, id cellModel);

typedef void (^GQCOllectionViewCellConfigureBlock)(UICollectionViewCell *cell, id cellModel);

@interface GQDataController : NSObject

@property (nonatomic, weak) id <GQDataControllerDelegate> delegate;

@property (nonatomic, weak) id <UITableViewDataSource> tableViewDataSource;

@property (nonatomic, copy) GQTableViewCellConfigureBlock tableViewCellConfigureBlock;

@property (nonatomic, weak) id <UICollectionViewDataSource> collectionViewDataSource;

@property (nonatomic, copy) GQCOllectionViewCellConfigureBlock collectionCellConfigureBlock;

@property (nonatomic, strong, readonly) id detailObject;

@property (nonatomic, strong, readonly) NSArray *listObjects;

+ (instancetype)sharedDataController;

- (void)request;

- (void)requestWithParams:(NSDictionary *)params;

/**
 *  HTTP的Method
 */
- (NSString *)requestMethod;

/**
 *  接口请求的地址，可以有多个用于备用重试
 *
 */
- (NSArray *)requestURL;

/**
 *  默认参数
 */
- (NSDictionary *)defaultParams;

/**
 *  检测返回的结果是否有效
 *
 */
- (BOOL)isValidWithObject:(id)object;

/**
 *  处理结果的方法
 *
 */
- (void)handleWithObject:(id)object;

/**
 *  本地响应文件，如果这个方法返回非nil且有效的路径，会从这个路径访问结果
 *
 */
- (NSString *)localResponseFilename;

- (void)requestOpertaionSuccess:(NSOperation *)operation responseObject:(id)responseObject;

- (void)requestOperationFailure:(NSOperation *)operation error:(NSError *)error;


@end


