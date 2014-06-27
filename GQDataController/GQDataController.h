//
//  GQDataController.h
//  GQDataController
//
//  Created by 钱国强 on 14-5-25.
//  Copyright (c) 2014年 Qian GuoQiang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GQDataControllerDelegate.h"

@interface GQDataController : NSObject

@property (nonatomic, strong) id detailObject;

@property (nonatomic, strong) NSArray *listObjects;

@property (nonatomic, weak) id <GQDataControllerDelegate> delegate;

@property (nonatomic, weak) id <UITableViewDataSource> tableViewDataSource;

+ (instancetype)sharedDataController;

+ (void)requestWithURL:(NSURL *)aURL complate:(void (^)(void))block;

- (instancetype)initWithDelegate:(id <GQDataControllerDelegate>)aDelegate;

- (void)requestWithArgs:(NSDictionary *)args;

- (BOOL)parseContent:(NSString *)content;

@end


