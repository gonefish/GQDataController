//
//  GQMantleAdapter.h
//  Pods
//
//  Created by QianGuoqiang on 16/7/12.
//
//

#import <Foundation/Foundation.h>
#import "GQModelAdapter.h"
#import "GQDataController.h"

#import <Mantle/Mantle.h>

@interface GQMantleAdapter : NSObject <GQModelAdapter>

@end


@interface GQDataController (GQMantleAdapter)

- (__kindof MTLModel *)mantleObject;

- (NSMutableArray<__kindof MTLModel *> *)mantleObjectList;

@end

