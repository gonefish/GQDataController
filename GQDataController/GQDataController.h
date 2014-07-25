//
//  GQDataController.h
//  GQDataController
//
//  Created by 钱国强 on 14-5-25.
//  Copyright (c) 2014年 Qian GuoQiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GQDataController : NSObject

//@property (nonatomic, strong) id detailObject;

//@property (nonatomic, strong) NSArray *listObjects;


+ (instancetype)sharedDataController;

+ (void)requestWithURLString:(NSString *)URLString completion:(void (^)(NSString *content))completion;

- (void)requestWithParams:(NSDictionary *)params;

- (NSString *)requestMethod;

- (NSArray *)requestURL;

- (BOOL)parseContent:(NSString *)content;

@end


