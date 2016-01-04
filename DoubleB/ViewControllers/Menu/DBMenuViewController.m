//
//  DBMenuViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 25/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBMenuViewController.h"

#import "DBMenu.h"
#import "DBMenuCategory.h"
#import "DBMenuPosition.h"
#import "OrderCoordinator.h"
#import "Venue.h"

#import "DBSettingsTableViewController.h"

#import "MBProgressHUD.h"
#import "DBBarButtonItem.h"
#import "DBCategoryPicker.h"
#import "DBDropdownTitleView.h"
#import "DBPositionModifiersListModalView.h"

#import "DBMixedMenuModuleView.h"
#import "DBCategoriesMenuModuleView.h"
#import "DBPositionsMenuModuleView.h"

#import "DBSubscriptionManager.h"
#import "DBSubscriptionModuleView.h"

@interface DBMenuViewController () <DBModuleViewDelegate, DBMenuModuleViewDelegate, DBCategoryPickerDelegate, DBMenuCategoryDropdownTitleViewDelegate, DBPopupComponentDelegate, DBOwnerViewControllerProtocol>
@property (strong, nonatomic) NSString *analyticsCategory;
@property (strong, nonatomic) DBMenuModuleView *menuModuleView;

@property (strong, nonatomic) DBDropdownTitleView *titleView;
@property (strong, nonatomic) DBCategoryPicker *categoryPicker;

@property (strong, nonatomic) DBSubscriptionModuleView *subscriptionModuleView;
@end

@implementation DBMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
    self.analyticsCategory = @"Menu_screen";
    
    self.navigationItem.rightBarButtonItem = [DBBarButtonItem orderItem:self action:@selector(moveToOrder)];
    
    if (self.type == DBMenuViewControllerTypeInitial) {
        [self setupInitial];
    }
    
    if (self.mode == DBMenuViewControllerModeCategoriesAndPositions) {
        [self setupCategoriesAndPositionsMode];
    } else if (self.mode == DBMenuViewControllerModeCategories) {
        [self setupCategoriesMode];
    } else {
        [self setupPositionsMode];
    }
    
    self.menuModuleView.analyticsCategory = self.analyticsCategory;
    self.menuModuleView.ownerViewController = self;
    self.menuModuleView.delegate = self;
    self.menuModuleView.menuModuleDelegate = self;
    
    [self.view addSubview:self.menuModuleView];
    self.menuModuleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.menuModuleView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.view];
    
