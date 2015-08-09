//
//  GQDataController.m
//  GQDataController
//
//  Created by 钱国强 on 14-5-25.
//  Copyright (c) 2014年 Qian GuoQiang. All rights reserved.
//

#import "GQDataController.h"

static void *GQReverseBindingContext = &GQReverseBindingContext;

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

@end

@implementation GQDataController

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
    [self removeBindingObserver];
}

#pragma mark - Public 

- (void)request
{
    [self requestWithParams:nil];
}

- (void)requestWithParams:(NSDictionary *)params
{
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

#pragma mark - Custom Method


- (void)requestOpertaionSuccess:(AFHTTPRequestOperation *)operation responseObject:(id)responseObject
{
    if ([self isValidWithObject:responseObject]) {
        
        Class mantleModelClass = [self mantleModelClass];
        
        // 是否启用Mantle
        if (mantleModelClass != Nil) {
            if ([responseObject isKindOfClass:[NSArray class]]) {
                [self handleMantleObjectListWithResponseObject:responseObject];
                
            } else if ([responseObject isKindOfClass:[NSDictionary class]]) {
                id jsonModel = [self mantleJSONWithResponseObject:responseObject];
                
                if ([jsonModel isKindOfClass:[NSArray class]]) {
                    
                    [self handleMantleObjectListWithResponseObject:jsonModel];
                    
                } else if ([jsonModel isKindOfClass:[NSDictionary class]]) {
                    self.mantleObject = [MTLJSONAdapter modelOfClass:mantleModelClass
                                                  fromJSONDictionary:jsonModel
                                                               error:nil];
                }
            }
        } else {
            [self handleWithObject:responseObject];
        }
        
        if ([self.delegate respondsToSelector:@selector(dataControllerDidFinishLoading:)]) {
            [self.delegate dataControllerDidFinishLoading:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(dataController:didFailWithError:)]) {
            
            NSError *error = [NSError errorWithDomain:GQDataControllerErrorDomain
                                                 code:GQDataControllerErrorInvalidObject
                                             userInfo:@{ GQResponseObjectKey : responseObject }];
            
            [self.delegate dataController:self
                         didFailWithError:error];
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
}

- (NSString *)requestMethod
{
    return @"GET";
}

- (NSArray *)requestURLStrings
{
    return nil;
}

- (NSString *)URLStringWithURLString:(NSString *)urlString params:(NSDictionary *)params
{
    return urlString;
}

- (BOOL)isValidWithObject:(id)object
{
    return YES;
}

- (void)handleWithObject:(id)object
{
}


- (Class)mantleModelClass
{
    return Nil;
}

- (NSString *)mantleObjectKeyPath
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
        if (self.currentHTTPRequestOperation) {
            [self.currentHTTPRequestOperation cancel];
            self.currentHTTPRequestOperation = nil;
        }
        
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

- (void)handleMantleObjectListWithResponseObject:(id)responseObject
{
    Class mantleModelClass = [self mantleModelClass];
    
    NSArray *models = [MTLJSONAdapter modelsOfClass:mantleModelClass
                                      fromJSONArray:responseObject
                                              error:nil];
    
    if (models) {
        if (self.mantleObjectList == nil) {
            self.mantleObjectList = [models mutableCopy];
        } else {
            if ([self.delegate respondsToSelector:@selector(removeAllObjectsWhenAddMantleObjectList:)]) {
                if ([self.delegate removeAllObjectsWhenAddMantleObjectList:self]) {
                    [self.mantleObjectList removeAllObjects];
                }
            }
            
            [self.mantleObjectList addObjectsFromArray:models];
        }
    }
}

- (id)mantleJSONWithResponseObject:(id)responseObject
{
    NSString *keyPath = [self mantleObjectKeyPath];
    
    if (keyPath == nil) {
        return responseObject;
    } else {
        return [(NSDictionary *)responseObject valueForKeyPath:keyPath];
    }
}

- (void)setBindingKeyPaths:(NSDictionary *)bindingKeyPaths
{
    NSAssert([bindingKeyPaths isKindOfClass:[NSDictionary class]], @"Must be a NSDictionary");
    
    if ([_bindingKeyPaths isEqualToDictionary:bindingKeyPaths]) {
        return;
    } else {
        [self removeBindingObserver];
    }
    
    _bindingKeyPaths = [bindingKeyPaths copy];
    
    self.reverseBindingKeyPaths = nil;
    
    // 两个属性都有返回值时才有效
    if (self.bindingTarget
        && self.bindingKeyPaths) {
        
        // 反转键值对 用于快速调用target
        NSMutableDictionary *reverseBindingKeyPaths = [NSMutableDictionary dictionary];
        
        for (NSString *key in self.bindingKeyPaths) {
            // 添加本地向目标的属性绑定
            
            NSString *localBindingKeyPath = self.bindingKeyPaths[key];
            
            [self addObserver:self
                   forKeyPath:localBindingKeyPath
                      options:NSKeyValueObservingOptionNew
                      context:GQReverseBindingContext];
            
            // 检测之前是否存在绑定
            NSArray *bindingInfo = reverseBindingKeyPaths[localBindingKeyPath];
            
            if (bindingInfo == nil) {
                reverseBindingKeyPaths[localBindingKeyPath] = @[key];
            } else {
                reverseBindingKeyPaths[localBindingKeyPath] = [bindingInfo arrayByAddingObject:key];
            }
        }
        
        self.reverseBindingKeyPaths = reverseBindingKeyPaths;
    }
}

- (void)setDelegate:(id<GQDataControllerDelegate>)delegate
{
    _delegate = delegate;
    
    self.bindingTarget = delegate;
}

- (void)removeBindingObserver
{
    for (NSString *key in [self.bindingKeyPaths allKeys]) {
        [self removeObserver:self
                  forKeyPath:self.bindingKeyPaths[key]];
    }
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context == GQReverseBindingContext) {
        NSArray *reverseBindingKeyPaths = self.reverseBindingKeyPaths[keyPath];
        
        for (NSString *keyPath in reverseBindingKeyPaths) {
            [self.bindingTarget setValue:change[NSKeyValueChangeNewKey]
                              forKeyPath:keyPath];
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
