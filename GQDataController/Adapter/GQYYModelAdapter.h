//
//  GQYYModelAdapter.h
//  
//
//  Created by 钱国强 on 16/7/17.
//
//

#import <Foundation/Foundation.h>
#import "GQModelAdapter.h"


#if __has_include(<YYModel/YYModel.h>)
    #import <YYModel/YYModel.h>

    #define GQYYModelHasPrefix 1
#else
    #import <YYKit/NSObject+YYModel.h>

    #define GQYYModelHasPrefix 0
#endif

@interface GQYYModelAdapter : NSObject <GQModelAdapter>

@end
