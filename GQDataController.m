//
//  GQDataController.m
//  GQDataController
//
//  Created by 钱国强 on 14-5-25.
//  Copyright (c) 2014年 Qian GuoQiang. All rights reserved.
//

#import "GQDataController.h"

#if QG_DEBUG
#import <OHHTTPStubs/OHHTTPStubs.h>
#endif

NSString * const GQDataControllerErrorDomain = @"GQDataControllerErrorDomain";

const NSInteger GQDataControllerErrorInvalidObject = 1;

NSString * const GQResponseObjectKey = @"GQResponseObjectKey";

@interface GQDataController ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *requestOperationManager;

@property (nonatomic, copy) NSDictionary *reverseBindingKeyPaths;

/**
 *  请求参数备份
 */
@property (nonatomic, copy) NSDictionary *requestParams;

/**
 *  接口请求重试计数
 */
@property (nonatomic) NSUInteger requestCount;

/**
 *  当前的请求
 */
@property (nonatomic, weak) AFHTTPRequestOperation *currentHTTPRequestOperation;

#if QG_DEBUG
@property (nonatomic, strong) id<OHHTTPStubsDescriptor> HTTPStubsDescriptor;
#endif

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
        _requestOperationManager = [AFHTTPRequestOperationManager manager];
        
        [(AFJSONResponseSerializer *)[_requestOperationManager responseSerializer] setRemovesKeysWithNullValues:YES];
        
        _currentPage = 1;
        
#if QG_DEBUG
        _HTTPStubsDescriptor = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            for (NSString *urlString in [self requestURLStrings]) {
                
                if ([request.URL.absoluteString hasPrefix:urlString]) {
                    NSString *path = OHPathForFileInBundle(NSStringFromClass([self class]), [NSBundle mainBundle]);
                    
                    // 路径匹配和存在本地结果文件时才返回
                    if (path) {
                        return YES;
                    }
                }
            }
            
            return NO;
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            // 读取本地JSON $className.json
            NSString *localJsonPath = [NSString stringWithFormat:@"%@.json", NSStringFromClass([self class])];
            
            NSString *path = OHPathForFileInBundle(localJsonPath, [NSBundle mainBundle]);
            
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
#if QG_QG_DEBUG
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
    self.requestSuccessBlock = success;
    self.requestFailureBlock = failure;
    
    NSNumber *page = params[[self pageParameterName]];
    
    if (page && [page isKindOfClass:[NSNumber class]]) {
        self.currentPage = [page integerValue];
    }
    
    [self requestWithParams:params isRetry:NO];
}

- (void)requestMore
{
    NSMutableDictionary *newParams = [self.requestParams mutableCopy];
    
    if ([self pageParameterName]) {
        [newParams setObject:@(++self.currentPage) forKey:[self pageParameterName]];
        
        [self requestWithParams:newParams isRetry:NO];
    }
}

- (void)cancelRequest
{
    if (self.currentHTTPRequestOperation) {
        [self.currentHTTPRequestOperation cancel];
        self.currentHTTPRequestOperation = nil;
    }
}

#pragma mark - Custom Method


- (void)requestOpertaionSuccess:(AFHTTPRequestOperation *)operation responseObject:(id)responseObject
{
    if ([self isValidWithObject:responseObject]) {
        
        // 在其它线程处理Model解析
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            Class mantleModelClass = [self mantleModelClass];
            
            // 是否启用Mantle
            if (mantleModelClass != Nil) {
                [self handleMantleWithObject:responseObject];
            } else {
                [self handleWithObject:responseObject];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(dataControllerDidFinishLoading:)]) {
                    [self.delegate dataControllerDidFinishLoading:self];
                }
                
                if (self.requestSuccessBlock) {
                    self.requestSuccessBlock();
                }
            });
        });
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

