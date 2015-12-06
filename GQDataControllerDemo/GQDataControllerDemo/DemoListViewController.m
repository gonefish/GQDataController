//
//  DemoListViewController.m
//  GQDataControllerDemo
//
//  Created by 钱国强 on 15/12/3.
//  Copyright © 2015年 Qian GuoQiang. All rights reserved.
//

#import "DemoListViewController.h"

@interface DemoListViewController ()

@property (nonatomic, copy) NSArray *classNameList;

@end

@implementation DemoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.classNameList = @[@"BasicViewController",
                           @"BlockViewController",
                           @"MantleViewController",
                           @"DataSourceViewController",
                           @"",
                           @"StubViewController"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSString *className = [self.classNameList objectAtIndex:indexPath.row];
    
    UIViewController *vc = [[NSClassFromString(className) alloc] init];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    vc.title = cell.textLabel.text;
    
    [self.navigationController pushViewController:vc animated:YES];
}



@end
