//
//  UITests.m
//  UITests
//
//  Created by Ivan Oschepkov on 28/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "UITests-Swift.h"

//#import <HSTestingBackchannel/HSTestingBackchannel.h>

@interface UITests : XCTestCase

@end

@implementation UITests

- (void)setUp {
    [super setUp];
    self.continueAfterFailure = NO;
    XCUIApplication *app = [XCUIApplication new];
    [Snapshot setLanguage: app];
    [app launch];
}

- (void)testTakeScreenshots {
    
    XCUIApplication *app = [XCUIApplication new];
    
//    [HSTestingBackchannel sendNotification:@"SnapshotTest"];
    
    [Snapshot snapshot:@"0SignIn" waitForLoadingIndicator:YES];
}

@end
