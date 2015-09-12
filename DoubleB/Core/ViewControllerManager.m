//
//  ViewControllerManager.m
//  
//
//  Created by Balaban Alexander on 15/07/15.
//
//

#import "ViewControllerManager.h"

#pragma mark - General

@implementation ViewControllerManager

+ (nullable NSString *)valueFromPropertyListByKey:(nonnull NSString *)key {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"CompanyInfo.plist"];
    NSDictionary *companyInfo = [NSDictionary dictionaryWithContentsOfFile:path];
    return [[companyInfo objectForKey:@"ViewControllers"] objectForKey:key];
}

@end


#pragma mark - Menu Controllers
#import "CategoriesAndPositionsTVController.h"
#import "CategoriesAndPositionsCVController.h"
#import "CategoriesTVController.h"
#import "PositionsTVController.h"
@implementation ViewControllerManager(MenuViewControllers)

+ (nonnull NSDictionary *)categoriesAndPositionsMenuViewControllerClasses {
    return @{
             @"default": [CategoriesAndPositionsTVController class],
             @"TableView": [CategoriesAndPositionsTVController class],
             @"CollectionView": [CategoriesAndPositionsCVController class],
             };
}

+ (nonnull Class<MenuListViewControllerProtocol>)rootMenuViewController{
    NSString *menuControllersMode = [self valueFromPropertyListByKey:@"MenuViewControllers"];
    if([menuControllersMode isEqualToString:@"Nested"]){
        return [self categoriesViewController];
    } else {
        return [self categoriesAndPositionsViewController];
    }
}

+ (nonnull Class<MenuListViewControllerProtocol>)categoriesViewController{
    Class<MenuListViewControllerProtocol> categoriesVCClass = [CategoriesTVController class];
    return categoriesVCClass;
}

+ (nonnull Class<MenuListViewControllerProtocol>)positionsViewController{
    Class<MenuListViewControllerProtocol> positionsVCClass = [PositionsTVController class];
    return positionsVCClass;
}

+ (nonnull Class<MenuListViewControllerProtocol>)categoriesAndPositionsViewController {
    Class<MenuListViewControllerProtocol> catAndPosVCClass = [self categoriesAndPositionsMenuViewControllerClasses][[self valueFromPropertyListByKey:@"MenuPositions"] ?: @"default"];
    return catAndPosVCClass;
}

@end


#pragma mark - Position
#import "PositionViewController1.h"
//#import "PositionViewController2.h"
@implementation ViewControllerManager(PositionViewControllers)

+ (nonnull NSDictionary *)positionViewControllerClasses {
    return @{
             @"default": [PositionViewController1 class],
             @"Classic": [PositionViewController1 class],
//             @"New": [PositionViewController2 class],
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

+ (nonnull UIViewController *)launchViewController {
    Class launchViewController = [self launchViewControllerClasses][[ViewControllerManager valueFromPropertyListByKey:@"Launch"] ?: @"default"];
    return [launchViewController new];
}

@end


#pragma mark - Main
#import "DBTabBarController.h"
@implementation ViewControllerManager(MainViewControllers)

+ (nonnull NSDictionary *)mainViewControllerClasses {
    return @{
             @"default": [DBTabBarController class]
             };
}

+ (nonnull UIViewController *)mainViewController {
    Class mainViewController = [self mainViewControllerClasses][[self valueFromPropertyListByKey:@"Main"] ?: @"default"];
    return [mainViewController new];
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

@end


#pragma mark - Company
#import "DBCompaniesViewController.h"
@implementation ViewControllerManager(CompaniesViewControllers)

+ (nonnull NSDictionary *)companiesViewControllerClasses {
    return @{
             @"default": [DBCompaniesViewController class]
             };
}

+ (nonnull UIViewController *)companiesViewControllers {
    Class companiesViewController = [self companiesViewControllerClasses][[self valueFromPropertyListByKey:@"Company"] ?: @"default"];
    return [companiesViewController new];
}

@end

