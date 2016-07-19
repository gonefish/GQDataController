//
//  GQDefaultAdapter.m
//  Pods
//
//  Created by 钱国强 on 16/7/16.
//
//

#import "GQDefaultAdapter.h"

@interface GQDefaultAdapter ()

@property (nonatomic, copy) NSDictionary *object;

@property (nonatomic, copy) NSArray *objectList;

@end

@implementation GQDefaultAdapter

- (instancetype)initWithJSONObject:(id)jsonObject modelClass:(Class)modelClass
{
    self = [super init];
    
    if (self) {
        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            
            self.object = jsonObject;
            
        } else if ([jsonObject isKindOfClass:[NSArray class]]) {
            
            self.objectList = jsonObject;
            
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

