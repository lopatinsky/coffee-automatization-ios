//
//  ViewControllerManager.m
//  
//
//  Created by Balaban Alexander on 15/07/15.
//
//

#import "ViewControllerManager.h"
#import "DBCompanyInfo.h"

#pragma mark - General

@implementation ViewControllerManager

+ (nullable NSString *)valueFromPropertyListByKey:(nonnull NSString *)key {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"CompanyInfo.plist"];
    NSDictionary *companyInfo = [NSDictionary dictionaryWithContentsOfFile:path];
    return [[companyInfo objectForKey:@"ViewControllers"] objectForKey:key];
}

@end


#pragma mark - Position
#import "DBPositionViewController.h"
@implementation ViewControllerManager(PositionViewControllers)

+ (nonnull NSDictionary *)positionViewControllerClasses {
    return @{
             @"default": [DBPositionViewController class],
             @"Classic": [DBPositionViewController class]
             };
}


+ (nonnull Class<PositionViewControllerProtocol>)positionViewController {
    return [self positionViewControllerClasses][[self valueFromPropertyListByKey:@"Position"] ?: @"default"];
}

@end


#pragma mark - Launch
#import "LaunchViewController.h"
@implementation ViewControllerManager(LaunchViewControllers)

+ (nonnull NSDictionary *)launchViewControllerClasses {
    return @{
             @"default": [LaunchViewController class]
             };
}

+ (nonnull UIViewController<DBLaunchViewControllerProtocol> *)launchViewController {
    Class launchViewController = [self launchViewControllerClasses][[ViewControllerManager valueFromPropertyListByKey:@"Launch"] ?: @"default"];
    return [launchViewController new];
}

@end


#pragma mark - News
#import "PopupNewsViewController.h"
@implementation ViewControllerManager(NewsViewControllers)

+ (nonnull NSDictionary *)newsViewControllerClasses {
    return @{
             @"default" : [PopupNewsViewController class]
             };
}

+ (nonnull UIViewController<PopupNewsViewControllerProtocol> *)newsViewController {
    Class newsViewController = [self newsViewControllerClasses][[self valueFromPropertyListByKey:@"News"] ?: @"default"];
    return [newsViewController new];
}

@end


#pragma mark - Promocodes
#import "PromocodeViewController.h"
@implementation ViewControllerManager(PromocodeViewControllers)

+ (nonnull NSDictionary *)promocodesViewControllerClasses {
    return @{
             @"default": [PromocodeViewController class]
             };
}

+ (nonnull UIViewController *)promocodeViewController {
    Class promocodeViewControllerr = [self promocodesViewControllerClasses][[self valueFromPropertyListByKey:@"Promocode"] ?: @"default"];
    return [promocodeViewControllerr new];
}

@end

#pragma mark - Share Friend Invitation
#import "DBSharePermissionViewController.h"
@implementation ViewControllerManager(ShareFriendInvitationViewControllers)

+ (nonnull NSDictionary *)shareFriendInvitationViewControllerClasses {
    return @{
             @"default": [DBSharePermissionViewController class]
             };
}

+ (nonnull UIViewController *)shareFriendInvitationViewController {
    Class shareFriendInvitation = [self shareFriendInvitationViewControllerClasses][[self valueFromPropertyListByKey:@"ShareFriendInvitation"] ?: @"default"];
    return [shareFriendInvitation new];
}

@end


#pragma mark - Company
#import "DBCompaniesViewController.h"
@implementation ViewControllerManager(CompaniesViewControllers)

+ (nonnull NSDictionary *)companiesViewControllerClasses {
    return @{
             @"default": [DBCompaniesViewController class]
             };
}

+ (nonnull UIViewController<DBCompaniesViewControllerProtocol> *)companiesViewController {
    Class companiesViewController = [self companiesViewControllerClasses][[self valueFromPropertyListByKey:@"Company"] ?: @"default"];
    return [companiesViewController new];
}

@end


#pragma mark - Subscription
#import "DBSubscriptionTableViewController.h"
@implementation ViewControllerManager(SubscriptionViewControllers)

+ (nonnull NSDictionary *)subscriptionViewControllerClasses {
    return @{
             @"default": [DBSubscriptionTableViewController class]
             };
}

+ (nonnull UIViewController<SubscriptionViewControllerProtocol> *)subscriptionViewController {
    Class subscriptionViewController = [self subscriptionViewControllerClasses][[self valueFromPropertyListByKey:@"Subscription"] ?: @"default"];
    return [subscriptionViewController new];
}

@end

#pragma mark - Review
#import "ReviewViewController.h"
@implementation ViewControllerManager(ReviewViewController)

+ (nonnull NSDictionary *)reviewViewControllerClasses {
    return @{
             @"default": [ReviewViewController class]
             };
}

+ (nonnull UIViewController<ReviewViewControllerProtocol> *)reviewViewController {
    Class reviewViewController = [self reviewViewControllerClasses][[self valueFromPropertyListByKey:@"Review"] ?: @"default"];
    return [reviewViewController new];
}

@end
