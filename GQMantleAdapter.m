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

@property (nonatomic, copy) NSArray *mantleArray;

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
            
            _mantleArray = [MTLJSONAdapter modelsOfClass:modelClass
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

- (NSArray *)modelArray
{
    return self.mantleArray;
}

@end


