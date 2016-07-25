//
//  GQYYModelAdapter.m
//  
//
//  Created by 钱国强 on 16/7/17.
//
//

#import "GQYYModelAdapter.h"

@interface GQYYModelAdapter ()

@property (nonatomic, strong) id object;

@property (nonatomic, copy) NSArray *objectList;

@end

@implementation GQYYModelAdapter

- (instancetype)initWithJSONObject:(id)jsonObject modelClass:(Class)modelClass
{
    self = [super init];
    
    if (self) {
        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            
#if GQYYModelHasPrefix
            self.object = [modelClass yy_modelWithDictionary:jsonObject];
#else
            self.object = [modelClass modelWithDictionary:jsonObject];
#endif
            
            
        } else if ([jsonObject isKindOfClass:[NSArray class]]) {

#if GQYYModelHasPrefix
            self.objectList = [NSArray yy_modelArrayWithClass:modelClass json:jsonObject];
#else
            self.objectList = [NSArray modelArrayWithClass:modelClass json:jsonObject];
#endif
            
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
