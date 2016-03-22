//
//  GQDynamicDataControllerTests.m
//  GQDataControllerDemo
//
//  Created by 钱国强 on 16/3/22.
//  Copyright © 2016年 Qian GuoQiang. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <GQDataController/GQDynamicDataController.h>


@interface GQDynamicDataControllerTests : XCTestCase

@end

@implementation GQDynamicDataControllerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDataControllerWithURLString {
    GQDynamicDataController *test = [GQDynamicDataController dataControllerWithURLString:@"http://httpbin.org/ip"];
    
    XCTAssertEqualObjects([test requestURLStrings], @[@"http://httpbin.org/ip"], @"");
    XCTAssertEqualObjects([test requestMethod], @"GET", @"");
}

- (void)testDataControllerWithURLStringRequestMethod {
    
    GQDynamicDataController *test = [GQDynamicDataController dataControllerWithURLString:@"http://httpbin.org/ip" requestMethod:@"POST"];
    
    XCTAssertEqualObjects([test requestURLStrings], @[@"http://httpbin.org/ip"], @"");
    XCTAssertEqualObjects([test requestMethod], @"POST", @"");
}


@end
