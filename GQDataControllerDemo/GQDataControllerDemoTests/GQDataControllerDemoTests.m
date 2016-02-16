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

#import "IP.h"
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
    XCTAssertEqual([BasicDataController sharedDataController], [BasicDataController sharedDataController], @"单例");
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

- (void)testRequest
{
    id partialMock = OCMPartialMock(self.basicDataController);
    
    [(BasicDataController *)partialMock request];
    
    OCMVerify([partialMock requestWithParams:nil]);
}

- (void)testRequestWithParams
{
    BasicDataController *partialMock = OCMPartialMock(self.basicDataController);
    
    [partialMock requestWithParams:nil];
    
    OCMVerify([partialMock requestWithParams:nil success:nil failure:nil]);
}

- (void)testQuestWithParamsSuccessFailure
{
//    BasicDataController *partialMock = OCMPartialMock(self.basicDataController);
//    
//    GQPagination *pagination = [GQPagination paginationWithPageIndexName:@"page"
//                                                            pageSizeName:@"size"];
//    
//    XCTAssertEqual(pagination.paginationMode, GQPaginationModeReplace);
//    
//    pagination.paginationMode = GQPaginationModeInsert;
//    
//    partialMock.pagination = pagination;
//    
//    [partialMock requestWithParams:nil success:nil failure:nil];
//    
//    XCTAssertEqual(pagination.paginationMode, GQPaginationModeReplace);
//    XCTAssertEqual(pagination.currentPageIndex, 1);
}

- (void)testRequestOperationFailureError
{
    id delegate = OCMProtocolMock(@protocol(GQDataControllerDelegate));
    self.mantleSimpleDataController.delegate = delegate;
    
    id operation = OCMClassMock([AFHTTPRequestOperation class]);
    
    id error = OCMClassMock([NSError class]);
    
    OCMStub([error code]).andReturn(0);
    
    self.mantleSimpleDataController.requestFailureBlock = ^(NSError *error) {
        NSLog(@"%@", @([error code]));
    };
    
    [self.mantleSimpleDataController requestOperationFailure:operation error:error];
    
    OCMVerify([error localizedDescription]);
    
    OCMVerify([delegate dataController:self.mantleSimpleDataController didFailWithError:error]);
    
    OCMVerify([error code]);
}

- (void)testHandleWithObject
{
    MantleSimpleDataController *mockDataController = OCMPartialMock(self.mantleSimpleDataController);
    
    [mockDataController handleWithObject:@{@"origin" : @"127.0.0.1"}];
    
    XCTAssertEqualObjects([(IP *)mockDataController.mantleObject origin], @"127.0.0.1");
    
    [mockDataController handleWithObject:@[@{@"origin" : @"127.0.0.1"}]];
    
    XCTAssertEqualObjects([(IP *)[mockDataController.mantleObjectList firstObject] origin], @"127.0.0.1");
}

- (void)testHandleWithObject2
{
    MantleSimpleDataController *mockDataController = OCMPartialMock(self.mantleSimpleDataController);
    OCMStub([mockDataController mantleObjectKeyPath]).andReturn(@"data");
    
    [mockDataController handleWithObject:@{@"data" : @{@"origin" : @"127.0.0.1"}}];
    
    XCTAssertEqualObjects([(IP *)mockDataController.mantleObject origin], @"127.0.0.1");
    
    [mockDataController handleWithObject:@{@"data" : @[@{@"origin" : @"127.0.0.1"}]}];
    
    XCTAssertEqualObjects([(IP *)[mockDataController.mantleObjectList firstObject] origin], @"127.0.0.1");
}

- (void)testRequestMore
{
//    BasicDataController *mockDataController = OCMPartialMock(self.basicDataController);
//    
//    GQPagination *pagination = [GQPagination paginationWithPageIndexName:@"page"
//                                                            pageSizeName:@"size"];
//    
//    XCTAssertEqual(pagination.paginationMode, GQPaginationModeReplace);
//    
//    mockDataController.pagination = pagination;
//    
//    [mockDataController requestMore];
//    
//    XCTAssertEqual(mockDataController.pagination.paginationMode, GQPaginationModeInsert);
}

- (void)testRequestOpertaionSuccessResponseObjectIsValid
{
    BasicDataController *mockDataController = OCMPartialMock(self.basicDataController);
    id operation = OCMClassMock([AFHTTPRequestOperation class]);
    
    id delegate = OCMProtocolMock(@protocol(GQDataControllerDelegate));
    mockDataController.delegate = delegate;
    
    NSString *foo = @"foo";
    
    mockDataController.requestSuccessBlock = ^{
        XCTAssertEqualObjects(@"foo", foo);
    };
    
    [mockDataController requestOpertaionSuccess:operation responseObject:@{}];
    
    OCMVerify([mockDataController isValidWithObject:[OCMArg any]]);
    
    OCMVerify([mockDataController handleWithObject:[OCMArg any]]);
    
    OCMVerify([delegate dataControllerDidFinishLoading:[OCMArg any]]);
}

- (void)testRequestOpertaionSuccessResponseObjectIsInvalid
{
    BasicDataController *mockDataController = OCMPartialMock(self.basicDataController);
    
    id delegate = OCMProtocolMock(@protocol(GQDataControllerDelegate));
    mockDataController.delegate = delegate;
    
    id operation = OCMClassMock([AFHTTPRequestOperation class]);
    
    OCMStub([mockDataController isValidWithObject:[OCMArg any]]).andReturn(NO);
    
    mockDataController.requestFailureBlock = ^(NSError *error) {
        XCTAssertTrue([error.domain isEqualToString:GQDataControllerErrorDomain]);
    };
    
    [mockDataController requestOpertaionSuccess:operation responseObject:@{}];
    
    OCMVerify([delegate dataController:[OCMArg any] didFailWithError:[OCMArg any]]);
    
    OCMVerify([mockDataController isValidWithObject:[OCMArg any]]);
}

@end
