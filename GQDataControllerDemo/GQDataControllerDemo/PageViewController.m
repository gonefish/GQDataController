//
//  PageViewController.m
//  GQDataControllerDemo
//
//  Created by 钱国强 on 15/12/8.
//  Copyright © 2015年 Qian GuoQiang. All rights reserved.
//

#import "PageViewController.h"
#import "PageDataController.h"

@interface PageViewController () <GQDataControllerDelegate>

@property (nonatomic, strong) PageDataController *pageDataController;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation PageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.pageDataController == nil) {
        self.pageDataController = [[PageDataController alloc] initWithDelegate:self];
    }
    
    self.tableView.dataSource = self.pageDataController;
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:self.pageDataController.cellIdentifier];
    
    self.pageDataController.tableViewCellConfigureBlock = ^(UITableViewCell *cell, MTLModel *model){
        
        cell.textLabel.text = [(AppInfo *)model trackName];
        
    };
    
    [self reset:nil];
}

- (IBAction)loadMore:(id)sender
{
    [self.pageDataController requestMoreWithPageName:@"p"];
}

- (IBAction)reset:(id)sender
{
    [self.pageDataController.mantleObjectList removeAllObjects];
    [self.tableView reloadData];
    
    [self.pageDataController requestWithParams:nil success:^{
        
        [self.tableView reloadData];
        
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
