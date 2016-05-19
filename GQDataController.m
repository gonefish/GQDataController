//
//  GQDataController.m
//  GQDataController
//
//  Created by 钱国强 on 14-5-25.
//  Copyright (c) 2014年 Qian GuoQiang. All rights reserved.
//

#import "GQDataController.h"

#if DEBUG
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OHHTTPStubs/OHPathHelpers.h>
#endif

NSString * const GQDataControllerErrorDomain = @"GQDataControllerErrorDomain";

const NSInteger GQDataControllerErrorInvalidObject = 1;

NSString * const GQResponseObjectKey = @"GQResponseObjectKey";

@interface GQDataController ()

@property (nonatomic, strong) AFHTTPSessionManager *httpSessionManager;

/**
 *  当前请求的Task
 */
@property (nonatomic, strong) NSURLSessionDataTask *URLSessionDataTask;

/**
 *  请求参数备份
 */
@property (nonatomic, copy) NSDictionary *requestParams;

/**
 *  接口请求重试计数
 */
@property (nonatomic) NSUInteger requestCount;


#if DEBUG
@property (nonatomic, strong) id<OHHTTPStubsDescriptor> HTTPStubsDescriptor;
#endif

@property (nonatomic, copy) id responseObject;

@end

@implementation GQDataController

- (id)copyWithZone:(NSZone *)zone
{
    GQDataController *copy = [[[self class] allocWithZone:zone] initWithDelegate:self.delegate];
    
    copy.requestSuccessBlock = self.requestSuccessBlock;
    copy.requestFailureBlock = self.requestFailureBlock;
    copy.logBlock = self.logBlock;
    
    return copy;
}

+ (instancetype)sharedDataController
{
    static dispatch_once_t onceToken;
    static NSMutableDictionary *sharedInstances = nil;
    static NSLock *sharedLock = nil;
    
    dispatch_once(&onceToken, ^{
        sharedInstances = [NSMutableDictionary dictionary];
        sharedLock = [[NSLock alloc] init];
    });
    
    NSString *keyName = NSStringFromClass([self class]);
    GQDataController *aController = nil;
    
    if ([sharedLock tryLock]) {
        aController = [sharedInstances objectForKey:keyName];
        
        if (aController == nil) {
            aController = [[self alloc] init];
            
            [sharedInstances setObject:aController
                                forKey:keyName];
        }
        
        [sharedLock unlock];
    }
    
    return aController;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _httpSessionManager = [[AFHTTPSessionManager alloc] init];
        
        [(AFJSONResponseSerializer *)[_httpSessionManager responseSerializer] setRemovesKeysWithNullValues:YES];
        
        _cellIdentifier = NSStringFromClass([self class]);
        
#if DEBUG
        NSString *localJSONName = [NSString stringWithFormat:@"%@.json", NSStringFromClass([self class])];
        
        _HTTPStubsDescriptor = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            for (NSString *urlString in [self requestURLStrings]) {
                
                if ([request.URL.absoluteString hasPrefix:urlString]) {
                    NSString *path = OHPathForFileInBundle(localJSONName, [NSBundle mainBundle]);
                    
                    // 路径匹配和存在本地结果文件时才返回
                    if (path) {
                        return YES;
                    }
                }
            }
            
            return NO;
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            // 读取本地JSON $className.json
            NSString *path = OHPathForFileInBundle(localJSONName, [NSBundle mainBundle]);
            
            return [OHHTTPStubsResponse responseWithFileAtPath:path
                                                    statusCode:200
                                                       headers:@{@"Content-Type":@"application/json"}];
        }];
#endif
    }
    
    return self;
}

- (instancetype)initWithDelegate:(id <GQDataControllerDelegate>)aDelegate
{
    self = [self init];
    
    if (self) {
        _delegate = aDelegate;
    }
    
    return self;
}


- (void)dealloc
{
#if DEBUG
    if (self.HTTPStubsDescriptor) {
        [OHHTTPStubs removeStub:self.HTTPStubsDescriptor];
    }
#endif
}

#pragma mark - Public 

- (void)request
{
    [self requestWithParams:nil];
}

- (void)requestWithParams:(NSDictionary *)params
{
    [self requestWithParams:params success:nil failure:nil];
}

- (void)requestWithParams:(NSDictionary *)params
                  success:(GQRequestSuccessBlock)success
                  failure:(GQRequestFailureBlock)failure
{
    if (success) {
        self.requestSuccessBlock = success;
    }
    
    if (failure) {
        self.requestFailureBlock = failure;
    }
    
    [self requestWithParams:params isRetry:NO];
}

