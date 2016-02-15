//
//  DBUnifiedMenuTableViewController.h
//  DoubleB
//
//  Created by Balaban Alexander on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Gradient.h"
#import "DBSettingsItem.h"

typedef enum : NSUInteger {
    UnifiedMenu,
    UnifiedVenue,
    UnifiedPosition,
} UnifiedTableViewType;

@interface DBUnifiedMenuTableViewController : UIViewController <DBSettingsProtocol>

@property (nonatomic) UnifiedTableViewType type;
@property (nonatomic) NSDictionary *product;

@end
