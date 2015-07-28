//
//  ApplicationManager.m
//  
//
//  Created by Balaban Alexander on 28/07/15.
//
//

#import "ApplicationManager.h"

@implementation ApplicationManager

+ (void)copyPlists {
    NSArray *plists = @[@"CompanyInfo", @"ViewControllers", @"Views"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths firstObject];
    for (NSString *plistName in plists) {
        [ApplicationManager copyPlistWithName:plistName withDocumentDirectory:documentDirectory];
    }
}

+ (void)copyPlistWithName:(NSString * __nonnull)plistName withDocumentDirectory:(NSString * __nonnull)directory {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [directory stringByAppendingPathComponent:[plistName stringByAppendingPathComponent:@".plist"]];
    if (![fileManager fileExistsAtPath:path]) {
        NSString *pathToCompanyInfo = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
        [fileManager copyItemAtPath:pathToCompanyInfo toPath:path error:&error];
    }
}

@end
