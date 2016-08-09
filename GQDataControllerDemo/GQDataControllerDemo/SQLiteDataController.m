//
//  SQLiteDataController.m
//  GQDataControllerDemo
//
//  Created by QianGuoqiang on 16/8/3.
//  Copyright © 2016年 Qian GuoQiang. All rights reserved.
//

#import "SQLiteDataController.h"

@implementation SQLiteDataController

- (NSArray *)requestURLStrings
{
    // NSString *url = [NSString sqliteURLStringWithDatabaseName:@"db.sqlite" sql:@"SELECT * FROM user_info"];
    NSString *url = [NSString sqliteURLStringWithDatabaseName:@"db.sqlite" sql:@"SELECT * FROM {{tablename}}"];
    
    return @[url];
}

@end
