//
//  GQDataController.h
//  GQDataController
//
//  Created by 钱国强 on 14-5-25.
//  Copyright (c) 2014年 Qian GuoQiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GQDataControllerDelegate.h"

typedef void (^GQTableViewCellConfigureBlock)(UITableViewCell *cell, id cellModel);

typedef void (^GQCOllectionViewCellConfigureBlock)(UICollectionViewCell *cell, id cellModel);

@interface GQDataController : NSObject

@property (nonatomic, weak) id <GQDataControllerDelegate> delegate;

@property (nonatomic, weak) id <UITableViewDataSource> tableViewDataSource;

@property (nonatomic, copy) GQTableViewCellConfigureBlock tableViewCellConfigureBlock;

@property (nonatomic, weak) id <UICollectionViewDataSource> collectionViewDataSource;

@property (nonatomic, copy) GQCOllectionViewCellConfigureBlock collectionCellConfigureBlock;

@property (nonatomic, strong, readonly) id detailObject;

@property (nonatomic, strong, readonly) NSArray *listObjects;

+ (instancetype)sharedDataController;

- (void)request;

- (void)requestWithParams:(nonnull NSDictionary *)params;

// Subclass Require Method

- (nonnull NSString *)requestMethod;

- (nonnull NSArray *)requestURL;

@end


