//
//  GQDataController.h
//  GQDataController
//
//  Created by 钱国强 on 14-5-25.
//  Copyright (c) 2014年 Qian GuoQiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mantle/Mantle.h>
#import <AFNetworking/AFNetworking.h>

#import "GQDataControllerDelegate.h"
#import "GQPagination.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const GQDataControllerErrorDomain;

extern const NSInteger GQDataControllerErrorInvalidObject;

extern NSString * const GQResponseObjectKey;

typedef void (^GQRequestSuccessBlock)(void);

typedef void (^GQRequestFailureBlock)(NSError * _Nullable error);

typedef void (^GQDataControllerLogBlock)(NSString *log);

typedef void (^GQTableViewCellConfigureBlock)(UITableViewCell *cell, MTLModel *model);

typedef void (^GQCollectionViewCellConfigureBlock)(UICollectionViewCell *cell, MTLModel *model);

@interface GQDataController : NSObject <
NSCopying,
UITableViewDataSource,
UICollectionViewDataSource
>

@property (nonatomic, strong, readonly) AFHTTPRequestOperationManager *requestOperationManager;

@property (nonatomic, copy) GQRequestSuccessBlock requestSuccessBlock;

@property (nonatomic, copy) GQRequestFailureBlock requestFailureBlock;

@property (nullable, nonatomic, weak) id <GQDataControllerDelegate> delegate;

@property (nonatomic, strong, nullable) __kindof MTLModel<MTLJSONSerializing> *mantleObject;

@property (nonatomic, strong, nullable) NSMutableArray<__kindof MTLModel *> *mantleObjectList;

@property (nonatomic, copy) GQDataControllerLogBlock logBlock;

@property (nonatomic, copy) NSString *cellIdentifier;

@property (nonatomic, copy) GQTableViewCellConfigureBlock tableViewCellConfigureBlock;

@property (nonatomic, copy) GQCollectionViewCellConfigureBlock collectionViewCellConfigureBlock;

@property (nonatomic, strong, nullable) GQPagination *pagination;


/**
 *  共享实例的方法
 *
 */
+ (instancetype)sharedDataController;


- (instancetype)initWithDelegate:(id <GQDataControllerDelegate>)aDelegate;


// ------------
// 发起请求的方法
// ------------

/**
 *  调用requestWithParams:并传入nil
 */
- (void)request;

/**
 *  发起网络请求
 *
 *  @param params 请求的参数
 */
- (void)requestWithParams:(nullable NSDictionary *)params;

/**
 *  Block风格的接口请求
 *
 *  @param params  请求的参数
 *  @param success 成功的Block
 *  @param failure 失败的Block
 */
- (void)requestWithParams:(nullable NSDictionary *)params
                  success:(nullable GQRequestSuccessBlock)success
                  failure:(nullable GQRequestFailureBlock)failure;

/**
 *  加载更多
 */
- (void)requestMore;

/**
 *  取消当前的接口请求
 */
- (void)cancelRequest;

// ----------------
// 子类需要自定义的方法
// ----------------

/**
 *  HTTP的Method
 */
- (NSString *)requestMethod;

/**
 *  接口请求的地址，可以有多个用于备用重试
 *
 */
- (NSArray<NSString *> *)requestURLStrings;


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

// ------------
// Mantle相关方法
// ------------

/**
 *  返回需要转换的Mantle模型类
 *
 *  @return Mantle的Class
 */
- (Class)mantleModelClass;

/**
 *  需要转换的JSON Dictionary位于整个Dictionary中的位置
 *
 *  @return Key Path
 */
- (NSString *)mantleObjectKeyPath;

/**
 *  objectList的键值映射
 *
 *  @return Key Path
 */
- (NSString *)mantleObjectListKeyPath;

/**
 *  指定用于转换到mantleList中的类
 *
 *  @return Mantle的Class
 */
- (Class)mantleListModelClass;


// ----------------
// 完全自定义的相关方法
// ----------------

/**
 *  接口请求成功的处理
 *
 */
- (void)requestOpertaionSuccess:(AFHTTPRequestOperation *)operation responseObject:(id)responseObject;

/**
 *  接口请求失败的处理
 *
 */
- (void)requestOperationFailure:(AFHTTPRequestOperation *)operation error:(NSError *)error;

@end

NS_ASSUME_NONNULL_END

