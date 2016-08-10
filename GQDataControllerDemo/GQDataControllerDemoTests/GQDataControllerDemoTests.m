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
    self.basicDataController.requestSuccessBlock = ^(GQDataController *controller){};
    self.basicDataController.requestFailureBlock = ^(GQDataController *controller, NSError *error){};
    self.basicDataController.logBlock = ^(NSString *log){};
    
    BasicDataController *another = [self.basicDataController copy];
    
    XCTAssertNotEqual(self.basicDataController, another, @"应该不是相同的地址");
    
    XCTAssertNotNil(another.requestSuccessBlock, @"属性没有复制成功");
    XCTAssertNotNil(another.requestFailureBlock, @"属性没有复制成功");
    XCTAssertNotNil(another.logBlock, @"属性没有复制成功");
}

- (void)testMantleObjectListKeyPath
{
    XCTAssertEqualObjects(self.mantleSimpleDataController.modelObjectListKeyPath, self.mantleSimpleDataController.modelObjectListKeyPath, @"mantleObjectListKeyPath默认返回mantleObjectKeyPath");
}

- (void)testMantleListModelClass
{
    XCTAssertEqual(self.mantleSimpleDataController.modelObjectListClass, self.mantleSimpleDataController.modelObjectClass, @"mantleListModelClass默认返回mantleModelClass");
}

- (void)testRequest
{
    id partialMock = OCMPartialMock(self.basicDataController);
    
    [(BasicDataController *)partialMock request];
    
    OCMVerify([partialMock requestWithParams:nil]);
}

- (void)testRequestWithParamsSuccessFailure
{
    BasicDataController *partialMock = OCMPartialMock(self.basicDataController);
    
    [partialMock requestWithParams:nil success:^(GQDataController *controller){
        
    } failure:^(GQDataController *controller, NSError * _Nullable error) {
        
    }];
    
    XCTAssertNotNil(partialMock.requestSuccessBlock);
    XCTAssertNotNil(partialMock.requestFailureBlock);
    
    [partialMock requestWithParams:nil success:nil failure:nil];
    
    XCTAssertNil(partialMock.requestSuccessBlock);
    XCTAssertNil(partialMock.requestFailureBlock);
}

- (void)testRequestMore
{
    BasicDataController *mockDataController = OCMPartialMock(self.basicDataController);
    
    [mockDataController requestMore];
    
    OCMVerify([mockDataController requestWithParams:[OCMArg any]]);
    
}

- (void)testRequestOperationFailureError
{
    id delegate = OCMProtocolMock(@protocol(GQDataControllerDelegate));
    self.mantleSimpleDataController.delegate = delegate;
    
    id operation = OCMClassMock([NSURLSessionDataTask class]);
    
    id error = OCMClassMock([NSError class]);
    
    OCMStub([error code]).andReturn(0);
    
    self.mantleSimpleDataController.requestFailureBlock = ^(GQDataController *controller, NSError *error) {
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
    
    [mockDataController handleWithJSONObject:@{@"origin" : @"127.0.0.1"}];
    
    XCTAssertEqualObjects([(IP *)mockDataController.modelObject origin], @"127.0.0.1");
    
    [mockDataController handleWithJSONObject:@[@{@"origin" : @"127.0.0.1"}]];
    
    XCTAssertEqualObjects([(IP *)[mockDataController.modelObjectList firstObject] origin], @"127.0.0.1");
}

- (void)testHandleWithObject2
{
    MantleSimpleDataController *mockDataController = OCMPartialMock(self.mantleSimpleDataController);
    OCMStub([mockDataController modelObjectKeyPath]).andReturn(@"data");
    
    [mockDataController handleWithJSONObject:@{@"data" : @{@"origin" : @"127.0.0.1"}}];
    
    XCTAssertEqualObjects([(IP *)mockDataController.modelObject origin], @"127.0.0.1");
    
    [mockDataController handleWithJSONObject:@{@"data" : @[@{@"origin" : @"127.0.0.1"}]}];
    
    XCTAssertEqualObjects([(IP *)[mockDataController.modelObjectList firstObject] origin], @"127.0.0.1");
}


- (void)testRequestOpertaionSuccessResponseObjectIsValid
{
    BasicDataController *mockDataController = OCMPartialMock(self.basicDataController);
    id task = OCMClassMock([NSURLSessionDataTask class]);
    
    id delegate = OCMProtocolMock(@protocol(GQDataControllerDelegate));
    mockDataController.delegate = delegate;
    
    NSString *foo = @"foo";
    
    mockDataController.requestSuccessBlock = ^(GQDataController *controller){
        XCTAssertEqualObjects(@"foo", foo);
    };
    
    [mockDataController requestOpertaionSuccess:task responseObject:@{}];
    
    OCMVerify([mockDataController isValidWithJSONObject:[OCMArg any]]);
    
    OCMVerify([mockDataController handleWithJSONObject:[OCMArg any]]);
    
    OCMVerify([delegate dataControllerDidFinishLoading:[OCMArg any]]);
}

- (void)testRequestOpertaionSuccessResponseObjectIsInvalid
{
    BasicDataController *mockDataController = OCMPartialMock(self.basicDataController);
    
    id delegate = OCMProtocolMock(@protocol(GQDataControllerDelegate));
    mockDataController.delegate = delegate;
    
    id task = OCMClassMock([NSURLSessionDataTask class]);
    
    OCMStub([mockDataController isValidWithJSONObject:[OCMArg any]]).andReturn(NO);
    
    mockDataController.requestFailureBlock = ^(GQDataController *controller, NSError *error) {
        XCTAssertTrue([error.domain isEqualToString:GQDataControllerErrorDomain]);
    };
    
    [mockDataController requestOpertaionSuccess:task responseObject:@{}];
    
    OCMVerify([delegate dataController:[OCMArg any] didFailWithError:[OCMArg any]]);
    
    OCMVerify([mockDataController isValidWithJSONObject:[OCMArg any]]);
}

@end
