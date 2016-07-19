//
//  GQModelAdapterTests.m
//  GQDataControllerDemo
//
//  Created by QianGuoqiang on 16/7/19.
//  Copyright © 2016年 Qian GuoQiang. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <GQDataController/GQMantleAdapter.h>
#import <GQDataController/GQJSONModelAdapter.h>
#import <GQDataController/GQYYModelAdapter.h>
#import <GQDataController/GQMJExtensionAdapter.h>

@interface TestMantleModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *show;

@end

@implementation TestMantleModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return nil;
}

@end

@interface TestJSONModel : JSONModel



@end

@implementation TestJSONModel

@end

@interface TestObjectModel : NSObject

@property (nonatomic, copy) NSString *show;

@end

@implementation TestObjectModel

@end

@interface GQModelAdapterTests : XCTestCase

@property (nonatomic, copy) NSDictionary *jsonObject;

@property (nonatomic, copy) NSArray *jsonArray;

@end

@implementation GQModelAdapterTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.jsonObject = @{@"show" : @"me"};
    
    self.jsonArray = @[self.jsonObject];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMantleAdapter
{
    GQMantleAdapter *adapter = [[GQMantleAdapter alloc] initWithJSONObject:self.jsonObject
                                                                modelClass:[TestMantleModel class]];
    
    XCTAssertTrue([[adapter modelObject] isKindOfClass:[TestMantleModel class]]);
    
    XCTAssertNil([adapter modelObjectList]);
}

- (void)testMantleAdapter2
{
    GQMantleAdapter *adapter = [[GQMantleAdapter alloc] initWithJSONObject:self.jsonArray
                                                                modelClass:[TestMantleModel class]];
    
    XCTAssertTrue([[adapter modelObjectList][0] isKindOfClass:[TestMantleModel class]]);
    
    XCTAssertNil([adapter modelObject]);
}

- (void)testJSONModelAdapter
{
    GQJSONModelAdapter *adapter = [[GQJSONModelAdapter alloc] initWithJSONObject:self.jsonObject modelClass:[TestJSONModel class]];
    
    XCTAssertTrue([[adapter modelObject] isKindOfClass:[TestJSONModel class]]);
    
    XCTAssertNil([adapter modelObjectList]);
}

- (void)testJSONModelAdapter2
{
    GQJSONModelAdapter *adapter = [[GQJSONModelAdapter alloc] initWithJSONObject:self.jsonArray modelClass:[TestJSONModel class]];
    
    XCTAssertTrue([[adapter modelObjectList][0] isKindOfClass:[TestJSONModel class]]);
    
    XCTAssertNil([adapter modelObject]);
}

- (void)testYYModelAdapter
{
    GQYYModelAdapter *adapter = [[GQYYModelAdapter alloc] initWithJSONObject:self.jsonObject modelClass:[TestObjectModel class]];
    
    XCTAssertTrue([[adapter modelObject] isKindOfClass:[TestObjectModel class]]);
    
    XCTAssertNil([adapter modelObjectList]);
}

- (void)testYYModelAdapter2
{
    GQYYModelAdapter *adapter = [[GQYYModelAdapter alloc] initWithJSONObject:self.jsonArray modelClass:[TestObjectModel class]];
    
    XCTAssertTrue([[adapter modelObjectList][0] isKindOfClass:[TestObjectModel class]]);
    
    XCTAssertNil([adapter modelObject]);
}

- (void)testMJExtensionAdapter
{
    GQMJExtensionAdapter *adapter = [[GQMJExtensionAdapter alloc] initWithJSONObject:self.jsonObject modelClass:[TestObjectModel class]];
    
    XCTAssertTrue([[adapter modelObject] isKindOfClass:[TestObjectModel class]]);
    
    XCTAssertNil([adapter modelObjectList]);
}

- (void)testMJExtensionAdapter2
{
    GQMJExtensionAdapter *adapter = [[GQMJExtensionAdapter alloc] initWithJSONObject:self.jsonArray modelClass:[TestObjectModel class]];
    
    XCTAssertTrue([[adapter modelObjectList][0] isKindOfClass:[TestObjectModel class]]);
    
    XCTAssertNil([adapter modelObject]);
}

@end
