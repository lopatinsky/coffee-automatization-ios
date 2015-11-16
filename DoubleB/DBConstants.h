//
//  DBConstants.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 18.09.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define BASE_URL @"http://empatika-coffeehostel.appspot.com/api/"

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

/* Google analytics */

#define APPLICATION_START @"Start_application"

#define LAUNCH_PLACEHOLDER_SCREEN @"Launch_placeholder_screen"

#define ORDER_SCREEN @"Order_screen"
#define ADDRESS_SCREEN @"Address_screen"
#define VENUES_SCREEN @"Venues_screen"
#define VENUES_ORDER_SCREEN @"Venues_order_screen"
#define VENUE_INFO_SCREEN @"Venue_info_screen"
#define HISTORY_SCREEN @"History_screen"
#define ORDER_HISTORY_SCREEN @"Order_history_screen"
#define PAYMENT_SCREEN @"Payment_screen"
#define CARDS_SCREEN @"Cards_screen"
#define SETTINGS_SCREEN @"Settings_screen"
#define PROMOS_LIST_SCREEN @"Promos_list_screen"
#define PROFILE_ORDER_SCREEN @"Profile_order_screen"
#define PROFILE_SCREEN @"Profile_screen"
#define CONFIDENCE_SCREEN @"Confidence_screen"
#define CATEGORIES_SCREEN @"Categories_screen"
#define POSITIONS_SCREEN @"Positions_screen"
#define MENU_SCREEN @"Menu_screen"
#define PRODUCT_SCREEN @"Product_screen"
#define SHARE_PERMISSION_SCREEN @"Share_permission_screen"

#define GROUP_MODIFIER_PICKER @"Group_modifier_popup"
#define SINGLE_MODIFIER_PICKER @"Single_modifier_popup"

#define DOCS_SCREEN @"Documents_screen"
#define NDA_SCREEN @"NDA_Screen"
#define LICENCE_AGREEMENT_SCREEN @"Licence_agreement_screen"
#define PAYMENT_RULES_SCREEN @"Payment_rules_screen"
#define ABOUT_APP_SCREEN @"About_application_screen"

/********************/

extern NSString *const kDBDefaultsNDASigned;

extern NSString *const kDBDefaultsSharingInfo;

extern NSString *const kDBDefaultsPromoInfo;
extern NSString *const kDBDefaultsCompanyInfo;

extern NSString *const kDBDefaultsLastScheduledLocalNotification;

extern NSString *const kDBStatusUpdatedNotification;
extern NSString *const kDBNotificationUpdatedOrder;
extern NSString *const kDBNewOrderCreatedNotification;
extern NSString *const kDBNewOrderAnimateAllErrorElementsNotification;

extern NSString *const kDBBindingNecessaryForAuthorization;


typedef NS_ENUM(NSInteger, DBUICurrencyDisplayMode){
    DBUICurrencyDisplayModeRub = 0,
    DBUICurrencyDisplayModeNone
};

typedef NS_ENUM(NSInteger, DBProcessState) {
    DBProcessStateDone = 0,
    DBProcessStateFailed,
    DBProcessStateCancelled
};

