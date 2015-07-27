//
//  ViewManager.m
//  
//
//  Created by Balaban Alexander on 27/07/15.
//
//

#import "ViewManager.h"

@implementation ViewManager

+ (nonnull UIView)demoView {
    
}

+ (nullable NSString *)valueFromPropertyListByKey:(nonnull NSString *)key {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"Views.plist"];
    NSDictionary *viewControllersConfig = [NSDictionary dictionaryWithContentsOfFile:path];
    return [viewControllersConfig objectForKey:key];
}

@end
