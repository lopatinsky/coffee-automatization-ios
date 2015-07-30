//
//  PositionViewControllerProtocol.h
//  
//
//  Created by Balaban Alexander on 18/07/15.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PositionViewControllerMode) {
    PositionViewControllerModeMenuPosition = 0,
    PositionViewControllerModeOrderPosition
};

@class DBMenuPosition;

@protocol PositionViewControllerProtocol <NSObject>

+ (instancetype)initWithPosition:(DBMenuPosition *)position mode:(PositionViewControllerMode)mode;
- (void)setParentNavigationController:(UINavigationController *)controller;

@end