//    [self setupSubscription];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [GANHelper analyzeScreen:self.analyticsCategory];
    
    if (self.type == DBMenuViewControllerTypeInitial) {
        [self loadMenu];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (self.mode == DBMenuViewControllerModeCategoriesAndPositions) {
        [self.categoryPicker hide];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (DBMenuViewControllerMode)mode {
    DBMenuViewControllerMode mode;
    
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"CompanyInfo.plist"];
    NSDictionary *companyInfo = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString *menuControllersMode = [[companyInfo objectForKey:@"ViewControllers"] objectForKey:@"MenuViewControllers"];
    
    if (self.type == DBMenuViewControllerTypeInitial) {
        if([DBMenu sharedInstance].hasNestedCategories){
            mode = DBMenuViewControllerModeCategories;
        } else if ([menuControllersMode isEqualToString:@"Mixed"]) {
            mode = DBMenuViewControllerModeCategoriesAndPositions;
        } else if ([menuControllersMode isEqualToString:@"Nested"]) {
            mode = DBMenuViewControllerModeCategories;
        } else {
            mode = DBMenuViewControllerModeCategoriesAndPositions;
        }
    } else {
        if(self.category.type == DBMenuCategoryTypeParent){
            BOOL lastLevel = YES;
            for (DBMenuCategory *category in self.category.categories) {
                lastLevel = lastLevel && category.type == DBMenuCategoryTypeStandart;
            }
            
            if ([menuControllersMode isEqualToString:@"Mixed"] && lastLevel) {
                mode = DBMenuViewControllerModeCategoriesAndPositions;
            } else {
                mode = DBMenuViewControllerModeCategories;
            }
        } else {
            mode = DBMenuViewControllerModePositions;
        }
    }
    
    return mode;
}

- (void)moveToOrder {
    [self.navigationController pushViewController:[DBClassLoader loadNewOrderViewController] animated:YES];
    [GANHelper analyzeEvent:@"order_pressed" category:self.analyticsCategory];
}


#pragma mark - DBMenuModuleViewDelegate

- (void)db_menuModuleViewDidReloadContent:(DBMenuModuleView *)module {
    if (self.mode == DBMenuViewControllerModeCategoriesAndPositions) {
        [self reloadTitleView:nil];
    }
}

- (void)db_menuModuleViewNeedsToMoveForward:(DBMenuModuleView *)module object:(id)object{
    if ([module isKindOfClass:[DBMixedMenuModuleView class]]) {
        UIViewController<PositionViewControllerProtocol> *positionVC = [[ViewControllerManager positionViewController] initWithPosition:object mode:PositionViewControllerModeMenuPosition];
        [self.navigationController pushViewController:positionVC animated:YES];
    }
    
    if ([module isKindOfClass:[DBCategoriesMenuModuleView class]]) {
        DBMenuViewController *menuVC = [DBMenuViewController new];
        menuVC.type = DBMenuViewControllerTypeSecond;
        menuVC.category = object;
        [self.navigationController pushViewController:menuVC animated:YES];
    }
    
    if ([module isKindOfClass:[DBPositionsMenuModuleView class]]) {
        UIViewController<PositionViewControllerProtocol> *positionVC = [[ViewControllerManager positionViewController] initWithPosition:object mode:PositionViewControllerModeMenuPosition];
        [self.navigationController pushViewController:positionVC animated:YES];
    }
}

- (void)db_menuModuleViewNeedsToAddPosition:(DBMenuModuleView *)module position:(DBMenuPosition *)position {
    if (position.hasEmptyRequiredModifiers) {
        DBPositionModifiersListModalView *modifiersList = [DBPositionModifiersListModalView new];
        [modifiersList configureWithMenuPosition:position];
        
        [modifiersList showOnView:self.navigationController.view appearance:DBPopupAppearanceModal transition:DBPopupTransitionBottom];
    } else {
        [[OrderCoordinator sharedInstance].itemsManager addPosition:position];
    }
    
    [GANHelper analyzeEvent:@"product_added" label:position.positionId category:self.analyticsCategory];
}

#pragma mark - DBModuleViewDelegate

- (UIView *)db_moduleViewModalComponentContainer:(DBModuleView *)view {
    return self.navigationController.view;
}

#pragma mark - Initial
- (void)setupInitial {
    self.navigationItem.leftBarButtonItem = [DBBarButtonItem profileItem:self action:@selector(moveToSettings)];
}

- (void)loadMenu{
    [GANHelper analyzeEvent:@"menu_update" category:self.analyticsCategory];
    
    Venue *venue = [OrderCoordinator sharedInstance].orderManager.venue;
    NSArray *categories;
    if (venue.venueId) {
        // Load menu for current Venue
        categories = [[DBMenu sharedInstance] getMenuForVenue:venue];
    } else {
        // Load whole menu
        categories = [[DBMenu sharedInstance] getMenu];
    }
    
    if (categories && categories.count > 0) {
        if (self.mode == DBMenuViewControllerModeCategoriesAndPositions) {
            ((DBMixedMenuModuleView *)self.menuModuleView).categories = categories;
        } else if (self.mode == DBMenuViewControllerModeCategories) {
            ((DBCategoriesMenuModuleView *)self.menuModuleView).categories = categories;
        }
        
        [self.menuModuleView reloadContent];
        [self reloadTitleView:nil];
    } else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[DBMenu sharedInstance] updateMenuForVenue:venue
                                         remoteMenu:^(BOOL success, NSArray *categories) {
                                             [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                             
                                             if (self.mode == DBMenuViewControllerModeCategoriesAndPositions) {
                                                 ((DBMixedMenuModuleView *)self.menuModuleView).categories = categories;
                                             } else if (self.mode == DBMenuViewControllerModeCategories) {
                                                 ((DBCategoriesMenuModuleView *)self.menuModuleView).categories = categories;
                                             }
                                             
                                             [self.menuModuleView reloadContent];
                                             [self reloadTitleView:nil];
                                         }];
    }
}

- (void)moveToSettings {
    DBSettingsTableViewController *settingsController = [DBClassLoader loadSettingsViewController];
    [self.navigationController pushViewController:settingsController animated:YES];
}

#pragma mark - Categories

- (void)setupCategoriesMode {
    DBCategoriesMenuModuleView *module = [DBCategoriesMenuModuleView create];
    if (self.type == DBMenuViewControllerTypeInitial) {
        module.updateEnabled = YES;
    } else {
        module.updateEnabled = NO;
        module.categories = self.category.categories;
    }
    self.menuModuleView = module;
    
    if (self.type == DBMenuViewControllerTypeInitial) {
        [self db_setTitle:NSLocalizedString(@"Меню", nil)];
    } else {
        [self db_setTitle:self.category.name];
    }
}

#pragma mark - Positions

