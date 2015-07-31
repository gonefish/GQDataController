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

typedef void (^GQDataControllerLogBlock)(NSString *log);

@interface GQDataController : NSObject

@property (nonatomic, strong, readonly) AFHTTPRequestOperationManager *requestOperationManager;

@property (nonatomic, weak) id <GQDataControllerDelegate> delegate;

/**
 *  绑定的对象，默认与GQDataControllerDelegate相同
 */
@property (nonatomic, weak) id bindingTarget;

@property (nonatomic, copy) NSDictionary *bindingKeyPaths;

@property (nonatomic, strong) MTLModel <MTLJSONSerializing> *mantleObject;

@property (nonatomic, strong) NSMutableArray *mantleObjectList;

@property (nonatomic, copy) GQDataControllerLogBlock logBlock;


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
 *  调用requestWithParams:并传入nil
 */
- (void)request;

/**
 *  发起网络请求
 *
 *  @param params 请求的参数
 */
- (void)requestWithParams:(NSDictionary *)params;

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
- (NSArray *)requestURLStrings;


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

