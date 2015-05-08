//
//  GQDataController.m
//  GQDataController
//
//  Created by 钱国强 on 14-5-25.
//  Copyright (c) 2014年 Qian GuoQiang. All rights reserved.
//

#import "GQDataController.h"
#import <AFNetworking/AFNetworking.h>

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
        NSLog(@"%@", operation);
        NSLog(@"%@", responseObject);
        
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
    
    if ([method isEqualToString:@"GET"]) {
        [self.requestOperationManager GET:urlString
                               parameters:[self buildRequestArgs:params]
                                  success:successBlock
                                  failure:failureBlock];
    }
}


#pragma mark - Abstract method

- (NSString *)requestMethod
{
    return @"GET";
}

- (NSDictionary *)defaultParams
{
    return nil;
}

- (NSArray *)requestURL
{
    return nil;
}

- (BOOL)isValideWithObject:(id)object
{
    return YES;
}

#pragma mark - 

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
