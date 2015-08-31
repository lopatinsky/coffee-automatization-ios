//
//  NetworkManagerTest.m
//  
//
//  Created by Balaban Alexander on 26/08/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "NetworkManager.h"

@interface NetworkManagerTest : XCTestCase

@property (nonatomic, strong) NetworkManager *networkManager;

@end

@implementation NetworkManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.networkManager = [NetworkManager sharedManager];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNetwortQueue {
    [self.networkManager addUniqueOperation:NetworkOperationFetchCompanies];
    [self.networkManager addUniqueOperation:NetworkOperationFetchCompanyInfo];
}

@end
