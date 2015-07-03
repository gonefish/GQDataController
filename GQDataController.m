//
//  GQDataController.m
//  GQDataController
//
//  Created by 钱国强 on 14-5-25.
//  Copyright (c) 2014年 Qian GuoQiang. All rights reserved.
//

#import "GQDataController.h"
#import <AFNetworking/AFNetworking.h>
#import <FormatterKit/TTTURLRequestFormatter.h>

static void *GQReverseBindingContext = &GQReverseBindingContext;

static void *GQBindingContext = &GQBindingContext;

@interface GQDataController ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *requestOperationManager;

@property (nonatomic, copy) NSDictionary *reverseBindingKeyPaths;

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
            aController.requestOperationManager.operationQueue.maxConcurrentOperationCount = 1;
            
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
    // 1. 生成URL
    NSString *urlString = nil;
    
    NSString *localResponseFilename = [self localResponseFilename];
    
    if (localResponseFilename) {
        NSMutableArray *components = [[localResponseFilename componentsSeparatedByString:@"."] mutableCopy];
        
        NSString *type = [components lastObject];
        [components removeLastObject];
        NSString *resource = [components componentsJoinedByString:@"."];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:resource
                                                         ofType:type];
        
        if (path) {
            urlString = [[NSURL fileURLWithPath:path] absoluteString];
        }
    }
    
    if (urlString ==  nil) {
        NSArray *URLs = [self requestURLStrings];
        
        NSAssert([URLs isKindOfClass:[NSArray class]], @"Must be a NSArray");
        
        if ([URLs count] < 1) {
            return;
        }
        
        urlString = URLs[0];
    }
    
    // 2. 生成request
    NSString *method = [self requestMethod];
    
    __weak GQDataController *weakSelf = self;
    
    void (^successBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject){
        [weakSelf requestOpertaionSuccess:operation
                           responseObject:responseObject];
    };
    
    void (^failureBlock)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error){
        [weakSelf requestOperationFailure:operation
                                    error:error];
    };
    
    AFHTTPRequestOperation *operation = nil;
    
    NSString *newURLString = [self URLStringWithURLString:urlString params:params];
    
    if ([self.delegate respondsToSelector:@selector(dataControllerWillStartLoading:)]) {
        [self.delegate dataControllerWillStartLoading:self];
    }
    
    if ([method isEqualToString:@"GET"]) {
        operation = [self.requestOperationManager GET:newURLString
                                           parameters:params
                                              success:successBlock
                                              failure:failureBlock];
    } else if ([method isEqualToString:@"POST"]) {
        operation = [self.requestOperationManager POST:newURLString
                                            parameters:params
                                               success:successBlock
                                               failure:failureBlock];
    }
    
    [self logWithString:[TTTURLRequestFormatter cURLCommandFromURLRequest:operation.request]];
}


#pragma mark - Custom Method



- (void)requestOpertaionSuccess:(NSOperation *)operation responseObject:(id)responseObject
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
            [self.delegate dataController:self didFailWithError:nil];
        }
    }
}

- (void)requestOperationFailure:(NSOperation *)operation error:(NSError *)error
{
    [self logWithString:[error localizedDescription]];
    
    if ([self.delegate respondsToSelector:@selector(dataController:didFailWithError:)]) {
        [self.delegate dataController:self didFailWithError:error];
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

- (NSString *)localResponseFilename
{
    return nil;
}

- (Class)mantleModelClass
{
    return Nil;
}

- (NSString *)mantleObjectKeyPath
{
    return nil;
}

#pragma mark - Private

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
            
            // 添加目标到本地的属性绑定
            
        }
        
        self.reverseBindingKeyPaths = reverseBindingKeyPaths;
    }
}

- (void)setDelegate:(id<GQDataControllerDelegate>)delegate
{
    _delegate = delegate;
    
    self.bindingTarget = delegate;
}

+ (NSString *)encodeURIComponent:(NSString *)string
{
	CFStringRef cfUrlEncodedString = CFURLCreateStringByAddingPercentEscapes(NULL,
																			 (CFStringRef)string,NULL,
																			 (CFStringRef)@"!#$%&'()*+,/:;=?@[]",
																			 kCFStringEncodingUTF8);
	
	NSString *urlEncoded = [NSString stringWithString:(__bridge NSString *)cfUrlEncodedString];
	
	CFRelease(cfUrlEncodedString);
	
	return urlEncoded;
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


@end
