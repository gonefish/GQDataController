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
            
            [sharedInstances setObject:aController
                                forKey:keyName];
        }
        
        [sharedLock unlock];
    }
    
    return aController;
}

+ (void)requestWithURLString:(NSString *)URLString completion:(void (^)(NSString *content))completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:URLString
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             if (completion) {
                 completion([operation responseString]);
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}

- (void)requestWithParams:(NSDictionary *)params completion:(void (^)(NSError *error))completion
{
    if (self.requestOperation) {
        [self.requestOperation cancel];
        self.requestOperation = nil;
    }
    
    if (self.requestOperationManager == nil) {
        self.requestOperationManager = [AFHTTPRequestOperationManager manager];
    }
    
    // 1. 生成URL
    NSString *urlString = [[self requestURL] objectAtIndex:0];
    
    // 2. 生成request
    NSString *method = [self requestMethod];
    
        void (^successBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject){
            NSLog(@"%@", operation);
            NSLog(@"%@", responseObject);
        };
        
        void (^failureBlock)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error){
            NSLog(@"%@", error);
        };
    
    if ([method isEqualToString:@"GET"]) {
        [self.requestOperationManager GET:urlString
                               parameters:[self buildRequestArgs:params]
                                  success:successBlock
                                  failure:failureBlock];
    }
    
    // 3. 发起request
}

- (NSURLRequest *)httpRequest
{
    return self.requestOperation.request;
}

- (NSHTTPURLResponse *)httpResponse
{
    return self.requestOperation.response;
}

#pragma mark - Abstract method

- (NSString *)requestMethod
{
    return @"GET";
}

- (NSArray *)requestURL
{
    return nil;
}

- (BOOL)parseContent:(NSString *)content
{
    return NO;
}

#pragma mark - 

- (NSDictionary *)buildRequestArgs:(NSDictionary *)params
{
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