- (void)requestOperationFailure:(AFHTTPRequestOperation *)operation error:(NSError *)error
{
    [self logWithString:[error localizedDescription]];
    
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

- (NSArray *)requestURLStrings
{
    return nil;
}

- (BOOL)isValidWithObject:(id)object
{
    return YES;
}

- (void)handleWithObject:(id)object
{
    
}

- (void)handleMantleWithObject:(id)object
{
    NSString *objectKeyPath = [self mantleObjectKeyPath];
    
    NSString *objectListKeyPath = [self mantleObjectListKeyPath];
    
    // 处理mantleObjectKeyPath
    id mantleObjectJSON = object;
    
    if (objectKeyPath) { // 允许自定义转换的JSON节点
        mantleObjectJSON = [object valueForKeyPath:objectKeyPath];
    }
    
    if ([mantleObjectJSON isKindOfClass:[NSDictionary class]]) {
        
        [self handleMantleObjectWithDictionary:mantleObjectJSON];
        
    } else if ([mantleObjectJSON isKindOfClass:[NSArray class]] // 如果mantleObjectKeyPath是数组，并且mantleObjectListKeyPath为空时默认转换为List处理
               && objectListKeyPath == nil) {
        
        [self handleMantleObjectListWithArray:mantleObjectJSON];
        
    }
    
    // 处理mantleObjectListKeyPath
    id mantleObjectListJSON = object;
    
    if (objectListKeyPath) { // 允许自定义转换的JSON节点
        mantleObjectListJSON = [object valueForKeyPath:objectListKeyPath];
    }
    
    if ([mantleObjectListJSON isKindOfClass:[NSArray class]]) {
        [self handleMantleObjectListWithArray:mantleObjectListJSON];
    }
}

- (Class)mantleModelClass
{
    return Nil;
}

- (NSString *)mantleObjectKeyPath
{
    return nil;
}

- (NSString *)mantleObjectListKeyPath
{
    return nil;
}

- (NSString *)pageParameterName
{
    return @"page";
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
    
    __weak GQDataController *weakSelf = self;
    
    void (^successBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject){
        [weakSelf requestOpertaionSuccess:operation
                           responseObject:responseObject];
        
        weakSelf.requestCount = 0;
    };
    
    void (^failureBlock)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error){
        
        if (weakSelf.requestCount + 1 < [[weakSelf requestURLStrings] count]) {
            // 开始重试
            weakSelf.requestCount++;
            
            [weakSelf requestWithParams:weakSelf.requestParams
                                isRetry:YES];
        } else {
            [weakSelf requestOperationFailure:operation
                                        error:error];
        }
    };
    
    if ([self.delegate respondsToSelector:@selector(dataControllerWillStartLoading:)]) {
        [self.delegate dataControllerWillStartLoading:self];
    }
    
    if ([method isEqualToString:@"GET"]) {
        self.currentHTTPRequestOperation = [self.requestOperationManager GET:urlString
                                                                  parameters:params
                                                                     success:successBlock
                                                                     failure:failureBlock];
    } else if ([method isEqualToString:@"POST"]) {
        self.currentHTTPRequestOperation = [self.requestOperationManager POST:urlString
                                                                   parameters:params
                                                                      success:successBlock
                                                                      failure:failureBlock];
    } else if ([method isEqualToString:@"PUT"]) {
        self.currentHTTPRequestOperation = [self.requestOperationManager PUT:urlString
                                                                  parameters:params
                                                                     success:successBlock
                                                                     failure:failureBlock];
        
    } else if ([method isEqualToString:@"DELETE"]) {
        self.currentHTTPRequestOperation = [self.requestOperationManager DELETE:urlString
                                                                     parameters:params
                                                                        success:successBlock
                                                                        failure:failureBlock];
    }
    
    [self logWithString:[self.currentHTTPRequestOperation.request.URL absoluteString]];
}

- (void)logWithString:(NSString *)log
{
    NSString *fullLog = [NSString stringWithFormat:@"GQDataController: %@", log];
    
    if (self.logBlock) {
        self.logBlock(fullLog);
    } else {
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
    
    self.mantleObject = [MTLJSONAdapter modelOfClass:mantleModelClass
                                  fromJSONDictionary:dictionary
                                               error:nil];
}

/**
 *  尝试将数组转换成指定的Mantle列表，并保存在mantleObjectList中
 *
 *  @param array 转换的数组
 */
- (void)handleMantleObjectListWithArray:(NSArray *)array
{
    Class mantleModelClass = [self mantleModelClass];
    
    NSArray *models = [MTLJSONAdapter modelsOfClass:mantleModelClass
                                      fromJSONArray:array
                                              error:nil];
    
    if (models) {
        if (self.mantleObjectList == nil) {
            self.mantleObjectList = [models mutableCopy];
        } else {
            if ([self.delegate respondsToSelector:@selector(removeAllObjectsWhenAddMantleObjectList:)]) {
                if ([self.delegate removeAllObjectsWhenAddMantleObjectList:self]) {
                    [self.mantleObjectList removeAllObjects];
                }
            } else {
                // 当请求的分页为1时，隐式的移除数据
                if (self.currentPage == 1) {
                    [self.mantleObjectList removeAllObjects];
                }
            }
            
            [self.mantleObjectList addObjectsFromArray:models];
        }
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier
                                                            forIndexPath:indexPath];
    
    MTLModel *model = [self.mantleObjectList objectAtIndex:indexPath.row];
    
    self.tableViewCellConfigureBlock(cell, model);
    
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
    
    self.collectionViewCellConfigureBlock(cell, model);
    
    return cell;
}


@end
