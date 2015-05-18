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
        
        if ([self customQueryString]) {
            __weak typeof(self) weakSelf = self;
            
            [_requestOperationManager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, id parameters, NSError *__autoreleasing *error) {
                
                return [weakSelf customQueryStringWithParams:parameters];
            }];
        }
    }
    
    return self;
}

- (instancetype)initWithDelegate:(id <GQDataControllerDelegate>)aDelegate
{
    self = [self init];
    
    if (self) {
        self.delegate = aDelegate;
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
        NSArray *URLs = [self requestURLs];
        
        NSAssert([URLs isKindOfClass:[NSArray class]], @"Must be a NSArray");
        
        if ([URLs count] < 1) {
            return;
        }
        
        urlString = [[self requestURLs] objectAtIndex:0];
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

- (NSString *)requestMethod
{
    return @"GET";
}

- (NSArray *)requestURLs
{
    return nil;
}

- (NSDictionary *)defaultParams
{
    return nil;
}

- (BOOL)isValidWithObject:(id)object
{
    return YES;
}

- (void)handleWithObject:(id)object
{
    NSLog(@"%@", object);
}

- (NSString *)localResponseFilename
{
    return nil;
}

- (BOOL)customQueryString
{
    return NO;
}

- (NSString *)customQueryStringWithParams:(NSDictionary *)params;
{
    return nil;
}

#pragma mark - Private

- (NSDictionary *)mergeDefaultParamsWithParams:(NSDictionary *)params
{
    NSMutableDictionary *defaultParams = [[self defaultParams] mutableCopy] ? : [NSMutableDictionary dictionary];
    
    [defaultParams addEntriesFromDictionary:params];
    
    return [defaultParams copy];
}

- (void)setDelegate:(id<GQDataControllerDelegate>)delegate
{
    // 如果设置delegate为nil 需要进行清理
    if (delegate == nil) {
        [self removeBindingObserver];
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

- (void)removeBindingObserver
{
    for (NSString *key in [self.bindingKeyPaths allKeys]) {
        [self removeObserver:self
                  forKeyPath:self.bindingKeyPaths[key]];
    }
    
    self.bindingKeyPaths = nil;
    self.bindingReverseKeyPaths = nil;
    self.bindingTarget = nil;
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
