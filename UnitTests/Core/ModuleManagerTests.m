//
//  ModuleManagerTests.m
//  
//
//  Created by Balaban Alexander on 19/08/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ModuleManager.h"

#import "Module.h"

@interface ModuleManagerTests : XCTestCase

@property (nonatomic, strong) ModuleManager *moduleManager;
@property (nonatomic, strong) NSMutableArray *modules;

@end

@implementation ModuleManagerTests

- (void)setUp {
    [super setUp];
    
    self.modules = [NSMutableArray new];
    Module *module1 = [[Module alloc] initWithOrderDict:@{@"order_dict1": @"simple", @"id1": @1} andCheckOrderDict:@{@"checkorder_dict": @"simple", @"id": @123}];
    [self.modules addObject:module1];
    Module *module2 = [[Module alloc] initWithOrderDict:@{@"order_dict2": @"simple1", @"id2": @2, @"ex": @"oh"} andCheckOrderDict:@{@"checkorder_dict1": @"simple"}];
    [self.modules addObject:module2];
    
    self.moduleManager = [ModuleManager sharedManager];
    [self.moduleManager addModule:module1];
    [self.moduleManager addModule:module2];
}

- (void)tearDown {
    [self.moduleManager cleanManager];
    [super tearDown];
}

- (void)testSingleton {
    XCTAssertEqual(self.moduleManager, [ModuleManager sharedManager], @"Wrong singletone implementation");
}

- (void)testModule {
    XCTAssertNotNil([self.moduleManager getModules]);
}

- (void)testAddModule {
    XCTAssertEqual(2, [[self.moduleManager getModules] count], @"Add module doesn't work");
}

- (void)testCleanManager {
    [self.moduleManager cleanManager];
    XCTAssertEqual(0, [[self.moduleManager getModules] count], @"NSArray modules is not empty");
}

- (void)testRemoveModule {
    [self.moduleManager removeModule:self.modules[0]];
    NSArray *modules = [self.moduleManager getModules];
    XCTAssertEqual(1, [modules count], @"Remove module doesn't work");
    XCTAssertEqual(self.modules[1], modules[0], @"Remove module method removed wrong object");
}

- (void)testGetOrderDictionary {
    NSDictionary *dictionary = [self.moduleManager getOrderParams];
    BOOL equals = [dictionary isEqualToDictionary:@{@"order_dict1": @"simple", @"id1": @1, @"order_dict2": @"simple1", @"id2": @2, @"ex": @"oh"}];
    XCTAssertTrue(equals, @"OrderParams dict is not valid");
}

- (void)testGetCheckOrderDictionary {
    NSDictionary *dictionary = [self.moduleManager getCheckOrderParams];
    BOOL equals = [dictionary isEqualToDictionary:@{@"checkorder_dict": @"simple", @"id": @123, @"checkorder_dict1": @"simple"}];
    XCTAssertTrue(equals, @"CheckOrderParams dict is not valid");
}

@end