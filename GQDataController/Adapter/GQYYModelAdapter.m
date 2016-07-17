//
//  GQYYModelAdapter.m
//  
//
//  Created by 钱国强 on 16/7/17.
//
//

#import "GQYYModelAdapter.h"

@interface GQYYModelAdapter ()

@property (nonatomic, copy) NSDictionary *object;

@property (nonatomic, copy) NSArray *objectList;

@end

@implementation GQYYModelAdapter

- (instancetype)initWithJSONObject:(id)jsonObject modelClass:(Class)modelClass
{
    self = [super init];
    
    if (self) {
        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            
            self.object = [modelClass yy_modelWithDictionary:jsonObject];
            
        } else if ([jsonObject isKindOfClass:[NSArray class]]) {
            
            self.objectList = [NSArray yy_modelArrayWithClass:modelClass json:jsonObject];
            
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
