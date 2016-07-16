//
//  GQMantleAdapter.h
//  Pods
//
//  Created by QianGuoqiang on 16/7/12.
//
//

#import "GQModelAdapter.h"
#import <Mantle/Mantle.h>
#import "GQDataController.h"

@interface GQMantleAdapter : NSObject <GQModelAdapter>

@end

@interface GQDataController (GQMantleAdapter)

- (__kindof MTLModel *)mantleObject;

- (NSMutableArray<__kindof MTLModel *> *)mantleObjectList;

@end

