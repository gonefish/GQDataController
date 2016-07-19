//
//  GQMJExtensionAdapter.m
//  GQDataControllerDemo
//
//  Created by 钱国强 on 16/7/17.
//  Copyright © 2016年 Qian GuoQiang. All rights reserved.
//

#import "GQMJExtensionAdapter.h"

@interface GQMJExtensionAdapter ()

@property (nonatomic, strong) id object;

@property (nonatomic, copy) NSArray *objectList;

@end

@implementation GQMJExtensionAdapter

- (instancetype)initWithJSONObject:(id)jsonObject modelClass:(Class)modelClass
{
    self = [super init];
    
    if (self) {
        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            
            self.object = [modelClass mj_objectWithKeyValues:jsonObject];
            
        } else if ([jsonObject isKindOfClass:[NSArray class]]) {
            
            self.objectList = [modelClass mj_objectArrayWithKeyValuesArray:jsonObject];
            
        }
    }
    
    return self;
}

- (id)modelObject
{
    return self.object;
}

- (NSArray *)modelObjectList
{
    return self.objectList;
}

@end
