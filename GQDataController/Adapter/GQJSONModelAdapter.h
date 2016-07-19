//
//  GQJSONModelAdapter.h
//  GQDataControllerDemo
//
//  Created by 钱国强 on 16/7/17.
//  Copyright © 2016年 Qian GuoQiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GQModelAdapter.h"
#import "GQDataController.h"

#import <JSONModel/JSONModel.h>

@interface GQJSONModelAdapter : NSObject <GQModelAdapter>

@end

@interface GQDataController (GQJSONModelAdapter)

- (__kindof JSONModel *)jsonModelObject;

- (NSMutableArray<__kindof JSONModel *> *)jsonModelObjectList;

@end