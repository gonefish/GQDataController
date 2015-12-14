//
//  GQPaginationTests.m
//  GQDataControllerDemo
//
//  Created by 钱国强 on 15/12/10.
//  Copyright © 2015年 Qian GuoQiang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <GQDataController/GQPagination.h>

@interface GQPaginationTests : XCTestCase

@end

@implementation GQPaginationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    GQPagination *p = [GQPagination paginationWithPageIndexName:@"page"
                                                   pageSizeName:@"size"];
    
    XCTAssertEqual(p.pageIndexName, @"page");
    XCTAssertEqual(p.pageSizeName, @"size");
    XCTAssertEqual(p.pageSize, 10);
    
}


@end
