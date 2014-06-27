//
//  GQDataControllerDelegate.h
//  GQDataController
//
//  Created by 钱国强 on 14/6/19.
//  Copyright (c) 2014年 Qian GuoQiang. All rights reserved.
//

@class GQDataController;

@protocol GQDataControllerDelegate <NSObject>

@optional
//数据请求成功
- (void)loadingDataFinished:(GQDataController *)controller;

//数据请求失败
- (void)loadingData:(GQDataController *)controller failedWithError:(NSError *)error;

@end