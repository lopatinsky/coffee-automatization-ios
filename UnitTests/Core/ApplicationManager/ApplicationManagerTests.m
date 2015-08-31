//
//  ApplicationManagerTests.m
//  
//
//  Created by Balaban Alexander on 20/08/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ApplicationManager.h"

@interface ApplicationManagerTests : XCTestCase

@property (nonatomic, strong) NSString *documentsDirectory;

@end

@implementation ApplicationManagerTests

- (void)setUp {
    [super setUp];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.documentsDirectory = [paths objectAtIndex:0];
    
    // delete CompanyInfo.plist that copied in AppDelegate
    [self deletePlist:@"CompanyInfo"];
    
    // reset stored build version
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"STORED_BUILD_NUMBER"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)tearDown {
    [super tearDown];
}

- (void)resetCompanyInfo {
    XCTAssertFalse([self checkExistenceOfPlist:@"CompanyInfo"], @"CompanyInfo.plist should be removed");
    [ApplicationManager copyPlistWithName:@"CompanyInfo" forceCopy:false];
    XCTAssertTrue([self checkExistenceOfPlist:@"CompanyInfo"], @"CompanyInfo.plist should be presented");
}

- (void)modifyPlist {
    NSMutableDictionary *companyInfo = [self getPlist:@"CompanyInfo"];
    [companyInfo setObject:@"UnitTest" forKey:@"Testing"];
    [self createPlist:companyInfo withName:@"CompanyInfo"];
}

- (void)testCopyPlist {
    [self resetCompanyInfo];
}

- (void)testFirstTimeCopy {
    [self resetCompanyInfo];
    
    NSString *buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    NSString *storedBuildNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"STORED_BUILD_NUMBER"];
    XCTAssertTrue([buildNumber isEqualToString:storedBuildNumber], @"Stored build number should be equal to current build number");
}

- (void)testDoNotUpdatePlist {
    [self resetCompanyInfo];
    [self modifyPlist];
    
    [ApplicationManager copyPlistWithName:@"CompanyInfo" forceCopy:false];
    NSMutableDictionary *companyInfo = [self getPlist:@"CompanyInfo"];
    XCTAssertTrue([[companyInfo objectForKey:@"Testing"] isEqualToString:@"UnitTest"], @"Plist has been updated. Check it");
}

- (void)testUpdatePlist {
    [self resetCompanyInfo];
    [self modifyPlist];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"STORED_BUILD_NUMBER"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [ApplicationManager copyPlistWithName:@"CompanyInfo" forceCopy:false];
    NSMutableDictionary *companyInfo = [self getPlist:@"CompanyInfo"];
    XCTAssertTrue([companyInfo objectForKey:@"Testing"] == nil, @"Plist has not been updated. Check it");
}

- (void)testForceUpdatePlist {
    [self resetCompanyInfo];
    [self modifyPlist];
    
    [ApplicationManager copyPlistWithName:@"CompanyInfo" forceCopy:true];
    NSMutableDictionary *companyInfo = [self getPlist:@"CompanyInfo"];
    XCTAssertTrue([companyInfo objectForKey:@"Testing"] == nil, @"Force update doesn't work");
}

#pragma mark - Auxiliary methods
- (void)createPlist:(NSDictionary *)content withName:(NSString *)name {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *plistPath = [self.documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", name]];
    
    if (![fileManager fileExistsAtPath:plistPath]) {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
        [fileManager copyItemAtPath:bundle toPath:plistPath error:&error];
    }
    [content writeToFile:plistPath atomically:YES];
}

- (void)deletePlist:(NSString *)name {
    NSError *error;
    NSString *path = [self.documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", name]];
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
}

- (NSMutableDictionary *)getPlist:(NSString *)name {
    NSString *path = [self.documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", name]];
    NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:path];
    return [[NSMutableDictionary alloc] initWithDictionary:plistDict];
}

- (BOOL)checkExistenceOfPlist:(NSString *)name {
    NSString *path = [self.documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", name]];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

@end