- (void)requestMore
{
    NSString *pageName = [self pageParameterName];
    
    NSMutableDictionary *newParams = [self.requestParams mutableCopy];
    
    if (newParams == nil) {
        newParams = [NSMutableDictionary dictionary];
    }
    
    if (pageName) {
        if ([newParams objectForKey:pageName]) {
            newParams[pageName] = @([[newParams objectForKey:pageName] integerValue] + 1);
        } else {
            newParams[pageName] = @(1);
        }
    }
    
    // 默认插入模式
    self.mantleObjectListUpdateStyle = GQMantleObjectListUpdateInsert;
    
    [self requestWithParams:newParams];
}

- (void)cancelRequest
{
    if (self.URLSessionDataTask) {
        [self.URLSessionDataTask cancel];
        self.URLSessionDataTask = nil;
        
        if ([self.delegate respondsToSelector:@selector(dataControllerDidCancelLoading:)]) {
            [self.delegate dataControllerDidCancelLoading:self];
        }
    }
}

#pragma mark - Custom Method


- (void)requestOpertaionSuccess:(NSURLSessionDataTask *)task responseObject:(id)responseObject
{
    self.responseObject = responseObject;
    
    if ([self isValidWithObject:responseObject]) {
        
        [self handleWithObject:responseObject];
        
        if ([self.delegate respondsToSelector:@selector(dataControllerDidFinishLoading:)]) {
            [self.delegate dataControllerDidFinishLoading:self];
        }
        
        if (self.requestSuccessBlock) {
            self.requestSuccessBlock();
        }
    } else {
        NSError *error = nil;
        
        if (responseObject) {
            error = [NSError errorWithDomain:GQDataControllerErrorDomain
                                        code:GQDataControllerErrorInvalidObject
                                    userInfo:@{ GQResponseObjectKey : responseObject }];
        }
        
        if ([self.delegate respondsToSelector:@selector(dataController:didFailWithError:)]) {
            [self.delegate dataController:self
                         didFailWithError:error];
        }
        
        if (self.requestFailureBlock) {
            self.requestFailureBlock(error);
        }
    }
}

- (void)requestOperationFailure:(NSURLSessionDataTask *)task error:(NSError *)error
{
    [self logWithObject:[error localizedDescription]];
    
    if ([self.delegate respondsToSelector:@selector(dataController:didFailWithError:)]) {
        [self.delegate dataController:self
                     didFailWithError:error];
    }
    
    if (self.requestFailureBlock) {
        self.requestFailureBlock(error);
    }
}

- (NSString *)requestMethod
{
    return @"GET";
}

- (NSArray<NSString *> *)requestURLStrings
{
    return nil;
}

- (NSString *)pageParameterName
{
    return @"p";
}

- (BOOL)isValidWithObject:(id)object
{
    return YES;
}

- (void)handleWithObject:(id)object
{
    // 默认实现对Mantle的支持
    Class mantleModelClass = [self mantleModelClass];
    
    if (mantleModelClass != Nil) {
        [self handleMantleWithObject:object];
    }
}

- (void)handleMantleWithObject:(id)object
{
    // 处理mantleObjectKeyPath
    NSString *objectKeyPath = [self mantleObjectKeyPath];
    
    id mantleObjectJSON = object;
    
    if (objectKeyPath) { // 允许自定义转换的JSON节点
        mantleObjectJSON = [object valueForKeyPath:objectKeyPath];
    }
    
    if ([mantleObjectJSON isKindOfClass:[NSDictionary class]]
        && [self mantleModelClass] != Nil) {
        
        [self handleMantleObjectWithDictionary:mantleObjectJSON];
    }
    
    // 处理mantleObjectListKeyPath
    NSString *objectListKeyPath = [self mantleObjectListKeyPath];
    
    id mantleObjectListJSON = object;
    
    if (objectListKeyPath) { // 允许自定义转换的JSON节点
        mantleObjectListJSON = [object valueForKeyPath:objectListKeyPath];
    }
    
    if ([mantleObjectListJSON isKindOfClass:[NSArray class]]
        && [self mantleListModelClass] != Nil) {
        [self handleMantleObjectListWithArray:mantleObjectListJSON
                                  mantleClass:[self mantleListModelClass]];
    }
}

- (Class)mantleModelClass
{
    return Nil;
}

- (Class)mantleListModelClass
{
    return [self mantleModelClass];
}

- (NSString *)mantleObjectKeyPath
{
    return nil;
}

- (NSString *)mantleObjectListKeyPath
{
    return [self mantleObjectKeyPath];
}

#pragma mark - Private

