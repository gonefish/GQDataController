//
//  DataSourceViewController.m
//  GQDataControllerDemo
//
//  Created by 钱国强 on 15/12/6.
//  Copyright © 2015年 Qian GuoQiang. All rights reserved.
//

#import "DataSourceViewController.h"
#import "DataSourceDataController.h"

@interface DataSourceViewController () <GQDataControllerDelegate>

@property (nonatomic, strong) DataSourceDataController *dataSourceDataController;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation DataSourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.dataSourceDataController == nil) {
        self.dataSourceDataController = [[DataSourceDataController alloc] initWithDelegate:self];
    }
    
    self.tableView.dataSource = self.dataSourceDataController;
    
    __weak __typeof(self) weakSelf = self;
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:self.dataSourceDataController.cellIdentifier];
    
    self.dataSourceDataController.tableViewCellConfigureBlock = ^(UITableViewCell *cell, MTLModel *model){
        
        cell.textLabel.text = [(AppInfo *)model trackName];
        
    };
    
    [self.dataSourceDataController requestWithParams:nil success:^(DataSourceDataController *controller){
        [weakSelf.tableView reloadData];
        
    } failure:^(DataSourceDataController *controller, NSError * _Nullable error) {
        
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
