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

#define ORDER_SCREEN @"Order_screen"
#define VENUES_SCREEN @"Venues_screen"
#define VENUE_INFO_SCREEN @"Venue_info_screen"
#define HISTORY_SCREEN @"History_screen"
#define ORDER_HISTORY_SCREEN @"Order_history_screen"
#define PAYMENT_SCREEN @"Payment_screen"
#define CARDS_SCREEN @"Cards_screen"
#define SETTINGS_SCREEN @"Settings_screen"
#define PROFILE_SCREEN @"Profile_screen"
#define CONFIDENCE_SCREEN @"Confidence_screen"
#define MENU_SCREEN @"Menu_screen"
#define PRODUCT_SCREEN @"Product_screen"
#define GROUP_MODIFIER_PICKER @"Group_modifier_popup"

/********************/

extern NSString *const kDBDefaultsName;
extern NSString *const kDBDefaultsPhone;
extern NSString *const kDBDefaultsMail;

extern NSString *const kDBDefaultsLastSelectedVenue;

extern NSString *const kDBDefaultsNDASigned;

extern NSString *const kDBDefaultsSharingInfo;

extern NSString *const kDBDefaultsLastScheduledLocalNotification;

extern NSString *const kDBStatusUpdatedNotification;
extern NSString *const kDBNotificationUpdatedOrder;
extern NSString *const kDBRepeateOrderNotification;
extern NSString *const kDBNewOrderAnimateAllErrorElementsNotification;

extern NSString *const kDBBindingNecessaryForAuthorization;