- (void)setupPositionsMode {
    DBPositionsMenuModuleView *module = [DBPositionsMenuModuleView create];
    module.category = self.category;
    self.menuModuleView = module;
    
    if (self.type == DBMenuViewControllerTypeInitial) {
        [self db_setTitle:NSLocalizedString(@"Меню", nil)];
    } else {
        [self db_setTitle:self.category.name];
    }
}

#pragma mark - CategoriesAndPositions

- (DBMixedMenuModuleView *)mixedModuleView {
    return (DBMixedMenuModuleView *)self.menuModuleView;
}

- (void)setupCategoriesAndPositionsMode {
    DBMixedMenuModuleView *module = [DBMixedMenuModuleView create];
    if (self.type == DBMenuViewControllerTypeInitial) {
        module.updateEnabled = YES;
    } else {
        module.updateEnabled = NO;
        module.categories = self.category.categories;
    }
    
    self.menuModuleView = module;
    
    [self setupTitleView];
    
    self.categoryPicker = [DBCategoryPicker new];
    self.categoryPicker.pickerDelegate = self;
    self.categoryPicker.delegate = self;
}

- (void)setupTitleView {
    _titleView = [DBDropdownTitleView new];
    _titleView.delegate = self;
    
    if (self.type == DBMenuViewControllerTypeInitial) {
        _titleView.title = NSLocalizedString(@"Меню", nil);
    } else {
        _titleView.title = self.category.name;
    }
    
    [self reloadTitleView:nil];
    
    self.navigationItem.titleView = _titleView;
}

- (void)reloadTitleView:(DBMenuCategory *)category {
    if ([self mixedModuleView].categories.count > 0) {
        if ([self mixedModuleView].categories.count == 1)
            _titleView.state = DBDropdownTitleViewStateNone;
        else
            _titleView.state = self.categoryPicker.presented ? DBDropdownTitleViewStateOpened : DBDropdownTitleViewStateClosed;
    } else {
        _titleView.state = DBDropdownTitleViewStateNone;
    }
}

#pragma mark - DBCategoryPickerDelegate

- (void)db_categoryPicker:(DBCategoryPicker *)picker didSelectCategory:(DBMenuCategory *)category{
    [self.categoryPicker hide];
    [self reloadTitleView:category];
    [[self mixedModuleView] scrollToCategory:category];
    
    [GANHelper analyzeEvent:@"category_spinner_selected" label:category.categoryId category:self.analyticsCategory];
}

#pragma mark - DBMenuCategoryDropdownTitleViewDelegate

- (void)db_dropdownTitleClick:(DBDropdownTitleView *)view {
    if(self.categoryPicker.presented){
        [self.categoryPicker hide];
    } else {
        if ([self mixedModuleView].categories.count > 0){
            [self.categoryPicker configureWithCurrentCategory:nil categories:[self mixedModuleView].categories];
            
            CGFloat offset = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
            [self.categoryPicker showOnView:self.navigationController.view appearance:DBPopupAppearanceModal transition:DBPopupTransitionTop offset:offset];
            [self.navigationController.view bringSubviewToFront:self.navigationController.navigationBar];
        }
    }
    
    [self reloadTitleView:nil];
    
    [GANHelper analyzeEvent:@"category_spinner_click" category:self.analyticsCategory];
}

- (void)db_componentWillDismiss:(DBPopupComponent *)component {
    [self reloadTitleView:nil];
    
    [GANHelper analyzeEvent:@"category_spinner_closed" category:self.analyticsCategory];
}

#pragma mark - Subscription

- (void)setupSubscription {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupSubscriptionModule) name:kDBSubscriptionManagerCategoryIsAvailable object:nil];
    
    [self setupSubscriptionModule];
}

- (void)setupSubscriptionModule {
    if (self.type == DBMenuViewControllerTypeInitial && !_subscriptionModuleView && [DBSubscriptionManager sharedInstance].isEnabled) {
        DBSubscriptionModuleViewMode mode;
        switch (self.mode) {
            case DBMenuViewControllerModeCategoriesAndPositions:
                mode = DBSubscriptionModuleViewModeCategoriesAndPositions;
                break;
            case DBMenuViewControllerModeCategories:
                mode = DBSubscriptionModuleViewModeCategory;
                break;
            case DBMenuViewControllerModePositions:
                mode = DBSubscriptionModuleViewModePositions;
                break;
        }
        _subscriptionModuleView = [DBSubscriptionModuleView create:mode];
        
        DBModuleView *module = [DBModuleView create];
        [module.submodules addObject:_subscriptionModuleView];
        ((DBMenuTableModuleView *)self.menuModuleView).tableHeaderModuleView = module;
    }
}

@end
