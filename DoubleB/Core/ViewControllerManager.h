//
//  ViewControllerManager.h
//  
//
//  Created by Balaban Alexander on 15/07/15.
//
//

#import <Foundation/Foundation.h>
#import "PositionViewControllerProtocol.h"
#import "PopupNewsViewControllerProtocol.h"
#import "DBLaunchViewControllerProtocol.h"
#import "DBCompaniesViewControllerProtocol.h"
#import "SubscriptionViewControllerProtocol.h"
#import "ReviewViewControllerProtocol.h"

@interface ViewControllerManager : NSObject
@end


@interface ViewControllerManager(PositionViewControllers)
+ (__nonnull Class<PositionViewControllerProtocol>)positionViewController;
@end

@interface ViewControllerManager(LaunchViewControllers)
+ (nonnull UIViewController<DBLaunchViewControllerProtocol> *)launchViewController;
@end

@interface ViewControllerManager(NewsViewControllers)
+ (nonnull UIViewController<PopupNewsViewControllerProtocol> *)newsViewController;
@end

@interface ViewControllerManager(PromocodeViewControllers)
+ (nonnull UIViewController *)promocodeViewController;
@end

@interface ViewControllerManager(ShareFriendInvitationViewControllers)
+ (nonnull UIViewController *)shareFriendInvitationViewController;
@end

@interface ViewControllerManager(CompaniesViewControllers)
+ (nonnull UIViewController *)companiesViewController;
@end

@interface ViewControllerManager(SubscriptionViewControllers)
+ (nonnull UIViewController<SubscriptionViewControllerProtocol> *)subscriptionViewController;
@end

@interface ViewControllerManager(ReviewViewControllers)
+ (nonnull UIViewController<ReviewViewControllerProtocol> *)reviewViewController;
@end