- (void)requestWithParams:(NSDictionary *)params isRetry:(BOOL)retry
{
    if (retry == NO) {
        // 如果不是重试，则重置状态
        [self cancelRequest];
        
        self.requestParams = params;
        self.requestCount = 0;
    }
    
    // 1. 生成URL
    NSString *urlString = nil;
    
    NSArray *URLs = [self requestURLStrings];
    
    NSAssert([URLs isKindOfClass:[NSArray class]], @"Must be a NSArray");
    
    if ([URLs count] < 1) {
        return;
    }
    
    urlString = URLs[self.requestCount];
    
    // 2. 生成request
    NSString *method = [self requestMethod];
    
    __weak __typeof(self)weakSelf = self;
    
    void (^successBlock)(NSURLSessionDataTask *, id) = ^(NSURLSessionDataTask *task, id responseObject){
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        [strongSelf requestOpertaionSuccess:task
                             responseObject:responseObject];
        
        strongSelf.requestCount = 0;
    };
    
    void (^failureBlock)(NSURLSessionDataTask *, NSError *) = ^(NSURLSessionDataTask *task, NSError *error){
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (strongSelf.requestCount + 1 < [[strongSelf requestURLStrings] count]) {
            // 开始重试
            strongSelf.requestCount++;
            
            [strongSelf requestWithParams:strongSelf.requestParams
                                  isRetry:YES];
        } else {
            [strongSelf requestOperationFailure:task
                                          error:error];
        }
    };
    
    if ([self.delegate respondsToSelector:@selector(dataControllerWillStartLoading:)]) {
        [self.delegate dataControllerWillStartLoading:self];
    }
    
    if ([method isEqualToString:@"GET"]) {
        
        self.URLSessionDataTask = [self.httpSessionManager GET:urlString
                                                    parameters:params
                                                      progress:nil
                                                       success:successBlock
                                                       failure:failureBlock];
        
    } else if ([method isEqualToString:@"POST"]) {
        
        self.URLSessionDataTask = [self.httpSessionManager POST:urlString
                                                     parameters:params
                                                       progress:nil
                                                        success:successBlock
                                                        failure:failureBlock];
        
    } else if ([method isEqualToString:@"PUT"]) {
        
        self.URLSessionDataTask = [self.httpSessionManager PUT:urlString
                                                    parameters:params
                                                       success:successBlock
                                                       failure:failureBlock];
        
    } else if ([method isEqualToString:@"PATCH"]) {
        
        self.URLSessionDataTask = [self.httpSessionManager PATCH:urlString
                                                      parameters:params
                                                         success:successBlock
                                                         failure:failureBlock];
        
    } else if ([method isEqualToString:@"DELETE"]) {
        
        self.URLSessionDataTask = [self.httpSessionManager DELETE:urlString
                                                       parameters:params
                                                          success:successBlock
                                                          failure:failureBlock];
        
    }
    
    [self.URLSessionDataTask resume];
    
    [self logWithObject:self.URLSessionDataTask.currentRequest];
}

- (void)logWithObject:(id)object
{
    if (self.logBlock) {
        self.logBlock(object);
    } else {
        NSString *fullLog = [NSString stringWithFormat:@"GQDataController: %@", object];
        
        NSLog(@"%@", fullLog);
    }
}

/**
 *  尝试将字典转换成指定的Mantle对象，并保存在mantleObject中
 *
 *  @param dictionary 转换的字典
 */
- (void)handleMantleObjectWithDictionary:(NSDictionary *)dictionary
{
    Class mantleModelClass = [self mantleModelClass];
    
    NSError *error;
    
    self.mantleObject = [MTLJSONAdapter modelOfClass:mantleModelClass
                                  fromJSONDictionary:dictionary
                                               error:&error];
    
    if (error) {
        [self logWithObject:[error localizedDescription]];
    }
}

/**
 *  尝试将数组转换成指定的Mantle列表，并保存在mantleObjectList中
 *
 *  @param array 转换的数组
 */
- (void)handleMantleObjectListWithArray:(NSArray *)array mantleClass:(Class)mantleClass
{
    NSError *error;
    
    NSArray *models = [MTLJSONAdapter modelsOfClass:mantleClass
                                      fromJSONArray:array
                                              error:&error];
    
    if (error) {
        [self logWithObject:[error localizedDescription]];
    }
    
    if (models) {
        if (self.mantleObjectListUpdateStyle == GQMantleObjectListUpdateInsert) {
            if (self.mantleObjectList == nil) {
                self.mantleObjectList = [models mutableCopy];
            } else {
                [self.mantleObjectList addObjectsFromArray:models];
            }
        } else if (self.mantleObjectListUpdateStyle == GQMantleObjectListUpdateReplace) {
            self.mantleObjectList = [models mutableCopy];
        }
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier
                                                            forIndexPath:indexPath];
    
    MTLModel *model = [self.mantleObjectList objectAtIndex:indexPath.row];
    
    if (self.tableViewCellConfigureBlock) {
        self.tableViewCellConfigureBlock(cell, model);
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.mantleObjectList count];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.mantleObjectList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    MTLModel *model = [self.mantleObjectList objectAtIndex:indexPath.row];
    
    if (self.collectionViewCellConfigureBlock) {
        self.collectionViewCellConfigureBlock(cell, model);
    }
    
    return cell;
}


@end
