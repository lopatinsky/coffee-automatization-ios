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

#import "DBCompanySettingsTableViewController.h"

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

#import "DBMenuSearchVC.h"

@interface DBMenuViewController () <DBModuleViewDelegate, DBMenuModuleViewDelegate, DBCategoryPickerDelegate, DBMenuCategoryDropdownTitleViewDelegate, DBPopupComponentDelegate, DBOwnerViewControllerProtocol, DBMenuSearchVCDelegate>
@property (strong, nonatomic) DBMenuModuleView *menuModuleView;

@property (strong, nonatomic) DBDropdownTitleView *titleView;
@property (strong, nonatomic) DBCategoryPicker *categoryPicker;

@property (strong, nonatomic) DBMenuSearchVC *searchVC;

@property (strong, nonatomic) DBModuleView *topModulesHolder;
@property (strong, nonatomic) NSArray *topModules;
@end

@implementation DBMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
    self.analyticsCategory = @"Menu_screen";
    
    self.navigationItem.leftBarButtonItem = [self leftBarButtonItem];
    self.navigationItem.rightBarButtonItem = [self rightBarButtonItem];
    
    if (self.type == DBMenuViewControllerTypeInitial) {
        if ([[DBMenu sharedInstance] getMenu].count > 0) {
            [self setupMenuModule];
            [self fetchMenu:nil];
        } else {
            [self fetchMenu:^(BOOL success) {
                if (success) {
                    [self setupMenuModule];
                    [self updateMenu];
                }
            }];
        }
    } else {
        [self setupMenuModule];
    }
    
    // Top Modules
    [self setupTopModuleHolder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [GANHelper analyzeScreen:self.analyticsCategory];
    [self.topModulesHolder reload:YES];
    
    if (self.type == DBMenuViewControllerTypeInitial) {
        [self updateMenu];
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

- (void)setupTopModuleHolder {
    _topModulesHolder = [DBModuleView create];
    _topModulesHolder.ownerViewController = self;
    _topModulesHolder.analyticsCategory = self.analyticsCategory;
    
    [_topModulesHolder.submodules addObjectsFromArray:[self setupTopModules]];
    
    [_topModulesHolder layoutModules];
    
    CGFloat height = _topModulesHolder.submodules.count > 0 ? [_topModulesHolder moduleViewContentHeight] : 0;
    _topModulesHolder.frame = CGRectMake(0, 0, _topModulesHolder.frame.size.width, height);
    ((DBMenuTableModuleView *)self.menuModuleView).tableHeaderModuleView = _topModulesHolder;
    [_topModulesHolder reload:NO];
}

- (void)setupMenuModule {
    if (self.mode == DBMenuViewControllerModeCategoriesAndPositions) {
        [self setupCategoriesAndPositionsMode];
    } else if (self.mode == DBMenuViewControllerModeCategories) {
        [self setupCategoriesMode];
    } else {
        [self setupPositionsMode];
    }
    
    [self.view addSubview:self.menuModuleView];
    self.menuModuleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.menuModuleView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.view];
}

- (NSArray *)setupTopModules {
    NSMutableArray *result = [NSMutableArray new];
    
    DBModuleView *subscriptionModule = [self setupSubscriptionModule];
    if (subscriptionModule){
        [result addObject:subscriptionModule];
    }
    
    _topModules = result;
    
    return result;
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

- (UIBarButtonItem *)leftBarButtonItem {
    if (self.type == DBMenuViewControllerTypeInitial) {
        return [DBBarButtonItem item:DBBarButtonTypeProfile handler:^{
            [self moveToSettings];
        }];
    }
    
    return nil;
}

- (UIBarButtonItem *)rightBarButtonItem {
    @weakify(self);
    DBBarButtonItemComponent *searchComp = [DBBarButtonItemComponent create:DBBarButtonTypeSearch handler:^{
        @strongify(self)
        [self searchClick];
    }];
    self.searchVC = [DBMenuSearchVC new];
    self.searchVC.delegate = self;
    
    DBBarButtonItemComponent *orderComp = [DBBarButtonItemComponent create:DBBarButtonTypeOrder handler:^{
        @strongify(self)
        [self moveToOrder];
    }];
    return [DBBarButtonItem itemWithComponents:@[searchComp, orderComp]];
}

- (void)moveToSettings {
    DBBaseSettingsTableViewController *settingsController = [ViewControllerManager companySettingsViewController];
    [self.navigationController pushViewController:settingsController animated:YES];
}

- (void)moveToOrder {
    [self.navigationController pushViewController:[DBClassLoader loadNewOrderVC] animated:YES];
    [GANHelper analyzeEvent:@"order_pressed" category:self.analyticsCategory];
}

- (void)searchClick {
    [self.searchVC presentInContainer:self.navigationController];
}

#pragma mark - DBMenuSearchVCDelegate

- (void)db_menuSearchVC:(DBMenuSearchVC *)controller didSelectPosition:(DBMenuPosition *)position {
    NSArray *trace = [[DBMenu sharedInstance] traceForPosition:position];
    
    NSMutableArray *controllers = [NSMutableArray arrayWithArray:@[[DBMenuViewController new]]];
    
    for (DBMenuCategory *category in trace) {
        DBMenuViewControllerMode mode = ((DBMenuViewController*)(controllers.lastObject)).mode;
        if (mode == DBMenuViewControllerModeCategories) {
            DBMenuViewController *menuVC = [DBMenuViewController new];
            menuVC.type = DBMenuViewControllerTypeSecond;
            menuVC.category = category;
            
            [controllers addObject:menuVC];
        }
    }
    UIViewController<PositionViewControllerProtocol> *positionVC = [[ViewControllerManager positionViewController] initWithPosition:position mode:PositionViewControllerModeMenuPosition];
    [controllers addObject:positionVC];
    
    [self.navigationController setViewControllers:controllers animated:NO];
    
    [self.searchVC hide];
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

- (void)updateMenu {
    Venue *venue = [OrderCoordinator sharedInstance].orderManager.venue;
    NSArray *categories;
    if (venue.venueId) {
        // Load menu for current Venue
        categories = [[DBMenu sharedInstance] getMenuForVenue:venue];
    } else {
        // Load whole menu
        categories = [[DBMenu sharedInstance] getMenu];
    }
    

    if (self.mode == DBMenuViewControllerModeCategoriesAndPositions) {
        ((DBMixedMenuModuleView *)self.menuModuleView).categories = categories;
    } else if (self.mode == DBMenuViewControllerModeCategories) {
        ((DBCategoriesMenuModuleView *)self.menuModuleView).categories = categories;
    }
    
    [self.menuModuleView reloadContent];
    [self reloadTitleView:nil];
}

- (void)fetchMenu:(void (^)(BOOL success))callback {
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
    
    if (categories.count == 0) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    [[DBMenu sharedInstance] updateMenu:^(BOOL success, NSArray *categories) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        NSArray *venueMenu = [[DBMenu sharedInstance] getMenuForVenue:venue];
        if (self.mode == DBMenuViewControllerModeCategoriesAndPositions) {
            ((DBMixedMenuModuleView *)self.menuModuleView).categories = venueMenu;
        } else if (self.mode == DBMenuViewControllerModeCategories) {
            ((DBCategoriesMenuModuleView *)self.menuModuleView).categories = venueMenu;
        }
        
        [self.menuModuleView reloadContent];
        [self reloadTitleView:nil];
        
        if (callback)
            callback(success);
    }];
}

#pragma mark - Categories

- (void)setupCategoriesMode {
    DBCategoriesMenuModuleView *module = [DBCategoriesMenuModuleView create];
    module.analyticsCategory = self.analyticsCategory;
    module.ownerViewController = self;
    module.delegate = self;
    module.menuModuleDelegate = self;
    
    if (self.type == DBMenuViewControllerTypeInitial) {
        module.updateEnabled = YES;
    } else {
        module.updateEnabled = NO;
        module.parent = self.category;
        module.categories = self.category.categories;
    }
    self.menuModuleView = module;
    
    if (self.type == DBMenuViewControllerTypeInitial) {
        [self db_setTitle:[DBTextResourcesHelper db_initialMenuTitle]];
    } else {
        [self db_setTitle:self.category.name];
    }
}

#pragma mark - Positions

- (void)setupPositionsMode {
    DBPositionsMenuModuleView *module = [DBPositionsMenuModuleView create];
    module.analyticsCategory = self.analyticsCategory;
    module.ownerViewController = self;
    module.delegate = self;
    module.menuModuleDelegate = self;
    
    module.category = self.category;
    self.menuModuleView = module;
    
    if (self.type == DBMenuViewControllerTypeInitial) {
        [self db_setTitle:[DBTextResourcesHelper db_initialMenuTitle]];
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
    module.analyticsCategory = self.analyticsCategory;
    module.ownerViewController = self;
    module.delegate = self;
    module.menuModuleDelegate = self;
    
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
        _titleView.title = [DBTextResourcesHelper db_initialMenuTitle];
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

- (DBModuleView *)setupSubscriptionModule {
    if (self.type == DBMenuViewControllerTypeInitial) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupTopModuleHolder) name:kDBSubscriptionManagerCategoryIsAvailable object:nil];
        
        if ([DBSubscriptionManager sharedInstance].isEnabled) {
            DBSubscriptionModuleViewMode mode;
            switch (self.mode) {
                case DBMenuViewControllerModeCategoriesAndPositions:
                    mode = DBSubscriptionModuleViewModeCategoriesAndPositions;
                    break;
                case DBMenuViewControllerModeCategories:
                    mode = DBSubscriptionModuleViewModeCategory;
                    break;
                default:
                    mode = DBSubscriptionModuleViewModeCategory;
                    break;
            }
            DBModuleView *subscriptionModule = [DBSubscriptionModuleView create:mode];
            subscriptionModule.ownerViewController = self;
            subscriptionModule.analyticsCategory = self.analyticsCategory;
            
            return subscriptionModule;
        }
    }
    
    return nil;
}

@end
