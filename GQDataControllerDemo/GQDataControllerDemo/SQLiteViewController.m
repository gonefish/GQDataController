//
//  SQLiteViewController.m
//  GQDataControllerDemo
//
//  Created by QianGuoqiang on 16/8/3.
//  Copyright © 2016年 Qian GuoQiang. All rights reserved.
//

#import "SQLiteViewController.h"
#import "SQLiteDataController.h"

@interface SQLiteViewController () <GQDataControllerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *label;

@property (nonatomic, strong) SQLiteDataController *sqliteDataController;

@end

@implementation SQLiteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.sqliteDataController == nil) {
        self.sqliteDataController = [[SQLiteDataController alloc] initWithDelegate:self];
    }
    
    [self.sqliteDataController requestWithParams:@{@"tablename" : @"user_info"}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dataControllerDidFinishLoading:(GQDataController *)controller
{
    NSDictionary *info = [self.sqliteDataController.modelObjectList objectAtIndex:0];
    
    NSLog(@"%@", info[@"firstname"]);
    NSLog(@"%@", info[@"lastname"]);
    
    self.label.text = [NSString stringWithFormat:@"%@ %@", info[@"firstname"], info[@"lastname"]];
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
