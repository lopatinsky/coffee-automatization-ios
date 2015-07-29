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

typedef NS_ENUM(NSInteger, PositionViewControllerContentType){
    PositionViewControllerContentTypeRegularPosition = 0,
    PositionViewControllerContentTypeBonusPosition,
    PositionViewControllerContentTypeGiftPosition
};

@class DBMenuPosition;

@protocol PositionViewControllerProtocol <NSObject>

+ (instancetype)initWithPosition:(DBMenuPosition *)position mode:(PositionViewControllerMode)mode contentType:(PositionViewControllerContentType)contentType;
- (void)setParentNavigationController:(UINavigationController *)controller;

@end
