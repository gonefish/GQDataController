//
//  GQDataControllerDemoTests.m
//  GQDataControllerDemoTests
//
//  Created by 钱国强 on 15/5/16.
//  Copyright (c) 2015年 Qian GuoQiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "GQTestDataController.h"


@interface GQDataControllerDemoTests : XCTestCase

@end

@implementation GQDataControllerDemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testsharedInstance {
    XCTAssertEqual([GQTestDataController sharedDataController], [GQTestDataController sharedDataController]);
}


@end
