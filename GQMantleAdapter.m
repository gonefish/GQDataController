//
//  GQMantleAdapter.m
//  Pods
//
//  Created by QianGuoqiang on 16/7/12.
//
//

#import "GQMantleAdapter.h"

@interface GQMantleAdapter ()

@property (nonatomic, strong) MTLModel *mantleObject;

@property (nonatomic, copy) NSArray *mantleObjectArray;

@property (nonatomic, strong) NSError *error;

@end

@implementation GQMantleAdapter

- (instancetype)initWithJSONObject:(id)jsonObject modelClass:(Class)modelClass
{
    self = [super init];
    
    if (self) {
        NSError *error;
        
        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            
            _mantleObject = [MTLJSONAdapter modelOfClass:modelClass
                                      fromJSONDictionary:jsonObject
                                                   error:&error];
            
        } else if ([jsonObject isKindOfClass:[NSArray class]]) {
            
            _mantleObjectArray = [MTLJSONAdapter modelsOfClass:modelClass
                                           fromJSONArray:jsonObject
                                                   error:&error];
        }
        
        _error = error;
        
    }
    
    return self;
}

- (id)modelObject
{
    return self.mantleObject;
}

- (NSArray *)modelObjectList
{
    return self.mantleObjectArray;
}

@end


@implementation GQDataController (GQMantleAdapter)

- (__kindof MTLModel *)mantleObject
{
    NSAssert([self.modelObject isKindOfClass:[MTLModel class]], @"Must be a MTLModel instance.");
    
    return self.modelObject;
}

- (NSMutableArray<__kindof MTLModel *> *)mantleObjectList
{
    return self.modelObjectList;
}


@end

