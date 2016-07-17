//
//  GQJSONModelAdapter.m
//  GQDataControllerDemo
//
//  Created by 钱国强 on 16/7/17.
//  Copyright © 2016年 Qian GuoQiang. All rights reserved.
//

#import "GQJSONModelAdapter.h"

@interface GQJSONModelAdapter ()

@property (nonatomic, strong) JSONModel *jsonModelObject;

@property (nonatomic, copy) NSArray *jsonModelObjectList;

@property (nonatomic, strong) NSError *error;

@end

@implementation GQJSONModelAdapter

- (instancetype)initWithJSONObject:(id)jsonObject modelClass:(Class)modelClass
{
    self = [super init];
    
    if (self) {
        NSError *error;
        
        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            
            self.jsonModelObject = [[modelClass alloc] initWithDictionary:jsonObject error:&error];
            
        } else if ([jsonObject isKindOfClass:[NSArray class]]) {
            
            self.jsonModelObjectList = [JSONModel arrayOfModelsFromDictionaries:jsonObject error:&error];
            
        }
        
        _error = error;
        
    }
    
    return self;
}

- (id)modelObject
{
    return self.jsonModelObject;
}

- (NSArray *)modelObjectList
{
    return self.jsonModelObjectList;
}

@end
