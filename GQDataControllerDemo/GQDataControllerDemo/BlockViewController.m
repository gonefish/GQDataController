//
//  BlockViewController.m
//  GQDataControllerDemo
//
//  Created by 钱国强 on 15/12/6.
//  Copyright © 2015年 Qian GuoQiang. All rights reserved.
//

#import "BlockViewController.h"
#import "BasicDataController.h"

@interface BlockViewController () <GQDataControllerDelegate>

@property (nonatomic, strong) BasicDataController *basicDataController;

@property (nonatomic, weak) IBOutlet UILabel *label;

@end

@implementation BlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    __weak __typeof(self) weakSelf = self;
    
    if (self.basicDataController == nil) {
//        self.basicDataController = [[BasicDataController alloc] initWithDelegate:self];
        
        self.basicDataController = [[BasicDataController alloc] initWithSuccessBlock:^(__kindof GQDataController * _Nonnull controller) {
            
            weakSelf.label.text = [NSString stringWithFormat:@"IP: %@", self.basicDataController.ip];
            
            NSLog(@"Block Style");
            
        } failureBlock:^(__kindof GQDataController * _Nonnull controller, NSError * _Nullable error) {
            
        } completedBlock:^(__kindof GQDataController * _Nonnull controller) {
            
            NSLog(@"Block completed");
            
        }];
    }
    
    
//    [self.basicDataController requestWithParams:nil success:^(BasicDataController *controller) {
//        weakSelf.label.text = [NSString stringWithFormat:@"IP: %@", self.basicDataController.ip];
//        
//        NSLog(@"Block Style");
//        
//    } failure:^(BasicDataController *controller, NSError * _Nullable error) {
//        
//    }];
    
    [self.basicDataController request];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dataControllerDidFinishLoading:(GQDataController *)controller
{
    self.label.text = [NSString stringWithFormat:@"IP: %@", self.basicDataController.ip];
    
    NSLog(@"Delegate Style");
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
