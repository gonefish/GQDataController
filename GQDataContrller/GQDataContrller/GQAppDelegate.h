//
//  GQAppDelegate.h
//  GQDataContrller
//
//  Created by 钱国强 on 12-12-9.
//  Copyright (c) 2012年 gonefish@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GQDemoDataController.h"

@interface GQAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) GQDemoDataController *dataController;

@end
