//
//  GQDataControllerDemoTests.m
//  GQDataControllerDemoTests
//
//  Created by 钱国强 on 15/5/16.
//  Copyright (c) 2015年 Qian GuoQiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>

#import "MantleSimpleDataController.h"
#import "BasicDataController.h"


@interface GQDataControllerDemoTests : XCTestCase

@property (nonatomic, strong) BasicDataController *basicDataController;

@property (nonatomic, strong) MantleSimpleDataController *mantleSimpleDataController;

@end

@implementation GQDataControllerDemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.basicDataController = [[BasicDataController alloc] init];
    
    self.mantleSimpleDataController = [[MantleSimpleDataController alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testsharedInstance {
    XCTAssertEqual([BasicDataController sharedDataController], [BasicDataController sharedDataController]);
}

- (void)testCopy
{
    self.basicDataController.requestSuccessBlock = ^(void){};
    self.basicDataController.requestFailureBlock = ^(NSError *error){};
    self.basicDataController.logBlock = ^(NSString *log){};
    
    BasicDataController *another = [self.basicDataController copy];
    
    XCTAssertNotEqual(self.basicDataController, another, @"应该不是相同的地址");
    
    XCTAssertNotNil(another.requestSuccessBlock, @"属性没有复制成功");
    XCTAssertNotNil(another.requestFailureBlock, @"属性没有复制成功");
    XCTAssertNotNil(another.logBlock, @"属性没有复制成功");
}

- (void)testMantleObjectListKeyPath
{
    XCTAssertEqualObjects(self.mantleSimpleDataController.mantleObjectListKeyPath, self.mantleSimpleDataController.mantleObjectKeyPath, @"mantleObjectListKeyPath默认返回mantleObjectKeyPath");
}

- (void)testMantleListModelClass
{
    XCTAssertEqual(self.mantleSimpleDataController.mantleListModelClass, self.mantleSimpleDataController.mantleModelClass, @"mantleListModelClass默认返回mantleModelClass");
}

- (void)testRequestOperationFailureError
{
    id operation = OCMClassMock([AFHTTPRequestOperation class]);
    id error = OCMClassMock([NSError class]);
    id delegate = OCMProtocolMock(@protocol(GQDataControllerDelegate));
    
    self.mantleSimpleDataController.delegate = delegate;
    
    [self.mantleSimpleDataController requestOperationFailure:operation error:error];
    
    OCMVerify([error localizedDescription]);
    
    OCMVerify([delegate dataController:self.mantleSimpleDataController didFailWithError:error]);
}


@end
