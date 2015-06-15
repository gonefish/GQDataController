//
//  ViewController.m
//  GQDataControllerDemo
//
//  Created by 钱国强 on 15/5/16.
//  Copyright (c) 2015年 Qian GuoQiang. All rights reserved.
//

#import "ViewController.h"
#import "GQTestDataController.h"

@interface ViewController () <GQDataControllerDelegate>

@property (nonatomic, strong) GQTestDataController *testDataController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.testDataController = [GQTestDataController new];
    self.testDataController.delegate = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.testDataController requestWithParams:@{@"foo": @"bar"}];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)dataControllerBindingTarget:(GQDataController *)controller
{
    return self;
}

- (NSDictionary *)dataControllerBindingKeyPaths:(GQDataController *)controller
{
    return @{@"ipLabel.text" : @"mantleObject.origin"};
    
//    return @{@"ipLabel.text" : @"ip"};
}

@end
