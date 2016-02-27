//
//  DBPersonalWalletView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.06.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBBaseSettingsTableViewController.h"
#import "DBPopupViewController.h"

@class DBPersonalWalletView;
@protocol DBPersonalWalletViewDelegate <NSObject>
- (void)db_personalWalletView:(DBPersonalWalletView *)view didUpdateBalance:(double)balance;
@end

@interface DBPersonalWalletView : UIView<DBSettingsProtocol, DBPopupViewControllerContent>
@property(weak, nonatomic) id<DBPersonalWalletViewDelegate> delegate;

+ (DBPersonalWalletView *)create;
@end
