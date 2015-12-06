//
//  Header.h
//  GQDataControllerDemo
//
//  Created by 钱国强 on 15/12/6.
//  Copyright © 2015年 Qian GuoQiang. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface Header : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *userAgent;

@end
