//
//  ViewControllerManager.h
//  
//
//  Created by Balaban Alexander on 15/07/15.
//
//

#import <Foundation/Foundation.h>
#import "PositionsViewControllerDelegate.h"

@interface ViewControllerManager : NSObject

+ (nonnull UIViewController<PositionsViewControllerDelegate> *)positionsViewController;

@end
