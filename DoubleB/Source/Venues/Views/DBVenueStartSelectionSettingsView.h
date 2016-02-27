//
//  DBVenueStartSelectionSettingsView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 27/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBPopupViewController.h"

@interface DBVenueStartSelectionSettingsView : UIView<DBPopupViewControllerContent>
@property (strong, nonatomic) NSString *title;
+ (DBVenueStartSelectionSettingsView *)create;

@end
