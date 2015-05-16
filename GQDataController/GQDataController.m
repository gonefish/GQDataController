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

- (void)request
{
    [self requestWithParams:nil];
}

- (void)requestWithParams:(NSDictionary *)params
{
    // 1. 生成URL
    NSString *urlString = [[self requestURL] objectAtIndex:0];
    
    // 2. 生成request
    NSString *method = [self requestMethod];
    
    __weak GQDataController *weakSelf = self;
    
    void (^successBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject){
        
        if ([weakSelf isValidWithObject:responseObject]) {
            [weakSelf handleWithObject:responseObject];
        } else {
            
        }
        
        if (weakSelf
            && weakSelf.delegate) {
            [weakSelf.delegate loadingDataFinished:weakSelf];
        }
    };
    
    void (^failureBlock)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"%@", error);
        
        if (weakSelf
            && weakSelf.delegate) {
            [weakSelf.delegate loadingData:weakSelf failedWithError:error];
        }
    };
    
    AFHTTPRequestOperation *operation = nil;
    
    if ([method isEqualToString:@"GET"]) {
        operation = [self.requestOperationManager GET:urlString
                               parameters:[self buildRequestArgs:params]
                                  success:successBlock
                                  failure:failureBlock];
    } else if ([method isEqualToString:@"POST"]) {
        
    }
    
    NSLog(@"%@", [TTTURLRequestFormatter cURLCommandFromURLRequest:operation.request]);
}


#pragma mark - Abstract method

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

#pragma mark - Private

- (NSDictionary *)buildRequestArgs:(NSDictionary *)params
{
    NSDictionary *defaultParams = [self defaultParams];
    
    if (defaultParams) {
        
    } else {
        
    }
    
    return @{};
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

#pragma mark - UITableViewDataSource

@end
