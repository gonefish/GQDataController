//
//  GQSQLiteProtocolTests.m
//  GQDataControllerDemo
//
//  Created by QianGuoqiang on 16/8/3.
//  Copyright © 2016年 Qian GuoQiang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <GQDataController/GQSQLiteProtocol.h>

@interface GQSQLiteProtocolTests : XCTestCase

@end

@implementation GQSQLiteProtocolTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testQueryDBWithURL {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    NSURL *url = [NSURL sqliteURLWithDatabaseName:@"db.sqlite" sql:@"SELECT * FROM user_info"];
    
    GQSQLiteProtocol *protocol = [[GQSQLiteProtocol alloc] init];
    
    NSArray *test = [protocol performSelector:@selector(queryDBWithURL:) withObject:url];
    
    XCTAssertTrue([test count] == 2);
    
    NSDictionary *item = [test objectAtIndex:0];
    
    XCTAssertTrue([item[@"age"] isKindOfClass:[NSNumber class]]);
    XCTAssertTrue([item[@"userID"] isKindOfClass:[NSNumber class]]);
    XCTAssertTrue([item[@"firstname"] isKindOfClass:[NSString class]]);
    XCTAssertTrue([item[@"lastname"] isKindOfClass:[NSString class]]);
    
}

- (void)testSqliteURLWithDatabaseNameSql
{
    NSString *databaseName = @"db.sqlite";
    NSString *sql = @"SELECT * FROM user_info";
    
    NSURL *url = [NSURL sqliteURLWithDatabaseName:databaseName sql:sql];
    
    XCTAssertEqualObjects(url.scheme, @"gqsqlite");
    
    NSString *databaseFilePath = [[NSBundle mainBundle] pathForResource:[databaseName stringByDeletingPathExtension]
                                                                 ofType:[databaseName pathExtension]];
    
    XCTAssertEqualObjects(url.path, databaseFilePath);
    
    XCTAssertEqualObjects(url.gq_sql, sql);
    
    
    
    
}


@end
