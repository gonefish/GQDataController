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

/**
 *  将要数据加载
 *
 */
- (void)dataControllerWillStartLoading:(GQDataController *)controller;

/**
 *  数据加载成功
 *
 */
- (void)dataControllerDidFinishLoading:(GQDataController *)controller;

/**
 *  数据加载失败
 *
 */
- (void)dataController:(GQDataController *)controller didFailWithError:(NSError *)error;


@end