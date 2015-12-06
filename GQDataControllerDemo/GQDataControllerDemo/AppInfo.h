//
//  AppInfo.h
//  GQDataControllerDemo
//
//  Created by 钱国强 on 15/12/6.
//  Copyright © 2015年 Qian GuoQiang. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface AppInfo : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *trackName;

@property (nonatomic, copy) NSString *artworkUrl100;

@end
