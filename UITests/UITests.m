//
//  UITests.m
//  UITests
//
//  Created by Ivan Oschepkov on 28/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "DoubleB-swift.h"

@interface UITests : XCTestCase

@end

@implementation UITests

- (void)setUp {
    [super setUp];
    self.continueAfterFailure = NO;
    XCUIApplication *app = [XCUIApplication new];
    [Snapshot setLanguage: app]
                            
                            
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testScreenshotsMake {
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.buttons[@"OK"] tap];
    
    XCUIElementQuery *tablesQuery = app.tables;
    [[[tablesQuery.cells containingType:XCUIElementTypeStaticText identifier:@"\U041a\U0430\U043f\U0443\U0447\U0438\U043d\U043e"] childrenMatchingType:XCUIElementTypeButton].element tap];
    
    XCUIElement *staticText = app.images.staticTexts[@"100 rub."];
    [staticText tap];
    [[[tablesQuery.cells containingType:XCUIElementTypeStaticText identifier:@"\U041b\U0430\U0442\U0442\U0435"] childrenMatchingType:XCUIElementTypeButton].element tap];
    [staticText tap];
    
    XCUIElement *button = [[app.navigationBars[@"Menu"] childrenMatchingType:XCUIElementTypeButton] elementBoundByIndex:1];
    [button tap];
    [app.alerts[@"\U201cT-App (auto)\U201d Would Like to Send You Notifications"].collectionViews.buttons[@"OK"] tap];
    // Failed to find matching element please file bug (bugreport.apple.com) and provide output from Console.app
    
    XCUIElementQuery *scrollViewsQuery = app.scrollViews;
    XCUIElementQuery *elementsQuery = scrollViewsQuery.otherElements;
    [elementsQuery.staticTexts[@"Refill"] tap];
    
    XCUIElementQuery *tablesQuery2 = tablesQuery;
    [tablesQuery2.staticTexts[@"\U041a\U0430\U043f\U0443\U0447\U0438\U043d\U043e"] tap];
    [[[[app.navigationBars[@"\U041a\U0430\U043f\U0443\U0447\U0438\U043d\U043e"] childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0] tap];
    [button tap];
    [elementsQuery.staticTexts[@"\U041a\U0440\U0430\U0441\U043d\U043e\U0441\U0435\U043b\U044c\U0441\U043a\U0430\U044f"] tap];
    [app.alerts[@"Allow \U201cT-App (auto)\U201d to access your location even when you are not using the app?"].collectionViews.buttons[@"Allow"] tap];
    [tablesQuery2.staticTexts[@"\U041a\U0440\U0430\U0441\U043d\U043e\U0441\U0435\U043b\U044c\U0441\U043a\U0430\U044f"] tap];
    
    XCUIElement *button2 = [[[scrollViewsQuery.otherElements containingType:XCUIElementTypeImage identifier:@"venue"] childrenMatchingType:XCUIElementTypeButton] elementBoundByIndex:1];
    [button2 tap];
    [button2 tap];
    
}

@end
