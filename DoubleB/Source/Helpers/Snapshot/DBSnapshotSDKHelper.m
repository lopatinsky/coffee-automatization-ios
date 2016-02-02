//
//  DBSnapshotSDKHelper.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 01/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBSnapshotSDKHelper.h"

#ifdef DEBUG
#import <HSTestingBackchannel/HSTestingBackchannel.h>
#endif

#import "DBNewOrderVC.h"
#import "DBMenu.h"
#import "DBMenuCategory.h"
#import "DBMenuPosition.h"

#import "DBTimePickerView.h"
#import "DBClientInfo.h"
#import "OrderCoordinator.h"
#import "DBCompanyInfo.h"

#import "DBCompanySettingsTableViewController.h"

#import "DBMenuViewController.h"

@interface DBSnapshotSDKHelper()

@property (nonatomic, strong) DBTimePickerView *pickerView;

@end

@implementation DBSnapshotSDKHelper

+ (instancetype)sharedInstance {
    static DBSnapshotSDKHelper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [DBSnapshotSDKHelper new];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    
#ifdef DEBUG
    [HSTestingBackchannel installReceiver];
#endif
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(toCategoriesScreen)
                                                 name:@"UITestNotificationCategoriesScreen"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(toPositionsScreen)
                                                 name:@"UITestNotificationPositionsScreen"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(toPositionOrNeworderScreen)
                                                 name:@"UITestNotificationPositionScreen"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(toOrderScreen)
                                                 name:@"UITestNotificationOrderScreen"
                                               object:nil];
    
    return self;
}

- (UINavigationController *)navController {
    UIViewController *currentVC = [UIViewController currentViewController];
    
    return currentVC.navigationController;
}

- (void)toCategoriesScreen {
//    [self.pickerView dismiss];
//    [[self navController] setViewControllers:@[[[[ApplicationManager sharedInstance] mainMenuViewController] createViewController]] animated:NO];
}

- (void)toPositionsScreen {
//    [self.pickerView dismiss];
//    UIViewController *mainMenuVC = [[[ApplicationManager sharedInstance] mainMenuViewController] createViewController];
//    if ([mainMenuVC isKindOfClass:[CategoriesAndPositionsTVController class]]) {
//        [[self navController] setViewControllers:@[[DBSettingsTableViewController new]] animated:NO];
//    } else if ([mainMenuVC isKindOfClass:[CategoriesTVController class]]) {
//        if ([[[CategoriesTVController preference] objectForKey:@"is_mixed_type"] boolValue]) {
//            DBMenu *menu = [DBMenu sharedInstance];
//            NSArray *categories = [menu getMenu];
//            while (true) {
//                for (DBMenuCategory *category in categories) {
//                    if (category.type == DBMenuCategoryTypeStandart) {
//                        CategoriesAndPositionsTVController *categoriesAndPositionsVC = [CategoriesAndPositionsTVController new];
//                        categoriesAndPositionsVC.categories = category.categories;
//                        [CategoriesAndPositionsTVController setPreferences:[CategoriesTVController preference]];
//                        [[self navController] setViewControllers:@[categoriesAndPositionsVC] animated:NO];
//                        break;
//                    }
//                }
//                categories = [categories firstObject];
//            }
//        } else {
//            DBMenu *menu = [DBMenu sharedInstance];
//            NSArray *categories = [menu getMenu];
//            while (true) {
//                for (DBMenuCategory *category in categories) {
//                    if (category.type == DBMenuCategoryTypeStandart) {
//                        PositionsTVController *positionsVC = [PositionsTVController new];
//                        positionsVC.category = category;
//                        [[self navController] setViewControllers:@[positionsVC] animated:NO];
//                        break;
//                    }
//                }
//                categories = [categories firstObject];
//            }
//        }
//    }
}

