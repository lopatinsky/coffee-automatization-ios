//
//  ViewControllerManager.h
//  
//
//  Created by Balaban Alexander on 15/07/15.
//
//

#import <Foundation/Foundation.h>
#import "PositionsViewControllerProtocol.h"
#import "PositionViewControllerProtocol.h"

@interface ViewControllerManager : NSObject

+ (nonnull UIViewController *)launchViewController;
+ (nonnull UIViewController<PositionsViewControllerProtocol> *)positionsViewController;
+ (__nonnull Class<PositionViewControllerProtocol>)positionViewController;

@end
