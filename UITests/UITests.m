//
//  UITests.m
//  UITests
//
//  Created by Ivan Oschepkov on 28/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "UITests-Swift.h"

#import "HSTestingBackchannel/HSTestingBackchannel.h"


@interface UITests : XCTestCase

@end

@implementation UITests

- (void)setUp {
    [super setUp];
    self.continueAfterFailure = NO;
    XCUIApplication *app = [XCUIApplication new];
    app.launchEnvironment = @{@"UITest": @"1"};
    [Snapshot setLanguage: app];
    [app launch];
}

- (void)testTakeScreenshots {
    XCTestExpectation *expectation = [self expectationWithDescription:@"The request should successfully complete within the specific timeframe."];
    
    XCUIApplication *app = [XCUIApplication new];
    [Snapshot setLanguage:app];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HSTestingBackchannel sendNotification:@"UITestNotificationCategoriesScreen"];
        [Snapshot snapshot:@"0Categories" waitForLoadingIndicator:NO];
        
        [HSTestingBackchannel sendNotification:@"UITestNotificationPositionsScreen"];
        [Snapshot snapshot:@"1Positions" waitForLoadingIndicator:NO];
        
        [HSTestingBackchannel sendNotification:@"UITestNotificationPositionScreen"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [Snapshot snapshot:@"2Position" waitForLoadingIndicator:NO];
            
            [HSTestingBackchannel sendNotification:@"UITestNotificationOrderScreen"];
            [Snapshot snapshot:@"3Order" waitForLoadingIndicator:NO];
            
            [expectation fulfill];
            
        });
    });
    
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

@end
