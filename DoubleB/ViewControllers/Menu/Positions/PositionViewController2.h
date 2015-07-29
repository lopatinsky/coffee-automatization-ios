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

@interface PositionViewController2 : UIViewController <PositionViewControllerProtocol>

@property (strong, nonatomic) DBMenuPosition *position;
@property (nonatomic) PositionViewControllerMode mode;
@property (nonatomic) PositionViewControllerContentType contentType;
@property (weak, nonatomic) UINavigationController *parentNavigationController;

@end
