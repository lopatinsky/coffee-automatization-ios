//
//  DBPhoneConfirmationView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 14/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBPopupViewController.h"

typedef NS_ENUM(NSInteger, DBPhoneConfirmationViewMode) {
    DBPhoneConfirmationViewModePhone = 0,
    DBPhoneConfirmationViewModeCode
};

@class DBPhoneConfirmationView;
@protocol DBPhoneConfirmationViewDelegate <NSObject>
- (void)db_phoneConfirmationViewConfirmedPhone:(DBPhoneConfirmationView *)view;
@end

@interface DBPhoneConfirmationView : UIView <DBPopupViewControllerContent>
@property (nonatomic) DBPhoneConfirmationViewMode mode;
@property (weak, nonatomic) id<DBPhoneConfirmationViewDelegate> delegate;

+ (DBPhoneConfirmationView *)create;
- (void)reload;
@end
