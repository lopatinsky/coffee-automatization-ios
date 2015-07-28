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
@end

@interface ViewControllerManager(PositionViewControllers)
+ (__nonnull Class<PositionViewControllerProtocol>)positionViewController;
@end

@interface ViewControllerManager(PositionsViewControllers)
+ (nonnull UIViewController<PositionsViewControllerProtocol> *)positionsViewController;
@end

@interface ViewControllerManager(LaunchViewControllers)
+ (nonnull UIViewController *)launchViewController;
@end

@interface ViewControllerManager(MainViewControllers)
+ (nonnull UIViewController *)mainViewController;
@end
