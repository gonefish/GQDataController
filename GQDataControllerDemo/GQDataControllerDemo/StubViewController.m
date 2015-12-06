//
//  StubViewController.m
//  GQDataControllerDemo
//
//  Created by 钱国强 on 15/12/7.
//  Copyright © 2015年 Qian GuoQiang. All rights reserved.
//

#import "StubViewController.h"
#import "StubDataController.h"

@interface StubViewController () <GQDataControllerDelegate>

@property (nonatomic, strong) StubDataController *stubDataController;

@property (nonatomic, weak) IBOutlet UILabel *label;

@end

@implementation StubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.stubDataController == nil) {
        self.stubDataController = [[StubDataController alloc] initWithDelegate:self];
    }
    
    [self.stubDataController request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dataControllerDidFinishLoading:(GQDataController *)controller
{
    self.label.text = [NSString stringWithFormat:@"IP: %@", self.stubDataController.ip];
    
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