- (void)toPositionOrNeworderScreen {
    [self.pickerView dismiss];
    DBMenu *menu = [DBMenu sharedInstance];
    NSArray *categories = [menu getMenu];
    
    for (DBMenuCategory *category in categories) {
        NSArray *positions = [category positions];
        for (DBMenuPosition *position in positions) {
            if ([position hasImage]) {
                Class<PositionViewControllerProtocol> positionVCClass = [ViewControllerManager positionViewController];
                UIViewController *positionVC = [positionVCClass initWithPosition:position mode:PositionViewControllerModeMenuPosition];
                [[self navController] setViewControllers:@[positionVC] animated:NO];
                return;
            }
        }
    }
    
    // there are no positions with image
    [[DBClientInfo sharedInstance] setName:@"Иван"];
    [[DBClientInfo sharedInstance] setPhone:@"79152975079"];
    
    if ([[DBCompanyInfo sharedInstance] isDeliveryTypeEnabled:DeliveryTypeIdShipping]) {
        [[OrderCoordinator sharedInstance].shippingManager setStreet:@"Ленина"];
        [[OrderCoordinator sharedInstance].shippingManager setHome:@"15"];
        [[OrderCoordinator sharedInstance].shippingManager setApartment:@"3"];
    }
    
    [OrderCoordinator sharedInstance].orderManager.ndaAccepted = YES;
    
    DBNewOrderVC *newOrderVC = [DBNewOrderVC new];
    self.pickerView = [[DBTimePickerView alloc] initWithDelegate:nil];
    
    switch ([OrderCoordinator sharedInstance].deliverySettings.deliveryType.timeMode) {
        case TimeModeTime:{
            self.pickerView.type = DBTimePickerTypeTime;
            self.pickerView.selectedDate = [OrderCoordinator sharedInstance].deliverySettings.selectedTime;
        }
            break;
        case TimeModeDateTime:{
            self.pickerView.type = DBTimePickerTypeDateTime;
            self.pickerView.selectedDate = [OrderCoordinator sharedInstance].deliverySettings.selectedTime;
        }
            break;
        case TimeModeSlots:{
            self.pickerView.type = DBTimePickerTypeItems;
            self.pickerView.items = [OrderCoordinator sharedInstance].deliverySettings.deliveryType.timeSlotsNames;
            self.pickerView.selectedItem = [[OrderCoordinator sharedInstance].deliverySettings.deliveryType.timeSlots indexOfObject:[OrderCoordinator sharedInstance].deliverySettings.selectedTimeSlot];
        }
            break;
        case TimeModeDateSlots:{
            self.pickerView.type = DBTimePickerTypeDateAndItems;
            self.pickerView.items = [OrderCoordinator sharedInstance].deliverySettings.deliveryType.timeSlotsNames;
            self.pickerView.minDate = [OrderCoordinator sharedInstance].deliverySettings.deliveryType.minDate;
            self.pickerView.maxDate = [OrderCoordinator sharedInstance].deliverySettings.deliveryType.maxDate;
        }
            
        default:
            break;
    }
    
    [self.pickerView configure];
    [[self navController] setViewControllers:@[newOrderVC] animated:NO];
    [self.pickerView showOnView:[self navController].view];
}

- (void)toOrderScreen {
    [self.pickerView dismiss];
    [[DBClientInfo sharedInstance] setName:@"Иван"];
    [[DBClientInfo sharedInstance] setPhone:@"79152975079"];
    
    if ([[DBCompanyInfo sharedInstance] isDeliveryTypeEnabled:DeliveryTypeIdShipping]) {
        [[OrderCoordinator sharedInstance].shippingManager setStreet:@"Ленина"];
        [[OrderCoordinator sharedInstance].shippingManager setHome:@"15"];
        [[OrderCoordinator sharedInstance].shippingManager setApartment:@"3"];
    }
    
    [OrderCoordinator sharedInstance].orderManager.ndaAccepted = YES;
    
    DBMenu *menu = [DBMenu sharedInstance];
    NSArray *categories = [menu getMenu];
    
    int numberOfAdded = 0;
    for (DBMenuCategory *category in categories) {
        if (numberOfAdded == 3) break;
        if (category.type == DBMenuCategoryTypeStandart) {
            NSArray *positions = [category positions];
            for (DBMenuPosition *position in positions) {
                [[OrderCoordinator sharedInstance].itemsManager addPosition:position];
                if (++numberOfAdded == 3) break;
            }
        }
    }
    
    DBNewOrderVC *newOrderVC = [DBNewOrderVC new];
    [[self navController] setViewControllers:@[newOrderVC] animated:NO];
}

@end