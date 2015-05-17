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
 *  数据加载成功
 *
 */
- (void)dataControllerDidFinishLoading:(GQDataController *)controller;

/**
 *  数据加载失败
 *
 */
- (void)dataController:(GQDataController *)controller didFailWithError:(NSError *)error;

/**
 *  数据的绑定对象
 *
 */
- (id)dataControllerBindingTarget:(GQDataController *)controller;

/**
 *  数据的绑定的键值对 key为target的keyPath value为DataController的value
 *
 */
- (NSDictionary *)dataControllerBindingKeyPaths:(GQDataController *)controller;


@end