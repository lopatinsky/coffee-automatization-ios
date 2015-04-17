//
//  DBPopupTextView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 13.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBPopupTextView;
@protocol DBPopupTextViewDelegate <NSObject>
- (void)db_popupTextViewDidSelectDone:(DBPopupTextView *)view text:(NSString *)text;
@optional
- (void)db_popupTextViewDidSelectCancel:(DBPopupTextView *)view;
@end

@interface DBPopupTextView : UIView
@property (weak, nonatomic) id<DBPopupTextViewDelegate> delegate;

- (void)configureWithTitle:(NSString *)title;
- (void)presentOnView:(UIView *)view;
- (void)dismiss;
@end
