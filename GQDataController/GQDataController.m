//
//  GQDataController.m
//  GQDataController
//
//  Created by 钱国强 on 14-5-25.
//  Copyright (c) 2014年 Qian GuoQiang. All rights reserved.
//

#import "GQDataController.h"
#import <AFNetworking/AFNetworking.h>

#define GQAppVersion @"gq_app_version"
#define GQDeviceMode @"gq_device_model"
#define GQDeviceVersion @"gq_device_version"
#define GQUserInterfaceIdiom @"gq_user_interface_idiom"
#define GQUserLanguage @"gq_user_language"

@implementation GQDataController

+ (instancetype)sharedDataController
{
    GQDataController *aController;
    static NSMutableDictionary *sharedInstances = nil;
    
    @synchronized(self)
    {
        if (sharedInstances == nil) {
            sharedInstances = [[NSMutableDictionary alloc] init];
        }
        
        NSString *keyName = NSStringFromClass([self class]);
        
        aController = [sharedInstances objectForKey:keyName];
        
        if (aController == nil) {
            aController = [[self alloc] init];
            
            [sharedInstances setObject:aController
                                forKey:keyName];
        }
    }
    
    return aController;
}

- (instancetype)initWithDelegate:(id <GQDataControllerDelegate>)aDelegate
{
    self = [super init];
    
    if (self) {
        self.delegate = aDelegate;
    }
    
    return self;
}

#pragma mark - Subclass implementation

- (NSString *)requestMethod
{
    return @"GET";
}

- (NSArray *)requestBaseURL
{
    // 子类自己实现
    NSAssert(NO, @"require implementation");
    
    return nil;
}

- (NSString *)requestPath
{
    // 子类自己实现
    NSAssert(NO, @"require implementation");
    
    return nil;
}

- (BOOL)addContextQueryString
{
    // 默认总是添加上下文参数
    return YES;
}

- (void)validate
{
    // 子类可以通过此方法来校验返回数据的完整性
}

#pragma mark - UITableViewDataSource

@end
