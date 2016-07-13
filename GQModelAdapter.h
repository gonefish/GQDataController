//
//  GQModelAdapter.h
//  Pods
//
//  Created by QianGuoqiang on 16/7/13.
//
//

#import <Foundation/Foundation.h>

@protocol GQModelAdapter <NSObject>

- (instancetype)initWithJSONObject:(id)jsonObject modelClass:(Class)modelClass;

- (id)modelObject;

- (NSArray *)modelArray;

@optional

- (NSError *)error;

@end

