//
//  PositionViewController.h
//  
//
//  Created by Balaban Alexander on 18/07/15.
//
//

#import <UIKit/UIKit.h>

#import "PositionViewControllerProtocol.h"

@class DBMenuPosition;

@interface PositionViewController : UIViewController <PositionViewControllerProtocol>

@property (strong, nonatomic) DBMenuPosition *position;
@property (nonatomic) PositionViewControllerMode mode;
@property (weak, nonatomic) UINavigationController *parentNavigationController;

+ (instancetype)initWithPosition:(DBMenuPosition *)position mode:(PositionViewControllerMode)mode;
- (void)setParentNavigationController:(UINavigationController *)controller;

@end
