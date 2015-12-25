//
//  DBUnifiedMenuTableViewController.h
//  DoubleB
//
//  Created by Balaban Alexander on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    UnifiedMenu,
    UnifiedVenue,
    UnifiedPosition,
} UnifiedTableViewType;

@interface DBUnifiedMenuTableViewController : UIViewController

@property (nonatomic) UnifiedTableViewType type;
@property (nonatomic, strong) NSMutableDictionary *data;

@end
