//
//  BasicViewController.m
//  GQDataControllerDemo
//
//  Created by 钱国强 on 15/12/5.
//  Copyright © 2015年 Qian GuoQiang. All rights reserved.
//

#import "BasicViewController.h"
#import "BasicDataController.h"

@interface BasicViewController () <GQDataControllerDelegate>

@property (nonatomic, strong) BasicDataController *basicDataController;

@property (nonatomic, weak) IBOutlet UILabel *label;

@end

@implementation BasicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.basicDataController == nil) {
        self.basicDataController = [[BasicDataController alloc] initWithDelegate:self];
    }
    
    [self.basicDataController request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dataControllerDidFinishLoading:(GQDataController *)controller
{
    self.label.text = [NSString stringWithFormat:@"IP: %@", self.basicDataController.ip];
    
}

@end
