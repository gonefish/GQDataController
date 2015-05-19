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

/**
 *  共享实例的方法，共享实例的请求队列是串行的
 *
 */
+ (instancetype)sharedDataController;

- (instancetype)initWithDelegate:(id <GQDataControllerDelegate>)aDelegate;


// ------------
// 发起请求的方法
// ------------

/**
 *  发起不添加参数的请求
 */
- (void)request;

/**
 *  发起添加参数的请求
 *
 */
- (void)requestWithParams:(NSDictionary *)params;

// ----------------
// 自定义接口请求的方法
// ----------------

/**
 *  HTTP的Method
 */
- (NSString *)requestMethod;

/**
 *  接口请求的地址，可以有多个用于备用重试
 *
 */
- (NSArray *)requestURLStrings;

/**
 *  重建地址
 *
 */
- (NSString *)requestURLStringWithURLString:(NSString *)urlString params:(NSDictionary *)params;

/**
 *  本地响应文件，如果这个方法返回非nil且有效的路径，会从这个路径访问结果
 *
 */
- (NSString *)localResponseFilename;

// ----------------
// 请求成功后的处理方法
// ----------------

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

// ----------------
// 完全自定义的相关方法
// ----------------

/**
 *  接口请求成功的处理
 *
 */
- (void)requestOpertaionSuccess:(NSOperation *)operation responseObject:(id)responseObject;

/**
 *  接口请求失败的处理
 *
 */
- (void)requestOperationFailure:(NSOperation *)operation error:(NSError *)error;

@end

