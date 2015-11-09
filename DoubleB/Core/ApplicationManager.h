//
//  ApplicationManager.h
//  
//
//  Created by Balaban Alexander on 28/07/15.
//
//

#import <Foundation/Foundation.h>
#import "ManagerProtocol.h"
#import "MenuListViewControllerProtocol.h"

typedef NS_ENUM(NSInteger, RootState) {
    RootStateStart = 0,
    RootStateMain
};

typedef NS_ENUM(NSInteger, ApplicationType) {
    ApplicationTypeCommon = 0,
    ApplicationTypeProxy,
    ApplicationTypeAggregator,
    ApplicationTypeDemo
};

@interface ApplicationManager : NSObject<ManagerProtocol>
+ (instancetype)sharedInstance;

@property (nonatomic) ApplicationType applicationType;

- (void)initializeVendorFrameworks;
- (void)startApplicationWithOptions:(NSDictionary *)launchOptions;

- (void)fetchCompanyDependentInfo;

@end

@interface ApplicationManager(Plist)
+ (void)copyPlistWithName:(NSString *)plistName forceCopy:(BOOL)forceCopy;
+ (void)copyPlistsWithNames:(NSArray *)plistsNames forceCopy:(BOOL)forceCopy;
@end

@interface ApplicationManager(Appearance)
+ (void)applyBrandbookStyle;
@end

@protocol DBStartNavControllerDelegate;
@interface ApplicationManager(Start)<DBStartNavControllerDelegate>
- (UIViewController *)rootViewController;
@end

@interface ApplicationManager(Menu)
- (Class<MenuListViewControllerProtocol>)rootMenuViewController;
@end

@interface ApplicationManager(DemoApp)
- (UIViewController *)demoLoginViewController;
@end