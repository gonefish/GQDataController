//
//  GQDataController.h
//  GQDataController
//
//  Created by Qian GuoQiang on 14-5-25.
//  Copyright (c) 2014年 Qian GuoQiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>

#import "GQDataControllerDelegate.h"
#import "GQSQLiteProtocol.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const GQDataControllerErrorDomain;

extern const NSInteger GQDataControllerErrorInvalidObject;

extern NSString * const GQResponseObjectKey;

typedef void (^GQRequestCompletedBlock)(__kindof GQDataController *controller);

typedef void (^GQRequestSuccessBlock)(__kindof GQDataController *controller);

typedef void (^GQRequestFailureBlock)(__kindof GQDataController *controller, NSError * _Nullable error);

typedef void (^GQDataControllerLogBlock)(id logObject);

typedef void (^GQTableViewCellConfigureBlock)(__kindof UITableViewCell *cell, id modelObject);

typedef void (^GQCollectionViewCellConfigureBlock)(__kindof UICollectionViewCell *cell, id modelObject);

typedef NS_ENUM(NSUInteger, GQModelObjectListUpdatePolicy) {
    GQModelObjectListUpdatePolicyInsert,
    GQModelObjectListUpdatePolicyReplace,
};

@interface GQDataController : NSObject <
NSCopying,
UITableViewDataSource,
UICollectionViewDataSource
>

@property (nullable, nonatomic, weak) id <GQDataControllerDelegate> delegate;

@property (nonatomic, strong, readonly) AFHTTPSessionManager *httpSessionManager;

@property (nonatomic, copy) GQRequestCompletedBlock requestCompletedBlock;

@property (nonatomic, copy) GQRequestSuccessBlock requestSuccessBlock;

@property (nonatomic, copy) GQRequestFailureBlock requestFailureBlock;

// -------------
// Model Object
// -------------

@property (nonatomic, strong, nullable) id modelObject;

@property (nonatomic, strong, nullable) NSMutableArray *modelObjectList;

@property (nonatomic, assign) GQModelObjectListUpdatePolicy modelObjectListUpdatePolicy;


// -----------
// Data Source
// -----------

@property (nonatomic, copy) NSString *cellIdentifier;

@property (nonatomic, copy) GQTableViewCellConfigureBlock tableViewCellConfigureBlock;

@property (nonatomic, copy) GQCollectionViewCellConfigureBlock collectionViewCellConfigureBlock;

// -----
// Other
// -----

@property (nonatomic, copy) GQDataControllerLogBlock logBlock;

/**
 *  共享实例的方法
 *
 */
+ (instancetype)sharedDataController;


- (instancetype)initWithDelegate:(id <GQDataControllerDelegate>)aDelegate;

- (instancetype)initWithSuccessBlock:(nullable GQRequestSuccessBlock)success
                        failureBlock:(nullable GQRequestFailureBlock)failure
                      completedBlock:(nullable GQRequestCompletedBlock)complated;


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


/**
 *  分页的参数名称
 *
 */
- (NSString *)pageParameterName;

// ----------------
// 请求成功后的处理方法
// ----------------

/**
 *  检测返回的结果是否有效
 *
 */
- (BOOL)isValidWithJSONObject:(id)object;

/**
 *  处理结果的方法
 *
 */
- (void)handleWithJSONObject:(id)object;

// ------------
// Model相关方法
// ------------

- (Class)modelAdapterClass;

/**
 *  返回需要转换的Mantle模型类
 *
 *  @return Mantle的Class
 */
- (Class)modelObjectClass;

/**
 *  需要转换的JSON Dictionary位于整个Dictionary中的位置
 *
 *  @return Key Path
 */
- (NSString *)modelObjectKeyPath;

/**
 *  指定用于转换到mantleList中的类
 *
 *  @return Mantle的Class
 */
- (Class)modelObjectListClass;

/**
 *  objectList的键值映射
 *
 *  @return Key Path
 */
- (NSString *)modelObjectListKeyPath;


// ----------------
// 完全自定义的相关方法
// ----------------

/**
 *  接口请求成功的处理
 *
 */
- (void)requestOpertaionSuccess:(NSURLSessionDataTask *)task responseObject:(id)responseObject;

/**
 *  接口请求失败的处理
 *
 */
- (void)requestOperationFailure:(NSURLSessionDataTask *)task error:(NSError *)error;

@end

NS_ASSUME_NONNULL_END

