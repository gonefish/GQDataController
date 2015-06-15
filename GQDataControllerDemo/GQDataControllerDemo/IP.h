//
//  IP.h
//  GQDataControllerDemo
//
//  Created by 钱国强 on 15/6/16.
//  Copyright (c) 2015年 Qian GuoQiang. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface IP : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString *origin;

@end
