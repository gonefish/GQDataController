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

@interface GQDataController ()

@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;

@property (nonatomic, strong) AFHTTPRequestOperationManager *requestOperationManager;

@property (nonatomic, strong) id bindingTarget;

@property (nonatomic, copy) NSDictionary *bindingKeyPaths;

@property (nonatomic, copy) NSDictionary *bindingReverseKeyPaths;

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

- (void)dealloc
{
    for (NSString *key in [self.bindingKeyPaths allKeys]) {
        [self removeObserver:self
                  forKeyPath:self.bindingKeyPaths[key]];
    }
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
        urlString = [[self requestURL] objectAtIndex:0];
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
    
    NSDictionary *newParams = [self mergeDefaultParamsWithParams:params];
    
    if ([method isEqualToString:@"GET"]) {
        operation = [self.requestOperationManager GET:urlString
                                           parameters:newParams
                                              success:successBlock
                                              failure:failureBlock];
    } else if ([method isEqualToString:@"POST"]) {
        operation = [self.requestOperationManager POST:urlString
                                            parameters:newParams
                                               success:successBlock
                                               failure:failureBlock];
    }
    
    NSLog(@"GQDataController Debug: %@", [TTTURLRequestFormatter cURLCommandFromURLRequest:operation.request]);
}


#pragma mark - Custom Method

- (void)requestOpertaionSuccess:(NSOperation *)operation responseObject:(id)responseObject
{
    if ([self isValidWithObject:responseObject]) {
        [self handleWithObject:responseObject];
        
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
    NSLog(@"%@", error);
    
    if ([self.delegate respondsToSelector:@selector(dataController:didFailWithError:)]) {
        [self.delegate dataController:self didFailWithError:error];
    }
}

/**
 *  HTTP的Method
 */
- (NSString *)requestMethod
{
    return @"GET";
}

/**
 *  接口请求的地址，可以有多个用于备用重试
 *
 */
- (NSArray *)requestURL
{
    return nil;
}

/**
 *  默认参数
 */
- (NSDictionary *)defaultParams
{
    return nil;
}

/**
 *  检测返回的结果是否有效
 *
 */
- (BOOL)isValidWithObject:(id)object
{
    return YES;
}

/**
 *  处理结果的方法
 *
 */
- (void)handleWithObject:(id)object
{
    NSLog(@"%@", object);
}

/**
 *  本地响应文件，如果这个方法返回非nil且有效的路径，会从这个路径访问结果
 *
 */
- (NSString *)localResponseFilename
{
    return nil;
}

- (NSDictionary *)mergeDefaultParamsWithParams:(NSDictionary *)params
{
    NSMutableDictionary *defaultParams = [[self defaultParams] mutableCopy] ? : [NSMutableDictionary dictionary];
    
    [defaultParams addEntriesFromDictionary:params];
    
    return [defaultParams copy];
}

#pragma mark - Private

- (void)setDelegate:(id<GQDataControllerDelegate>)delegate
{
    // 如果设置delegate为nil 需要进行清理
    if (delegate == nil) {
        for (NSString *key in [self.bindingKeyPaths allKeys]) {
            [self removeObserver:self
                      forKeyPath:self.bindingKeyPaths[key]];
        }
        
        self.bindingKeyPaths = nil;
        self.bindingReverseKeyPaths = nil;
        self.bindingTarget = nil;
    }
    
    _delegate = delegate;
    
    if ([_delegate respondsToSelector:@selector(dataControllerBindingTarget:)]
        && [_delegate respondsToSelector:@selector(dataControllerBindingKeyPaths:)]) {
        
        id bindingTarget = [_delegate dataControllerBindingTarget:self];
        NSDictionary *bindingKeyPaths = [_delegate dataControllerBindingKeyPaths:self];
        
        // 两个方法都有返回值时才有效
        if (bindingTarget && bindingKeyPaths) {
            NSAssert([bindingKeyPaths isKindOfClass:[NSDictionary class]], @"Must be a NSDictionary");
            
            self.bindingTarget = bindingTarget;
            self.bindingKeyPaths = bindingKeyPaths;
            
            // 反转键值对 用于快速调用target
            NSMutableDictionary *bindingReverseKeyPaths = [NSMutableDictionary dictionary];
            
            for (NSString *key in [self.bindingKeyPaths allKeys]) {
                [self addObserver:self
                       forKeyPath:self.bindingKeyPaths[key]
                          options:NSKeyValueObservingOptionNew
                          context:NULL];
                
                bindingReverseKeyPaths[self.bindingKeyPaths[key]] = key;
            }
            
            self.bindingReverseKeyPaths = bindingReverseKeyPaths;
        }
    }
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

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    NSString *targetKeyPath = self.bindingReverseKeyPaths[keyPath];
    
    if (targetKeyPath) {
        [self.bindingTarget setValue:change[NSKeyValueChangeNewKey]
                          forKeyPath:targetKeyPath];
    }
}

#pragma mark - UITableViewDataSource

@end
