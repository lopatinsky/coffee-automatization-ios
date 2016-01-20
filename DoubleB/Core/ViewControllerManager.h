//
//  ViewControllerManager.h
//  
//
//  Created by Balaban Alexander on 15/07/15.
//
//

#import <Foundation/Foundation.h>
#import "DBBaseSettingsTableViewController.h"

#import "PositionViewControllerProtocol.h"
#import "PopupNewsViewControllerProtocol.h"
#import "DBLaunchViewControllerProtocol.h"
#import "DBCompaniesViewControllerProtocol.h"
#import "SubscriptionViewControllerProtocol.h"
#import "ReviewViewControllerProtocol.h"
#import "DBBaseSettingsTableViewController.h"

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
+ (nonnull UIViewController<DBSettingsProtocol> *)promocodeViewController;
@end

@interface ViewControllerManager(ShareFriendInvitationViewControllers)
+ (nonnull UIViewController<DBSettingsProtocol> *)shareFriendInvitationViewController;
@end

@interface ViewControllerManager(CompaniesViewControllers)
+ (nonnull UIViewController<DBCompaniesViewControllerProtocol, DBSettingsProtocol> *)companiesViewController;
@end

@interface ViewControllerManager(SubscriptionViewControllers)
+ (nonnull UIViewController<SubscriptionViewControllerProtocol, DBSettingsProtocol> *)subscriptionViewController;
@end

@interface ViewControllerManager(ReviewViewControllers)
+ (nonnull UIViewController<ReviewViewControllerProtocol> *)reviewViewController;
@end

@interface ViewControllerManager(SettingsViewControllers)
+ (nonnull DBBaseSettingsTableViewController *)generalSettingsViewController;
+ (nonnull DBBaseSettingsTableViewController *)companySettingsViewController;
@end