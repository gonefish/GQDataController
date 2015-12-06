//
//  MantleViewController.m
//  GQDataControllerDemo
//
//  Created by 钱国强 on 15/12/6.
//  Copyright © 2015年 Qian GuoQiang. All rights reserved.
//

#import "MantleViewController.h"
#import "MantleSimpleDataController.h"
#import "MantleComplexDataController.h"

@interface MantleViewController () <GQDataControllerDelegate>

@property (nonatomic, strong) MantleSimpleDataController *mantleSimpleDataController;

@property (nonatomic, strong) MantleComplexDataController *mantleComplexDataController;

@property (nonatomic, weak) IBOutlet UILabel *ipLabel;

@property (nonatomic, weak) IBOutlet UILabel *userAgentLabel;

@end

@implementation MantleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    __weak __typeof(self) weakSelf = self;
    
    if (self.mantleSimpleDataController == nil) {
        self.mantleSimpleDataController = [[MantleSimpleDataController alloc] initWithDelegate:self];
    }
    
    [self.mantleSimpleDataController requestWithParams:nil success:^{
        IP *ip = weakSelf.mantleSimpleDataController.mantleObject;
        
        weakSelf.ipLabel.text = [NSString stringWithFormat:@"IP: %@", ip.origin];
        
        
    } failure:^(NSError * _Nullable error) {
        
    }];
    
    if (self.mantleComplexDataController == nil) {
        self.mantleComplexDataController = [[MantleComplexDataController alloc] initWithDelegate:self];
    }
    
    [self.mantleComplexDataController requestWithParams:nil success:^{
        Header *header = weakSelf.mantleComplexDataController.mantleObject;
        
        weakSelf.userAgentLabel.text = [NSString stringWithFormat:@"User-Agent: %@", header.userAgent];
        
        
    } failure:^(NSError * _Nullable error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
